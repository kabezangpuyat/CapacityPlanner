CREATE TABLE [dbo].[Campaign]
(
	[ID] BIGINT NOT NULL IDENTITY (1, 1) CONSTRAINT [PK_Campaign_ID] PRIMARY KEY([ID]), 
	[SiteID] BIGINT NOT NULL,
    [Name] NVARCHAR(250) NOT NULL,
	[Code] NVARCHAR(50) NOT NULL, 
    [Description] NVARCHAR(250) NULL, 	
	[CreatedBy] NVARCHAR(250) NULL, 
	[ModifiedBy] NVARCHAR(250) NULL, 
    [DateCreated] DATETIME NOT NULL CONSTRAINT [DF_Campaign_DateCreated] DEFAULT(GETDATE()), 
    [DateModified] DATETIME NULL, 
    [Active] BIT NOT NULL CONSTRAINT [DF_Campaign_Active] DEFAULT(1)   
)
