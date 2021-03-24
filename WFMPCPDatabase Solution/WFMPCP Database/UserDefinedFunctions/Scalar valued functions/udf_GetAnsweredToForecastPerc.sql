CREATE FUNCTION [dbo].[udf_GetAnsweredToForecastPerc]
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
	
	--(ahc8-ahc6)/ahc6
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,8)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)
	
	RETURN ISNULL(@Value,0)
END