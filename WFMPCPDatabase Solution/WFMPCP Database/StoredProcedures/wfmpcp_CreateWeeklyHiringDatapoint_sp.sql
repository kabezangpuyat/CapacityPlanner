CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]
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
