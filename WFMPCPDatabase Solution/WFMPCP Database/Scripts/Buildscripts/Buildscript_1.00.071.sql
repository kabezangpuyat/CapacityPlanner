/******************************
** File: Buildscript_1.00.071.sql
** Name: Buildscript_1.00.071
** Auth: McNiel Viray
** Date: 26 September 2017
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO

PRINT N'Altering [dbo].[wfmpcp_GetCampaignWeeklyActualHC_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetCampaignWeeklyActualHC_sp]
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
		SET @where = ' AND w.SiteID=' + @SiteID + '  '
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
				SELECT w.CampaignID
					,w.[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(w.[Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 ' + @where + '
					AND w.DatapointID=21
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
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
		SET @where = ' AND w.SiteID=' + @SiteID + '  '
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
				SELECT w.CampaignID
					,w.[Date]
					,CAST(w.[Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 ' + @where + '
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
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
PRINT N'Altering [dbo].[wfmpcp_GetExcessDeficitVsActualHC_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetExcessDeficitVsActualHC_sp]
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
		SET @where = ' AND w.SiteID=' + @SiteID + '  '
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
		SELECT s.ID CampaignID,s.Name [Campaign],[Type],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT w.CampaignID
					,[Campaign]=(SELECT Name FROM Campaign WHERE ID=w.CampaignID)
					,Type=''E/D''
					,TypeID=1
					,[Date]=w.[Date]
					,[Data] = CASE w.DatapointID WHEN 23 THEN CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(w.[Data],''%'',''''))),''''),''0'') AS DECIMAL)) END
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 ' + @where + '
					AND w.DatapointID IN (23)
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
				UNION
				SELECT w.CampaignID
					,[Campaign]=(SELECT Name FROM Campaign WHERE ID=w.CampaignID)
					,Type=''Act HC''
					,TypeID=2
					,[Date]=w.[Date]
					,[Data] = CASE w.DatapointID WHEN 22 THEN CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(w.[Data],''%'',''''))),''''),''0'') AS DECIMAL)) END
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 ' + @where + '
					AND w.DatapointID IN (22)
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				MAX(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name,[TypeID]
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
		SET @where = ' AND w.CampaignID=' + @CampaignID + ' '
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
				SELECT w.LoBID
				    ,w.CampaignID
					,w.[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(w.[Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 ' + @where + '			
					AND w.DatapointID=23		
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				MAX(Data)
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
		SET @where = ' AND w.SiteID=' + @SiteID + '  '
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
				SELECT w.CampaignID
					,w.[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(w.[Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 ' + @where + '
					AND w.DatapointID=23
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
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
