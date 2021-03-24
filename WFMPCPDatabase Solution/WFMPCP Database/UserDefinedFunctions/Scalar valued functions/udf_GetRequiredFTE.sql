CREATE FUNCTION [dbo].[udf_GetRequiredFTE]
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
		,@baseHours DECIMAL

	SELECT @baseHours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @Value=@baseHours/40
		
	RETURN ISNULL(@Value,0)
END