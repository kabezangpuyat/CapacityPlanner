CREATE FUNCTION [dbo].[udf_GetCurrentGrossFTE]
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
	,@c28 DECIMAL
	,@c29 DECIMAL
	,@c30 DECIMAL
	,@c31 DECIMAL
	,@ah30 DECIMAL
	,@ah17 DECIMAL
	,@ah116 DECIMAL
	,@ah117 DECIMAL
    ,@ah30perc DECIMAL(10,2)
    ,@ah17perc DECIMAL(10,2)

	--(C28+(C29*0.5))+((C30+(C31*0.5))*(((1 - [['Assumptions and Headcount'!C43]])/(1 - [['Assumptions and Headcount'!C21]]))*(([['Assumptions and Headcount'!C121]])/([['Assumptions and Headcount'!C122]]))))
    --(@c28+(@c29*0.5))+((@c30+(@c31*0.5))*())
	--C28
	--24
	SELECT @c28=[dbo].[udf_GetTotalProductionFullTime](@SiteID,@CampaignID,@LoBID,@Date)
	
	--C29
	--25
	SELECT @c29=[dbo].[udf_GetTotalProductionPartTime](@SiteID,@CampaignID,@LoBID,@Date)

	--C30
	--26
	SELECT @c30=[dbo].[udf_GetTotalNestingFullTime](@SiteID,@CampaignID,@LoBID,@Date)

	--C31
	--27
	SELECT @c31=[dbo].[udf_GetTotalNestingPartTime](@SiteID,@CampaignID,@LoBID,@Date)

	--Assumptions and Headcount'!C30
	--26   %
	SELECT @ah30=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,26),0)
	SELECT @ah30perc = @ah30/100

	--Assumptions and Headcount'!C21
	--17   %
	SELECT @ah17=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,17),0)/100
	SELECT @ah17perc=@ah17/100

	--Assumptions and Headcount'!C121
	--117
	SELECT @ah116=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,116)

	--Assumptions and Headcount'!C122
	--117
	SELECT @ah117=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,117)

	--2018-09-26 UPDATED
	SELECT @Value=(@c28+(@c29*0.5))+((@c30+(@c31*0.5))*(((1-@ah30perc)/(1-@ah17perc))*((@ah116)/(@ah117))))

	RETURN ISNULL(@Value,0)
END