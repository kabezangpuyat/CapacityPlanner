CREATE TABLE [dbo].[Permission]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT [PK_Permission_ID] PRIMARY KEY([ID]),
	[Name] NVARCHAR(50) NOT NULL, 
    [Description] NVARCHAR(250) NULL, 
    [CreatedBy] NVARCHAR(250) NULL, 
    [ModifiedBy] NVARCHAR(250) NULL, 
    [DateCreated] DATETIME NOT NULL CONSTRAINT[DF_Permission_DateCreated] DEFAULT(GETDATE()), 
    [DateModified] DATE NULL, 
    [Active] BIT NOT NULL CONSTRAINT[DF_Permission_Active] DEFAULT(1)
)
