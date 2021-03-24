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
				SELECT w.SiteID
					,w.[Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(w.[Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
					AND w.DatapointID=23
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				AVG(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
		ORDER BY s.Name
	'

	EXECUTE( @select )
END