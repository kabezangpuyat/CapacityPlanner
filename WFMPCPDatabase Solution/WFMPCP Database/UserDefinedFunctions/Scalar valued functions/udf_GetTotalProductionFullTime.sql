CREATE FUNCTION [dbo].[udf_GetTotalProductionFullTime]
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
	
	--[['Assumptions and Headcount'!D136]]
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,131)

	RETURN ISNULL(@Value,0)
END