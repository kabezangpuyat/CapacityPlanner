CREATE PROCEDURE [dbo].[wfmpcp_GetAllStagingAHDatapoint_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
AS
BEGIN
	SELECT 
		ID	
		,SiteID
		,CampaignID
		,LoBID
		,DatapointID
		,[Week]
		,[Data]
		,[Date]
		,CreatedBy
		,DateCreated
	FROM StagingWeeklyAHDatapoint
	WHERE SiteID=@SiteID AND CampaignID=@CampaignID AND LoBID=@LoBID
END
