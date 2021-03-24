/******************************
** File: Buildscript_1.xx.xxx.sql
** Name: Buildscript_1.xx.xxx
** Auth: 
** Date: 
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = x,
	@i_Build = x

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END


