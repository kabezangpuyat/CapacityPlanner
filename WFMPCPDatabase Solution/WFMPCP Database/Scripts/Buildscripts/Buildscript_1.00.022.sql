/******************************
** File: Buildscript_1.00.022.sql
** Name: Buildscript_1.00.022
** Auth: McNiel Viray
** Date: 21 June 2017
**************************
** Change History
**************************
** Create data for [dbo].[StaffSegment]
** Create data for [dbo].[StaffDatapoint]
*******************************/
USE WFMPCP
GO

DECLARE @SegmentID BIGINT=NULL
,@DatapoinID BIGINT=NULL

INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('Headcount',1,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Required Headcount','Formula',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Current Headcount','Reference',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Excess/Deficits','Formula',3,'McNiel Viray',1,1)


INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('FTE',2,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Required FTE','Formula',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Planned FTE','Formula',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Teleopti Required FTE','Not Used',3,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Excess/Deficits','Formula',4,'McNiel Viray',1,1)


INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('HOURS',3,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Base Hours (Workload)','Formula',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Net Required Hours','Formula',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Planned Production Hrs','Formula',3,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Production Prod Hrs','Formula',4,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'SME Prod Hrs','Formula',5,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Nesting Prod Hrs','Formula',6,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Planned Training Hours','Formula',7,'McNiel Viray',1,1)



INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('VOLUME',4,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Required FTE','Reference',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Projected Capacity','Formula',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Capacity to Forecast %','Formula',3,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Actual to Forecast %','Formula',4,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Answered to Forecast %','Formula',5,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Answered to Capacity %','Formula',6,'McNiel Viray',1,1)


INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('Billable Headcount',5,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Billable Headcount','Formula',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Current Headcount','Formula',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Billable Excess/Deficits','Formula',3,'McNiel Viray',1,1)

GO