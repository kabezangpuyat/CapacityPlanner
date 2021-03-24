/******************************
** File: Buildscript_1.00.051.sql
** Name: Buildscript_1.00.051
** Auth: McNiel Viray
** Date: 07 August 2017
**************************
** Change History
**************************
** Create Site Weekly Summary stored procedure
** Create Campaign weekly summary stored procedure
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[wfmpcp_GetCampaignWeeklyHiringPlan_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetCampaignWeeklyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')


	SET @select = '
		SELECT s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,[Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name
	'
	EXECUTE( @select )
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetSiteWeeklyHiringPlan_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetSiteWeeklyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')
--SELECT @cols
	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT SiteID
					,[Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
	'

	EXECUTE( @select )
END
GO
PRINT N'Update complete.';
UPDATE [Module] SET [Name]='Site - Monthly Summary' WHERE ID=20;
UPDATE [Module] SET [Name]='Campaign - Monthly Summary' WHERE ID=22;

GO

/******************************
** File: Buildscript_1.00.052.sql
** Name: Buildscript_1.00.052
** Auth: McNiel Viray
** Date: 08 August 2017
**************************
** Change History
**************************
** Add SiteID Param in stored procedure [dbo].[wfmpcp_GetCampaignWeeklyHiringPlan_sp]
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[wfmpcp_GetCampaignWeeklyHiringPlan_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetCampaignWeeklyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
	,@SiteID NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@where  AS NVARCHAR(MAX)=''
		,@startdate DATE
		,@enddate DATE
	
	IF(@SiteID != '' )
	BEGIN
		SET @where = ' AND SiteID=' + @SiteID + '  '
	END

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')
	

	SET @select = '
		SELECT s.ID CampaignID,s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,[Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 ' + @where + '
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name
	'

	

	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO

/******************************
** File: Buildscript_1.00.053.sql
** Name: Buildscript_1.00.053
** Auth: McNiel Viray
** Date: 08 August 2017
**************************
** Change History
**************************
** Create procedure [dbo].[wfmpcp_GetLoBWeeklyHiringPlan_sp]
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[wfmpcp_GetLoBWeeklyHiringPlan_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetLoBWeeklyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
	,@CampaignID NVARCHAR(20) = ''
AS
BEGIN
		DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@where  AS NVARCHAR(MAX)=''
		,@startdate DATE
		,@enddate DATE

	IF(@CampaignID != '' )
	BEGIN
		SET @where = ' AND CampaignID=' + @CampaignID + ' '
	END

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')


	SET @select = '
		SELECT A.CampaignID,s.Name [LoB],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT LoBID
				    ,CampaignID
					,[Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 ' + @where + '					
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [LoB] s ON s.ID=A.LoBID
		WHERE 1=1 
		ORDER BY s.Name
	'

	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO

/******************************
** File: Buildscript_1.00.054.sql
** Name: Buildscript_1.00.054
** Auth: McNiel Viray
** Date: 11 August 2017
**************************
** Change History
**************************
** Create scalar valued function to get First Monday and Last Monday of Month
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[udf_GetFirstMondayOfMonth]...';


GO
CREATE FUNCTION [dbo].[udf_GetFirstMondayOfMonth]
(
	@Now DATE
)
RETURNS DATETIME
AS
BEGIN	
	DECLARE @FirstDayOfMonth AS DATETIME
		,@Monday AS DATETIME
		,@ctr INT = 1
		,@Datename AS VARCHAR(20)


	SELECT @FirstDayOfMonth = DATEADD(m, DATEDIFF(m, 0, @Now), 0) 
	SELECT @Monday = @FirstDayOfMonth

	SELECT @Datename = UPPER( DATENAME(dw,@FirstDayOfMonth) )

	IF(@Datename = 'TUESDAY' OR @Datename = 'WEDNESDAY' OR @Datename = 'THURSDAY')
	BEGIN
		SET @ctr = -1;
	END

	WHILE(UPPER( DATENAME(dw,@Monday) ) != 'MONDAY')
	BEGIN
		SET @Monday = DATEADD(DAY,@ctr,@Monday)
	END

	RETURN @Monday
END
GO
PRINT N'Creating [dbo].[udf_GetLastMondayOfMonth]...';


GO
CREATE FUNCTION [dbo].[udf_GetLastMondayOfMonth]
(
	@Now DATE
)
RETURNS DATETIME
AS
BEGIN	
	DECLARE @LastDayOfMonth DATETIME
		,@Monday DATETIME
		,@DateDiff INT = 0 

	SELECT @LastDayOfMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Now)+1,0))
	SELECT @Monday = @LastDayOfMonth

	WHILE(UPPER( DATENAME(dw,@Monday) ) != 'MONDAY')
	BEGIN
		SET @Monday = DATEADD(DAY,-1,@Monday)
	END

	SET @DateDiff = DATEDIFF(DAY,@Monday,@LastDayOfMonth) + 1

	IF(@DateDiff < 4)
	BEGIN
		SET @Monday = DATEADD(DAY,-1,@Monday)
		WHILE(UPPER( DATENAME(dw,@Monday) ) != 'MONDAY')
		BEGIN
			SET @Monday = DATEADD(DAY,-1,@Monday)
		END
	END
	
	RETURN @Monday
END
GO
PRINT N'Update complete.';


GO

/******************************
** File: Buildscript_1.00.055.sql
** Name: Buildscript_1.00.055
** Auth: McNiel Viray
** Date: 15 August 2017
**************************
** Change History
**************************
** modify the following sp ([wfmpcp_GetCampaignMonthlyHiringPlan_sp],[wfmpcp_GetCampaignWeeklyHiringPlan_sp]
** [wfmpcp_GetLoBWeeklyHiringPlan_sp],[wfmpcp_GetSiteMonthlyHiringPlan_sp],[wfmpcp_GetSiteWeeklyHiringPlan_sp])
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[wfmpcp_GetCampaignMonthlyHiringPlan_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetCampaignMonthlyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE
		,@origstart DATE
		,@origend DATE
		,@origstartstring VARCHAR(25)
		,@origendstring VARCHAR(25)
		,@wfmstart VARCHAR(25)
		,@wfmend VARCHAR(25)

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @origstart = @startdate
	SET @origend = @enddate

	SET @origstartstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8))
	SET @origendstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	SET @wfmstart = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8)) 
	SET @wfmend = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @origstart AND @origend) 
	
	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
					 END [Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name
	'
	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetCampaignWeeklyHiringPlan_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetCampaignWeeklyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
	,@SiteID NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@where  AS NVARCHAR(MAX)=''
		,@startdate DATE
		,@enddate DATE
	
	IF(@SiteID != '' )
	BEGIN
		SET @where = ' AND SiteID=' + @SiteID + '  '
	END

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')
	

	SET @select = '
		SELECT s.ID CampaignID,s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,[Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 ' + @where + '
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name
	'

	

	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetLoBWeeklyHiringPlan_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetLoBWeeklyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
	,@CampaignID NVARCHAR(20) = ''
AS
BEGIN
		DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@where  AS NVARCHAR(MAX)=''
		,@startdate DATE
		,@enddate DATE

	IF(@CampaignID != '' )
	BEGIN
		SET @where = ' AND CampaignID=' + @CampaignID + ' '
	END

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')


	SET @select = '
		SELECT A.CampaignID,s.Name [LoB],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT LoBID
				    ,CampaignID
					,[Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 ' + @where + '					
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [LoB] s ON s.ID=A.LoBID
		WHERE 1=1 
		ORDER BY s.Name
	'

	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetSiteMonthlyHiringPlan_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetSiteMonthlyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE
		,@origstart DATE
		,@origend DATE
		,@origstartstring VARCHAR(25)
		,@origendstring VARCHAR(25)
		,@wfmstart VARCHAR(25)
		,@wfmend VARCHAR(25)

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @origstart = @startdate
	SET @origend = @enddate

	SET @origstartstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8))
	SET @origendstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	SET @wfmstart = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8)) 
	SET @wfmend = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @origstart AND @origend) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT SiteID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
					 END [Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
	'
	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetSiteWeeklyHiringPlan_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetSiteWeeklyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')
--SELECT @cols
	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT SiteID
					,[Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
	'

	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.056.sql
** Name: Buildscript_1.00.056
** Auth: McNiel Viray
** Date: 15 August 2017
**************************
** Change History
**************************
** Create Excess Deficit Modules
*******************************/
USE WFMPCP
GO


PRINT N'Create MOdule..'
UPDATE Module
SET SortOrder=7
WHERE ID=7
GO

DECLARE @ModuleID BIGINT
	,@ParentID BIGINT

INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(0,'Excess/Deficit','fa-tag','#',6,'McNiel Viray')

SELECT @ParentID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,5,1,'McNiel Viray',1)

--************************
--SUMMARY OVERALL
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Summary (Overall)','fa-tag','/ExcessDeficit/SummaryOverall',1,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)


--************************
--SITE WEEKLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Site - Weekly Summary','fa-tag','/ExcessDeficit/SiteWeeklySummary',2,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)


--************************
--SITE MONTHLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Site - Monhtly Summary','fa-tag','/ExcessDeficit/SiteMonthlySummary',3,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)


--************************
--CAMPAIGN WEEKLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Campaign - Weekly Summary','fa-tag','/ExcessDeficit/CampaignWeeklySummary',4,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)


--************************
--CAMPAIGN MONTHLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Campaign - Monhtly Summary','fa-tag','/ExcessDeficit/CampaignMonthlySummary',5,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)


--************************
--EXCESS DEFICIT VS CURRENT HEADCOUNT
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Excess/Deficit vs Current Headcount','fa-tag','/ExcessDeficit/ExcessDeficitVsCurrentHeadCount',6,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)
GO
/******************************
** File: Buildscript_1.00.057.sql
** Name: Buildscript_1.00.057
** Auth: McNiel Viray
** Date: 16 August 2017
**************************
** Change History
**************************
** Create stored procedures([wfmpcp_GetCampaignMonthlyExcessDeficit_sp],[wfmpcp_GetSiteMonthlyExcessDeficit_sp])
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[wfmpcp_GetCampaignMonthlyExcessDeficit_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetCampaignMonthlyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE
		,@origstart DATE
		,@origend DATE
		,@origstartstring VARCHAR(25)
		,@origendstring VARCHAR(25)
		,@wfmstart VARCHAR(25)
		,@wfmend VARCHAR(25)

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @origstart = @startdate
	SET @origend = @enddate

	SET @origstartstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8))
	SET @origendstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	SET @wfmstart = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8)) 
	SET @wfmend = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @origstart AND @origend) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
					 END [Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				AVG(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
	'
	EXECUTE( @select )
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetSiteMonthlyExcessDeficit_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetSiteMonthlyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE
		,@origstart DATE
		,@origend DATE
		,@origstartstring VARCHAR(25)
		,@origendstring VARCHAR(25)
		,@wfmstart VARCHAR(25)
		,@wfmend VARCHAR(25)

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @origstart = @startdate
	SET @origend = @enddate

	SET @origstartstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8))
	SET @origendstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	SET @wfmstart = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8)) 
	SET @wfmend = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @origstart AND @origend) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT SiteID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
					 END [Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				AVG(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
	'
	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.058.sql
** Name: Buildscript_1.00.058
** Auth: McNiel Viray
** Date: 16 August 2017
**************************
** Change History
**************************
** Modify stored procedures([wfmpcp_GetCampaignMonthlyExcessDeficit_sp],[wfmpcp_GetSiteMonthlyExcessDeficit_sp])
** Create stored procedure([wfmpcp_GetSiteWeeklyExcessDeficit_sp])
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[wfmpcp_GetCampaignMonthlyExcessDeficit_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetCampaignMonthlyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE
		,@origstart DATE
		,@origend DATE
		,@origstartstring VARCHAR(25)
		,@origendstring VARCHAR(25)
		,@wfmstart VARCHAR(25)
		,@wfmend VARCHAR(25)

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @origstart = @startdate
	SET @origend = @enddate

	SET @origstartstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8))
	SET @origendstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	SET @wfmstart = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8)) 
	SET @wfmend = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @origstart AND @origend) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
					 END [Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 
					AND DatapointID=23
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				AVG(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
	'
	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetSiteMonthlyExcessDeficit_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetSiteMonthlyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE
		,@origstart DATE
		,@origend DATE
		,@origstartstring VARCHAR(25)
		,@origendstring VARCHAR(25)
		,@wfmstart VARCHAR(25)
		,@wfmend VARCHAR(25)

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @origstart = @startdate
	SET @origend = @enddate

	SET @origstartstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8))
	SET @origendstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	SET @wfmstart = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8)) 
	SET @wfmend = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @origstart AND @origend) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT SiteID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))
					 END [Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 
					AND DatapointID=23
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				AVG(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
	'
	EXECUTE( @select )
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetSiteWeeklyExcessDeficit_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetSiteWeeklyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')
--SELECT @cols
	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT SiteID
					,[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 
					AND DatapointID=23
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
	'

	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO

/******************************
** File: Buildscript_1.00.059.sql
** Name: Buildscript_1.00.059
** Auth: McNiel Viray
** Date: 17 August 2017
**************************
** Change History
**************************
** Create stored procedure([wfmpcp_GetLoBWeeklyExcessDeficit_sp],[wfmpcp_GetCampaignWeeklyExcessDeficit_sp])
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[wfmpcp_GetCampaignWeeklyExcessDeficit_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetCampaignWeeklyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
	,@SiteID NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@where  AS NVARCHAR(MAX)=''
		,@startdate DATE
		,@enddate DATE
	
	IF(@SiteID != '' )
	BEGIN
		SET @where = ' AND SiteID=' + @SiteID + '  '
	END

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')
	

	SET @select = '
		SELECT s.ID CampaignID,s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 ' + @where + '
					AND DatapointID=23
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name
	'

	

	EXECUTE( @select )
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetLoBWeeklyExcessDeficit_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetLoBWeeklyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
	,@CampaignID NVARCHAR(20) = ''
AS
BEGIN
		DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@where  AS NVARCHAR(MAX)=''
		,@startdate DATE
		,@enddate DATE

	IF(@CampaignID != '' )
	BEGIN
		SET @where = ' AND CampaignID=' + @CampaignID + ' '
	END

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')


	SET @select = '
		SELECT A.CampaignID,s.Name [LoB],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT LoBID
				    ,CampaignID
					,[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 ' + @where + '			
					AND DatapointID=23		
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [LoB] s ON s.ID=A.LoBID
		WHERE 1=1 
		ORDER BY s.Name
	'

	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.060.sql
** Name: Buildscript_1.00.060
** Auth: McNiel Viray
** Date: 17 August 2017
**************************
** Change History
**************************
** modified stored procedure([wfmpcp_GetLoBWeeklyExcessDeficit_sp],[wfmpcp_GetCampaignWeeklyExcessDeficit_sp],[wfmpcp_GetSiteWeeklyExcessDeficit_sp])
*******************************/
USE WFMPCP
GO



PRINT N'Altering [dbo].[wfmpcp_GetCampaignWeeklyExcessDeficit_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetCampaignWeeklyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
	,@SiteID NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@where  AS NVARCHAR(MAX)=''
		,@startdate DATE
		,@enddate DATE
	
	IF(@SiteID != '' )
	BEGIN
		SET @where = ' AND SiteID=' + @SiteID + '  '
	END

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')
	

	SET @select = '
		SELECT s.ID CampaignID,s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 ' + @where + '
					AND DatapointID=23
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				AVG(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name
	'

	

	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetLoBWeeklyExcessDeficit_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetLoBWeeklyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
	,@CampaignID NVARCHAR(20) = ''
AS
BEGIN
		DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@where  AS NVARCHAR(MAX)=''
		,@startdate DATE
		,@enddate DATE

	IF(@CampaignID != '' )
	BEGIN
		SET @where = ' AND CampaignID=' + @CampaignID + ' '
	END

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')


	SET @select = '
		SELECT A.CampaignID,s.Name [LoB],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT LoBID
				    ,CampaignID
					,[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 ' + @where + '			
					AND DatapointID=23		
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				AVG(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [LoB] s ON s.ID=A.LoBID
		WHERE 1=1 
		ORDER BY s.Name
	'

	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetSiteWeeklyExcessDeficit_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetSiteWeeklyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT [Date]
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 
	GROUP BY [Date]
	ORDER BY [Date]

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')
--SELECT @cols
	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT SiteID
					,[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint
				WHERE 1=1 
					AND DatapointID=23
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				AVG(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
	'

	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO
