/******************************
** File: Buildscript_1.00.004.sql
** Name: Buildscript_1.00.004
** Auth: McNiel Viray
** Date: 06 April 2017
**************************
** Change History
**************************
** Create data for Permission and module
*******************************/
USE WFMPCP
GO


PRINT N'Dropping [dbo].[DF_Module_DateCreated]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF_Module_DateCreated];


GO
PRINT N'Starting rebuilding table [dbo].[Module]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Module] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [ParentID]     BIGINT         CONSTRAINT [DF_Module_ParentID] DEFAULT (0) NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
	[FontAwesome]  NVARCHAR(100)  NULL,
    [Route]        NVARCHAR (MAX) NOT NULL,
    [SortOrder]    INT            DEFAULT 0 NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       CONSTRAINT [DF_Module_DateCreated] DEFAULT GETDATE() NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            CONSTRAINT [DF_Module_Active] DEFAULT (1) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_Module_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Module])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Module] ON;
        INSERT INTO [dbo].[tmp_ms_xx_Module] ([ID], [Name], [Route], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified])
        SELECT   [ID],
                 [Name],
                 [Route],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified]
        FROM     [dbo].[Module]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Module] OFF;
    END

DROP TABLE [dbo].[Module];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Module]', N'Module';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_Module_ID1]', N'PK_Module_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO






PRINT 'Creating data for Permission..'
INSERT INTO Permission([Name],[Description],CreatedBy)
VALUES('View','View','McNiel Viray')
INSERT INTO Permission([Name],[Description],CreatedBy)
VALUES('Edit','Edit','McNiel Viray')
INSERT INTO Permission([Name],[Description],CreatedBy)
VALUES('Design','Design','McNiel Viray')
GO

PRINT 'Creating data for Module..'
GO
INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,FontAwesome)
VALUES('Profile','/Home/MyProfile',1,'McNiel Viray','fa-user')
INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,FontAwesome)
VALUES('Data Management','#',2,'McNiel Viray','fa-list-alt')
INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
VALUES('User Manager','/UserManagement/ManageUser',1,'McNiel Viray',2,'fa-tag')
INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
VALUES('Site Manager','/SiteManagement/ManageSite',2,'McNiel Viray',2,'fa-tag')
INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
VALUES('Campaign Manager','/CampaignManagement/ManageCampaign',3,'McNiel Viray',2,'fa-tag')
INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
VALUES('LoB Manager','/LoBManagement/ManageLoB',3,'McNiel Viray',2,'fa-tag')
INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,FontAwesome)
VALUES('Help','/Home/Help',3,'McNiel Viray','fa-list-alt')
GO


PRINT N'The following operation was generated from a refactoring log file 17f5a37e-a262-46a9-81a8-620bd67b5be7';

PRINT N'Rename [dbo].[ModuleRolePermission].[DateModifieed] to DateModified';


GO
EXECUTE sp_rename @objname = N'[dbo].[ModuleRolePermission].[DateModifieed]', @newname = N'DateModified', @objtype = N'COLUMN';


GO
PRINT N'Altering [dbo].[ModuleRolePermission]...';


GO
ALTER TABLE [dbo].[ModuleRolePermission] ALTER COLUMN [DateModified] DATETIME NULL;


GO
-- Refactoring step to update target server with deployed transaction logs

IF OBJECT_ID(N'dbo.__RefactorLog') IS NULL
BEGIN
    CREATE TABLE [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
    EXEC sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
END
GO
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '17f5a37e-a262-46a9-81a8-620bd67b5be7')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('17f5a37e-a262-46a9-81a8-620bd67b5be7')

GO

GO

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,1,3,'McNiel Viray')


INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(2,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(2,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(2,1,3,'McNiel Viray')


INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(3,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(3,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(3,1,3,'McNiel Viray')


INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(4,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(4,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(4,1,3,'McNiel Viray')


INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(5,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(5,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(5,1,3,'McNiel Viray')

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(6,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(6,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(6,1,3,'McNiel Viray')

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,1,3,'McNiel Viray')
GO
PRINT N'Update complete.';


GO