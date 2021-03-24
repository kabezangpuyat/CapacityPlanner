CREATE TABLE [dbo].[ModuleRolePermission]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT[PK_ModuleRolePermission_ID] PRIMARY KEY([ID]),
	[ModuleID] BIGINT NOT NULL,
	[RoleID] BIGINT NOT NULL,
	[PermissionID] BIGINT NOT NULL, 
    [CreatedBy] NVARCHAR(250) NULL, 
    [ModifiedBy] NVARCHAR(250) NULL, 
    [DateCreated] DATETIME NOT NULL CONSTRAINT[DF_ModuleRolePermission_DateCreated] DEFAULT(GETDATE()), 
    [DateModified] DATETIME NULL, 
    [Active] BIT NOT NULL CONSTRAINT[DF_ModuleRolePermission_Active] DEFAULT(1)	
)
