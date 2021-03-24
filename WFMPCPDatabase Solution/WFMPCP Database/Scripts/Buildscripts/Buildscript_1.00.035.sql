/******************************
** File: Buildscript_1.00.035.sql
** Name: Buildscript_1.00.035
** Auth: McNiel Viray
** Date: 11 July 2017
**************************
** Change History
**************************
** Update wfmpcp_CreateWeeklyAHDatapoint_sp and wfmpcp_CreateWeeklyStaffDatapoint_sp
** Create wfmpcp_CreateWeeklyHiringDatapoint_sp
** Truncate table WeeklyAHDatapoint and WeeklyStaffDatapoint
** Create data to table(s) WeeklyAHDatapoint, WeeklyStaffDatapoint,WeeklyStaffDatapoint
*******************************/
USE WFMPCP
GO
PRINT N'Truncate table WeeklyAHDatapoint and WeeklyStaffDatapoint ...'
GO
TRUNCATE TABLE WeeklyAHDatapoint
TRUNCATE TABLE WeeklyStaffDatapoint
TRUNCATE TABLE WeeklyHiringDatapoint
GO

PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]
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
			SELECT ID, CampaignID, LoBID, SiteID FROM SiteCampaignLoB
			--SELECT ID, CampaignID FROM LoB

			OPEN lob_cursor
	
			FETCH FROM lob_cursor
			INTO @ID,@LoBID,@CampaignID,@SiteID

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
				INTO @ID,@LoBID,@CampaignID,@SiteID
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
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]
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
				SELECT ID, CampaignID, LoBID, SiteID FROM SiteCampaignLoB
				ORDER BY ID

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @ID,@LoBID,@CampaignID,@SiteID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyStaffDatapoint(CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@CampaignID
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
					INTO @ID,@LoBID,@CampaignID,@SiteID
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
PRINT N'Creating [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]
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
				SELECT ID, CampaignID, LoBID, SiteID FROM SiteCampaignLoB
				ORDER BY ID

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @ID,@LoBID,@CampaignID,@SiteID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyHiringDatapoint(CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@CampaignID
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
					INTO @ID,@LoBID,@CampaignID,@SiteID
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
PRINT N'Creating data to WeeklyAHDatapoint...';
GO
EXEC wfmpcp_CreateWeeklyAHDatapoint_sp
GO
PRINT N'Creating data to WeeklyStaffDataoint...';
GO
EXEC wfmpcp_CreateWeeklyStaffDatapoint_sp
GO
PRINT N'Creating data to WeeklyHiringDatapoint...'
GO
EXEC wfmpcp_CreateWeeklyHiringDatapoint_sp

GO
PRINT N'Update complete.';


GO
