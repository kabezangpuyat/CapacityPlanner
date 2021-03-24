CREATE TABLE [dbo].[SiteCampaignLobFormula]
(
	[ID] BIGINT NOT NULL IDENTITY (1, 1) CONSTRAINT [PK_SiteCampaignLobFormula_ID] PRIMARY KEY([ID]), 
    [SiteID] BIGINT NOT NULL, 
    [CampaignID] BIGINT NOT NULL, 
    [LoBID] BIGINT NOT NULL, 
    [DynamicFormulaID] BIGINT NOT NULL, 
    [DateCreated] DATETIME NOT NULL CONSTRAINT [DF_SiteCampaignLoBFormula_DateCreated] DEFAULT GETDATE(), 
    [DateModified] DATETIME NULL, 
    [Active] BIT NOT NULL CONSTRAINT [DF_SiteCampaignLoBFormula_Active] DEFAULT (1)
)
