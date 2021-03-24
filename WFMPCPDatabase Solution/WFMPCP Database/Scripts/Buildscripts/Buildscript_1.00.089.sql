/******************************
** File: Buildscript_1.00.089.sql
** Name: Buildscript_1.00.089
** Auth: McNiel Viray
** Date: 29 June 2018
**************************
** Change History
**************************
** Create new data for Segment and Datapoint
*******************************/
USE WFMPCP
GO


DECLARE @SegmentID BIGINT
INSERT INTO Segment([Name],SortOrder,CreatedBy,SegmentCategoryID)
VALUES('Actual Prod Headcount',8,'McNiel Viray',2)

SELECT @SegmentID = SCOPE_IDENTITY()

	--CREATE Datapoint
	INSERT INTO Datapoint([Name],SortOrder,CreatedBy,SegmentID,Datatype)
	VALUES('Actual Full TIme Prod HC',1,'McNiel Viray',@SegmentID,'Inputted')
		,('Actual Part TIme Prod HC',2,'McNiel Viray',@SegmentID,'Inputted')

GO

DECLARE @SegmentID BIGINT
INSERT INTO Segment([Name],SortOrder,CreatedBy,SegmentCategoryID)
VALUES('Actual Nesting Headcount',9,'McNiel Viray',2)

SELECT @SegmentID = SCOPE_IDENTITY()

	--CREATE Datapoint
	INSERT INTO Datapoint([Name],SortOrder,CreatedBy,SegmentID,Datatype)
	VALUES('Actual Week 3 - Nesting - Full Time',1,'McNiel Viray',@SegmentID,'Inputted')
		,('Actual Week 2 - Nesting - Full Time',2,'McNiel Viray',@SegmentID,'Inputted')
		,('Actual Week 1 - Nesting - Full Time',3,'McNiel Viray',@SegmentID,'Inputted')
		,('Actual Week 3 - Nesting - Part Time',4,'McNiel Viray',@SegmentID,'Inputted')
		,('Actual Week 2 - Nesting - Part Time',5,'McNiel Viray',@SegmentID,'Inputted')
		,('Actual Week 1 - Nesting - Part Time',6,'McNiel Viray',@SegmentID,'Inputted')

GO

DECLARE @SegmentID BIGINT
INSERT INTO Segment([Name],SortOrder,CreatedBy,SegmentCategoryID)
VALUES('Actual New Hire Headcount',10,'McNiel Viray',2)

SELECT @SegmentID = SCOPE_IDENTITY()

	--CREATE Datapoint
	INSERT INTO Datapoint([Name],SortOrder,CreatedBy,SegmentID,Datatype)
	VALUES(N'Actual New Capacity Hire / Scale ups - Full Time',1,'McNiel Viray',@SegmentID,'Inputted')
		,(N'Actual New Capacity Hire / Scale ups - Part Time',2,'McNiel Viray',@SegmentID,'Inputted')
		,(N'Actual Attrition / Backfill - Full Time',3,'McNiel Viray',@SegmentID,'Inputted')
		,(N'Actual Attrition / Backfill - Part Time',4,'McNiel Viray',@SegmentID,'Inputted')

GO


DECLARE @SegmentID BIGINT
INSERT INTO Segment([Name],SortOrder,CreatedBy,SegmentCategoryID)
VALUES('Planned Prod Headcount',11,'McNiel Viray',2)

SELECT @SegmentID = SCOPE_IDENTITY()

	--CREATE Datapoint
	INSERT INTO Datapoint([Name],SortOrder,CreatedBy,SegmentID,Datatype)
	VALUES('Planned Full TIme Prod HC',1,'McNiel Viray',@SegmentID,'Formula')
		,('Planned Part TIme Prod HC',2,'McNiel Viray',@SegmentID,'Formula')

GO



DECLARE @SegmentID BIGINT
INSERT INTO Segment([Name],SortOrder,CreatedBy,SegmentCategoryID)
VALUES('Planned Nesting Headcount',12,'McNiel Viray',2)

SELECT @SegmentID = SCOPE_IDENTITY()

	--CREATE Datapoint
	INSERT INTO Datapoint([Name],SortOrder,CreatedBy,SegmentID,Datatype)
	VALUES('Planned Week 3 - Nesting - Full Time',1,'McNiel Viray',@SegmentID,'Formula')
		,('Planned Week 2 - Nesting - Full Time',2,'McNiel Viray',@SegmentID,'Formula')
		,('Planned Week 1 - Nesting - Full Time',3,'McNiel Viray',@SegmentID,'Formula')
		,('Planned Week 3 - Nesting - Part Time',4,'McNiel Viray',@SegmentID,'Formula')
		,('Planned Week 2 - Nesting - Part Time',5,'McNiel Viray',@SegmentID,'Formula')
		,('Planned Week 1 - Nesting - Part Time',6,'McNiel Viray',@SegmentID,'Formula')

GO

DECLARE @SegmentID BIGINT
INSERT INTO Segment([Name],SortOrder,CreatedBy,SegmentCategoryID)
VALUES('Planned New Hire Headcount',13,'McNiel Viray',2)

SELECT @SegmentID = SCOPE_IDENTITY()

	--CREATE Datapoint
	INSERT INTO Datapoint([Name],SortOrder,CreatedBy,SegmentID,Datatype)
	VALUES(N'Planned New Capacity Hire / Scale ups - Full Time',1,'McNiel Viray',@SegmentID,'Formula')
		,(N'Planned New Capacity Hire / Scale ups - Part Time',2,'McNiel Viray',@SegmentID,'Formula')
		,(N'Planned Attrition / Backfill - Full Time',3,'McNiel Viray',@SegmentID,'Formula')
		,(N'Planned Attrition / Backfill - Part Time',4,'McNiel Viray',@SegmentID,'Formula')

GO

