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