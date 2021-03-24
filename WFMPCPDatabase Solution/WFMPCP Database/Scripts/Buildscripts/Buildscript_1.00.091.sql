/******************************
** File: Buildscript_1.00.091.sql
** Name: Buildscript_1.00.091
** Auth: McNiel Viray
** Date: 24 July 2018
**************************
** Change History
**************************
** Add new StaffDatapoint
** Update name of StaffDatapoint
*******************************/
USE WFMPCP
GO

UPDATE StaffDatapoint
SET [Name]='Gross Required FTE'
WHERE ID=1-- old: Required Headcount
GO

UPDATE StaffDatapoint
SET [Name]='Current  Gross FTE'
WHERE ID=2-- old: Current Headcount
GO

UPDATE StaffDatapoint
SET [Name]='Required Net FTE'
WHERE ID=4 -- old: Required FTE
GO

UPDATE StaffDatapoint
SET [Name]='Planned Net FTE'
WHERE ID=5 -- old: Planned FTE
GO

UPDATE StaffDatapoint
SET [Name]='Gross Required Hours'
WHERE ID=9 -- old: Net Required Hours
GO

UPDATE StaffDatapoint
SET [Name]='Production Prod Hrs'
WHERE ID=11 -- old: Production Prod Hrs
GO

UPDATE StaffDatapoint
SET [Name]='SME Prod Hrs'
WHERE ID=12 -- old: SME Prod Hrs
GO

UPDATE StaffDatapoint
SET [Name]='Nesting Prod Hrs'
WHERE ID=13 -- old: Nesting Prod Hrs
GO

UPDATE StaffDatapoint
SET [Name]='Planned Training Hours'
WHERE ID=14 -- old: Planned Training Hours
GO

UPDATE StaffDatapoint
SET [Name]='Projected Capacity'
WHERE ID=16 -- old: Projected Capacity
GO

-- Add new staff datapoint
--**************
--SEGMENT Staff and Datapoint
--**************

DECLARE @SegmentID BIGINT

INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('Head Count Details',6,'McNiel Viray',1,1)

SELECT @SegmentID = SCOPE_IDENTITY()

	INSERT INTO StaffDatapoint([Name],SortOrder,CreatedBy,SegmentID,Datatype)
	VALUES('Total Production Full Time',1,'McNiel Viray',@SegmentID,'Formula')
		,('Total Production Part Time',2,'McNiel Viray',@SegmentID,'Formula')
		,('Total Nesting Full Time',3,'McNiel Viray',@SegmentID,'Formula')
		,('Total Nesting Part Time',4,'McNiel Viray',@SegmentID,'Formula')
		,('Total Training Full Time',5,'McNiel Viray',@SegmentID,'Formula')
		,('Total Training Part Time',6,'McNiel Viray',@SegmentID,'Formula')
GO



