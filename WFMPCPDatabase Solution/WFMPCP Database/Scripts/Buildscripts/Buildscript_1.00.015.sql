/******************************
** File: Buildscript_1.00.015.sql
** Name: Buildscript_1.00.015
** Auth: McNiel Viray
** Date: 15 May 2017
**************************
** Change History
**************************
** update [wfmpcp_GetAssumptionsHeadcount_sp]
*******************************/
USE WFMPCP
GO
ALTER PROCEDURE [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',
	@includeDatapoint BIT = 1
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX)
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
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
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
				WHERE 1=1 '
	END

	IF(@lobid != '')
	BEGIN
		SET @whereClause = ' AND a.LoBID=' + @lobid
	END	

	SET @orderBy = ' ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END

GO
PRINT N'Update complete.';



GO