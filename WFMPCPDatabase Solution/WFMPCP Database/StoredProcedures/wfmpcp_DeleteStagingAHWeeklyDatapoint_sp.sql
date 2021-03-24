CREATE PROCEDURE [dbo].[wfmpcp_DeleteStagingAHWeeklyDatapoint_sp]
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT
AS
BEGIN
	DELETE FROM StagingWeeklyAHDatapoint WHERE SiteID=@SiteID AND CampaignID=@CampaignID AND LoBID=@LobID
END
