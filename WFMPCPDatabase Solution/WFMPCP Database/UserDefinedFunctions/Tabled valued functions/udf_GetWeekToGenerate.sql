CREATE FUNCTION [dbo].[udf_GetWeekToGenerate]
(
	@DatapointTableName VARCHAR(100),
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LoBID BIGINT
)
RETURNS @returntable TABLE
(
	[Year] SMALLINT,
	[Month] VARCHAR(150),
	WeekOfYear SMALLINT,
	WeekNo  VARCHAR(100),
	WeekNoDate DATE
)
AS
BEGIN
	DELETE FROM @returntable
	IF(@DatapointTableName='ahc')
	BEGIN
		INSERT INTO @returntable([Year],[Month],WeekOfYear,WeekNo,WeekNoDate)
		SELECT [Year],[Month],WeekOfYear,WeekNo,CAST(WeekNoDate AS DATE) FROM [Week]
		WHERE LTRIM(RTRIM(WeekNoDate)) NOT IN (
			SELECT CAST(w.[Date] AS VARCHAR(12)) FROM WeeklyAHDatapoint w
			WHERE w.SiteID=@SiteID
				AND w.CampaignID=@CampaignID
				AND w.LobID=@LoBID
		)
		ORDER BY ID ASC
	END

	IF(@DatapointTableName='staffing')
	BEGIN
		INSERT INTO @returntable([Year],[Month],WeekOfYear,WeekNo,WeekNoDate)
		SELECT [Year],[Month],WeekOfYear,WeekNo,CAST(WeekNoDate AS DATE) FROM [Week]
		WHERE LTRIM(RTRIM(WeekNoDate)) NOT IN (
			SELECT CAST(w.[Date] AS VARCHAR(12)) FROM WeeklyStaffDatapoint w
			WHERE w.SiteID=@SiteID
				AND w.CampaignID=@CampaignID
				AND w.LobID=@LoBID
		)
		ORDER BY ID ASC
	END

	IF(@DatapointTableName='hiring')
	BEGIN
		INSERT INTO @returntable([Year],[Month],WeekOfYear,WeekNo,WeekNoDate)
		SELECT [Year],[Month],WeekOfYear,WeekNo,CAST(WeekNoDate AS DATE) FROM [Week]
		WHERE LTRIM(RTRIM(WeekNoDate)) NOT IN (
			SELECT CAST(w.[Date] AS VARCHAR(12)) FROM WeeklyHiringDatapoint w
			WHERE w.SiteID=@SiteID
				AND w.CampaignID=@CampaignID
				AND w.LobID=@LoBID
		)
		ORDER BY ID ASC
	END

	RETURN;
END
