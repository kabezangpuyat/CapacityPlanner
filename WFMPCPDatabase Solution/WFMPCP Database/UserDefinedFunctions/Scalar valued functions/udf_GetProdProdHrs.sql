CREATE FUNCTION [dbo].[udf_GetProdProdHrs]
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
		,@ah13 DECIMAL
		,@ah17 DECIMAL
		,@ah54 DECIMAL
	
	--= (([['Assumptions and Headcount'!C17]] * 40) * (1 - [[Assumptions and Headcount!C21]]))* [['Assumptions and Headcount'!C58]]

	--Assumptions and Headcount'!C17
	--ah13
	SELECT @ah13=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,13)

	--Assumptions and Headcount!C21
	--ah17 %
	SELECT @ah17=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)/100)

	--Assumptions and Headcount'!C58
	--ah54 %
	SELECT @ah54=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)/100)

	SELECT @Value=((@ah13 * 40) * (1 - @ah17))* @ah54
		
	RETURN ISNULL(@Value,0)
END