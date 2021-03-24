/******************************
** File: Buildscript_1.00.009.sql
** Name: Buildscript_1.00.009
** Auth: McNiel Viray
** Date: 08 May 2017
**************************
** Change History
**************************
** Create data for Segment,Datapoint
*******************************/
USE WFMPCP
GO


PRINT N'Creating Segment data ....';
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Volume',1,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted Volume',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Volume',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Handled Volume',3,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'AHT',2,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Target AHT',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projected AHT',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual AHT',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projected to Actual %',4,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Headcount',3,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production HC',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting HC',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training HC',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Support HC',4,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Production Shrinkage',4,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projection based on goal',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Coaching',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Meeting',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Nesting Shrinkage',5,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projection based on goal',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'In-center Shrinkage',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Breaks',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Coaching',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Meeting',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Out-of center Shrinkage',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Unplanned',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Planned',9,'McNiel Viray')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Shrinkage Actuals',6,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Projection Based on actual trends',1,'McNiel Viray')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Occupancy',7,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Derived Occupancy',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Occupancy',2,'McNiel Viray')

GO


INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Service Metrics',8,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Service Level %',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Service Time',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual SL%',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual ST',4,'McNiel Viray')

GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'VTO',9,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Planned VTO Hours',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual VTO Hours',2,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'OT',10,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Planned OT Hours',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual OT Hours',2,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy,Visible)
VALUES(1,'Derived Schedule Constraints',11,'McNiel Viray',0)
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Derived Schedule Constraints',1,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(1,'Support Ratio to TMs',12,'McNiel Viray')

DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Team Leader',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'SMEs',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Yogis',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Trainers',4,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy,Visible)
VALUES(1,'Required Hours',13,'McNiel Viray',0)
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Required Hours',1,'McNiel Viray')
GO


--*****************************************
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Overview',1,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
		
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Total Headcount',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Billable HC',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Non-Billable HC',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production + Nesting',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production Total',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting Total',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training Total',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Temporarily Deactivated',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'RTWO',9,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Suspended',10,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'LOA/ML/Medical Leave',11,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Transfer-In',12,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Tranfer-Out',13,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Headcount',2,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Site 1',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production - Site',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting - Site',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Week 3 - Nesting',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Week 2 - Nesting',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Week 1 - Nesting',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training - Site',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Wk 1 - Training',9,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Training Information',3,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting Date',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production Date',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'New Hire Classes',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'New Capacity Hire / Scale ups',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Attrition Class /Backfill',5,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Attrition',4,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted Production Attrition',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production Attrition',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Prod Attrition',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Attrition',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Prod - Actual to Forecasted %',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted Nesting Attrition',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Nesting Attrition',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Attrition',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting - Actual to Forecasted %',9,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted Training Attrition',10,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Training Attrition',11,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Attrition',12,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Training - Actual to Forecasted %',13,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'Support Headcount',5,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'TOTAL SUPPORT COUNT',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual TL Count',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Required TL Headcount',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'WFM Recommended TL Hiring',4,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual Yogi Count',5,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Required Yogis Headcount',6,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'WFM Recommended Yogis Hiring',7,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Actual SME Count',8,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Required SME Headcount',9,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'WFM Recommended SME Hiring',10,'McNiel Viray')
GO
INSERT INTO Segment(SegmentCategoryID,Name,SortOrder,CreatedBy)
VALUES(2,'TpH',6,'McNiel Viray')
DECLARE @SegmentID BIGINT 
SELECT @SegmentID = SCOPE_IDENTITY()
	
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Target TpH',1,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Forecasted TpH',2,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Production',3,'McNiel Viray')
	INSERT INTO Datapoint(SegmentID,Name,SortOrder,CreatedBy)
	VALUES(@SegmentID,'Nesting',4,'McNiel Viray')

GO