CREATE FUNCTION [dbo].[udf_Dynamic_Erlang]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL(10,2) = 0
	,@ahc123 DECIMAL = 0
    ,@ahc10 DECIMAL = 0
    ,@ahc60 DECIMAL = 0
	,@ahc10Perc DECIMAL = 0
	--= Teammates ASA (ASA, Weekly Calls/Operating Hours) * Operating Hours / 37.5
	    
	SELECT @ahc123=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,118)
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)

	SELECT @ahc10Perc = @ahc10/100

	--= (('Assumptions and Headcount'!D123 * 'Assumptions and Headcount'!D10) * 'Assumptions and Headcount'!D60) / 37.5
	SELECT @Value=((@ahc123 * @ahc10Perc) * @ahc60) / 37.5

	RETURN ISNULL(@Value,0)
END
