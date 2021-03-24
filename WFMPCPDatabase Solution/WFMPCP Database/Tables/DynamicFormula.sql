CREATE TABLE [dbo].[DynamicFormula]
(
	[ID] BIGINT NOT NULL IDENTITY (1, 1) CONSTRAINT [PK_DynamicFormula_ID] PRIMARY KEY([ID]), 
    [Name] NVARCHAR(50) NOT NULL, 
    [Description] NVARCHAR(150) NULL, 
    [DateCreated] DATETIME NOT NULL CONSTRAINT [DF_DynamicFormula_DateCreated] DEFAULT GETDATE(), 
    [DateModified] DATETIME NULL, 
    [Active] BIT NOT NULL CONSTRAINT [DF_DynamicFormula_Active] DEFAULT (1)
)
