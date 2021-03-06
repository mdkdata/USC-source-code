USE [TCC]
GO
/****** Object:  UserDefinedFunction [results].[day_delta]    Script Date: 3/7/2016 11:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [results].[day_delta](@lhs dateTime, @rhs dateTime) returns integer 
as 
BEGIN
  RETURN abs(dateDiff( day, @lhs, @rhs) );
END;

GO
/****** Object:  UserDefinedFunction [results].[month_delta]    Script Date: 3/7/2016 11:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [results].[month_delta](@lhs dateTime, @rhs dateTime) returns float 
as
BEGIN
RETURN CASE
   WHEN (@rhs >= @lhs) THEN 
     CASE
        WHEN (datePart(day, @rhs) >= datePart(day, @lhs))
          THEN ((datePart(year, @rhs) - datePart(year, @lhs)) * 12 + datePart(month, @rhs)) - datePart(month, @lhs)
        WHEN (datePart(day, @rhs) < datePart(day, @lhs))
          THEN (((datePart(year, @rhs) - datePart(year, @lhs)) * 12 + datePart(month, @rhs)) - datePart(month, @lhs)) - 1
     END
   WHEN (@rhs < @lhs) THEN
       CASE
          WHEN (datePart(day, @rhs) >= datePart(day, @rhs))
            THEN ((datePart(year, @rhs) - datePart(year, @rhs)) * 12 + datePart(month, @rhs)) - datePart(month, @rhs) 
          WHEN (datePart(day, @rhs) < datePart(day, @rhs))
            THEN (((datePart(year, @rhs) - datePart(year, @rhs)) * 12 + datePart(month, @rhs)) - datePart(month, @rhs)) - 1
       END
    ELSE NULL
END;
END;

GO
/****** Object:  UserDefinedFunction [results].[week_delta]    Script Date: 3/7/2016 11:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [results].[week_delta](@lhs dateTime, @rhs dateTime) returns float
 as
 BEGIN
   RETURN floor(abs(dateDiff( day, @lhs, @rhs) ) / 7);
 END;

GO
/****** Object:  UserDefinedFunction [results].[year_delta]    Script Date: 3/7/2016 11:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [results].[year_delta](@lhs dateTime, @rhs dateTime) returns float 
AS
BEGIN
RETURN
 CASE
   WHEN (@rhs >= @lhs) THEN
       CASE
          WHEN (datePart(month, @rhs) < datePart(month, @lhs)) 
            THEN (datePart(year, @rhs) - datePart(year, @lhs)) - 1
          WHEN (datePart(month, @rhs) = datePart(month, @lhs) AND datePart(day, @rhs) >= datePart(day, @lhs)) 
            THEN datePart(year, @rhs) - datePart(year, @lhs)
          WHEN (datePart(month, @rhs) = datePart(month, @lhs) AND datePart(day, @rhs) < datePart(day, @lhs))
            THEN (datePart(year, @rhs) - datePart(year, @lhs)) - 1 
          WHEN (datePart(month, @rhs) > datePart(month, @lhs)) 
            THEN datePart(year, @rhs) - datePart(year, @lhs)
       END 
   WHEN (@rhs < @lhs) THEN 
       CASE
          WHEN (datePart(month, @lhs) < datePart(month, @rhs)) 
            THEN (datePart(year, @lhs) - datePart(year, @rhs)) - 1
          WHEN (datePart(month, @lhs) = datePart(month, @rhs) AND datePart(day, @lhs) >= datePart(day, @rhs))
            THEN datePart(year, @lhs) - datePart(year, @rhs)
          WHEN (datePart(month, @lhs) = datePart(month, @rhs) AND datePart(day, @lhs) < datePart(day, @rhs))
            THEN (datePart(year, @lhs) - datePart(year, @rhs)) - 1
          WHEN (datePart(month, @lhs) > datePart(month, @rhs))
            THEN datePart(year, @lhs) - datePart(year, @rhs) 
       END
   ELSE NULL
 END;
 END;

GO
