/******************************
** File: Buildscript_1.00.014.sql
** Name: Buildscript_1.00.014
** Auth: McNiel Viray
** Date: 11 May 2017
**************************
** Change History
**************************
** Create Week table
** Create sp on creating for creating week
*******************************/
USE WFMPCP
GO
CREATE TABLE [dbo].[Week](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [smallint] NULL,
	[Month] [varchar](15) NULL,
	[WeekOfYear] [smallint] NULL,
	[WeekNo] [varchar](15) NULL,
	[WeekNoDate] [varchar](12) NULL,
	[WeekStartdate] [smalldatetime] NULL,
	[WeekEnddate] [smalldatetime] NULL,
	[FirstDayOfWeek] [varchar](10) NULL,
 CONSTRAINT [PK_week] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
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
GO

EXEC AddWeek 2017,'Monday'
GO
EXEC AddWeek 2018,'Monday'
GO
EXEC AddWeek 2019,'Monday'
GO
EXEC AddWeek 2020,'Monday'
GO
EXEC AddWeek 2021,'Monday'
GO
EXEC AddWeek 2022,'Monday'
GO
EXEC AddWeek 2023,'Monday'
GO
EXEC AddWeek 2024,'Monday'
GO
CREATE PROCEDURE [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
	@lobid AS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
						FROM WeeklyAHDatapoint
						WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
						GROUP BY [Date]
						ORDER BY [Date]
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')
		
	SET @query = '
			SELECT d.Name [Datapoint Name],' + @cols + '
			FROM (
				SELECT *
				FROM
				(
					SELECT LobID,datapointid,[Date],Data from WeeklyAHDatapoint 
				) x		
				PIVOT
				(
					MAX(Data)
					FOR [Date] IN ('+ @cols +')
				)p
			) A
			INNER JOIN Datapoint d ON d.ID=A.DatapointID
			INNER JOIN Segment s ON s.ID=d.SegmentID
			INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
			WHERE a.LoBID='+ @lobid +'
			ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder
	'

	EXECUTE(@query);
END
GO
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(11,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(11,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(11,1,3,'McNiel Viray')
GO