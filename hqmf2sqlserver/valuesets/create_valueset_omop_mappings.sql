:r "C:\Ephir\hqmf2sql\valuesets\defaults.sql"
---set search_path = :valueset_schema, :vocab_schema;

EXEC ('create table '+@valueset_schema+'.hqmf_code_lists (
  code integer,
  code_list_id varchar(5000)
);');

--create index hqmf_code_lists_code_list_id_idx on hqmf_code_lists(code_list_id);
--cluster hqmf_code_lists using hqmf_code_lists_code_idx;
EXEC ('create index hqmf_code_lists_code_idx on '+@valueset_schema+'.hqmf_code_lists(code);');
EXEC ('create clustered index hqmf_code_lists_code_list_id_idx on '+@valueset_schema+'.hqmf_code_lists(code_list_id);');

--comment on table hqmf_code_lists is 'Derived table - associates OMOP concepts (for individual codes) to HQMF vocabulary IDs';
execute sp_addextendedproperty 'MS_Description', 
   'Derived table - associates OMOP concepts (for individual codes) to HQMF vocabulary IDs',
   'schema', @valueset_schema, 'table', 'hqmf_code_lists';
--comment on column hqmf_code_lists.code is 'Concept ID associated with a particular code.';
execute sp_addextendedproperty 'MS_Description', 
   'Concept ID associated with a particular code.',
   'schema', @valueset_schema, 'table', 'hqmf_code_lists', 'column', 'code';
--comment on column hqmf_code_lists.code_list_id is 'HQMF vocabulary OID.';
execute sp_addextendedproperty 'MS_Description', 
   'HQMF vocabulary OID.',
   'schema', @valueset_schema, 'table', 'hqmf_code_lists', 'column', 'code_list_id';

EXEC('insert into '+@valueset_schema+'.hqmf_code_lists (code, code_list_id)
  select distinct
    r.concept_id_1,
    c.concept_code
from '+@vocab_schema+'.concept_relationship r join '+@vocab_schema+'.concept c
   on c.concept_id = r.concept_id_2
where r.invalid_reason is null and
   r.valid_start_date <= getdate() and r.valid_end_date >= getdate() and
   r.relationship_id in ('+@value_set_member_relationship_id+','+ @value_set_member_relationship_id_mapped+');');

--cluster hqmf_code_lists;
--analyze hqmf_code_lists;

EXEC('create table '+@valueset_schema+'.omop_level_2_concept_code_lists (
   code integer,
   code_list_id varchar(5000)
);');

EXEC('create view '+@valueset_schema+'.code_lists as
  select code, code_list_id from hqmf_code_lists
union
  select code, code_list_id from '+@valueset_schema+'.omop_level_2_concept_code_lists;');

EXEC('create table '+@valueset_schema+'.med_status_map (
   omop_concept_id integer,
   hqmf_status varchar(5000)
);');

--truncate table med_status_map;

EXEC('insert into '+@valueset_schema+'.med_status_map (omop_concept_id, hqmf_status) values
  (38000177, ''ordered''),
  (38000178, ''active''),
  (38000175, ''dispensed''),
  (38000176, ''dispensed''),
  (38000179, ''administered''),
  (38000180, ''administered'')
;');

--create or replace function ydm_to_date(numeric(4,0), numeric(2,0), numeric(2,0)) returns date as $$
--DECLARE
--   i_year alias for $1;
--   i_month alias for $2;
--   i_day alias for $3;
--BEGIN
--   if ((i_year is null) or (i_month is null) or (i_day is null)) then
--      return null;
--   end if;
--   return cast (
--      (cast (i_year as char(4)) || '-' ||
--       cast (i_month as char(2)) || '-' ||
--       cast (i_day as char(2))) as date);
--END
--$$
--LANGUAGE 'plpgsql' immutable;


-- verify that all codes in value set definitions are mapped into concepts in code lists
EXEC('select * into '+@valueset_schema+'.value_code_xref from (
    select distinct v.code, v.code_system, v.code_system_name, v.display_name, c.concept_id, c.concept_name
      from '+@valueset_schema+'.value_set_entries v
      join '+@valueset_schema+'.unified_vocabulary_map m on m.hqmf_code_system_oid = v.code_system
      join '+@vocab_schema+'.concept c on c.concept_code = v.code and c.vocabulary_id = m.omop_vocabulary_id and c.vocabulary_id != 0
    union 
    select distinct v.code, v.code_system, v.code_system_name, v.display_name, s.target_concept_id concept_id, c.concept_name
      from '+@valueset_schema+'.value_set_entries v
      join '+@valueset_schema+'.unified_vocabulary_map m on m.hqmf_code_system_oid = v.code_system
      join '+@vocab_schema+'.source_to_concept_map s on s.source_code = v.code and s.source_vocabulary_id = m.omop_vocabulary_id
      join '+@vocab_schema+'.concept c on c.concept_id = s.target_concept_id and c.vocabulary_id != 0) a;');

EXEC('create clustered index value_code_xref_code_system_code_idx on '+@valueset_schema+'.value_code_xref (code_system, code);');
--cluster value_code_xref using value_code_xref_code_system_code_idx;
--analyze value_code_xref;

EXEC('create table '+@valueset_schema+'.value_set_sanity_checks (
    test_name varchar(5000),
    passed bit
);');

EXEC('
insert into '+@valueset_schema+'.value_set_sanity_checks(test_name, passed)
    select ''all concepts mapped from all value sets are in the code list for that value set'',
       --not exists (
          case (select sign(sum(1)) from '+@valueset_schema+'.value_set_entries v
            where not exists (
              select 1 from '+@valueset_schema+'.value_code_xref x 
                join '+@valueset_schema+'.code_lists c on c.code = x.concept_id
                where x.code_system = v.code_system and x.code = v.code))
			when 1 then 0
			else 1
			end	
				;');

EXEC('select * into '+@valueset_schema+'.value_set_code_xref from (
   select v.value_set_name,
          e.value_set_oid,
          e.code_system,
          e.code,
          e.code_system_name,
          e.display_name,
          x.concept_id,
          x.concept_name
   from '+@valueset_schema+'.value_sets v join '+@valueset_schema+'.value_set_entries e on e.value_set_oid = v.value_set_oid
      left join '+@valueset_schema+'.value_code_xref x on x.code = e.code and x.code_system = e.code_system)a;');

EXEC('select * into '+@valueset_schema+'.value_set_code_systems from (
   select value_set_oid, code_system, min(code_system_name) code_system_name from '+@valueset_schema+'.value_set_entries group by value_set_oid, code_system)a;');
EXEC('alter table '+@valueset_schema+'.value_set_code_systems add constraint value_set_code_systems_pkey primary key clustered (value_set_oid, code_system);');
--cluster value_set_code_systems using value_set_code_systems_pkey;

EXEC('select * into '+@valueset_schema+'.code_lists_value_set_reverse_map from (
   select
     v.value_set_oid,
     v.value_set_name,
     s.code_system,
     s.code_system_name,
     c.concept_id,
     c.concept_code,
     c.concept_name,
     c.vocabulary_id,
     vo.vocabulary_name,
     case (select sign(sum(1)) from '+@valueset_schema+'.value_set_entries e where e.value_set_oid = v.value_set_oid
               and e.code_system = s.code_system and e.code = c.concept_code)
     when 1 then 0
	 else 1
	 end in_original_value_set
   from '+@valueset_schema+'.code_lists l
     join '+@valueset_schema+'.value_sets v on v.value_set_oid = l.code_list_id
     join '+@valueset_schema+'.value_set_code_systems s on s.value_set_oid = v.value_set_oid
     join '+@valueset_schema+'.unified_vocabulary_map m on m.hqmf_code_system_oid = s.code_system
     join '+@vocab_schema+'.concept c on c.vocabulary_id = m.omop_vocabulary_id and c.concept_id = l.code
     join '+@vocab_schema+'.vocabulary vo on vo.vocabulary_id = c.vocabulary_id
   union 
   select
     v.value_set_oid,
     v.value_set_name,
     s.code_system,
     s.code_system_name,
     scm.target_concept_id,
     scm.source_code,
     scm.source_code_description,
     scm.source_vocabulary_id,
     vo.vocabulary_name,
     case (select sign(sum(1)) from '+@valueset_schema+'.value_set_entries e where e.value_set_oid = v.value_set_oid
               and e.code_system = s.code_system and e.code = scm.source_code) 
     when 1 then 0
	 else 1
	 end  in_original_value_set
   from '+@valueset_schema+'.code_lists l
     join '+@valueset_schema+'.value_sets v on v.value_set_oid = l.code_list_id
     join '+@valueset_schema+'.value_set_code_systems s on s.value_set_oid = v.value_set_oid
     join '+@valueset_schema+'.unified_vocabulary_map m on m.hqmf_code_system_oid = s.code_system
     join '+@vocab_schema+'.source_to_concept_map scm on scm.source_vocabulary_id = m.omop_vocabulary_id and scm.target_concept_id = l.code
           and primary_map = ''Y'' and invalid_reason is null
     join '+@vocab_schema+'.concept c on c.concept_id = scm.target_concept_id
     join '+@vocab_schema+'.vocabulary vo on vo.vocabulary_id = scm.source_vocabulary_id)a;');

EXEC('create clustered index code_lists_value_set_reverse_map_code_system_value_set_oid_idx on '+@valueset_schema+'.code_lists_value_set_reverse_map(code_system, value_set_oid);');
--cluster code_lists_value_set_reverse_map using code_lists_value_set_reverse_map_code_system_value_set_oid_idx;
EXEC('create index orig_value_set_idx on '+@valueset_schema+'.code_lists_value_set_reverse_map(in_original_value_set);');
