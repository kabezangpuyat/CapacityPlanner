CREATE FUNCTION [dbo].[udf_GetActualToForecastPerc]
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
	
	--(ahc7-ahc6)/ahc6
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,7)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)
	
	RETURN ISNULL(@Value,0)
END