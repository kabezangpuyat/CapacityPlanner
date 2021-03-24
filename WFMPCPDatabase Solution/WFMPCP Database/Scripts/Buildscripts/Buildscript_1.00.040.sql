/******************************
** File: Buildscript_1.00.040.sql
** Name: Buildscript_1.00.040
** Auth: McNiel Viray
** Date: 14 July 2017
**************************
** Change History
**************************
** Alter stored procedure [dbo].[wfmpcp_GetHiringRequirements_sp]
*******************************/
USE WFMPCP
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
				SELECT a.DatapointID,l.ID LobID,l.Name [Lob], d.Name [Datapoint],' + @cols + '
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