CREATE FUNCTION [dbo].[udf_GetExcessDeficitFTE]
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
		,@plannedFTE DECIMAL(10,3) 
		,@netFTE DECIMAL(10,3)
	--'= C8 - C7
	
	SELECT @plannedFTE=[dbo].[udf_GetPlannedNetFTE](@SiteID,@CampaignID,@LobID,@Date)
	SELECT @netFTE=[dbo].[udf_GetRequiredNetFTE](@SiteID,@CampaignID,@LobID,@Date)

	SELECT @Value=@plannedFTE-@netFTE

	RETURN ISNULL(@Value,0)
END