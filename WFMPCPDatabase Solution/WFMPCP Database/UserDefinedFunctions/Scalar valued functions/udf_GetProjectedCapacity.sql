CREATE FUNCTION [dbo].[udf_GetProjectedCapacity]
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
	,@c14 DECIMAL
	,@c15 DECIMAL
	,@c16 DECIMAL
	,@ah9 DECIMAL
	,@ah117 DECIMAL


	--= (C14 * 3600 / [['Assumptions and Headcount'!C13]]) + (C15 * 3600 / [['Assumptions and Headcount'!C13]]) + (C16 * 3600 / [['Assumptions and Headcount'!C122]])
	--C14
	SELECT @c14=[dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)
	--C15
	SELECT @c15=[dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)
	--C16
	SELECT @c16=[dbo].[udf_NestingProdHrs](@SiteID,@CampaignID,@LobID,@Date)
	

	--Assumptions and Headcount'!C13
	--ah9
	SELECT @ah9=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,9)

	--Assumptions and Headcount'!C122
	--ah117
	SELECT @ah117=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,117)

	SELECT @Value=(@c14 * 3600 / NULLIF(@ah9,0)) + (@c15 * 3600 / NULLIF(@ah9,0)) + (@c16 * 3600 / NULLIF(@ah117,0))

	RETURN ISNULL(@Value,0)
END