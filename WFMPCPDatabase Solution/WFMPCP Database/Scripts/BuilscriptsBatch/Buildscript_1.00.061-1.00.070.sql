/******************************
** File: Buildscript_1.00.061.sql
** Name: Buildscript_1.00.061
** Auth: McNiel Viray
** Date: 17 August 2017
**************************
** Change History
**************************
** modified stored procedure([wfmpcp_GetCampaignMonthlyExcessDeficit_sp],
** [wfmpcp_GetSiteMonthlyExcessDeficit_sp],[wfmpcp_GetSiteMonthlyHiringPlan_sp],[wfmpcp_GetSiteWeeklyExcessDeficit_sp],
** [wfmpcp_GetSiteWeeklyHiringPlan_sp])
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
		ORDER BY s.Name
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
		ORDER BY s.Name
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
		ORDER BY s.Name
	'

	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.062.sql
** Name: Buildscript_1.00.062
** Auth: McNiel Viray
** Date: 17 August 2017
**************************
** Change History
**************************
** add module permission to wfm role
*******************************/
USE WFMPCP
GO

--add module(PCP Management>AHC Manager) to WFM role
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(8,2,1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(8,2,2)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(8,2,3)


INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(11,2,1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(11,2,2)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(11,2,3)
GO
UPDATE Datapoint
SET Name='Attrition / Backfill'
WHERE ID=93
GO

/******************************
** File: Buildscript_1.00.063.sql
** Name: Buildscript_1.00.063
** Auth: McNiel Viray
** Date: 04 September 2017
**************************
** Change History
**************************
** Create staging table
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[StagingWeeklyAHDatapoint]...';


GO
CREATE TABLE [dbo].[StagingWeeklyAHDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SiteID]       BIGINT         NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Data]         NVARCHAR (200) NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [PK_StagingWeeklyAHDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_StagingWeeklyAHDatapoint_Data]...';


GO
ALTER TABLE [dbo].[StagingWeeklyAHDatapoint]
    ADD CONSTRAINT [DF_StagingWeeklyAHDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Creating [dbo].[DF_StagingWeeklyAHDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[StagingWeeklyAHDatapoint]
    ADD CONSTRAINT [DF_StagingWeeklyAHDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Update complete.';


GO

--CREATE NEW USERS

INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy)
VALUES
(1,'','1604825','McNiel Viray'),
(1,'','1604123','McNiel Viray'),
(1,'','1504607','McNiel Viray'),
(1,'','1505336','McNiel Viray'),
(1,'','1603065','McNiel Viray')
GO

/******************************
** File: Buildscript_1.00.064.sql
** Name: Buildscript_1.00.064
** Auth: McNiel Viray
** Date: 07 September 2017
**************************
** Change History
**************************
** Modify sp [dbo].[wfmpcp_GetAssumptionsHeadcount_sp] by removing rounding off and ceiling.
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@tablename AS NVARCHAR(MAX)='WeeklyAHDatapoint',
	@segmentcategoryid  AS NVARCHAR(MAX)='',
	@segmentid  AS NVARCHAR(MAX)='',
	@siteID AS NVARCHAR(MAX)='',
	@campaignID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		UPDATE WeeklyAHDatapoint
			SET [Data]=
			CASE DatapointID 
				WHEN 1 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 2 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 3 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 4 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 5 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 6 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 7 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 8 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 9 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 10 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 11 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 12 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + '%'
				WHEN 13 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 14 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 15 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 16 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 17 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 18 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 19 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 20 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 21 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 22 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 23 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 24 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 25 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 26 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 27 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 28 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 29 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 30 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 31 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 32 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 33 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 34 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 35 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 36 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 37 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 38 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 39 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 40 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 41 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 42 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 43 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 44 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 45 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 46 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 47 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 48 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 49 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 50 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 51 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 52 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 53 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 54 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 55 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 56 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 57 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 58 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 59 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 60 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 61 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 62 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 63 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 64 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 65 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 66 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 67 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 68 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 69 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 70 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 71 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 72 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 73 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 74 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 75 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 76 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 77 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 78 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 79 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 80 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 81 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 82 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 83 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 84 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 85 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 86 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 87 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 91 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 92 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 93 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 94 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 95 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 96 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 97 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 98 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 99 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 100 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 101 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 102 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 103 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 104 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 105 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 106 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 107 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 108 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 109 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 110 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 111 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 112 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 113 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 114 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 115 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 116 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 117 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				ELSE [Data]	END
			WHERE Lobid=CAST(@lobid AS BIGINT)
				AND SiteID=CAST(@siteID AS BIGINT)
				AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		UPDATE WeeklyAHDatapoint
			SET [Data]=
			CASE DatapointID 
				WHEN 1 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 2 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 3 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 4 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 5 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 6 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 7 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 8 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 9 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 10 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 11 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 12 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + '%'
				WHEN 13 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 14 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 15 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 16 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 17 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 18 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 19 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 20 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 21 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 22 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 23 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 24 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 25 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 26 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 27 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 28 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 29 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 30 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 31 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 32 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 33 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 34 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 35 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 36 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 37 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 38 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 39 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 40 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 41 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 42 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 43 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 44 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 45 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 46 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 47 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 48 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 49 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 50 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 51 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 52 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 53 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 54 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 55 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 56 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 57 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 58 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 59 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 60 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 61 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 62 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 63 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 64 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 65 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 66 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 67 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 68 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 69 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 70 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 71 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 72 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 73 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 74 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 75 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 76 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 77 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 78 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 79 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 80 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 81 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 82 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 83 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 84 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 85 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 86 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 87 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 91 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 92 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 93 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 94 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 95 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 96 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 97 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 98 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 99 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 100 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 101 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 102 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 103 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 104 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 105 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 106 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 107 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 108 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 109 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 110 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 111 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 112 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 113 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 114 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 115 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 116 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 117 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				ELSE [Data]	END
			WHERE Lobid=CAST(@lobid AS BIGINT)
				AND SiteID=CAST(@siteID AS BIGINT)
				AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],Data from ' + @tablename + 
					' ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN Datapoint d ON d.ID=A.DatapointID
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],Data from ' + @tablename + 
					' ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN Datapoint d ON d.ID=A.DatapointID
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				WHERE 1=1 '
	END

	IF(@segmentcategoryid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.SegmentCategoryID=' + @segmentcategoryid
	END

	IF(@segmentid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.ID=' + @segmentid
	END

	IF(@lobid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.LoBID=' + @lobid
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.CampaignID=' + @campaignID
	END	

	SET @orderBy = ' ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Update complete.';
GO
/******************************
** File: Buildscript_1.00.065.sql
** Name: Buildscript_1.00.065
** Auth: McNiel Viray
** Date: 12 September 2017
**************************
** Change History
**************************
** Create User
*******************************/
USE WFMPCP
GO
INSERT INTO UserRole(EmployeeID,RoleID,CreatedBy,NTLogin)
VALUES
('1400465',3,'Bulk Insert',''),
('1503090',3,'Bulk Insert',''),
('1400688',2,'Bulk Insert',''),
('1503087',3,'Bulk Insert',''),
('1701920',3,'Bulk Insert',''),
('1503311',3,'Bulk Insert',''),
('1600505',3,'Bulk Insert',''),
('1400529',3,'Bulk Insert',''),
('1601534',3,'Bulk Insert',''),
('1503596',3,'Bulk Insert',''),
('1505527',3,'Bulk Insert',''),
('1701105',3,'Bulk Insert',''),
('1604142',3,'Bulk Insert',''),
('1400401',3,'Bulk Insert',''),
('1502267',3,'Bulk Insert',''),
('1603913',3,'Bulk Insert',''),
('1700150',3,'Bulk Insert',''),
('1605963',2,'Bulk Insert',''),
('1601071',2,'Bulk Insert',''),
('1700097',2,'Bulk Insert',''),
('1700125',2,'Bulk Insert',''),
('1602545',2,'Bulk Insert',''),
('1700907',2,'Bulk Insert',''),
('1701064',3,'Bulk Insert',''),
('1501747',3,'Bulk Insert',''),
('1500812',3,'Bulk Insert',''),
('1400820',3,'Bulk Insert',''),
('1505339',3,'Bulk Insert',''),
('1700337',2,'Bulk Insert',''),
('1700388',2,'Bulk Insert',''),
('1500886',3,'Bulk Insert',''),
('1701945',3,'Bulk Insert',''),
('1504229',3,'Bulk Insert',''),
('1505824',3,'Bulk Insert',''),
('1600784',3,'Bulk Insert',''),
('1603702',3,'Bulk Insert',''),
('1701786',3,'Bulk Insert',''),
('1701542',3,'Bulk Insert',''),
('1401036',2,'Bulk Insert',''),
('1603723',3,'Bulk Insert',''),
('1503000',3,'Bulk Insert',''),
('1504175',3,'Bulk Insert',''),
('1600580',3,'Bulk Insert',''),
('1504708',3,'Bulk Insert',''),
('1604015',3,'Bulk Insert',''),
('1504992',3,'Bulk Insert',''),
('1604075',3,'Bulk Insert',''),
('1604072',3,'Bulk Insert',''),
('1602199',2,'Bulk Insert',''),
('1502928',3,'Bulk Insert',''),
('1500037',3,'Bulk Insert',''),
('1502437',3,'Bulk Insert',''),
('1502916',3,'Bulk Insert',''),
('1505400',2,'Bulk Insert',''),
('1502017',3,'Bulk Insert',''),
('1600111',3,'Bulk Insert',''),
('1601424',2,'Bulk Insert',''),
('1604721',3,'Bulk Insert',''),
('1500707',3,'Bulk Insert',''),
('1401226',2,'Bulk Insert',''),
('1503573',3,'Bulk Insert',''),
('1600143',3,'Bulk Insert',''),
('1700909',3,'Bulk Insert',''),
('1502920',3,'Bulk Insert',''),
('1603065',3,'Bulk Insert',''),
('1702133',3,'Bulk Insert',''),
('2011099',2,'Bulk Insert',''),
('1501913',3,'Bulk Insert',''),
('1501184',2,'Bulk Insert',''),
('1505107',2,'Bulk Insert',''),
('1700017',2,'Bulk Insert',''),
('1701062',2,'Bulk Insert',''),
('1504069',3,'Bulk Insert',''),
('1501657',2,'Bulk Insert',''),
('1603595',3,'Bulk Insert',''),
('1503021',3,'Bulk Insert','')
GO
/******************************
** File: Buildscript_1.00.067.sql
** Name: Buildscript_1.00.067
** Auth: McNiel Viray
** Date: 21 September 2017
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[wfmpcp_GetCampaignWeeklyActualHC_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetCampaignWeeklyActualHC_sp]
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
					AND DatapointID=21
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
CREATE PROCEDURE [dbo].[wfmpcp_GetExcessDeficitVsActualHC_sp]
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
		SELECT s.ID CampaignID,s.Name [Campaign],[Type],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,[Campaign]=(SELECT Name FROM Campaign WHERE ID=CampaignID)
					,Type=''E/D''
					,TypeID=1
					,[Date]=[Date]
					,[Data] = CASE DatapointID WHEN 23 THEN CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) END
				FROM WeeklyStaffDatapoint
				WHERE 1=1 ' + @where + '
					AND DatapointID IN (23)
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
				UNION
				SELECT CampaignID
					,[Campaign]=(SELECT Name FROM Campaign WHERE ID=CampaignID)
					,Type=''Act HC''
					,TypeID=2
					,[Date]=[Date]
					,[Data] = CASE DatapointID WHEN 21 THEN CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) END
				FROM WeeklyStaffDatapoint
				WHERE 1=1 ' + @where + '
					AND DatapointID IN (21)
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
		ORDER BY s.Name,[TypeID]
	'
	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.068.sql
** Name: Buildscript_1.00.068
** Auth: McNiel Viray
** Date: 22 September 2017
**************************
** Change History
**************************
** modified [wfmpcp_GetLoBWeeklyExcessDeficit_sp] change AVG(Data) to  SUM(Data)
** modified [wfmpcp_GetCampaignWeeklyExcessDeficit_sp] change AVG(Data) to  MAX(Data)
** modified [wfmpcp_GetExcessDeficitVsActualHC_sp] change AVG(Data) to  MAX(Data)
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
		SELECT s.ID CampaignID,s.Name [Campaign],[Type],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,[Campaign]=(SELECT Name FROM Campaign WHERE ID=CampaignID)
					,Type=''E/D''
					,TypeID=1
					,[Date]=[Date]
					,[Data] = CASE DatapointID WHEN 23 THEN CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) END
				FROM WeeklyStaffDatapoint
				WHERE 1=1 ' + @where + '
					AND DatapointID IN (23)
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
				UNION
				SELECT CampaignID
					,[Campaign]=(SELECT Name FROM Campaign WHERE ID=CampaignID)
					,Type=''Act HC''
					,TypeID=2
					,[Date]=[Date]
					,[Data] = CASE DatapointID WHEN 22 THEN CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) END
				FROM WeeklyStaffDatapoint
				WHERE 1=1 ' + @where + '
					AND DatapointID IN (22)
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
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
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.069.sql
** Name: Buildscript_1.00.069
** Auth: McNiel Viray
** Date: 25 September 2017
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]
	@SID BIGINT = NULL,
	@CID BIGINT = NULL,
	@LID BIGINT = NULL
AS
BEGIN

	DECLARE @ID INT
	,@WeekStartDatetime SMALLDATETIME
	,@WeekOfYear SMALLINT
	,@CampaignID BIGINT
	,@LoBID BIGINT
	,@SiteID BIGINT

	DECLARE week_cursor CURSOR FOR
	SELECT ID, WeekStartdate, WeekOfYear FROM [Week]

	OPEN week_cursor

	FETCH FROM week_cursor
	INTO @ID,@WeekStartDatetime,@WeekOfYear

	WHILE @@FETCH_STATUS=0
	BEGIN

			DECLARE lob_cursor CURSOR FOR
			SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB
			WHERE ((SiteID=@SID) OR (@SID IS NULL))
				AND ((CampaignID=@CID) OR (@CID IS NULL))
				AND ((LobID=@LID) OR (@LID IS NULL))
			--SELECT ID, CampaignID FROM LoB

			OPEN lob_cursor
	
			FETCH FROM lob_cursor
			INTO @SiteID,@CampaignID,@LoBID

			WHILE @@FETCH_STATUS=0
			BEGIN
				INSERT INTO WeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],Data,[Date],CreatedBy,DateCreated)
				SELECT 
					@SiteID
					,@CampaignID
					,@LoBID
					,d.ID
					,@WeekOfYear
					,'0'--data
					,CAST(@WeekStartDatetime AS DATE)
					,'McNiel Viray'
					,GETDATE()		
				FROM Datapoint d
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder


				FETCH NEXT FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID
			END
			CLOSE lob_cursor;
			DEALLOCATE lob_cursor;

		FETCH NEXT FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear
	END
	CLOSE week_cursor;
	DEALLOCATE week_cursor;

END
GO
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]
	@SID BIGINT = NULL,
	@CID BIGINT = NULL,
	@LID BIGINT = NULL
AS
BEGIN
		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT
			,@SiteID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB
				WHERE ((SiteID=@SID) OR (@SID IS NULL))
					AND ((CampaignID=@CID) OR (@CID IS NULL))
					AND ((LobID=@LID) OR (@LID IS NULL))

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyHiringDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@SiteID
							,@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM HiringDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @SiteID,@CampaignID,@LoBID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
END
GO
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]
	@SID BIGINT = NULL,
	@CID BIGINT = NULL,
	@LID BIGINT = NULL
AS
BEGIN
		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT
			,@SiteID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB
				WHERE ((SiteID=@SID) OR (@SID IS NULL))
					AND ((CampaignID=@CID) OR (@CID IS NULL))
					AND ((LobID=@LID) OR (@LID IS NULL))

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyStaffDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@SiteID
							,@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM StaffDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @SiteID,@CampaignID,@LoBID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
END
GO
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]
	@SID BIGINT = NULL,
	@CID BIGINT = NULL,
	@LID BIGINT = NULL
AS
BEGIN
		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT
			,@SiteID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB
				WHERE ((SiteID=@SID) OR (@SID IS NULL))
					AND ((CampaignID=@CID) OR (@CID IS NULL))
					AND ((LobID=@LID) OR (@LID IS NULL))

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklySummaryDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@SiteID
							,@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM SummaryDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @SiteID,@CampaignID,@LoBID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
END
GO
PRINT N'Creating [dbo].[wfmpcp_CreateWeeklyDatapoints_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklyDatapoints_sp]
	@SiteID BIGINT 
	,@CampaignID BIGINT 
	,@LobID BIGINT 
AS
BEGIN
	--Check if not exists in [dbo].[WeeklyAHDatapoint]
	IF NOT EXISTS(SELECT ID FROM [dbo].[WeeklyAHDatapoint] WHERE SiteID=@SiteID AND 
		CampaignID=@CampaignID AND LobID=@LobID)
	BEGIN 
		EXEC [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp] @SiteID,@CampaignID,@LobID
	END
	--Check if not exists in [dbo].[WeeklyHiringDatapoint]
	IF NOT EXISTS(SELECT ID FROM [dbo].[WeeklyHiringDatapoint] WHERE SiteID=@SiteID AND 
		CampaignID=@CampaignID AND LobID=@LobID)
	BEGIN 
		EXEC [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp] @SiteID,@CampaignID,@LobID
	END
	--Check if not exists in [dbo].[WeeklyStaffDatapoint]
	IF NOT EXISTS(SELECT ID FROM [dbo].[WeeklyStaffDatapoint] WHERE SiteID=@SiteID AND 
		CampaignID=@CampaignID AND LobID=@LobID)
	BEGIN 
		EXEC [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp] @SiteID,@CampaignID,@LobID
	END
	--Check if not exists in [dbo].[WeeklySummaryDatapoint]
	IF NOT EXISTS(SELECT ID FROM [dbo].[WeeklySummaryDatapoint] WHERE SiteID=@SiteID AND 
		CampaignID=@CampaignID AND LobID=@LobID)
	BEGIN 
		EXEC [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp] @SiteID,@CampaignID,@LobID
	END
END
GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.070.sql
** Name: Buildscript_1.00.070
** Auth: McNiel Viray
** Date: 26 September 2017
**************************
** Change History
**************************
** Modify all get stored procedure. added filter to display just the active Site,Campaign and Lob
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@tablename AS NVARCHAR(MAX)='WeeklyAHDatapoint',
	@segmentcategoryid  AS NVARCHAR(MAX)='',
	@segmentid  AS NVARCHAR(MAX)='',
	@siteID AS NVARCHAR(MAX)='',
	@campaignID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		UPDATE WeeklyAHDatapoint
			SET [Data]=
			CASE DatapointID 
				WHEN 1 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 2 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 3 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 4 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 5 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 6 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 7 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 8 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 9 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 10 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 11 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 12 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + '%'
				WHEN 13 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 14 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 15 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 16 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 17 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 18 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 19 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 20 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 21 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 22 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 23 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 24 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 25 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 26 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 27 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 28 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 29 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 30 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 31 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 32 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 33 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 34 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 35 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 36 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 37 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 38 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 39 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 40 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 41 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 42 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 43 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 44 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 45 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 46 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 47 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 48 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 49 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 50 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 51 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 52 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 53 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 54 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 55 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 56 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 57 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 58 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 59 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 60 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 61 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 62 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 63 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 64 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 65 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 66 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 67 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 68 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 69 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 70 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 71 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 72 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 73 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 74 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 75 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 76 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 77 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 78 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 79 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 80 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 81 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 82 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 83 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 84 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 85 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 86 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 87 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 91 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 92 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 93 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 94 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 95 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 96 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 97 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 98 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 99 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 100 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 101 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 102 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 103 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 104 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 105 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 106 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 107 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 108 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 109 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 110 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 111 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 112 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 113 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 114 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 115 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 116 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 117 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				ELSE [Data]	END
			WHERE Lobid=CAST(@lobid AS BIGINT)
				AND SiteID=CAST(@siteID AS BIGINT)
				AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		UPDATE WeeklyAHDatapoint
			SET [Data]=
			CASE DatapointID 
				WHEN 1 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 2 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 3 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 4 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 5 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 6 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 7 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 8 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 9 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 10 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 11 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 12 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + '%'
				WHEN 13 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) 
				WHEN 14 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 15 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 16 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 17 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 18 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 19 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 20 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 21 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 22 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 23 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 24 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 25 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 26 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 27 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 28 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 29 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 30 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 31 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 32 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 33 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 34 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 35 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 36 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 37 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 38 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 39 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 40 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 41 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 42 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 43 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 44 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 45 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 46 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 47 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 48 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 49 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 50 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 51 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 52 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 53 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 54 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 55 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 56 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 57 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 58 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 59 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 60 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 61 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 62 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 63 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 64 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 65 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 66 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 67 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 68 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 69 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 70 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 71 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 72 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 73 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 74 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 75 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 76 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 77 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 78 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 79 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 80 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 81 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 82 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 83 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 84 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 85 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 86 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 87 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 91 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 92 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 93 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 94 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 95 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 96 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 97 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 98 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 99 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 100 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 101 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 102 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 103 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 104 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 105 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX)) + ' %'
				WHEN 106 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 107 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 108 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 109 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 110 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 111 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 112 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 113 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 114 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 115 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 116 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				WHEN 117 THEN CAST(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)) AS NVARCHAR(MAX))
				ELSE [Data]	END
			WHERE Lobid=CAST(@lobid AS BIGINT)
				AND SiteID=CAST(@siteID AS BIGINT)
				AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.LobID,w.datapointid,w.[Date],w.Data from ' + @tablename + 
					' w 
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID	
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
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
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.LobID,w.datapointid,w.[Date],w.Data from ' + @tablename + 
					' w 
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID	
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
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
				WHERE 1=1 '
	END

	IF(@segmentcategoryid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.SegmentCategoryID=' + @segmentcategoryid
	END

	IF(@segmentid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.ID=' + @segmentid
	END

	IF(@lobid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.LoBID=' + @lobid
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.CampaignID=' + @campaignID
	END	

	SET @orderBy = ' ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
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
				SELECT w.CampaignID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
					 END [Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 AND w.DatapointID=23
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
				SELECT w.CampaignID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
					 END [Date]
					,CAST(w.[Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
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
PRINT N'Altering [dbo].[wfmpcp_GetHiringRequirements_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetHiringRequirements_sp]
	@campaignID AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@siteID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyHiringDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyHiringDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT a.DatapointID,l.ID LobID,l.Name [Lob], d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.LobID,w.datapointid,w.[Date],w.[Data] from WeeklyHiringDatapoint w
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID
						WHERE s.Active=1 AND c.Active=1 AND l.Active=1 
					 ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN HiringDatapoint d ON d.ID=A.DatapointID
				INNER JOIN Lob l ON l.ID=A.LobID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.LobID,w.datapointid,w.[Date],w.[Data] from WeeklyHiringDatapoint w
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN HiringDatapoint d ON d.ID=A.DatapointID
				INNER JOIN Lob l ON l.ID=A.LobID
				WHERE 1=1 '
	END
	
	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND A.CampaignID=' + @campaignID
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	SET @orderBy = ' ORDER BY l.Name,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetHiringRequirementsTotal_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetHiringRequirementsTotal_sp]
	@campaignID AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@siteID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyHiringDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyHiringDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.datapointid,w.[Date],[Data]=CAST(w.[Data] AS BIGINT) from WeeklyHiringDatapoint w
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
					 ) x		
					PIVOT
					(
						SUM(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN HiringDatapoint d ON d.ID=A.DatapointID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.datapointid,w.[Date],[Data]=CAST(w.[Data] AS BIGINT) from WeeklyHiringDatapoint w
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
					) x		
					PIVOT
					(
						SUM(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN HiringDatapoint d ON d.ID=A.DatapointID
				WHERE 1=1 '
	END
	
	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND A.CampaignID=' + @campaignID
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	SET @orderBy = ' ORDER BY d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
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
				SELECT w.LoBID
				    ,w.CampaignID
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
		INNER JOIN [LoB] s ON s.ID=A.LoBID
		WHERE 1=1 
		ORDER BY s.Name
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
				SELECT w.SiteID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
					 END [Date]
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
				SELECT w.SiteID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
					 END [Date]
					,CAST(w.[Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
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
				SELECT w.SiteID
					,w.[Date]
					,CAST(w.[Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
		ORDER BY s.Name
	'

	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetStaffPlanner_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetStaffPlanner_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@segmentid  AS NVARCHAR(MAX)='',
	@siteID AS NVARCHAR(MAX)='',
	@campaignID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyStaffDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')


		UPDATE WeeklyStaffDatapoint
		SET [Data]=
				CASE DatapointID 
					WHEN 1 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 2 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 3 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 5 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 7 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 8 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 13 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
					WHEN 14 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
					WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 21 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 22 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					ELSE CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(10)) END
		--FROM WeeklyStaffDatapoint 
		WHERE Lobid=CAST(@lobid AS BIGINT)
			AND SiteID=CAST(@siteID AS BIGINT)
			AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyStaffDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')


		UPDATE WeeklyStaffDatapoint
		SET [Data]=
				CASE DatapointID 
					WHEN 1 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 2 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 3 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 5 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 7 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 8 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 13 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
					WHEN 14 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
					WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 21 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 22 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					ELSE CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(10)) END
		--FROM WeeklyStaffDatapoint 
		WHERE Lobid=CAST(@lobid AS BIGINT)
			AND SiteID=CAST(@siteID AS BIGINT)
			AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.LobID,w.datapointid,w.[Date],w.[Data] from WeeklyStaffDatapoint w
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1
					 ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN StaffDatapoint d ON d.ID=A.DatapointID
				INNER JOIN StaffSegment s ON s.ID=d.SegmentID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.LobID,w.datapointid,w.[Date],w.[Data] from WeeklyStaffDatapoint w
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN StaffDatapoint d ON d.ID=A.DatapointID
				INNER JOIN StaffSegment s ON s.ID=d.SegmentID
				WHERE 1=1 '
	END
	
	IF(@segmentid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.ID=' + @segmentid
	END

	IF(@lobid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.LoBID=' + @lobid
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.CampaignID=' + @campaignID
	END	

	SET @orderBy = ' ORDER BY s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetSummary1_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetSummary1_sp]
	@campaignID AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@siteID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklySummaryDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklySummaryDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT a.DatapointID,l.ID LobID,l.Name [Lob], d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.LobID,w.datapointid,w.[Date],w.[Data] from WeeklySummaryDatapoint w
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1
					 ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN SummaryDatapoint d ON d.ID=A.DatapointID
				INNER JOIN Lob l ON l.ID=A.LobID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT w.SiteID,w.CampaignID,w.LobID,w.datapointid,w.[Date],w.[Data] from WeeklySummaryDatapoint w
						INNER JOIN [Site] s ON s.ID=w.SiteID
						INNER JOIN [Campaign] c ON c.ID=w.CampaignID
						INNER JOIN [LoB] l ON l.ID=w.LoBID
						WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN SummaryDatapoint d ON d.ID=A.DatapointID
				INNER JOIN Lob l ON l.ID=A.LobID
				WHERE 1=1 '
	END
	
	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND A.CampaignID=' + @campaignID
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	SET @orderBy = ' ORDER BY l.Name,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Update complete.';


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
		INNER JOIN [LoB] s ON s.ID=A.LoBID
		WHERE 1=1 
		ORDER BY s.Name
	'

	EXECUTE( @select )
END
GO
