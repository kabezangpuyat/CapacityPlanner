/******************************
** File: Buildscript_1.00.062.sql
** Name: Buildscript_1.00.062
** Auth: McNiel Viray
** Date: 17 August 2017
**************************
** Change History
**************************
** add module permission to wfm role
*******************************/
USE WFMPCP
GO

--add module(PCP Management>AHC Manager) to WFM role
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(8,2,1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(8,2,2)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(8,2,3)


INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(11,2,1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(11,2,2)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID)
VALUES(11,2,3)
GO
UPDATE Datapoint
SET Name='Attrition / Backfill'
WHERE ID=93
GO