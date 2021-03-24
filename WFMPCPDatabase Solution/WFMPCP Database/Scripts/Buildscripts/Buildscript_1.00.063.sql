/******************************
** File: Buildscript_1.00.063.sql
** Name: Buildscript_1.00.063
** Auth: McNiel Viray
** Date: 04 September 2017
**************************
** Change History
**************************
** Create staging table
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[StagingWeeklyAHDatapoint]...';


GO
CREATE TABLE [dbo].[StagingWeeklyAHDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SiteID]       BIGINT         NULL,
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
    CONSTRAINT [PK_StagingWeeklyAHDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_StagingWeeklyAHDatapoint_Data]...';


GO
ALTER TABLE [dbo].[StagingWeeklyAHDatapoint]
    ADD CONSTRAINT [DF_StagingWeeklyAHDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Creating [dbo].[DF_StagingWeeklyAHDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[StagingWeeklyAHDatapoint]
    ADD CONSTRAINT [DF_StagingWeeklyAHDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Update complete.';


GO
--CREATE NEW USERS

INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy)
VALUES
(1,'','1604825','McNiel Viray'),
(1,'','1604123','McNiel Viray'),
(1,'','1504607','McNiel Viray'),
(1,'','1505336','McNiel Viray'),
(1,'','1603065','McNiel Viray')
GO