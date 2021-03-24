CREATE TABLE [dbo].[mgmt_DbVersions]
(
	[DbVersionID] [int] NOT NULL IDENTITY(1, 1),
	[Major] [int] NOT NULL,
	[Minor] [int] NOT NULL,
	[Build] [int] NOT NULL,
	[DeployDate] [datetime] NOT NULL CONSTRAINT [DF_mgmt_DbVersions_DeployDate] DEFAULT ( getdate() ),
	[CurrentVersion] [bit] NOT NULL CONSTRAINT [DF_mgmt_DbVersions_CurrentVersion] DEFAULT ( 1 ),
	[Created] [datetime] NOT NULL CONSTRAINT [DF_mgmt_DbVersions_Created] DEFAULT ( getdate() )
)
