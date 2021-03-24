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
