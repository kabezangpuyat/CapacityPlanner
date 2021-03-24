/******************************
** File: Buildscript_1.00.109.sql
** Name: Buildscript_1.00.109
** Auth: McNiel Viray
** Date: 30 April 2019
**************************
** Change History
**************************
** Updated datapoint name base on the formula sheet
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 109

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
GO


UPDATE Datapoint
SET [Name]='Target Service Level %'
WHERE ID = 1
GO
UPDATE Datapoint
SET [Name]='Actual AHT'
WHERE ID = 11
GO
UPDATE Datapoint
SET [Name]='Current Production HC'
WHERE ID = 13
GO
UPDATE Datapoint
SET [Name]='Current Nesting HC'
WHERE ID = 14
GO
UPDATE Datapoint
SET [Name]='Current Training HC'
WHERE ID = 15
GO
UPDATE Datapoint
SET [Name]='Overall Actual Production Shrinkage'
WHERE ID = 35
GO
UPDATE Datapoint
SET [Name]='Overall Actual Nesting Shrinkage'
WHERE ID = 44
GO

