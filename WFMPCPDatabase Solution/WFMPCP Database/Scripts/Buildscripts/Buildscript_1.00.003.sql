/******************************
** File: Buildscript_1.00.003.sql
** Name: Buildscript_1.00.003
** Auth: McNiel Viray
** Date: 06 April 2017
**************************
** Change History
**************************
** Add column and change datatype column of Module Table
** Create tables Module, Permission, ModuleRolePermission
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[Permission]...';


GO
CREATE TABLE [dbo].[Permission] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (250) NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATE           NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_Permission_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[Module]...';


GO
CREATE TABLE [dbo].[Module] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
    [Route]        NVARCHAR (MAX) NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [PK_Module_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[ModuleRolePermission]...';


GO
CREATE TABLE [dbo].[ModuleRolePermission] (
    [ID]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [ModuleID]        BIGINT         NOT NULL,
    [RoleID]          BIGINT         NOT NULL,
    [PermissionID] BIGINT         NOT NULL,
    [CreatedBy]       NVARCHAR (250) NULL,
    [ModifiedBy]      NVARCHAR (250) NULL,
    [DateCreated]     DATETIME       NOT NULL,
    [DateModifieed]   DATETIME       NOT NULL,
    [Active]          BIT            NOT NULL,
    CONSTRAINT [PK_ModuleRolePermission_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_Permission_DateCreated]...';


GO
ALTER TABLE [dbo].[Permission]
    ADD CONSTRAINT [DF_Permission_DateCreated] DEFAULT (GETDATE()) FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_Permission_Active]...';


GO
ALTER TABLE [dbo].[Permission]
    ADD CONSTRAINT [DF_Permission_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_Module_DateCreated]...';


GO
ALTER TABLE [dbo].[Module]
    ADD CONSTRAINT [DF_Module_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_ModuleRolePermission_DateCreated]...';


GO
ALTER TABLE [dbo].[ModuleRolePermission]
    ADD CONSTRAINT [DF_ModuleRolePermission_DateCreated] DEFAULT (GETDATE()) FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_ModuleRolePermission_Active]...';


GO
ALTER TABLE [dbo].[ModuleRolePermission]
    ADD CONSTRAINT [DF_ModuleRolePermission_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Update complete.';


GO
