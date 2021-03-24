CREATE FUNCTION [dbo].[udf_NestingProdHrs]
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
		,@ah71 DECIMAL
		,@ah44 DECIMAL
		,@ah54 DECIMAL
	

	--= [['Assumptions and Headcount'!C76]] * 40 * (1 - [['Assumptions and Headcount'!C48]]) * [['Assumptions and Headcount'!C58]]


	--Assumptions and Headcount'!C76
	--ah71
	SELECT @ah71=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,71) 

	--Assumptions and Headcount'!C48
	--ah44 %
	SELECT @ah44=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,44)/100)

	--Assumptions and Headcount'!C58
	--ah54 %
	SELECT @ah54=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)/100)


	SELECT @Value=@ah71 * 40 * (1 - @ah44) * @ah54
	RETURN ISNULL(@Value,0)
END