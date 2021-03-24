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

/******************************
** File: Buildscript_1.00.013.sql
** Name: Buildscript_1.00.013
** Auth: McNiel Viray
** Date: 10 May 2017
**************************
** Change History
**************************
** Create data for Segment,Datapoint
** Addnew module for assumptions and headcount management
*******************************/
USE WFMPCP
GO
TRUNCATE TABLE [dbo].[Segment]
GO

PRINT N'Creating Segment data ....';
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Volume',1,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted Volume',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Volume',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Handled Volume',3,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'AHT',2,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Target AHT',1,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Projected AHT',2,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual AHT',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Projected to Actual %',4,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Headcount',3,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production HC',1,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting HC',2,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training HC',3,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Support HC',4,'McNiel Viray','Reference')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Production Shrinkage',4,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Projection based on goal',1,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Coaching',4,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Meeting',5,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training',6,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray','Not Used')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Nesting Shrinkage',5,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Projection based on goal',1,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Coaching',4,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Meeting',5,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training',6,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray','Not Used')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Shrinkage Actuals',6,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Projection Based on actual trends',1,'McNiel Viray','Reference')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Occupancy',7,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Derived Occupancy',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Occupancy',2,'McNiel Viray','Inputted')

GO


INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Service Metrics',8,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Service Level %',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Service Time',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual SL%',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual ST',4,'McNiel Viray','Not Used')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'VTO',9,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned VTO Hours',1,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual VTO Hours',2,'McNiel Viray','Not Used')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'OT',10,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned OT Hours',1,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual OT Hours',2,'McNiel Viray','Not Used')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy,Visible)
VALUES(1,'Derived Schedule Constraints',11,'McNiel Viray',0)
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Derived Schedule Constraints',1,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Support Ratio to TMs',12,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Team Leader',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'SMEs',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Yogis',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Trainers',4,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy,Visible)
VALUES(1,'Required Hours',13,'McNiel Viray',0)
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Required Hours',1,'McNiel Viray','Inputted')
GO


--*****************************************
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Overview',1,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
		
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Total Headcount',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Billable HC',2,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Non-Billable HC',3,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production + Nesting',4,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production Total',5,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting Total',6,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training Total',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Temporarily Deactivated',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'RTWO',9,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Suspended',10,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'LOA/ML/Medical Leave',11,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Transfer-In',12,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Tranfer-Out',13,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Headcount',2,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Site 1',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production - Site',2,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting - Site',3,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Week 3 - Nesting',5,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Week 2 - Nesting',6,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Week 1 - Nesting',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training - Site',8,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Wk 1 - Training',9,'McNiel Viray','Reference')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Training Information',3,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting Date',1,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production Date',2,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'New Hire Classes',3,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'New Capacity Hire / Scale ups',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Attrition Class /Backfill',5,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Attrition',4,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted Production Attrition',1,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production Attrition',2,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Prod Attrition',3,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Attrition',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Prod - Actual to Forecasted %',5,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted Nesting Attrition',6,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Nesting Attrition',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Attrition',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting - Actual to Forecasted %',9,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted Training Attrition',10,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Training Attrition',11,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Attrition',12,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training - Actual to Forecasted %',13,'McNiel Viray','Not Used')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Support Headcount',5,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'TOTAL SUPPORT COUNT',1,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual TL Count',2,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Required TL Headcount',3,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'WFM Recommended TL Hiring',4,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Yogi Count',5,'McNiel Viray','Not Used')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Required Yogis Headcount',6,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'WFM Recommended Yogis Hiring',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual SME Count',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Required SME Headcount',9,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'WFM Recommended SME Hiring',10,'McNiel Viray','Formula')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'TpH',6,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Target TpH',1,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted TpH',2,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production',3,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting',4,'McNiel Viray','Reference')

GO
INSERT INTO Module(ParentID,Name,FontAwesome,[Route],SortOrder,CreatedBy,DateCreated)
VALUES(8,'AHC Manager','fa-tag','/AssumptionsHeadcountManagement/ManageAHC',3,'McNiel Viray',GETDATE());
GO
/******************************
** File: Buildscript_1.00.014.sql
** Name: Buildscript_1.00.014
** Auth: McNiel Viray
** Date: 11 May 2017
**************************
** Change History
**************************
** Create Week table
** Create sp on creating for creating week
*******************************/
USE WFMPCP
GO
CREATE TABLE [dbo].[Week](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [smallint] NULL,
	[Month] [varchar](15) NULL,
	[WeekOfYear] [smallint] NULL,
	[WeekNo] [varchar](15) NULL,
	[WeekNoDate] [varchar](12) NULL,
	[WeekStartdate] [smalldatetime] NULL,
	[WeekEnddate] [smalldatetime] NULL,
	[FirstDayOfWeek] [varchar](10) NULL,
 CONSTRAINT [PK_week] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE PROCEDURE [dbo].[AddWeek]
@Year SMALLINT = 2017,
@StartDay VARCHAR(10)='Monday'
AS
BEGIN

	declare @DateFrom Date 
	declare @DateTo Date

	set @DateFrom = CAST(@Year AS VARCHAR(4)) + '-01-01'
	set @DateTo = CAST(@Year AS VARCHAR(4)) + '-12-31'

	INSERT INTO [Week]([Year],[Month],WeekOfYear,WeekNo,WeekNoDate,WeekStartDate,WeekEndDate,FirstDayOfWeek)
	SELECT 
		 @Year
		,CASE WHEN DATEPART(MM,AllDates) = 1 THEN 'JANUARY'
					 WHEN DATEPART(MM,AllDates) =  2 THEN 'FEBRUARY'
					 WHEN DATEPART(MM,AllDates) =  3 THEN 'MARCH'
					 WHEN DATEPART(MM,AllDates) =  4 THEN 'APRIL'
					 WHEN DATEPART(MM,AllDates) =  5 THEN 'MAY'
					 WHEN DATEPART(MM,AllDates) =  6 THEN 'JUNE'
					 WHEN DATEPART(MM,AllDates) =  7 THEN 'JULY'
					 WHEN DATEPART(MM,AllDates) =  8 THEN 'AUGUST'
					 WHEN DATEPART(MM,AllDates) =  9 THEN 'SEPTEMBER'
					 WHEN DATEPART(MM,AllDates) =  10 THEN 'OCTOBER'
					 WHEN DATEPART(MM,AllDates) =  11 THEN 'NOVEMBER'
					 WHEN DATEPART(MM,AllDates) =  12 THEN 'DECEMBER' 
				 END
		 ,DATEPART( wk, AllDates)
		 ,'Week ' + CAST(DATEPART( wk, AllDates) AS VARCHAR(5))
		 ,AllDates
		 ,CAST(AllDates AS smalldatetime)
		 ,DATEADD(DAY,6,CAST(AllDates AS smalldatetime))
		 ,@StartDay
		--,AllDates as WeekNoDate 
	FROM 
	(Select DATEADD(d, number, @dateFrom) as AllDates from master..spt_values 
	   where type = 'p' and number between 0 and datediff(dd, @dateFrom,   @dateTo)) AS D1    
	WHERE DATENAME(dw, D1.AllDates)In(@StartDay)
	--SELECT 
	--	[Year] = @Year
	--	,[Month]=CASE WHEN DATEPART(MM,AllDates) = 1 THEN 'JANUARY'
	--				 WHEN DATEPART(MM,AllDates) =  2 THEN 'FEBRUARY'
	--				 WHEN DATEPART(MM,AllDates) =  3 THEN 'MARCH'
	--				 WHEN DATEPART(MM,AllDates) =  4 THEN 'APRIL'
	--				 WHEN DATEPART(MM,AllDates) =  5 THEN 'MAY'
	--				 WHEN DATEPART(MM,AllDates) =  6 THEN 'JUNE'
	--				 WHEN DATEPART(MM,AllDates) =  7 THEN 'JULY'
	--				 WHEN DATEPART(MM,AllDates) =  8 THEN 'AUGUST'
	--				 WHEN DATEPART(MM,AllDates) =  9 THEN 'SEPTEMBER'
	--				 WHEN DATEPART(MM,AllDates) =  10 THEN 'OCTOBER'
	--				 WHEN DATEPART(MM,AllDates) =  11 THEN 'NOVEMBER'
	--				 WHEN DATEPART(MM,AllDates) =  12 THEN 'DECEMBER' 
	--			 END
	--	 ,WeekOfYear=DATEPART( wk, AllDates)
	--	 ,WeekNo='Week ' + CAST(DATEPART( wk, AllDates) AS VARCHAR(5))
	--	 ,WeekNoDate='W' + CAST(DATEPART( wk, AllDates) AS VARCHAR(5)) + ' ' + CAST(AllDates AS VARCHAR(10))
	--	 ,WeekStartDate=CAST(AllDates AS smalldatetime)
	--	 ,WeekEndDate=DATEADD(DAY,6,CAST(AllDates AS smalldatetime))
	--	 ,FirstDayOfWeek=@StartDay
	--	--,AllDates as WeekNoDate 
	--FROM 
	--(Select DATEADD(d, number, @dateFrom) as AllDates from master..spt_values 
	--   where type = 'p' and number between 0 and datediff(dd, @dateFrom,   @dateTo)) AS D1    
	--WHERE DATENAME(dw, D1.AllDates)In(@StartDay)
END
GO


EXEC AddWeek 2017,'Monday'
GO
EXEC AddWeek 2018,'Monday'
GO
EXEC AddWeek 2019,'Monday'
GO
EXEC AddWeek 2020,'Monday'
GO
EXEC AddWeek 2021,'Monday'
GO
EXEC AddWeek 2022,'Monday'
GO
EXEC AddWeek 2023,'Monday'
GO
EXEC AddWeek 2024,'Monday'
GO
CREATE PROCEDURE [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
	@lobid AS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
						FROM WeeklyAHDatapoint
						WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
						GROUP BY [Date]
						ORDER BY [Date]
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')
		
	SET @query = '
			SELECT d.Name [Datapoint Name],' + @cols + '
			FROM (
				SELECT *
				FROM
				(
					SELECT LobID,datapointid,[Date],Data from WeeklyAHDatapoint 
				) x		
				PIVOT
				(
					MAX(Data)
					FOR [Date] IN ('+ @cols +')
				)p
			) A
			INNER JOIN Datapoint d ON d.ID=A.DatapointID
			INNER JOIN Segment s ON s.ID=d.SegmentID
			INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
			WHERE a.LoBID='+ @lobid +'
			ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder
	'

	EXECUTE(@query);
END
GO
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(11,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(11,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(11,1,3,'McNiel Viray')
GO
/******************************
** File: Buildscript_1.00.015.sql
** Name: Buildscript_1.00.015
** Auth: McNiel Viray
** Date: 15 May 2017
**************************
** Change History
**************************
** update [wfmpcp_GetAssumptionsHeadcount_sp]
*******************************/
USE WFMPCP
GO
ALTER PROCEDURE [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',
	@includeDatapoint BIT = 1
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX)
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT LobID,datapointid,[Date],Data from WeeklyAHDatapoint 
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN Datapoint d ON d.ID=A.DatapointID
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT LobID,datapointid,[Date],Data from WeeklyAHDatapoint 
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN Datapoint d ON d.ID=A.DatapointID
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				WHERE 1=1 '
	END

	IF(@lobid != '')
	BEGIN
		SET @whereClause = ' AND a.LoBID=' + @lobid
	END	

	SET @orderBy = ' ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END

GO
PRINT N'Update complete.';



GO
/******************************
** File: Buildscript_1.00.016.sql
** Name: Buildscript_1.00.016
** Auth: McNiel Viray
** Date: 24 May 2017
**************************
** Change History
**************************
** Change [dbo].[WeeklyAHDatapoint] column [Data] 
** data type from Float to NVARCHAR
*******************************/
USE WFMPCP
GO
PRINT N'Altering [dbo].[WeeklyAHDatapoint]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint] ALTER COLUMN [Data] NVARCHAR (200) NOT NULL;


GO
PRINT N'Creating [dbo].[DF_WeeklyAHDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint]
    ADD CONSTRAINT [DF_WeeklyAHDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Refreshing [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_GetAssumptionsHeadcount_sp]';


GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.017.sql
** Name: Buildscript_1.00.017
** Auth: McNiel Viray
** Date: 25 May 2017
**************************
** Change History
**************************
** ADD [dbo].[Datapoint] column [ReferenceID] 
*******************************/
USE WFMPCP
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
    [ReferenceID]  BIGINT         CONSTRAINT [DF_Datapoint_ReferenceID] DEFAULT (0) NOT NULL,
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
        INSERT INTO [dbo].[tmp_ms_xx_Datapoint] ([ID], [SegmentID], [Name], [Datatype], [SortOrder], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified], [Active], [Visible])
        SELECT   [ID],
                 [SegmentID],
                 [Name],
                 [Datatype],
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
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.018.sql
** Name: Buildscript_1.00.018
** Auth: McNiel Viray
** Date: 25 May 2017
**************************
** Change History
**************************
** Create data for Segment,Datapoint
*******************************/
USE WFMPCP
GO
TRUNCATE TABLE [dbo].[Segment]
GO
TRUNCATE TABLE [dbo].[Datapoint]
GO
TRUNCATE TABLE [dbo].[WeeklyAHDatapoint]
GO




PRINT N'Creating Segment data ....';
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Service Metrics',1,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Target Service Level %',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Projected Service Level %',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Service Time',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual SL%',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual ST',5,'McNiel Viray','Inputted')
GO

INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Volume',2,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted Volume',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Volume',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Handled Volume',3,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'AHT',3,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Target AHT',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Projected AHT',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual AHT',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Goal to Target AHT',4,'McNiel Viray','Formula')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Headcount',4,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production HC',1,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting HC',2,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training HC',3,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Support HC',4,'McNiel Viray','Reference')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Projected Production Shrinkage',5,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Overall Projected Production Shrinkage',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Coaching + Meeting + Training',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'System Down Time',5,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Lost Hours',6,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Projected Nesting Shrinkage',6,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Overall Projected Nesting Shrinkage',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Coaching + Meeting + Training',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'System Down Time',5,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Lost Hours',6,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray','Inputted')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Actual Production Shrinkage',7,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Overall Projected Nesting Shrinkage',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Coaching + Meeting + Training',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'System Down Time',5,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Lost Hours',6,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray','Inputted')
	
GO

INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Actual Nesting Shrinkage',8,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Overall Projected Nesting Shrinkage',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Coaching + Meeting + Training',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'System Down Time',5,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Lost Hours',6,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray','Inputted')
	
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Shrinkage Variance',9,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Projected and Actual Shrinkage Variance',1,'McNiel Viray','Formula')

GO

INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Occupancy',10,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Derived Occupancy',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Occupancy',2,'McNiel Viray','Inputted')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Productive Hours',11,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Required Hours',1,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'VTO',12,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned VTO Hours',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual VTO Hours',2,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'OT',13,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Planned OT Hours',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual OT Hours',2,'McNiel Viray','Inputted')
GO

INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy,Visible)
VALUES(1,'Derived Schedule Constraints',14,'McNiel Viray',0)
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Derived Schedule Constraints',1,'McNiel Viray','Inputted')
GO

INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Support Ratio to TMs',15,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Team Leader',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'SMEs',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Yogis',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Trainers',4,'McNiel Viray','Inputted')
GO



--*****************************************
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Overview',1,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
		
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Total Headcount',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Billable HC',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Non-Billable HC',3,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production + Nesting',4,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production Total',5,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting Total',6,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training Total',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Temporarily Deactivated',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'RTWO',9,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Suspended',10,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'LOA/ML/Medical Leave',11,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Transfer-In',12,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Tranfer-Out',13,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Headcount',2,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Site 1',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production - Site',2,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting - Site',3,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production',4,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Week 3 - Nesting',5,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Week 2 - Nesting',6,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Week 1 - Nesting',7,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training - Site',8,'McNiel Viray','Reference')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Wk 1 - Training',9,'McNiel Viray','Reference')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Training Information',3,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training Date',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting Date',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production Date',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'New Hire Classes',4,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'New Capacity Hire / Scale ups',5,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Attrition Class /Backfill',6,'McNiel Viray','Inputted')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Attrition',4,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted Production Attrition',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Prod Attrition',2,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Attrition',3,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Prod - Actual to Forecasted %',4,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted Nesting Attrition',5,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Nesting Attrition',6,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Attrition',7,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting - Actual to Forecasted %',8,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Forecasted Training Attrition',9,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Training Attrition',10,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Attrition',11,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Training - Actual to Forecasted %',12,'McNiel Viray','Formula')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Support Headcount',5,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'TOTAL SUPPORT COUNT',1,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual TL Count',2,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Required TL Headcount',3,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'WFM Recommended TL Hiring',4,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual Yogi Count',5,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Required Yogis Headcount',6,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'WFM Recommended Yogis Hiring',7,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Actual SME Count',8,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Required SME Headcount',9,'McNiel Viray','Formula')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'WFM Recommended SME Hiring',10,'McNiel Viray','Formula')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'AHT',6,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Production AHT',1,'McNiel Viray','Inputted')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy,Datatype)
	VALUES(@SegmentID,'Nesting AHT',2,'McNiel Viray','Inputted')
GO


--CREATE DUMMY DATA 

DECLARE @ID INT
,@WeekStartDatetime SMALLDATETIME
,@WeekOfYear SMALLINT
,@CampaignID BIGINT
,@LoBID BIGINT

DECLARE week_cursor CURSOR FOR
SELECT ID, WeekStartdate, WeekOfYear FROM [Week]

OPEN week_cursor

FETCH FROM week_cursor
INTO @ID,@WeekStartDatetime,@WeekOfYear

WHILE @@FETCH_STATUS=0
BEGIN

		DECLARE lob_cursor CURSOR FOR
		SELECT ID, CampaignID FROM LoB

		OPEN lob_cursor
	
		FETCH FROM lob_cursor
		INTO @LoBID,@CampaignID

		WHILE @@FETCH_STATUS=0
		BEGIN
			INSERT INTO WeeklyAHDatapoint(CampaignID,LoBID,DatapointID,[Week],Data,[Date],CreatedBy,DateCreated)
			SELECT 
				@CampaignID
				,@LoBID
				,d.ID
				,@WeekOfYear
				,'0'--data
				,CAST(@WeekStartDatetime AS DATE)
				,'McNiel Viray'
				,GETDATE()		
			FROM Datapoint d
			INNER JOIN Segment s ON s.ID=d.SegmentID
			INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
			ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder


			FETCH NEXT FROM lob_cursor
			INTO @LoBID,@CampaignID
		END
		CLOSE lob_cursor;
		DEALLOCATE lob_cursor;

	FETCH NEXT FROM week_cursor
	INTO @ID,@WeekStartDatetime,@WeekOfYear
END
CLOSE week_cursor;
DEALLOCATE week_cursor;
GO
/******************************
** File: Buildscript_1.00.019.sql
** Name: Buildscript_1.00.019
** Auth: McNiel Viray
** Date: 06 June 2017
**************************
** Change History
**************************
** Create wfmpcp_SaveWeeklyAHDatapoint_sp
*******************************/
USE WFMPCP
GO
CREATE PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapoint_sp]
	@CampaignID BIGINT = NULL,
	@LobID BIGINT = NULL,
	@DatapointID BIGINT = NULL,
	@Data NVARCHAR(MAX) = NULL,
	@Date DATE = NULL,
	@ModifiedBy NVARCHAR(50),
	@DateModified DATETIME
AS
BEGIN
	DECLARE @Year SMALLINT
	SELECT @Year=YEAR(@Date)
	IF NOT EXISTS(SELECT ID FROM WeeklyAHDatapoint WHERE [Date]=@Date)
	BEGIN
	--create week		
		EXEC addweek @Year,'Monday'
		
		--INSERT Using cursor
		DECLARE @ID INT
		,@WeekStartDatetime SMALLDATETIME
		,@WeekOfYear SMALLINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] WHERE [Year]=@Year

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN

			--INSERT
			INSERT INTO WeeklyAHDatapoint(CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
			SELECT 
				@CampaignID
				,@LoBID
				,d.ID
				,@WeekOfYear
				,'0'--data
				,CAST(@WeekStartDatetime AS DATE)
				,@ModifiedBy
				,@DateModified		
			FROM Datapoint d

			--VALUES
			--(
			--	@CampaignID
			--	,@LobID
			--	,@DatapointID
			--	,@WeekOfYear
			--	,@Data
			--	,CAST(@WeekStartDatetime AS DATE)
			--	,@ModifiedBy
			--	,@DateModified	
			--)				
			--End INSERT	

			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
	END

	UPDATE WeeklyAHDatapoint
	SET [Data]=@Data,
		DateModified=@DateModified,
		ModifiedBy=@ModifiedBy
	WHERE CampaignID=@CampaignID
		AND LoBID=@LobID
		AND DatapointID=@DatapointID
		AND [Date] >= @Date

END
GO
/******************************
** File: Buildscript_1.00.020.sql
** Name: Buildscript_1.00.020
** Auth: McNiel Viray
** Date: 15 June 2017
**************************
** Change History
**************************
** Create Table Type for WeeklyDatapoint
** Create storedprocedure [wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
** Create Table [dbo].[WeeklyAHDatapointLog]
** Alter Procedure [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
** Create new module
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[WeeklyDatapointTableType]...';


GO
CREATE TYPE [dbo].[WeeklyDatapointTableType] AS TABLE (
    [DatapointID] BIGINT,
	[LoBID] BIGINT,
	[Date] DATE,
	[DataValue] NVARCHAR(MAX),
	[UserName] NVARCHAR(50),
	[DateModified] DATETIME
)
GO
PRINT N'Update complete.';


GO
PRINT N'Creating [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';

GO
CREATE PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
	@WeeklyDatapointTableType [dbo].[WeeklyDatapointTableType] READONLY
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		--UPDATE FIRST Related Data
		UPDATE w
		SET w.[Data]=wt.DataValue,
			w.ModifiedBy=wt.UserName,
			w.DateModified=wt.DateModified
		FROM WeeklyAHDatapoint w
		INNER JOIN @WeeklyDatapointTableType wt ON wt.DatapointID=w.DatapointID	
			AND wt.[Date]=w.[Date]
			AND wt.LoBID=w.LoBID

		--cascade to remaining data.

		DECLARE @Date DATE

		SELECT @Date = MAX([Date]) FROM @WeeklyDatapointTableType
		DECLARE @tbl AS TABLE
		(
			DatapointID BIGINT,
			LobID BIGINT,
			DataValue NVARCHAR(MAX),
			DateMofidifed DATETIME,
			ModifiedBy NVARCHAR(50)
		)

		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy)
		SELECT DatapointID,LoBID,DataValue,DateModified,UserName
		FROM @WeeklyDatapointTableType
		WHERE [Date]=@Date

		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyAHDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
		WHERE w.[Date]>@Date

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN --RollBack in case of Error

		RAISERROR(15600,-1,-1,'[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]')
	END CATCH
END

GO
PRINT N'Creating [dbo].[WeeklyAHDatapointLog]...';
GO
CREATE TABLE [dbo].[WeeklyAHDatapointLog]
(
	[ID] BIGINT NOT NULL, 
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
GO
PRINT N'Creating [dbo].[WeeklyAHDatapointLog] Update TRIGGER...';
GO
CREATE TRIGGER TRG_WeeklyAHDatapoint_Update 
	ON [dbo].[WeeklyAHDatapoint] 
	FOR UPDATE
AS
BEGIN
	INSERT [dbo].[WeeklyAHDatapointLog] (ID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,ModifiedBy,DateCreated,DateModified)
	SELECT
	   d.ID,d.CampaignID,d.LoBID,d.DatapointID,d.[Week],d.[Data],d.[Date],d.CreatedBy,d.ModifiedBy,d.DateCreated,d.DateModified
	FROM
	   DELETED d 
	--   JOIN INSERTED i ON d.ID = i.ID
	--WHERE
	--   d.[Data] <> i.[Data]
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]...';
GO
ALTER PROCEDURE [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@tablename AS NVARCHAR(MAX)='WeeklyAHDatapoint',
	@segmentcategoryid  AS NVARCHAR(MAX)='',
	@segmentid  AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT LobID,datapointid,[Date],Data from ' + @tablename + 
					' ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN Datapoint d ON d.ID=A.DatapointID
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT LobID,datapointid,[Date],Data from ' + @tablename + 
					' ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN Datapoint d ON d.ID=A.DatapointID
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				WHERE 1=1 '
	END

	IF(@segmentcategoryid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.SegmentCategoryID=' + @segmentcategoryid
	END

	IF(@segmentid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.ID=' + @segmentid
	END

	IF(@lobid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.LoBID=' + @lobid
	END	

	SET @orderBy = ' ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END


GO
PRINT 'Creating ModuleRolePermission'
GO
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,2,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,3,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,4,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(1,5,1,'McNiel Viray')

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,2,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,3,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,4,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(7,5,1,'McNiel Viray')
GO
PRINT 'Creating new Module...'
GO
UPDATE Module
SET SortOrder=5
WHERE ID=7
GO
DECLARE @ParentID BIGINT
,@ModuleID BIGINT

INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,FontAwesome)
VALUES('Capacity Planner','#',4,'McNiel Viray','fa-list-alt')

SELECT @ParentID=SCOPE_IDENTITY()

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,2,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,3,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,4,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ParentID,5,1,'McNiel Viray')

	--create child
	INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
	VALUES('Asumption and Headcount','/CapacityPlanner/AHC',1,'McNiel Viray',@ParentID,'fa-tag')
		SELECT @ModuleID = SCOPE_IDENTITY()
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,1,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,2,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,3,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,4,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,5,1,'McNiel Viray')

	INSERT INTO Module([Name],[Route],SortOrder,CreatedBy,ParentID,FontAwesome)
	VALUES('Staff Planner','/CapacityPlanner/StaffPlanner',2,'McNiel Viray',@ParentID,'fa-tag')
		SELECT @ModuleID = SCOPE_IDENTITY()
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,1,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,2,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,3,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,4,1,'McNiel Viray')
		INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
		VALUES(@ModuleID,5,1,'McNiel Viray')

GO
