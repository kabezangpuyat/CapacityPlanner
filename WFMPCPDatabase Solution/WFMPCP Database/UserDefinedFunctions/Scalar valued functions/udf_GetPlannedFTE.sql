CREATE FUNCTION [dbo].[udf_GetPlannedFTE]
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
	
	--C13/40
	SELECT @Value=[dbo].[udf_GetPlannedProdHrs](@SiteID,@CampaignID,@LobID,@Date)/40

	RETURN ISNULL(@Value,0)
END