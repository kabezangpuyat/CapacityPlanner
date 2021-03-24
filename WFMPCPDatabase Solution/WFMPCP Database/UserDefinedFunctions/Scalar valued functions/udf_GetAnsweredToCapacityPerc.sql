CREATE FUNCTION [dbo].[udf_GetAnsweredToCapacityPerc]
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
	
	--(ahc8-@ProjectedCapacity)/@ProjectedCapacity
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,8)-[dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date))/NULLIF([dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date),0)
	
	RETURN ISNULL(@Value,0)
END