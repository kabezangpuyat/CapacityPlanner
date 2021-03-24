/******************************
** File: Buildscript_1.00.011.sql
** Name: Buildscript_1.00.011
** Auth: McNiel Viray
** Date: 09 May 2017
**************************
** Change History
**************************
** Add new column campaignid and lobid to weeklydatapoint table
*******************************/
USE WFMPCP
GO


PRINT N'Dropping [dbo].[DF_WeeklyAHDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint] DROP CONSTRAINT [DF_WeeklyAHDatapoint_DateCreated];


GO
PRINT N'Starting rebuilding table [dbo].[WeeklyAHDatapoint]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_WeeklyAHDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Datatype]     NVARCHAR (150) NOT NULL,
    [Data]         FLOAT NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       CONSTRAINT [DF_WeeklyAHDatapoint_DateCreated] DEFAULT (getdate()) NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_WeeklyAHDatapoint_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[WeeklyAHDatapoint])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_WeeklyAHDatapoint] ON;
        INSERT INTO [dbo].[tmp_ms_xx_WeeklyAHDatapoint] ([ID], [DatapointID], [Week], [Datatype], [Data], [Date], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified])
        SELECT   [ID],
                 [DatapointID],
                 [Week],
                 [Datatype],
                 [Data],
                 [Date],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified]
        FROM     [dbo].[WeeklyAHDatapoint]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_WeeklyAHDatapoint] OFF;
    END

DROP TABLE [dbo].[WeeklyAHDatapoint];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_WeeklyAHDatapoint]', N'WeeklyAHDatapoint';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_WeeklyAHDatapoint_ID1]', N'PK_WeeklyAHDatapoint_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Update complete.';


GO
