CREATE FUNCTION [dbo].[udf_GetExcessDeficitHC]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
		,@currentHC DECIMAL
		,@requiredHC DECIMAL

		SELECT @requiredHC = [dbo].[udf_GetGrossRequiredFTE](@SiteID,@CampaignID,@LoBID,@Date)--StaffDatapointID: 1
		SELECT @currentHC =	[dbo].[udf_GetCurrentGrossFTE](@SiteID,@CampaignID,@LoBID,@Date)--StaffDatapointID: 2

		SELECT @Value=@currentHC-@requiredHC
		
	RETURN ISNULL(@Value,0)
END