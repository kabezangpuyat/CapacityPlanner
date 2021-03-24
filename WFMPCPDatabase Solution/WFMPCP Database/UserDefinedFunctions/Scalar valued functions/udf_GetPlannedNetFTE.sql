CREATE FUNCTION [dbo].[udf_GetPlannedNetFTE]
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
	,@ah21 DECIMAL--datapoint 17 of AHC
	,@ah21perc DECIMAL(10,3)
	,@c2 DECIMAL(10,2) --FROM Staff planner
	
	--= (C2 *(1 - [['Assumptions and Headcount'!C21]])
	SELECT @c2=[dbo].[udf_GetCurrentGrossFTE](@SiteID,@CampaignID,@LobID,@Date)

	SELECT @ah21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ah21perc=@ah21/100

	SELECT @Value=@c2*(1-@ah21perc)

	RETURN ISNULL(@Value,0)
END