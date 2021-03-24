/*
The database must have a MEMORY_OPTIMIZED_DATA filegroup
before the memory optimized object can be created.
*/

CREATE TYPE [dbo].[WeeklyDatapointTableType] AS TABLE (
    [DatapointID] BIGINT,
	[SiteID] BIGINT,
	[CampaignID] BIGINT,
	[LoBID] BIGINT,
	[Date] DATE,
	[DataValue] NVARCHAR(MAX),
	[UserName] NVARCHAR(50),
	[DateModified] DATETIME
)