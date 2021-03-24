/******************************
** File: Buildscript_1.00.006.sql
** Name: Buildscript_1.00.006
** Auth: McNiel Viray
** Date: 05 May 2017
**************************
** Change History
**************************
** Create segment table
** add new module for segment management
** ModuleRolePermission for segment page
*******************************/
USE WFMPCP
GO

PRINT N'Updating Help Module sort order...'
GO

UPDATE Module
SET SortOrder=4
WHERE ID=7
GO

PRINT N'Creating parent module PCP Management & child...'
GO
INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,FontAwesome)
VALUES('PCP Management','#',3,'McNiel Viray','fa-list-alt')

DECLARE @ModuleID BIGINT
	,@SegmentID BIGINT
	,@DatapointID BIGINT

SELECT @ModuleID = SCOPE_IDENTITY()

INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
VALUES('Segment Manager','/SegmentManagement/ManageSegment',1,'McNiel Viray',@ModuleID,'fa-tag')
SELECT @SegmentID = SCOPE_IDENTITY()

INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
VALUES('Data Point Manager','/DataPointManagement/ManageDatapoint',2,'McNiel Viray',@ModuleID,'fa-tag')
SELECT @DatapointID = SCOPE_IDENTITY()

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,1,3,'McNiel Viray')

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@SegmentID,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@SegmentID,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@SegmentID,1,3,'McNiel Viray')

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@DatapointID,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@DatapointID,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@DatapointID,1,3,'McNiel Viray')
GO


PRINT N'Creating [dbo].[Segment]...';


GO
CREATE TABLE [dbo].[Segment] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (200) NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_Segment_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_Segment_DateCreated]...';


GO
ALTER TABLE [dbo].[Segment]
    ADD CONSTRAINT [DF_Segment_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_Segment_Active]...';


GO
ALTER TABLE [dbo].[Segment]
    ADD CONSTRAINT [DF_Segment_Active] DEFAULT (1) FOR [Active];


GO
-- Refactoring step to update target server with deployed transaction logs
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '36f008c5-b8b4-4e17-96c1-a90ddd214adf')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('36f008c5-b8b4-4e17-96c1-a90ddd214adf')

GO

GO
PRINT N'Update complete.';


GO
