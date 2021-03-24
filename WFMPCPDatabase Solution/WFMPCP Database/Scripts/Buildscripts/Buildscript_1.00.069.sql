/******************************
** File: Buildscript_1.00.069.sql
** Name: Buildscript_1.00.069
** Auth: McNiel Viray
** Date: 25 September 2017
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]
	@SID BIGINT = NULL,
	@CID BIGINT = NULL,
	@LID BIGINT = NULL
AS
BEGIN

	DECLARE @ID INT
	,@WeekStartDatetime SMALLDATETIME
	,@WeekOfYear SMALLINT
	,@CampaignID BIGINT
	,@LoBID BIGINT
	,@SiteID BIGINT

	DECLARE week_cursor CURSOR FOR
	SELECT ID, WeekStartdate, WeekOfYear FROM [Week]

	OPEN week_cursor

	FETCH FROM week_cursor
	INTO @ID,@WeekStartDatetime,@WeekOfYear

	WHILE @@FETCH_STATUS=0
	BEGIN

			DECLARE lob_cursor CURSOR FOR
			SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB
			WHERE ((SiteID=@SID) OR (@SID IS NULL))
				AND ((CampaignID=@CID) OR (@CID IS NULL))
				AND ((LobID=@LID) OR (@LID IS NULL))
			--SELECT ID, CampaignID FROM LoB

			OPEN lob_cursor
	
			FETCH FROM lob_cursor
			INTO @SiteID,@CampaignID,@LoBID

			WHILE @@FETCH_STATUS=0
			BEGIN
				INSERT INTO WeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],Data,[Date],CreatedBy,DateCreated)
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
				FROM Datapoint d
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder


				FETCH NEXT FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID
			END
			CLOSE lob_cursor;
			DEALLOCATE lob_cursor;

		FETCH NEXT FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear
	END
	CLOSE week_cursor;
	DEALLOCATE week_cursor;

END
GO
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]
	@SID BIGINT = NULL,
	@CID BIGINT = NULL,
	@LID BIGINT = NULL
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
				WHERE ((SiteID=@SID) OR (@SID IS NULL))
					AND ((CampaignID=@CID) OR (@CID IS NULL))
					AND ((LobID=@LID) OR (@LID IS NULL))

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyHiringDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
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
						FROM HiringDatapoint d
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
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]
	@SID BIGINT = NULL,
	@CID BIGINT = NULL,
	@LID BIGINT = NULL
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
				WHERE ((SiteID=@SID) OR (@SID IS NULL))
					AND ((CampaignID=@CID) OR (@CID IS NULL))
					AND ((LobID=@LID) OR (@LID IS NULL))

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyStaffDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
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
						FROM StaffDatapoint d
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
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]
	@SID BIGINT = NULL,
	@CID BIGINT = NULL,
	@LID BIGINT = NULL
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
				WHERE ((SiteID=@SID) OR (@SID IS NULL))
					AND ((CampaignID=@CID) OR (@CID IS NULL))
					AND ((LobID=@LID) OR (@LID IS NULL))

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
PRINT N'Creating [dbo].[wfmpcp_CreateWeeklyDatapoints_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklyDatapoints_sp]
	@SiteID BIGINT 
	,@CampaignID BIGINT 
	,@LobID BIGINT 
AS
BEGIN
	--Check if not exists in [dbo].[WeeklyAHDatapoint]
	IF NOT EXISTS(SELECT ID FROM [dbo].[WeeklyAHDatapoint] WHERE SiteID=@SiteID AND 
		CampaignID=@CampaignID AND LobID=@LobID)
	BEGIN 
		EXEC [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp] @SiteID,@CampaignID,@LobID
	END
	--Check if not exists in [dbo].[WeeklyHiringDatapoint]
	IF NOT EXISTS(SELECT ID FROM [dbo].[WeeklyHiringDatapoint] WHERE SiteID=@SiteID AND 
		CampaignID=@CampaignID AND LobID=@LobID)
	BEGIN 
		EXEC [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp] @SiteID,@CampaignID,@LobID
	END
	--Check if not exists in [dbo].[WeeklyStaffDatapoint]
	IF NOT EXISTS(SELECT ID FROM [dbo].[WeeklyStaffDatapoint] WHERE SiteID=@SiteID AND 
		CampaignID=@CampaignID AND LobID=@LobID)
	BEGIN 
		EXEC [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp] @SiteID,@CampaignID,@LobID
	END
	--Check if not exists in [dbo].[WeeklySummaryDatapoint]
	IF NOT EXISTS(SELECT ID FROM [dbo].[WeeklySummaryDatapoint] WHERE SiteID=@SiteID AND 
		CampaignID=@CampaignID AND LobID=@LobID)
	BEGIN 
		EXEC [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp] @SiteID,@CampaignID,@LobID
	END
END
GO
PRINT N'Update complete.';


GO
