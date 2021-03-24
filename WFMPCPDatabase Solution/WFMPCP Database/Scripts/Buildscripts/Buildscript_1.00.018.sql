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