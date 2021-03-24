CREATE FUNCTION [dbo].[udf_GetPlannedProdHrs]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	--C13
	DECLARE @Value DECIMAL
	

	SELECT @Value=[dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)--C14
		+[dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)--C15
		+[dbo].[udf_NestingProdHrs](@SiteID,@CampaignID,@LobID,@Date)--C16

	RETURN ISNULL(@Value,0)
END