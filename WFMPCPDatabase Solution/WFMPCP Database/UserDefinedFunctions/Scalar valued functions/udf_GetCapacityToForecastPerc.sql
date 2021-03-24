CREATE FUNCTION [dbo].[udf_GetCapacityToForecastPerc]
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
	
	-- (@ProjectedCapacity-ahc6)/ahc6	OLD
	--SELECT @Value= ([dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)

	--NEW 10.25.2017
	--c19AHC/D10AHC
	--ahc15/ahc6
	SELECT @Value=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,15),0)/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)
	RETURN ISNULL(@Value,0)
END