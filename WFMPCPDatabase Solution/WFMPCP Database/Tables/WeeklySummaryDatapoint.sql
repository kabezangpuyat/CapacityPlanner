CREATE TABLE [dbo].[WeeklySummaryDatapoint]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT[PK_WeeklySummaryDatapoint_ID] PRIMARY KEY([ID]), 
	[SiteID] BIGINT NULL,
	[CampaignID] BIGINT NULL,
	[LoBID] BIGINT NULL,
	[DatapointID] BIGINT NOT NULL,
    [Week] INT NOT NULL,  
    [Data] NVARCHAR(200) NOT NULL CONSTRAINT[DF_WeeklySummaryDatapoint_Data] DEFAULT(''), 
    [Date] DATE NOT NULL, 
    [CreatedBy] NVARCHAR(50) NULL, 
    [ModifiedBy] NVARCHAR(50) NULL, 
    [DateCreated] DATETIME NOT NULL CONSTRAINT[DF_WeeklySummaryDatapoint_DateCreated] DEFAULT(getdate()), 
    [DateModified] DATETIME NULL
)
