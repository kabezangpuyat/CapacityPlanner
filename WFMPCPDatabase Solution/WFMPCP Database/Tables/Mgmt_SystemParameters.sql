CREATE TABLE [dbo].[mgmt_SystemParameters]
(
	[SystemParameterId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255)  NOT NULL,
	[Value] [nvarchar](4000) NOT NULL,
	[Description] [nvarchar](2000) NULL,
	[DeployDate] [datetime] NOT NULL CONSTRAINT [DF_mgmt_SystemParameters_DeployDate] DEFAULT ( getdate() ),
	[Created] [datetime] NOT NULL CONSTRAINT [DF_mgmt_SystemParameters_Created] DEFAULT ( getdate() )
)