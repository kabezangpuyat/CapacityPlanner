/******************************
** File: Buildscript_1.00.012.sql
** Name: Buildscript_1.00.012
** Auth: McNiel Viray
** Date: 10 May 2017
**************************
** Change History
**************************
** Update datapoint table and weeklyahdatapoint
*******************************/
USE WFMPCP
GO


TRUNCATE TABLE [dbo].[Datapoint]
GO
IF EXISTS (select top 1 1 from [dbo].[Datapoint])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
/*
The column [dbo].[WeeklyAHDatapoint].[Datatype] is being dropped, data loss could occur.
*/

IF EXISTS (select top 1 1 from [dbo].[WeeklyAHDatapoint])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
PRINT N'Dropping [dbo].[DF_Datapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[Datapoint] DROP CONSTRAINT [DF_Datapoint_DateCreated];


GO
PRINT N'Dropping [dbo].[DF_Datapoint_Active]...';


GO
ALTER TABLE [dbo].[Datapoint] DROP CONSTRAINT [DF_Datapoint_Active];


GO
PRINT N'Dropping [dbo].[DF_Datapoint_Visible]...';


GO
ALTER TABLE [dbo].[Datapoint] DROP CONSTRAINT [DF_Datapoint_Visible];


GO
PRINT N'Starting rebuilding table [dbo].[Datapoint]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Datapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentID]    BIGINT         NOT NULL,
    [Name]         NVARCHAR (200) NOT NULL,
    [Datatype]     NVARCHAR (50)  NOT NULL,
    [SortOrder]    INT            NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       CONSTRAINT [DF_Datapoint_DateCreated] DEFAULT GETDATE() NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            CONSTRAINT [DF_Datapoint_Active] DEFAULT (1) NOT NULL,
    [Visible]      BIT            CONSTRAINT [DF_Datapoint_Visible] DEFAULT (1) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_Datapoint_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Datapoint])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Datapoint] ON;
        INSERT INTO [dbo].[tmp_ms_xx_Datapoint] ([ID], [SegmentID], [Name], [SortOrder], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified], [Active], [Visible])
        SELECT   [ID],
                 [SegmentID],
                 [Name],
                 [SortOrder],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified],
                 [Active],
                 [Visible]
        FROM     [dbo].[Datapoint]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Datapoint] OFF;
    END

DROP TABLE [dbo].[Datapoint];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Datapoint]', N'Datapoint';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_Datapoint_ID1]', N'PK_Datapoint_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Altering [dbo].[WeeklyAHDatapoint]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint] DROP COLUMN [Datatype];


GO
PRINT N'Update complete.';


GO

