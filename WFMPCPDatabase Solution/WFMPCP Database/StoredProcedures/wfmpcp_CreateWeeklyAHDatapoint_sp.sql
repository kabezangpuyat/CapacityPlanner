CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]
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
