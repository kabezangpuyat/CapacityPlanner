CREATE TABLE [dbo].[HiringDatapoint]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1)  CONSTRAINT [PK_HiringDatapoint_ID] PRIMARY KEY([ID]),
	[SegmentID] BIGINT NULL,
	[ReferenceID] BIGINT NOT NULL CONSTRAINT [DF_HiringDatapoint_ReferenceID] DEFAULT(0),
	[Name] NVARCHAR(200) NOT NULL,
	[Datatype] NVARCHAR(50) NOT NULL,
	[SortOrder] INT NOT NULL,
	[CreatedBy] NVARCHAR(250) NULL,
	[ModifiedBy] NVARCHAR(250) NULL,
    [DateCreated] DATETIME NOT NULL CONSTRAINT[DF_HiringDatapoint_DateCreated] DEFAULT GETDATE(), 
    [DateModified] DATETIME NULL,
	[Active] BIT NOT NULL CONSTRAINT[DF_HiringDatapoint_Active] DEFAULT(1), 
    [Visible] BIT NOT NULL CONSTRAINT[DF_HiringDatapoint_Visible] DEFAULT(1)
)
