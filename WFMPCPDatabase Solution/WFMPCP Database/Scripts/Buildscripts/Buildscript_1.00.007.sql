/******************************
** File: Buildscript_1.00.007.sql
** Name: Buildscript_1.00.007
** Auth: McNiel Viray
** Date: 08 May 2017
**************************
** Change History
**************************
** Update Segment table, add foreign key of DatapointCategory
** Create table DatapointCategory
** Create table Datapoint
*******************************/
USE WFMPCP
GO

IF EXISTS (select top 1 1 from [dbo].[Segment])
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
PRINT N'Starting rebuilding table [dbo].[Segment]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Segment] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [DatapointCategoryID] INT            NULL,
    [Name]                NVARCHAR (200) NOT NULL,
    [SortOrder]           INT            NOT NULL,
    [CreatedBy]           NVARCHAR (250) NULL,
    [ModifiedBy]          NVARCHAR (250) NULL,
    [DateCreated]         DATETIME       CONSTRAINT [DF_Segment_DateCreated] DEFAULT GETDATE() NOT NULL,
    [DateModified]        DATETIME       NULL,
    [Active]              BIT            CONSTRAINT [DF_Segment_Active] DEFAULT (1) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_Segment_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Segment])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Segment] ON;
        INSERT INTO [dbo].[tmp_ms_xx_Segment] ([ID], [Name], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified], [Active])
        SELECT   [ID],
                 [Name],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified],
                 [Active]
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
PRINT N'Creating [dbo].[Datapoint]...';


GO
CREATE TABLE [dbo].[Datapoint] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [DatapointCategoryID] INT            NULL,
    [SegmentID]           BIGINT         NULL,
    [Name]                NVARCHAR (200) NOT NULL,
    [SortOrder]           INT            NOT NULL,
    [CreatedBy]           NVARCHAR (250) NULL,
    [ModifiedBy]          NVARCHAR (250) NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [DateModified]        DATETIME       NULL,
    [Active]              BIT            NOT NULL,
    CONSTRAINT [PK_Datapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DatapointCategory]...';


GO
CREATE TABLE [dbo].[DatapointCategory] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [SortOrder]    INT            NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    CONSTRAINT [PK_DatapointCategory_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_Datapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[Datapoint]
    ADD CONSTRAINT [DF_Datapoint_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_Datapoint_Active]...';


GO
ALTER TABLE [dbo].[Datapoint]
    ADD CONSTRAINT [DF_Datapoint_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_DatapointCategory_DateCreated]...';


GO
ALTER TABLE [dbo].[DatapointCategory]
    ADD CONSTRAINT [DF_DatapointCategory_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_DatapointCategory_Active]...';


GO
ALTER TABLE [dbo].[DatapointCategory]
    ADD CONSTRAINT [DF_DatapointCategory_Active] DEFAULT (1) FOR [Active];


GO

PRINT N'Creating DatapointCategory data ....';


GO
INSERT INTO DatapointCategory(Name,SortOrder,CreatedBy)
VALUES('Assumptions',1,'McNiel Viray')
INSERT INTO DatapointCategory(Name,SortOrder,CreatedBy)
VALUES('Headcount',2,'McNiel Viray')
GO