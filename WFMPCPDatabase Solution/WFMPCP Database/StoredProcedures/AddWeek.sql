CREATE PROCEDURE [dbo].[AddWeek]
@Year SMALLINT = 2017,
@StartDay VARCHAR(10)='Monday'
AS
BEGIN

	declare @DateFrom Date 
	declare @DateTo Date

	set @DateFrom = CAST(@Year AS VARCHAR(4)) + '-01-01'
	set @DateTo = CAST(@Year AS VARCHAR(4)) + '-12-31'

	INSERT INTO [Week]([Year],[Month],WeekOfYear,WeekNo,WeekNoDate,WeekStartDate,WeekEndDate,FirstDayOfWeek)
	SELECT 
		 @Year
		,CASE WHEN DATEPART(MM,AllDates) = 1 THEN 'JANUARY'
					 WHEN DATEPART(MM,AllDates) =  2 THEN 'FEBRUARY'
					 WHEN DATEPART(MM,AllDates) =  3 THEN 'MARCH'
					 WHEN DATEPART(MM,AllDates) =  4 THEN 'APRIL'
					 WHEN DATEPART(MM,AllDates) =  5 THEN 'MAY'
					 WHEN DATEPART(MM,AllDates) =  6 THEN 'JUNE'
					 WHEN DATEPART(MM,AllDates) =  7 THEN 'JULY'
					 WHEN DATEPART(MM,AllDates) =  8 THEN 'AUGUST'
					 WHEN DATEPART(MM,AllDates) =  9 THEN 'SEPTEMBER'
					 WHEN DATEPART(MM,AllDates) =  10 THEN 'OCTOBER'
					 WHEN DATEPART(MM,AllDates) =  11 THEN 'NOVEMBER'
					 WHEN DATEPART(MM,AllDates) =  12 THEN 'DECEMBER' 
				 END
		 ,DATEPART( wk, AllDates)
		 ,'Week ' + CAST(DATEPART( wk, AllDates) AS VARCHAR(5))
		 ,AllDates
		 ,CAST(AllDates AS smalldatetime)
		 ,DATEADD(DAY,6,CAST(AllDates AS smalldatetime))
		 ,@StartDay
		--,AllDates as WeekNoDate 
	FROM 
	(Select DATEADD(d, number, @dateFrom) as AllDates from master..spt_values 
	   where type = 'p' and number between 0 and datediff(dd, @dateFrom,   @dateTo)) AS D1    
	WHERE DATENAME(dw, D1.AllDates)In(@StartDay)
	--SELECT 
	--	[Year] = @Year
	--	,[Month]=CASE WHEN DATEPART(MM,AllDates) = 1 THEN 'JANUARY'
	--				 WHEN DATEPART(MM,AllDates) =  2 THEN 'FEBRUARY'
	--				 WHEN DATEPART(MM,AllDates) =  3 THEN 'MARCH'
	--				 WHEN DATEPART(MM,AllDates) =  4 THEN 'APRIL'
	--				 WHEN DATEPART(MM,AllDates) =  5 THEN 'MAY'
	--				 WHEN DATEPART(MM,AllDates) =  6 THEN 'JUNE'
	--				 WHEN DATEPART(MM,AllDates) =  7 THEN 'JULY'
	--				 WHEN DATEPART(MM,AllDates) =  8 THEN 'AUGUST'
	--				 WHEN DATEPART(MM,AllDates) =  9 THEN 'SEPTEMBER'
	--				 WHEN DATEPART(MM,AllDates) =  10 THEN 'OCTOBER'
	--				 WHEN DATEPART(MM,AllDates) =  11 THEN 'NOVEMBER'
	--				 WHEN DATEPART(MM,AllDates) =  12 THEN 'DECEMBER' 
	--			 END
	--	 ,WeekOfYear=DATEPART( wk, AllDates)
	--	 ,WeekNo='Week ' + CAST(DATEPART( wk, AllDates) AS VARCHAR(5))
	--	 ,WeekNoDate='W' + CAST(DATEPART( wk, AllDates) AS VARCHAR(5)) + ' ' + CAST(AllDates AS VARCHAR(10))
	--	 ,WeekStartDate=CAST(AllDates AS smalldatetime)
	--	 ,WeekEndDate=DATEADD(DAY,6,CAST(AllDates AS smalldatetime))
	--	 ,FirstDayOfWeek=@StartDay
	--	--,AllDates as WeekNoDate 
	--FROM 
	--(Select DATEADD(d, number, @dateFrom) as AllDates from master..spt_values 
	--   where type = 'p' and number between 0 and datediff(dd, @dateFrom,   @dateTo)) AS D1    
	--WHERE DATENAME(dw, D1.AllDates)In(@StartDay)
END