CREATE TABLE [dbo].[StaffSegment]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1)  CONSTRAINT [PK_StaffSegment_ID] PRIMARY KEY([ID]),
	[SegmentCategoryID] INT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	[SortOrder] INT NOT NULL,
	[CreatedBy] NVARCHAR(250) NULL,
	[ModifiedBy] NVARCHAR(250) NULL,
    [DateCreated] DATETIME NOT NULL CONSTRAINT[DF_StaffSegment_DateCreated] DEFAULT GETDATE(), 
    [DateModified] DATETIME NULL,
	[Active] BIT NOT NULL CONSTRAINT[DF_StaffSegment_Active] DEFAULT(1),
	[Visible] BIT NOT NULL CONSTRAINT[DF_StaffSegment_Visible] DEFAULT(1)
)
