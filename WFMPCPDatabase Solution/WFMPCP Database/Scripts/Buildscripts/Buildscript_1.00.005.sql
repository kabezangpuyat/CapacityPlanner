/******************************
** File: Buildscript_1.00.005.sql
** Name: Buildscript_1.00.005
** Auth: McNiel Viray
** Date: 10 April 2017
**************************
** Change History
**************************
** Delete Password column in UserRole table
** Create Initial user
** Create AuditTrail table
*******************************/
USE WFMPCP
GO

IF EXISTS (select top 1 1 from [dbo].[UserRole])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
PRINT N'Altering [dbo].[UserRole]...';


GO
ALTER TABLE [dbo].[UserRole] DROP COLUMN [Password];


GO
PRINT N'Update complete.';


GO
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(1,'mv1604993','1604993','McNiel Viray',GETDATE())
GO
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(2,'mviray.admin','1234567','McNiel Viray',GETDATE())
GO
--migs
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(1,'mc1700097','1700097','McNiel Viray',GETDATE())
GO
--joms
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(2,'JC2012268','2012268','McNiel Viray',GETDATE())
GO
--ronald
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(3,'rt1604993','1604993','McNiel Viray',GETDATE())
GO
--olive
INSERT INTO UserRole(RoleID,NTLogin,EmployeeID,CreatedBy,DateCreated)
VALUES(1,'','1700017','McNiel Viray',GETDATE())
GO
CREATE TABLE [dbo].[AuditTrail]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT [PK_AuditTrail_ID] PRIMARY KEY([ID]), 
    [AuditEntry] NVARCHAR(MAX) NOT NULL, 
	[CreatedBy] NVARCHAR(40) NOT NULL,
    [DateCreated] DATETIME NOT NULL DEFAULT GETDATE(), 
    [DateModified] DATETIME NULL DEFAULT NULL
)
GO
