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
