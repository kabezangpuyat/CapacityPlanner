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
/******************************
** File: Buildscript_1.00.002.sql
** Name: Buildscript_1.00.002
** Auth: McNiel Viray
** Date: 05 April 2017
**************************
** Change History
**************************
** Create initial data for Site, Campaign, LoB
*******************************/
USE WFMPCP
GO

DECLARE @DateNow DATETIME = GETDATE()
	,@SiteID BIGINT
	,@CampaignID BIGINT

PRINT 'Create Site for CHR'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Chateau Ridiculous','CHR','Taskus Anonas QC','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()

	PRINT 'Create Campaign for CHR - 1. UBER'

	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'UBER','UberCHR','CHR Uber campaign','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()

		PRINT 'Create LoB for UBER CHR'

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US EATS Phone','USEATSPhone','US EATS Phone','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'EMEA EATS Phone','EMEAEATSPhone','EMEA EATS Phone','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'EMEA EATS Rider Email','EMEAEATSRiderEmail','EMEA EATS Rider Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'EMEA EATS Driver Email','EMEAEATSDriverEmail','EMEA EATS Driver Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US EATS Rider Email','USEATSRiderEmail','US EATS Rider Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US EATS Driver Email','USEATSDriverEmail','US EATS Driver Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US Driver T1_Driver Account','USDriverT1DriverAccount','US Driver T1_Driver Account','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UKI Rider T1','UKIRiderT1','UKI Rider T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UKI Driver T1','UKIDriverT1','UKI Driver T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UKI Rider T2','UKIRiderT2','UKI Rider T2','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UKI Driver T2','UKIDriverT2','UKI Driver T2','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'MENA Rider T1','MENARiderT1','MENA Rider T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SSA Rider T1','SSARiderT1','SSA Rider T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SSA Rider T2','SSARiderT2','SSA Rider T2','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZ Rider T1','ANZRiderT1','ANZ Rider T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZ Driver T1','ANZDriverT1','ANZ Driver T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZ Rider/Driver T2','ANZRiderDriverT2','ANZ Rider/Driver T2','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZDocsApprover','ANZ Docs Approver','ANZ Docs Approver','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Account','SENADriverAccount','SENA Driver Account','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Trip Questions','SENADriverTripQuestions','SENA Driver Trip Questions','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Rider Account','SENARiderAccount','SENA Rider Account','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Voice Support - PH','SENADriverVoiceSupportPH','SENA Driver Voice Support - PH','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Voice Support - LCR','SENADriverVoiceSupportLCR','SENA Driver Voice Support - LCR','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Voice Support - SG','SENADriverVoiceSupportSG','SENA Driver Voice Support - SG','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Voice Support - MY','SENADriverVoiceSupportMY','SENA Driver Voice Support - MY','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US IIT','US IIT','US IIT','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZ IIT','ANZ IIT','ANZ IIT','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA IIT','SENA IIT','SENA IIT','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA ECR','SENA ECR','SENA ECR','McNiel Viray',@DateNow)


	PRINT 'Create Campaign for CHR - 2. ADOREME'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'ADORME','ADOREMECHR','ADOREME','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		
		PRINT 'Create LoB For CHR Adorme'
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Phone','APhone','Phone','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','AEmail','Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Chat','AChat','Chat','McNiel Viray',@DateNow)

	PRINT 'Create Campaign for CHR - 3. TURO'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'TURO','TUROCHR','TURO','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		
		PRINT 'Create LoB For CHR TURO'
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'General Line','General Line','General Line','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Emergency Line and Tier 3','Emergency Line and Tier 3','Emergency Line and Tier 3','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Verifications','Verifications','Verifications','McNiel Viray',@DateNow)

PRINT 'Create Site for LBL'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('LizardBear Lair','LBL','Taskus BGC','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()

	PRINT 'Create Campaign for LBL - 1. Nimble'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'NIMBLE','NIMBLELBL','Nimble LBL','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Phone','NIMBLEPHONE','Nimble Phone','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','NIMBLEEMAIL','Nimble Email','McNiel Viray',@DateNow)
		

	PRINT 'Create Campaign for LBL - 2. Box'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'BOX','BOXLBL','BOX LBL','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Billing','BOXBILLING','Box Billing','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Tech','BOXTECH','Box tech','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Sales','BOXSALES','Box sales','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for LBL - 3. Tile'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'TILE','TILELBL','Tile Lbl','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','TILEEMAIL','Tile EMail','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Chat','TILECHAT','Tile Chat','McNiel Viray',@DateNow)
		


	PRINT 'Create Campaign for LBL - 4. PostMates'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'POSTMATES','PMLBL','PostMates LBL','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Full Time','PMFULLTIME','Postmates full time employee','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Part Time','PMPARTTIME','Postmates part time employee','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for LBL - 5. SHOPIFY'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'SHOPIFY','SHOPIFY','Shopify','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Shopify','SHOPIFYLOB','Shopify lob','McNiel Viray',@DateNow)


PRINT 'Create Site for House Teamwork'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('House Teamwork','HTM','Taskus Pampanga','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()
	
	PRINT 'Create Campaign for HTM - 1. Doordash'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'DOORDASH','DOORDAHSHTM','Doordash house teammate','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Customer Support - Chat','DDCSCHTM','','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Order Placer','DDOPTHM','Oder placer','McNiel Viray',@DateNow)


	PRINT 'Create Campaign for HTM - 2. HUDL'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'HUDL','HUDLHTM','HUDL House Teammate','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Football - Full Time','FBFTHTM','Football full time','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Football - Part Time','FBPTHTM','Football part time','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Basketball - Full Time','BBFTGTN','Basketball full time','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for HTM - 3. Wish'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'WISH','WHISHHTM','Wish HTM','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','WISHEMAIL','Wish Email HTM','McNiel Viray',@DateNow)


	PRINT 'Create Campaign for HTM - 4. MediaMax'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'MEDIAMAX','MEDIAMAXHTM','MediaMax HTM','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'MediaMax','MMHTM','MediaMax HTM','McNiel Viray',@DateNow)


PRINT 'Create Site for TaskHouse'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('TaskHouse','TH','Taskus Cavite','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()	

	PRINT 'Create Campaign for TH - 1. MediaMax'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'MEDIAMAX','MEDIAMAXTH','MediaMax TH','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'MediaMax','MMTH','MediaMax TH','McNiel Viray',@DateNow)




	PRINT 'Create Campaign for TH - 2. Postmates'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'POSTMATES','POSTMATESTH','Postmates TH','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Full Time','PMFTTH',' TH','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Part Time','PMPTTH',' TH','McNiel Viray',@DateNow)


	PRINT 'Create Campaign for TH - 3. MERCARI'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'MERCARI','MERCARITH','MERCARI TH','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Mercari CX','MERCCX','Mercar CX TH','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Content Moderation','MERCCMTH','Mercari Content Moderation TH','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for TH - 4. HUDL'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'HUDL','HUDLTH','HUDL TH','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Football - Full Time','FBFTTH','Football Full Time TH','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Football - Part Time','FBPTTH','Football part time TH','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Basketball - Full Time','BBFT','Basketball Full time TH','McNiel Viray',@DateNow)



PRINT 'Create Site for Lizzy''s Nook'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Lizzy''s Nook','LN','Taskus Cavite-Lumina','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()

	PRINT 'Create Campaign for LN - 1. WISH'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'WISH','WISHLN','WISH LN','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()	
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','EMAILLNWISH','Email WIh','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Zendesk','ZDWISHLN','Zendesk','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Content Moderation','CMWISHLN','Content moderation','McNiel Viray',@DateNow)
	
	
	
	PRINT 'Create Campaign for LN - 2. FREEDOMPOP'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'FREEDOMPOP','FREEDOMPOLN','FREEDOMPOP LN','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Service Agents','FPSALN','FPSALN','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Sales Outbound','FPSOLN','FPSOLN','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Online Services (email)','FPOSELN','FPOSELN','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Sales Inbound','FPSILN','FPSILN','McNiel Viray',@DateNow)		




	PRINT 'Create Campaign for LN - 3. SPAREFOOT'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'SPAREFOOT','SPAREFOOTLN','SPAREFOOT LN','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()	
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Sales','SFSALESLN','SFSALESLN','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Support','SFSUPPORTLN','SFSUPPORTLN','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for LN - 4. DELIVEROO'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'DELIVEROO','DELIVEROOLN','DELIVEROO LN','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()	
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'RS Outbound (SG/AU)','RSO','RS Outbound (SG/AU)','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'DS Inbound SG','DSISG','DS Inbound SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'DS Outbound AU','DSOAU','DS Outbound AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Customer Calls AU','CCAU','Customer Calls AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Restaurant Calls AU','RCAU','Restaurant Calls AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email SG','ESG','Email SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Chat SG','CSG','Chat SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email AU','EAU','Email AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Chat AU','CAU','Chat AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Customer Calls SG','CCSG','Customer Calls SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Restaurant Calls SG','RCSG','Restaurant Calls SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Driver Support - Voice','UDSV','UK Driver Support - Voice','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Restaurant Support','URS','UK Restaurant Support','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Email','UKE','UK Email','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Chat','UKC','UK Chat','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Menu Transcription','UMT','UK Menu Transcription','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Guru','UKG','UK Guru','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Driver Support - Email','UDSE','UK Driver Support - Email','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Restaurant Support - Email','UKRSE','UK Restaurant Support - Email','McNiel Viray',@DateNow)


PRINT 'Create Role'


INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Administrator','ADMN','Administrator','McNiel Viray',@DateNow)
INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Workforce','WFM','Workforce','McNiel Viray',@DateNow)
INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Operations','OPS','Operations','McNiel Viray',@DateNow)
INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Training','TRN','Training','McNiel Viray',@DateNow)
INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Recruitment','RCT','Recruitment','McNiel Viray',@DateNow)
GO
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
/******************************
** File: Buildscript_1.00.005.sql
** Name: Buildscript_1.00.005
** Auth: McNiel Viray
** Date: 10 April 2017
**************************
** Change History
**************************
** Delete Password column in UserRole table
** Create Initial user
** Create AuditTrail table
*******************************/
USE WFMPCP
GO

IF EXISTS (select top 1 1 from [dbo].[UserRole])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
PRINT N'Altering [dbo].[UserRole]...';


GO
ALTER TABLE [dbo].[UserRole] DROP COLUMN [Password];


GO
PRINT N'Update complete.';


GO
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(1,'mv1604993','1604993','McNiel Viray',GETDATE())
GO
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(2,'mviray.admin','1234567','McNiel Viray',GETDATE())
GO
--migs
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(1,'mc1700097','1700097','McNiel Viray',GETDATE())
GO
--joms
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(2,'JC2012268','2012268','McNiel Viray',GETDATE())
GO
--ronald
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(3,'rt1604993','1604993','McNiel Viray',GETDATE())
GO
--olive
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(1,'','1700017','McNiel Viray',GETDATE())
GO
CREATE TABLE [dbo].[AuditTrail]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT [PK_AuditTrail_ID] PRIMARY KEY([ID]), 
    [AuditEntry] NVARCHAR(MAX) NOT NULL, 
	[CreatedBy] NVARCHAR(40) NOT NULL,
    [DateCreated] DATETIME NOT NULL DEFAULT GETDATE(), 
    [DateModified] DATETIME NULL DEFAULT NULL
)
GO
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
/******************************
** File: Buildscript_1.00.007.sql
** Name: Buildscript_1.00.007
** Auth: McNiel Viray
** Date: 08 May 2017
**************************
** Change History
**************************
** Update Segment table, add foreign key of DatapointCategory
** Create table DatapointCategory
** Create table Datapoint
*******************************/
USE WFMPCP
GO

IF EXISTS (select top 1 1 from [dbo].[Segment])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
PRINT N'Dropping [dbo].[DF_Segment_DateCreated]...';


GO
ALTER TABLE [dbo].[Segment] DROP CONSTRAINT [DF_Segment_DateCreated];


GO
PRINT N'Dropping [dbo].[DF_Segment_Active]...';


GO
ALTER TABLE [dbo].[Segment] DROP CONSTRAINT [DF_Segment_Active];


GO
PRINT N'Starting rebuilding table [dbo].[Segment]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Segment] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [DatapointCategoryID] INT            NULL,
    [Name]                NVARCHAR (200) NOT NULL,
    [SortOrder]           INT            NOT NULL,
    [CreatedBy]           NVARCHAR (250) NULL,
    [ModifiedBy]          NVARCHAR (250) NULL,
    [DateCreated]         DATETIME       CONSTRAINT [DF_Segment_DateCreated] DEFAULT GETDATE() NOT NULL,
    [DateModified]        DATETIME       NULL,
    [Active]              BIT            CONSTRAINT [DF_Segment_Active] DEFAULT (1) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_Segment_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Segment])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Segment] ON;
        INSERT INTO [dbo].[tmp_ms_xx_Segment] ([ID], [Name], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified], [Active])
        SELECT   [ID],
                 [Name],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified],
                 [Active]
        FROM     [dbo].[Segment]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Segment] OFF;
    END

DROP TABLE [dbo].[Segment];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Segment]', N'Segment';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_Segment_ID1]', N'PK_Segment_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [dbo].[Datapoint]...';


GO
CREATE TABLE [dbo].[Datapoint] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [DatapointCategoryID] INT            NULL,
    [SegmentID]           BIGINT         NULL,
    [Name]                NVARCHAR (200) NOT NULL,
    [SortOrder]           INT            NOT NULL,
    [CreatedBy]           NVARCHAR (250) NULL,
    [ModifiedBy]          NVARCHAR (250) NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [DateModified]        DATETIME       NULL,
    [Active]              BIT            NOT NULL,
    CONSTRAINT [PK_Datapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DatapointCategory]...';


GO
CREATE TABLE [dbo].[DatapointCategory] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [SortOrder]    INT            NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_DatapointCategory_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_Datapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[Datapoint]
    ADD CONSTRAINT [DF_Datapoint_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_Datapoint_Active]...';


GO
ALTER TABLE [dbo].[Datapoint]
    ADD CONSTRAINT [DF_Datapoint_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_DatapointCategory_DateCreated]...';


GO
ALTER TABLE [dbo].[DatapointCategory]
    ADD CONSTRAINT [DF_DatapointCategory_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_DatapointCategory_Active]...';


GO
ALTER TABLE [dbo].[DatapointCategory]
    ADD CONSTRAINT [DF_DatapointCategory_Active] DEFAULT (1) FOR [Active];


GO

PRINT N'Creating DatapointCategory data ....';


GO
INSERT INTO DatapointCategory(Name,SortOrder,CreatedBy)
VALUES('Assumptions',1,'McNiel Viray')
INSERT INTO DatapointCategory(Name,SortOrder,CreatedBy)
VALUES('Headcount',2,'McNiel Viray')
GO
/******************************
** File: Buildscript_1.00.008.sql
** Name: Buildscript_1.00.008
** Auth: McNiel Viray
** Date: 08 May 2017
**************************
** Change History
**************************
** Update Datapoint table, remove column datapointcategory
** Rename table DatapointCategory to SegmentCategory
*******************************/
USE WFMPCP
GO
ALTER TABLE [dbo].[Segment]
ADD Visible BIT NOT NULL CONSTRAINT[DF_Segment_Visible] DEFAULT(1)
GO
ALTER TABLE [dbo].[Datapoint] DROP COLUMN [DatapointCategoryID] 
GO

IF EXISTS (select top 1 1 from [dbo].[Segment])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
/*
Table [dbo].[DatapointCategory] is being dropped.  Deployment will halt if the table contains data.
*/
TRUNCATE TABLE [dbo].[DatapointCategory]
GO
IF EXISTS (select top 1 1 from [dbo].[DatapointCategory])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
PRINT N'Dropping [dbo].[DF_Segment_DateCreated]...';


GO
ALTER TABLE [dbo].[Segment] DROP CONSTRAINT [DF_Segment_DateCreated];


GO
PRINT N'Dropping [dbo].[DF_Segment_Active]...';


GO
ALTER TABLE [dbo].[Segment] DROP CONSTRAINT [DF_Segment_Active];


GO
PRINT N'Dropping [dbo].[DF_Segment_Visible]...';


GO
ALTER TABLE [dbo].[Segment] DROP CONSTRAINT [DF_Segment_Visible];


GO
PRINT N'Dropping [dbo].[DF_DatapointCategory_DateCreated]...';


GO
ALTER TABLE [dbo].[DatapointCategory] DROP CONSTRAINT [DF_DatapointCategory_DateCreated];


GO
PRINT N'Dropping [dbo].[DF_DatapointCategory_Active]...';


GO
ALTER TABLE [dbo].[DatapointCategory] DROP CONSTRAINT [DF_DatapointCategory_Active];


GO
PRINT N'Dropping [dbo].[DatapointCategory]...';


GO
DROP TABLE [dbo].[DatapointCategory];


GO
PRINT N'Altering [dbo].[Datapoint]...';


GO
ALTER TABLE [dbo].[Datapoint]
    ADD [Visible] BIT CONSTRAINT [DF_Datapoint_Visible] DEFAULT (1) NOT NULL;


GO
PRINT N'Starting rebuilding table [dbo].[Segment]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Segment] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentCategoryID] INT            NULL,
    [Name]              NVARCHAR (200) NOT NULL,
    [SortOrder]         INT            NOT NULL,
    [CreatedBy]         NVARCHAR (250) NULL,
    [ModifiedBy]        NVARCHAR (250) NULL,
    [DateCreated]       DATETIME       CONSTRAINT [DF_Segment_DateCreated] DEFAULT GETDATE() NOT NULL,
    [DateModified]      DATETIME       NULL,
    [Active]            BIT            CONSTRAINT [DF_Segment_Active] DEFAULT (1) NOT NULL,
    [Visible]           BIT            CONSTRAINT [DF_Segment_Visible] DEFAULT (1) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_Segment_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Segment])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Segment] ON;
        INSERT INTO [dbo].[tmp_ms_xx_Segment] ([ID], [Name], [SortOrder], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified], [Active], [Visible])
        SELECT   [ID],
                 [Name],
                 [SortOrder],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified],
                 [Active],
                 [Visible]
        FROM     [dbo].[Segment]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Segment] OFF;
    END

DROP TABLE [dbo].[Segment];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Segment]', N'Segment';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_Segment_ID1]', N'PK_Segment_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [dbo].[SegmentCategory]...';


GO
CREATE TABLE [dbo].[SegmentCategory] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [SortOrder]    INT            NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    [Visible]      BIT            NOT NULL,
    CONSTRAINT [PK_SegmentCategory_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_SegmentCategory_DateCreated]...';


GO
ALTER TABLE [dbo].[SegmentCategory]
    ADD CONSTRAINT [DF_SegmentCategory_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_SegmentCategory_Active]...';


GO
ALTER TABLE [dbo].[SegmentCategory]
    ADD CONSTRAINT [DF_SegmentCategory_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_SegmentCategory_Visble]...';


GO
ALTER TABLE [dbo].[SegmentCategory]
    ADD CONSTRAINT [DF_SegmentCategory_Visble] DEFAULT (1) FOR [Visible];


GO
PRINT N'Update complete.';


GO

PRINT N'Creating SegmentCategory data ....';


GO
INSERT INTO SegmentCategory(Name,SortOrder,CreatedBy)
VALUES('Assumptions',1,'McNiel Viray')
INSERT INTO SegmentCategory(Name,SortOrder,CreatedBy)
VALUES('Headcount',2,'McNiel Viray')
GO
/******************************
** File: Buildscript_1.00.009.sql
** Name: Buildscript_1.00.009
** Auth: McNiel Viray
** Date: 08 May 2017
**************************
** Change History
**************************
** Create data for Segment,Datapoint
*******************************/
USE WFMPCP
GO


PRINT N'Creating Segment data ....';
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Volume',1,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted Volume',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Volume',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Handled Volume',3,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'AHT',2,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Target AHT',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projected AHT',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual AHT',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projected to Actual %',4,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Headcount',3,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production HC',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting HC',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training HC',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Support HC',4,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Production Shrinkage',4,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projection based on goal',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Coaching',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Meeting',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Nesting Shrinkage',5,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projection based on goal',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Coaching',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Meeting',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Shrinkage Actuals',6,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projection Based on actual trends',1,'McNiel Viray')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Occupancy',7,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Derived Occupancy',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Occupancy',2,'McNiel Viray')

GO


INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Service Metrics',8,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Service Level %',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Service Time',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual SL%',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual ST',4,'McNiel Viray')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'VTO',9,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Planned VTO Hours',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual VTO Hours',2,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'OT',10,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Planned OT Hours',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual OT Hours',2,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy,Visible)
VALUES(1,'Derived Schedule Constraints',11,'McNiel Viray',0)
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Derived Schedule Constraints',1,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Support Ratio to TMs',12,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Team Leader',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'SMEs',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Yogis',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Trainers',4,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy,Visible)
VALUES(1,'Required Hours',13,'McNiel Viray',0)
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Required Hours',1,'McNiel Viray')
GO


--*****************************************
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Overview',1,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
		
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Total Headcount',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Billable HC',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Non-Billable HC',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production + Nesting',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production Total',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting Total',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training Total',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Temporarily Deactivated',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'RTWO',9,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Suspended',10,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'LOA/ML/Medical Leave',11,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Transfer-In',12,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Tranfer-Out',13,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Headcount',2,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Site 1',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production - Site',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting - Site',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Week 3 - Nesting',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Week 2 - Nesting',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Week 1 - Nesting',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training - Site',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Wk 1 - Training',9,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Training Information',3,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting Date',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production Date',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'New Hire Classes',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'New Capacity Hire / Scale ups',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Attrition Class /Backfill',5,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Attrition',4,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted Production Attrition',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production Attrition',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Prod Attrition',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Attrition',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Prod - Actual to Forecasted %',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted Nesting Attrition',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Nesting Attrition',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Attrition',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting - Actual to Forecasted %',9,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted Training Attrition',10,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Training Attrition',11,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Attrition',12,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training - Actual to Forecasted %',13,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Support Headcount',5,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'TOTAL SUPPORT COUNT',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual TL Count',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Required TL Headcount',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'WFM Recommended TL Hiring',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Yogi Count',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Required Yogis Headcount',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'WFM Recommended Yogis Hiring',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual SME Count',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Required SME Headcount',9,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'WFM Recommended SME Hiring',10,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'TpH',6,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Target TpH',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted TpH',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting',4,'McNiel Viray')

GO
/******************************
** File: Buildscript_1.00.010.sql
** Name: Buildscript_1.00.010
** Auth: McNiel Viray
** Date: 09 May 2017
**************************
** Change History
**************************
** Create data for Segment,Datapoint
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[WeeklyAHDatapoint]...';


GO
CREATE TABLE [dbo].[WeeklyAHDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Datatype]     NVARCHAR (150) NOT NULL,
    [Data]         NVARCHAR (200) NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [PK_WeeklyAHDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_WeeklyAHDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint]
    ADD CONSTRAINT [DF_WeeklyAHDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Update complete.';


GO