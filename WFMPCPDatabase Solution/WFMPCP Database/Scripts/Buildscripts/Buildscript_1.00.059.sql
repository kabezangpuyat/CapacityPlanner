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
