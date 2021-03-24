CREATE FUNCTION [dbo].[udf_GetRequiredNetFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	,@c1 DECIMAL -- c1 of staff planner
	,@ah21 DECIMAL(10,2)--AH DatapointId = 17
    ,@ah21Perc DECIMAL(10,2)

	--c1
	--8  = [['Assumptions and Headcount'!C60]] ah56
	SELECT @c1=[dbo].[udf_Dynamic_Straight](@SiteID,@CampaignID,@LobID,@Date)--[dbo].[udf_GetGrossRequiredFTE](@SiteID,@CampaignID,@LoBID,@Date)
	SELECT @ah21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,17)
	SELECT @ah21Perc = @ah21/100
	
	SELECT @Value = @c1*(1-@ah21Perc)	

	RETURN ISNULL(@Value,0)
END