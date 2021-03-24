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