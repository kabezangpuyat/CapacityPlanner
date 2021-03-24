/******************************
** File: Buildscript_1.00.108.sql
** Name: Buildscript_1.00.108
** Auth: McNiel Viray	
** Date: 25 April 2019
**************************
** Change History
**************************
** Add new column 'MenuIcon' to table Module
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 108

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
GO

GO
PRINT N'Dropping [dbo].[DF_Module_ParentID]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF_Module_ParentID];


GO
PRINT N'Dropping unnamed constraint on [dbo].[Module]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF__tmp_ms_xx__SortO__4222D4EF];


GO
PRINT N'Dropping [dbo].[DF_Module_DateCreated]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF_Module_DateCreated];


GO
PRINT N'Dropping [dbo].[DF_Module_Active]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF_Module_Active];


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
    [FontAwesome]  NVARCHAR (100) NULL,
    [MenuIcon]     NVARCHAR (100) NULL,
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
        INSERT INTO [dbo].[tmp_ms_xx_Module] ([ID], [ParentID], [Name], [FontAwesome], [Route], [SortOrder], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified], [Active])
        SELECT   [ID],
                 [ParentID],
                 [Name],
                 [FontAwesome],
                 [Route],
                 [SortOrder],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified],
                 [Active]
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
UPDATE Module
SET MenuIcon='menu-icon fa fa-group'
WHERE ID=1
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-pencil-square-o'
WHERE  ID=2 -- Data Management
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-list-ul'
WHERE  ID=8 -- PCP Management
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-calendar'
WHERE  ID=12 -- Capacity Planner
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-eye'
WHERE  ID=17 -- Hiring Outlook
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-code'
WHERE  ID=23 -- Excess Deficit
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-support'
WHERE  ID=7 -- Help
GO
PRINT N'Update complete.';


GO



