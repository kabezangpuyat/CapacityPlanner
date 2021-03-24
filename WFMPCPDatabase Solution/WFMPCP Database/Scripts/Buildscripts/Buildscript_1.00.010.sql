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