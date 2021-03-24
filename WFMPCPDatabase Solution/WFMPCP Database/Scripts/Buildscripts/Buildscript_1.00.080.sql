/******************************
** File: Buildscript_1.00.080.sql
** Name: Buildscript_1.00.080
** Auth: McNiel Viray
** Date: 28 November 2017
**************************
** Change History
**************************
** Update sequence of module Lob Manager from 3 to 4
** Create module for dynamic formula
** Create Module Role relationship
*******************************/
USE WFMPCP
GO

PRINT N'Updating Lob Manager sortorder...'
GO
UPDATE [Module]
SET SortOrder=4
WHERE ID=6;
GO

PRINT N'Creating new module for Dynamic Formula Mapping...'
GO
INSERT INTO [Module](ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy,Active)
VALUES(2,'Formula Mapping','fa-tag','/DynamicFormula/MapFormula',5,'McNiel Viray',1);
GO

DECLARE @ModuleID BIGINT
SELECT @ModuleID=ID FROM Module WHERE [Name]='Formula Mapping'
AND ParentID=2

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,1,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,1,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,1,3,'McNiel Viray')

INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,2,1,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,2,2,'McNiel Viray')
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy)
VALUES(@ModuleID,2,3,'McNiel Viray')

GO

UPDATE Segment
SET Visible=1
WHERE ID=14


GO
PRINT N'Update Complete...';
GO

