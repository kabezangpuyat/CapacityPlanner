/******************************
** File: Buildscript_1.00.021.sql
** Name: Buildscript_1.00.021
** Auth: McNiel Viray
** Date: 20 June 2017
**************************
** Change History
**************************
** Create Table [dbo].[StaffSegment]
** Create Table [dbo].[StaffDatapoint]
** Create Table [dbo].[WeeklyStaffDatapoint]
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[StaffDatapoint]...';


GO
CREATE TABLE [dbo].[StaffDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentID]    BIGINT         NOT NULL,
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
    CONSTRAINT [PK_StaffDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[StaffSegment]...';


GO
CREATE TABLE [dbo].[StaffSegment] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentCategoryID] INT            NULL,
    [Name]              NVARCHAR (200) NOT NULL,
    [SortOrder]         INT            NOT NULL,
    [CreatedBy]         NVARCHAR (250) NULL,
    [ModifiedBy]        NVARCHAR (250) NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [DateModified]      DATETIME       NULL,
    [Active]            BIT            NOT NULL,
    [Visible]           BIT            NOT NULL,
    CONSTRAINT [PK_StaffSegment_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[WeeklyStaffDatapoint]...';


GO
CREATE TABLE [dbo].[WeeklyStaffDatapoint] (
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
    CONSTRAINT [PK_WeeklyStaffDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_StaffDatapoint_ReferenceID]...';


GO
ALTER TABLE [dbo].[StaffDatapoint]
    ADD CONSTRAINT [DF_StaffDatapoint_ReferenceID] DEFAULT (0) FOR [ReferenceID];


GO
PRINT N'Creating [dbo].[DF_StaffDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[StaffDatapoint]
    ADD CONSTRAINT [DF_StaffDatapoint_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_StaffDatapoint_Active]...';


GO
ALTER TABLE [dbo].[StaffDatapoint]
    ADD CONSTRAINT [DF_StaffDatapoint_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_StaffDatapoint_Visible]...';


GO
ALTER TABLE [dbo].[StaffDatapoint]
    ADD CONSTRAINT [DF_StaffDatapoint_Visible] DEFAULT (1) FOR [Visible];


GO
PRINT N'Creating [dbo].[DF_StaffSegment_DateCreated]...';


GO
ALTER TABLE [dbo].[StaffSegment]
    ADD CONSTRAINT [DF_StaffSegment_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_StaffSegment_Active]...';


GO
ALTER TABLE [dbo].[StaffSegment]
    ADD CONSTRAINT [DF_StaffSegment_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_StaffSegment_Visible]...';


GO
ALTER TABLE [dbo].[StaffSegment]
    ADD CONSTRAINT [DF_StaffSegment_Visible] DEFAULT (1) FOR [Visible];


GO
PRINT N'Creating [dbo].[DF_WeeklyStaffDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyStaffDatapoint]
    ADD CONSTRAINT [DF_WeeklyStaffDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Creating [dbo].[DF_WeeklyStaffDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyStaffDatapoint]
    ADD CONSTRAINT [DF_WeeklyStaffDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Update complete.';


GO
