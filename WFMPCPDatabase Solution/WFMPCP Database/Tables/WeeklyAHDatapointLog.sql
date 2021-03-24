CREATE TABLE [dbo].[WeeklyAHDatapointLog]
(
	[ID] BIGINT NOT NULL, 
	[SiteID] BIGINT NULL,
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
