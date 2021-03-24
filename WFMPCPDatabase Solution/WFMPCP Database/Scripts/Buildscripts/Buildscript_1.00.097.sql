/******************************
** File: Buildscript_1.00.097.sql
** Name: Buildscript_1.00.097
** Auth: McNiel Viray
** Date: 31 August 2018
**************************
** Change History
**************************
** Data for mgmt_DBVersions
*******************************/
USE WFMPCP
GO

DECLARE @ctr INT = 0
WHILE @ctr < 97
BEGIN
	SET @ctr = @ctr + 1
	INSERT INTO mgmt_DbVersions(Major,Minor,Build,DeployDate,CurrentVersion,Created)
	VALUES(1,0,@ctr,GETDATE(),0,GETDATE());
END
GO
UPDATE mgmt_DbVersions
SET CurrentVersion=1
WHERE DBVersionID=(SELECT MAX(DBVersionID) FROM mgmt_DbVersions)
GO
