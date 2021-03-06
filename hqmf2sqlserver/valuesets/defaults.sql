DECLARE @valueset_schema varchar(60) = 'valuesets';
DECLARE @vocab_schema varchar(60) = 'vocabulary_plus';
DECLARE @base_vocab_schema varchar(60) = 'vocabulary';
DECLARE @hqmf_value_set_vocabulary_name varchar(60) = '''hqmf value sets''';
DECLARE @hqmf_value_set_vocabulary_id int = 40000;
DECLARE @hqmf_value_set_concept_class varchar(60) = '''value set''';
DECLARE @hqmf_value_set_concept_level int = 2;
DECLARE @hqmf_value_set_default_start_date varchar(60) = '''1970-01-01''';
DECLARE @hqmf_relationship_default_start_date varchar(60) = '''1970-01-01''';
DECLARE @lab_observation_numeric_concept_id int = 38000277;
DECLARE @lab_observation_text_concept_id int = 38000278;
DECLARE @lab_observation_concept_code_concept_id int = 38000279;
DECLARE @lab_observation_recorded_from_ehr_concept_id int = 38000280;
DECLARE @lab_observation_recorded_from_ehr_with_text_concept_id int = 38000281;
DECLARE @icd9_overflow_vocabulary_name_1 varchar(60) = '''hqmf_overflow_ICD-9-CM__5''';
DECLARE @icd9_overflow_vocabulary_name_2 varchar(60) = '''hqmf_overflow_ICD-9-CM__6''';
DECLARE @hqmf_concept_id_start_value int = 1002000000;
DECLARE @allergy_observation_type_concept_id int = 1003000000;
DECLARE @icd9_cm_vocabulary_id int = 2;
DECLARE @icd9_proc_vocabulary_id int = 3;
DECLARE @icd9_overflow_vocabulary_1 int = 40101;
DECLARE @icd9_overflow_vocabulary_2 int = 40110;
DECLARE @snomed_vocabulary_id int = 1;
DECLARE @relationship_subsumes int = 10;
DECLARE @relationship_medra_to_snomed int = 125;
DECLARE @relationship_indication_to_snomed int = 247;
DECLARE @lab_observation_unmapped_text_name varchar(60) = '''Unmapped text result''';
DECLARE @hqmf_miscellaneous_vocabulary_id int = 40113;
DECLARE @hqmf_miscellaneous_vocabulary_name varchar(60) = '''HQMF miscellaneous concepts''';
DECLARE @value_set_member_relationship_id int = 1000;
DECLARE @value_set_member_relationship_name varchar(60) = '''in value set (HQMF)''';
DECLARE @value_set_member_relationship_id_mapped int = 1001;
DECLARE @value_set_member_relationship_name_mapped varchar(60) = '''mapped value in value set (HQMF)''';
DECLARE @hqmf_overflow_concept_level int = 1;
DECLARE @hqmf_overflow_concept_class varchar(60) = '''hqmf mapped overflow concept''';
DECLARE @loinc_vocabulary_id int = 6;
DECLARE @administrative_sex_vocabulary_id int = 12;
DECLARE @cvx_vocabulary_id int = 40127;
