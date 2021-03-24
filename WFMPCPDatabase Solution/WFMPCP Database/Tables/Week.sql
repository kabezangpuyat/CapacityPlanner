CREATE TABLE [dbo].[Week](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [smallint] NULL,
	[Month] [varchar](15) NULL,
	[WeekOfYear] [smallint] NULL,
	[WeekNo] [varchar](15) NULL,
	[WeekNoDate] [varchar](12) NULL,
	[WeekStartdate] [smalldatetime] NULL,
	[WeekEnddate] [smalldatetime] NULL,
	[FirstDayOfWeek] [varchar](10) NULL,
 CONSTRAINT [PK_week] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]