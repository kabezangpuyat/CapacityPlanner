/******************************
** File: Buildscript_1.00.028.sql
** Name: Buildscript_1.00.028
** Auth: McNiel Viray
** Date: 07 July 2017
**************************
** Change History
**************************
** Create table [dbo].[HiringDatapoint]
** Create table [dbo].[WeeklyHiringDatapoint]
** Index for [dbo].[WeeklyHiringDatapoint]
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[HiringDatapoint]...';


GO
CREATE TABLE [dbo].[HiringDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentID]    BIGINT         NULL,
    [ReferenceID]  BIGINT         NOT NULL,
    [Name]         NVARCHAR (200) NOT NULL,
    [Datatype]     NVARCHAR (50)  NOT NULL,
    [SortOrder]    INT            NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    [Visible]      BIT            NOT NULL,
    CONSTRAINT [PK_HiringDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[WeeklyHiringDatapoint]...';


GO
CREATE TABLE [dbo].[WeeklyHiringDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Data]         NVARCHAR (200) NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [PK_WeeklyHiringDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[WeeklyHiringDatapoint].[IX_WeeklyHiringDatapoint_ByCampaignLobDatapointDataDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_WeeklyHiringDatapoint_ByCampaignLobDatapointDataDate]
    ON [dbo].[WeeklyHiringDatapoint]([CampaignID] ASC, [LoBID] ASC, [DatapointID] ASC, [Date] ASC)
    INCLUDE([Data]);


GO
PRINT N'Creating [dbo].[DF_HiringDatapoint_ReferenceID]...';


GO
ALTER TABLE [dbo].[HiringDatapoint]
    ADD CONSTRAINT [DF_HiringDatapoint_ReferenceID] DEFAULT (0) FOR [ReferenceID];


GO
PRINT N'Creating [dbo].[DF_HiringDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[HiringDatapoint]
    ADD CONSTRAINT [DF_HiringDatapoint_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_HiringDatapoint_Active]...';


GO
ALTER TABLE [dbo].[HiringDatapoint]
    ADD CONSTRAINT [DF_HiringDatapoint_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_HiringDatapoint_Visible]...';


GO
ALTER TABLE [dbo].[HiringDatapoint]
    ADD CONSTRAINT [DF_HiringDatapoint_Visible] DEFAULT (1) FOR [Visible];


GO
PRINT N'Creating [dbo].[DF_WeeklyHiringDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyHiringDatapoint]
    ADD CONSTRAINT [DF_WeeklyHiringDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Creating [dbo].[DF_WeeklyHiringDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyHiringDatapoint]
    ADD CONSTRAINT [DF_WeeklyHiringDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Update complete.';


GO
