/******************************
** File: Buildscript_1.00.001.sql
** Name: Buildscript_1.00.001
** Auth: McNiel Viray
** Date: 05 April 2017
**************************
** Change History
**************************
** Initial database table(s)
** Campaign,LoB,Role,Site,UserRole
*******************************/


USE Master
GO
IF DB_ID('WFMPCP') IS NOT NULL
BEGIN
	--Make it offline
	ALTER DATABASE WFMPCP
	SET OFFLINE WITH ROLLBACK IMMEDIATE
	--Make it online so that .mdf and .ldf file will be deleted.
	ALTER DATABASE WFMPCP
	SET ONLINE WITH ROLLBACK IMMEDIATE

	DROP DATABASE WFMPCP
	CREATE DATABASE WFMPCP
END
ELSE
BEGIN
	CREATE DATABASE WFMPCP
END
GO

USE WFMPCP
GO

PRINT N'Creating [dbo].[Campaign]...';


GO
CREATE TABLE [dbo].[Campaign] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SiteID]       BIGINT         NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [Code]         NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (250) NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_Campaign_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[LoB]...';


GO
CREATE TABLE [dbo].[LoB] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [CampaignID]   BIGINT         NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [Code]         NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (250) NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_LoB_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[Role]...';


GO
CREATE TABLE [dbo].[Role] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
    [Code]         NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (250) NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_Role_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[Site]...';


GO
CREATE TABLE [dbo].[Site] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [Code]         NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (250) NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_Site_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[UserRole]...';


GO
CREATE TABLE [dbo].[UserRole] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [RoleID]       BIGINT         NOT NULL,
    [NTLogin]      NVARCHAR (50)  NOT NULL,
    [EmployeeID]   NVARCHAR (50)  NOT NULL,
    [Password]     NVARCHAR (50)  NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_UserRole_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_Campaign_DateCreated]...';


GO
ALTER TABLE [dbo].[Campaign]
    ADD CONSTRAINT [DF_Campaign_DateCreated] DEFAULT (GETDATE()) FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_Campaign_Active]...';


GO
ALTER TABLE [dbo].[Campaign]
    ADD CONSTRAINT [DF_Campaign_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_LoB_DateCreated]...';


GO
ALTER TABLE [dbo].[LoB]
    ADD CONSTRAINT [DF_LoB_DateCreated] DEFAULT (GETDATE()) FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_LoB_Active]...';


GO
ALTER TABLE [dbo].[LoB]
    ADD CONSTRAINT [DF_LoB_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_Role_DateCreated]...';


GO
ALTER TABLE [dbo].[Role]
    ADD CONSTRAINT [DF_Role_DateCreated] DEFAULT (GETDATE()) FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_Role_Active]...';


GO
ALTER TABLE [dbo].[Role]
    ADD CONSTRAINT [DF_Role_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_Site_DateCreated]...';


GO
ALTER TABLE [dbo].[Site]
    ADD CONSTRAINT [DF_Site_DateCreated] DEFAULT (GETDATE()) FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_Site_Active]...';


GO
ALTER TABLE [dbo].[Site]
    ADD CONSTRAINT [DF_Site_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_UserRole_DateCreated]...';


GO
ALTER TABLE [dbo].[UserRole]
    ADD CONSTRAINT [DF_UserRole_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating unnamed constraint on [dbo].[UserRole]...';


GO
ALTER TABLE [dbo].[UserRole]
    ADD DEFAULT 1 FOR [Active];


GO
PRINT N'Update complete.';


GO
