/******************************
** File: Buildscript_1.00.042.sql
** Name: Buildscript_1.00.042
** Auth: McNiel Viray
** Date: 27 July 2017
**************************
** Change History
**************************
** Create [dbo].[WeeklySummaryDatapoint]
** Create [dbo].[SummaryDatapoint]
** Create stored procedure on creating Weekly Summary Datapoint([dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp])
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[SummaryDatapoint]...';


GO
CREATE TABLE [dbo].[SummaryDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentID]    BIGINT         NULL,
    [ReferenceID]  BIGINT         NOT NULL,
    [Name]         NVARCHAR (200) NOT NULL,
    [Datatype]     NVARCHAR (50)  NOT NULL,
    [SortOrder]    INT            NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    [Visible]      BIT            NOT NULL,
    CONSTRAINT [PK_SummaryDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[WeeklySummaryDatapoint]...';


GO
CREATE TABLE [dbo].[WeeklySummaryDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SiteID]       BIGINT         NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Data]         NVARCHAR (200) NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [PK_WeeklySummaryDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_SummaryDatapoint_ReferenceID]...';


GO
ALTER TABLE [dbo].[SummaryDatapoint]
    ADD CONSTRAINT [DF_SummaryDatapoint_ReferenceID] DEFAULT (0) FOR [ReferenceID];


GO
PRINT N'Creating [dbo].[DF_SummaryDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[SummaryDatapoint]
    ADD CONSTRAINT [DF_SummaryDatapoint_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_SummaryDatapoint_Active]...';


GO
ALTER TABLE [dbo].[SummaryDatapoint]
    ADD CONSTRAINT [DF_SummaryDatapoint_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_SummaryDatapoint_Visible]...';


GO
ALTER TABLE [dbo].[SummaryDatapoint]
    ADD CONSTRAINT [DF_SummaryDatapoint_Visible] DEFAULT (1) FOR [Visible];


GO
PRINT N'Creating [dbo].[DF_WeeklySummaryDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklySummaryDatapoint]
    ADD CONSTRAINT [DF_WeeklySummaryDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Creating [dbo].[DF_WeeklySummaryDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklySummaryDatapoint]
    ADD CONSTRAINT [DF_WeeklySummaryDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Creating [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]
AS
BEGIN
		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT
			,@SiteID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklySummaryDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@SiteID
							,@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM SummaryDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @SiteID,@CampaignID,@LoBID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
END
GO
PRINT N'Update complete.';


GO
