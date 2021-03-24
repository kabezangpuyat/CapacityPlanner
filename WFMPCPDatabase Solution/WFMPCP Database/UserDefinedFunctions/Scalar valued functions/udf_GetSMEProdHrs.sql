CREATE FUNCTION [dbo].[udf_GetSMEProdHrs]
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
	,@ah113 DECIMAL
	,@ah17 DECIMAL
	,@ah54 DECIMAL

	--= (([['Assumptions and Headcount'!C118]] * 20) * (1 - [[Assumptions and Headcount!C21]]))* [['Assumptions and Headcount'!C58]]

	--Assumptions and Headcount'!C118
	--ah113
	SELECT @ah113=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,113)

	--Assumptions and Headcount!C21
	--ah17 %
	SELECT @ah17=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,58)/100)

	--Assumptions and Headcount'!C58
	--ah54 %
	SELECT @ah54=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,58)/100)

	SELECT @Value=((@ah113 * 20) * (1 - @ah17))* @ah54
		
	RETURN ISNULL(@Value,0)
END