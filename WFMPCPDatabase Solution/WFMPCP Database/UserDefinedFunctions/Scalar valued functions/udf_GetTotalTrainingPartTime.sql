CREATE FUNCTION [dbo].[udf_GetTotalTrainingPartTime]
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
	,@ah140 DECIMAL
	,@ah142 DECIMAL
	
	--= = [['Assumptions and Headcount'!D145]]+[['Assumptions and Headcount'!D147]]
	--' = [['Assumptions and Headcount'!D145]]+[['Assumptions and Headcount'!D147]]

	--[['Assumptions and Headcount'!D145]]
	--140
	SELECT @ah140=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,140)

	--[['Assumptions and Headcount'!D147]]
	--142
	SELECT @ah142=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,142)

	SELECT @Value=@ah140+@ah142

	RETURN ISNULL(@Value,0)
END