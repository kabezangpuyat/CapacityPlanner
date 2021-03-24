CREATE TABLE [dbo].[StaffDatapoint]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1)  CONSTRAINT [PK_StaffDatapoint_ID] PRIMARY KEY([ID]),
	[SegmentID] BIGINT NOT NULL,
	[ReferenceID] BIGINT NOT NULL CONSTRAINT [DF_StaffDatapoint_ReferenceID] DEFAULT(0),
	[Name] NVARCHAR(200) NOT NULL,
	[Datatype] NVARCHAR(50) NOT NULL,
	[SortOrder] INT NOT NULL,
	[CreatedBy] NVARCHAR(250) NULL,
	[ModifiedBy] NVARCHAR(250) NULL,
    [DateCreated] DATETIME NOT NULL CONSTRAINT[DF_StaffDatapoint_DateCreated] DEFAULT GETDATE(), 
    [DateModified] DATETIME NULL,
	[Active] BIT NOT NULL CONSTRAINT[DF_StaffDatapoint_Active] DEFAULT(1), 
    [Visible] BIT NOT NULL CONSTRAINT[DF_StaffDatapoint_Visible] DEFAULT(1)
)
