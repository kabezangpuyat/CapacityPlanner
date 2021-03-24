CREATE TABLE [dbo].[SegmentCategory]
(
	[ID] INT NOT NULL IDENTITY(1,1) CONSTRAINT[PK_SegmentCategory_ID] PRIMARY KEY([ID]),
	[Name] NVARCHAR(100) NOT NULL,
	[SortOrder] INT NOT NULL,
	[CreatedBy] NVARCHAR(250) NULL,
	[ModifiedBy] NVARCHAR(250) NULL,
    [DateCreated] DATETIME NOT NULL CONSTRAINT[DF_SegmentCategory_DateCreated] DEFAULT GETDATE(), 
    [DateModified] DATETIME NULL,
	[Active] BIT NOT NULL CONSTRAINT[DF_SegmentCategory_Active] DEFAULT(1),
	[Visible] BIT NOT NULL CONSTRAINT[DF_SegmentCategory_Visble] DEFAULT(1)
)
