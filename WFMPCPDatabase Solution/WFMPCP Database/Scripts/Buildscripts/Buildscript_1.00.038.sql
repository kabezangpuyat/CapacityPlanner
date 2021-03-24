/******************************
** File: Buildscript_1.00.038.sql
** Name: Buildscript_1.00.038
** Auth: McNiel Viray
** Date: 12 July 2017
**************************
** Change History
**************************
** Alter stored procedures wfmpcp_GetAssumptionsHeadcount_sp,wfmpcp_GetHiringRequirements_sp,wfmpcp_GetHiringRequirementsTotal_sp
** wfmpcp_GetStaffPlanner_sp
*******************************/
USE WFMPCP
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
							FROM WeeklyStaffDatapoint
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
							FROM WeeklyStaffDatapoint
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
				SELECT l.Name [Lob], d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT CampaignID,LobID,datapointid,[Date],[Data] from WeeklyHiringDatapoint
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
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklyHiringDatapoint
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
							FROM WeeklyStaffDatapoint
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
							FROM WeeklyStaffDatapoint
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
						SELECT SiteID,CampaignID,datapointid,[Date],[Data]=CAST([Data] AS BIGINT) from WeeklyHiringDatapoint
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
						SELECT CampaignID,datapointid,[Date],[Data]=CAST([Data] AS BIGINT) from WeeklyHiringDatapoint
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
					WHEN 1 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 2 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 3 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 5 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 7 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 8 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 13 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
					WHEN 14 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
					WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 21 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 22 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					ELSE CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(10)) END
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
					WHEN 1 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 2 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 3 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 5 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 7 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 8 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 13 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
					WHEN 14 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
					WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 21 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 22 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					ELSE CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(10)) END
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
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklyStaffDatapoint
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
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklyStaffDatapoint
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
PRINT N'Update complete.';


GO
