/******************************
** File: Buildscript_1.00.048.sql
** Name: Buildscript_1.00.048
** Auth: McNiel Viray
** Date: 02 August 2017
**************************
** Change History
**************************
** Create Hiring Outlook Moduels
*******************************/
USE WFMPCP
GO


PRINT N'Create MOdule..'
UPDATE Module
SET SortOrder=6
WHERE ID=7
GO
DECLARE @ModuleID BIGINT
	,@ParentID BIGINT

INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(0,'Hiring Outlook','fa-tag','#',5,'McNiel Viray')

SELECT @ParentID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,5,1,'McNiel Viray',1)

--************************
--SUMMARY OVERALL
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Summary (Overall)','fa-tag','/HiringOutlook/SummaryOverall',1,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)


--************************
--SITE WEEKLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Site - Weekly Summary','fa-tag','/HiringOutlook/SiteWeeklySummary',2,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)


--************************
--SITE MONTHLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Site - Monhtly Summary','fa-tag','/HiringOutlook/SiteMonthlySummary',3,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)
GO