CREATE PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapoint_sp]
	@CampaignID BIGINT = NULL,
	@LobID BIGINT = NULL,
	@DatapointID BIGINT = NULL,
	@Data NVARCHAR(MAX) = NULL,
	@Date DATE = NULL,
	@ModifiedBy NVARCHAR(50),
	@DateModified DATETIME
AS
BEGIN
	DECLARE @Year SMALLINT
	SELECT @Year=YEAR(@Date)
	IF NOT EXISTS(SELECT ID FROM WeeklyAHDatapoint WHERE [Date]=@Date)
	BEGIN
	--create week		
		EXEC addweek @Year,'Monday'
		
		--INSERT Using cursor
		DECLARE @ID INT
		,@WeekStartDatetime SMALLDATETIME
		,@WeekOfYear SMALLINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] WHERE [Year]=@Year

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN

			--INSERT
			INSERT INTO WeeklyAHDatapoint(CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
			SELECT 
				@CampaignID
				,@LoBID
				,d.ID
				,@WeekOfYear
				,'0'--data
				,CAST(@WeekStartDatetime AS DATE)
				,@ModifiedBy
				,@DateModified		
			FROM Datapoint d

			--VALUES
			--(
			--	@CampaignID
			--	,@LobID
			--	,@DatapointID
			--	,@WeekOfYear
			--	,@Data
			--	,CAST(@WeekStartDatetime AS DATE)
			--	,@ModifiedBy
			--	,@DateModified	
			--)				
			--End INSERT	

			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
	END

	UPDATE WeeklyAHDatapoint
	SET [Data]=@Data,
		DateModified=@DateModified,
		ModifiedBy=@ModifiedBy
	WHERE CampaignID=@CampaignID
		AND LoBID=@LobID
		AND DatapointID=@DatapointID
		AND [Date] >= @Date

END