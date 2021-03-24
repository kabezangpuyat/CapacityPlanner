/******************************
** File: Buildscript_1.00.032.sql
** Name: Buildscript_1.00.032
** Auth: McNiel Viray
** Date: 10 July 2017
**************************
** Change History
**************************
** Create [dbo].[SiteCampaign]...
** Create [dbo].[SiteCampaignLob]...
** Deactive old Campaign...
** Add data to SiteCampaign table.
** Recreate camapign with duplicate..
*******************************/
USE WFMPCP
GO
PRINT N'Creating [dbo].[SiteCampaign]...';
GO
CREATE TABLE [dbo].[SiteCampaign]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT [PK_SiteCampaign_ID] PRIMARY KEY([ID]), 
	[SiteID] BIGINT NOT NULL , 
    [CampaignID] BIGINT NOT NULL,
	[Active] BIT  NOT NULL CONSTRAINT [DF_SiteCampaign_Active] DEFAULT(1)
)
GO
PRINT N'Creating [dbo].[SiteCampaignLoB]...';
GO
CREATE TABLE [dbo].[SiteCampaignLoB]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT [PK_SiteCampaignLob_ID] PRIMARY KEY([ID]), 
	[SiteID] BIGINT NOT NULL , 
    [CampaignID] BIGINT NOT NULL, 
    [LobID] BIGINT NOT NULL,
	[Active] BIT  NOT NULL CONSTRAINT [DF_SiteCampaignLob_Active] DEFAULT(1)
)
GO
PRINT N'Create SiteCampaign record for single campaign...';
GO
INSERT INTO [SiteCampaign](SiteID,CampaignID)
SELECT 
c.SiteID
,c.ID
FROM Campaign c
WHERE Name IN (
	SELECT  
		c.Name
	FROM Campaign c
	INNER JOIN [Site] s on s.ID=c.SiteID
	GROUP BY c.Name
	HAVING COUNT(c.Name)=1
)
GO
PRINT N'Deactivate old Campaign with duplicate...';
GO
UPDATE Campaign
SET Active=0
WHERE Name IN (
	SELECT  
		c.Name
	FROM Campaign c
	INNER JOIN [Site] s on s.ID=c.SiteID
	GROUP BY c.Name
	HAVING COUNT(c.Name)>1
)
GO
PRINT N'Create new Campaign...';
GO
DECLARE @CampaignID BIGINT

INSERT INTO Campaign(SiteID,Name,Code,[Description],CreatedBy,DateCreated,Active)
VALUES(0,'HUDL','HUDL','','McNiel Viray',GETDATE(),1)
SELECT @CampaignID = SCOPE_IDENTITY()
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(3,@CampaignID)
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(4,@CampaignID)

INSERT INTO Campaign(SiteID,Name,Code,[Description],CreatedBy,DateCreated,Active)
VALUES(0,'MEDIAMAX','MEDIAMAX','','McNiel Viray',GETDATE(),1)
SELECT @CampaignID = SCOPE_IDENTITY()
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(3,@CampaignID)
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(4,@CampaignID)

INSERT INTO Campaign(SiteID,Name,Code,[Description],CreatedBy,DateCreated,Active)
VALUES(0,'POSTMATES','POSTMATES','','McNiel Viray',GETDATE(),1)
SELECT @CampaignID = SCOPE_IDENTITY()
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(2,@CampaignID)
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(4,@CampaignID)

INSERT INTO Campaign(SiteID,Name,Code,[Description],CreatedBy,DateCreated,Active)
VALUES(0,'WISH','WISH','','McNiel Viray',GETDATE(),1)
SELECT @CampaignID = SCOPE_IDENTITY()
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(3,@CampaignID)
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(5,@CampaignID)
GO
PRINT N'Update complete.'
GO