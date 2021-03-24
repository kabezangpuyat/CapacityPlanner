CREATE FUNCTION [dbo].[udf_GetTotalProductionPartTime]
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
	
	-- [['Assumptions and Headcount'!D137]]	
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,132)

	RETURN ISNULL(@Value,0)
END