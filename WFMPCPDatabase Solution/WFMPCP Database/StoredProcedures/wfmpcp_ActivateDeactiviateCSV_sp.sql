CREATE PROCEDURE [dbo].[wfmpcp_ActivateDeactiviateCSV_sp]
	@Active BIT=NULL,
	@SiteID BIGINT=NULL,
	@CampaignID BIGINT=NULL,
	@LoBID BIGINT=NULL
AS
BEGIN
	UPDATE CSVRawData
	SET Active=ISNULL(@Active,Active)
	WHERE ((SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((CampaignID=@CampaignID) OR (@CampaignID IS NULL))
		AND ((LoBID=@LoBID) OR (@LoBID IS NULL))
END