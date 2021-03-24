/******************************
** File: Buildscript_1.00.020.sql
** Name: Buildscript_1.00.020
** Auth: McNiel Viray
** Date: 15 June 2017
**************************
** Change History
**************************
** Create Table Type for WeeklyDatapoint
** Create storedprocedure [wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
** Create Table [dbo].[WeeklyAHDatapointLog]
** Alter Procedure [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
** Create new module
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[WeeklyDatapointTableType]...';


GO
CREATE TYPE [dbo].[WeeklyDatapointTableType] AS TABLE (
    [DatapointID] BIGINT,
	[LoBID] BIGINT,
	[Date] DATE,
	[DataValue] NVARCHAR(MAX),
	[UserName] NVARCHAR(50),
	[DateModified] DATETIME
)
GO
PRINT N'Update complete.';


GO
PRINT N'Creating [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';

GO
CREATE PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
	@WeeklyDatapointTableType [dbo].[WeeklyDatapointTableType] READONLY
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		--UPDATE FIRST Related Data
		UPDATE w
		SET w.[Data]=wt.DataValue,
			w.ModifiedBy=wt.UserName,
			w.DateModified=wt.DateModified
		FROM WeeklyAHDatapoint w
		INNER JOIN @WeeklyDatapointTableType wt ON wt.DatapointID=w.DatapointID	
			AND wt.[Date]=w.[Date]
			AND wt.LoBID=w.LoBID

		--cascade to remaining data.

		DECLARE @Date DATE

		SELECT @Date = MAX([Date]) FROM @WeeklyDatapointTableType
		DECLARE @tbl AS TABLE
		(
			DatapointID BIGINT,
			LobID BIGINT,
			DataValue NVARCHAR(MAX),
			DateMofidifed DATETIME,
			ModifiedBy NVARCHAR(50)
		)

		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy)
		SELECT DatapointID,LoBID,DataValue,DateModified,UserName
		FROM @WeeklyDatapointTableType
		WHERE [Date]=@Date

		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyAHDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
		WHERE w.[Date]>@Date

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN --RollBack in case of Error

		RAISERROR(15600,-1,-1,'[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]')
	END CATCH
END

GO
PRINT N'Creating [dbo].[WeeklyAHDatapointLog]...';
GO
CREATE TABLE [dbo].[WeeklyAHDatapointLog]
(
	[ID] BIGINT NOT NULL, 
	[CampaignID] BIGINT NULL,
	[LoBID] BIGINT NULL,
	[DatapointID] BIGINT NOT NULL,
    [Week] INT NOT NULL,  
    [Data] NVARCHAR(200) NOT NULL DEFAULT(''), 
    [Date] DATE NOT NULL, 
    [CreatedBy] NVARCHAR(50) NULL, 
    [ModifiedBy] NVARCHAR(50) NULL, 
    [DateCreated] DATETIME NOT NULL DEFAULT(getdate()), 
    [DateModified] DATETIME NULL,
	[DateEntered] DATETIME NOT NULL DEFAULT(getdate())
)
GO
PRINT N'Creating [dbo].[WeeklyAHDatapointLog] Update TRIGGER...';
GO
CREATE TRIGGER TRG_WeeklyAHDatapoint_Update 
	ON [dbo].[WeeklyAHDatapoint] 
	FOR UPDATE
AS
BEGIN
	INSERT [dbo].[WeeklyAHDatapointLog] (ID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,ModifiedBy,DateCreated,DateModified)
	SELECT
	   d.ID,d.CampaignID,d.LoBID,d.DatapointID,d.[Week],d.[Data],d.[Date],d.CreatedBy,d.ModifiedBy,d.DateCreated,d.DateModified
	FROM
	   DELETED d 
	--   JOIN INSERTED i ON d.ID = i.ID
	--WHERE
	--   d.[Data] <> i.[Data]
END
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
	@segmentid  AS NVARCHAR(MAX)=''
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
						SELECT LobID,datapointid,[Date],Data from ' + @tablename + 
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
						SELECT LobID,datapointid,[Date],Data from ' + @tablename + 
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

	SET @orderBy = ' ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END


GO
PRINT 'Creating ModuleRolePermission'
GO
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,2,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,3,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,4,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,5,1,'McNiel Viray')

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,2,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,3,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,4,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,5,1,'McNiel Viray')
GO
PRINT 'Creating new Module...'
GO
UPDATE Module
SET SortOrder=5
WHERE ID=7
GO
DECLARE @ParentID BIGINT
,@ModuleID BIGINT

INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,FontAwesome)
VALUES('Capacity Planner','#',4,'McNiel Viray','fa-list-alt')

SELECT @ParentID=SCOPE_IDENTITY()

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,2,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,3,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,4,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,5,1,'McNiel Viray')

	--create child
	INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
	VALUES('Asumption and Headcount','/CapacityPlanner/AHC',1,'McNiel Viray',@ParentID,'fa-tag')
		SELECT @ModuleID = SCOPE_IDENTITY()
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,1,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,2,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,3,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,4,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,5,1,'McNiel Viray')

	INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
	VALUES('Staff Planner','/CapacityPlanner/StaffPlanner',2,'McNiel Viray',@ParentID,'fa-tag')
		SELECT @ModuleID = SCOPE_IDENTITY()
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,1,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,2,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,3,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,4,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,5,1,'McNiel Viray')

GO
