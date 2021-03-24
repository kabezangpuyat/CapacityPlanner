/******************************
** File: Buildscript_1.00.075.sql
** Name: Buildscript_1.00.075
** Auth: McNiel Viray	
** Date: 09 November 2017
**************************
** Change History
**************************
** Added DynamicFormula and SiteCampaignLoBFormula table
** Rectify spelling of Module ID 26,28
*******************************/
USE WFMPCP


GO
PRINT N'Disabling all DDL triggers...'
GO
DISABLE TRIGGER ALL ON DATABASE
GO
PRINT N'Rename refactoring operation with key 507bede8-627e-492c-a385-4052816a95c3 is skipped, element [dbo].[SiteCampaignLobFormula].[Id] (SqlSimpleColumn) will not be renamed to ID';


GO
PRINT N'Rename refactoring operation with key 1d39bf04-b4ec-46bc-9c17-4126977582cb is skipped, element [dbo].[SiteCampaignLobFormula].[CampaingID] (SqlSimpleColumn) will not be renamed to CampaignID';


GO
PRINT N'Creating [dbo].[DynamicFormula]...';


GO
CREATE TABLE [dbo].[DynamicFormula] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (150) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NOT NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_DynamicFormula_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[SiteCampaignLobFormula]...';


GO
CREATE TABLE [dbo].[SiteCampaignLobFormula] (
    [ID]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [SiteID]           BIGINT   NOT NULL,
    [CampaignID]       BIGINT   NOT NULL,
    [LoBID]            BIGINT   NOT NULL,
    [DynamicFormulaID] BIGINT   NOT NULL,
    [DateCreated]      DATETIME NOT NULL,
    [DateModified]     DATETIME NULL,
    [Active]           BIT      NOT NULL,
    CONSTRAINT [PK_SiteCampaignLobFormula_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_DynamicFormula_DateCreated]...';


GO
ALTER TABLE [dbo].[DynamicFormula]
    ADD CONSTRAINT [DF_DynamicFormula_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_DynamicFormula_Active]...';


GO
ALTER TABLE [dbo].[DynamicFormula]
    ADD CONSTRAINT [DF_DynamicFormula_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_SiteCampaignLoBFormula_DateCreated]...';


GO
ALTER TABLE [dbo].[SiteCampaignLobFormula]
    ADD CONSTRAINT [DF_SiteCampaignLoBFormula_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_SiteCampaignLoBFormula_Active]...';


GO
ALTER TABLE [dbo].[SiteCampaignLobFormula]
    ADD CONSTRAINT [DF_SiteCampaignLoBFormula_Active] DEFAULT (1) FOR [Active];


GO
-- Refactoring step to update target server with deployed transaction logs
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '507bede8-627e-492c-a385-4052816a95c3')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('507bede8-627e-492c-a385-4052816a95c3')
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '1d39bf04-b4ec-46bc-9c17-4126977582cb')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('1d39bf04-b4ec-46bc-9c17-4126977582cb')

GO
UPDATE [Module]
SET [Name]='Campaign - Monthly Summary'
WHERE ID=28
GO
UPDATE [Module]
SET [Name]='Site - Monthly Summary'
WHERE ID=26
GO

ALTER TABLE [dbo].[DynamicFormula] ALTER COLUMN [DateModified] DATETIME NULL;
GO
INSERT INTO DynamicFormula([Name],[Description])VALUES
('DEFAULT','Default formula'),
('ERLANG','FTE requirement per week based on Service Level and Service Time'),
('STRAIGHT','Net FTE required straight line + occupancy'),
('BILLABLE (Per Hour)','Based on Deliveroo UK calculation'),
('BILLABLE (Per Unit)','Based on Uber calculation'),
('BILLABLE (Per Minute','')
GO

PRINT N'Reenabling DDL triggers...'
GO
ENABLE TRIGGER [tr_DDL_SchemaChangeLog] ON DATABASE
GO
PRINT N'Update complete.';


GO

