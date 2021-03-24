CREATE FUNCTION [dbo].[udf_Dynamic_BillablePerUnit]
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
		,@NetRequiredHours DECIMAL
	    ,@ahc60 DECIMAL = 0
		,@ahc65 DECIMAL(10,2) = 0
		,@ahc21 DECIMAL(10,2) = 0
		,@ahc10 DECIMAL = 0
		,@ahc13 DECIMAL(10,2) = 0
		,@ahc21Perc DECIMAL(10,2) = 0
		
	--'= Required Hours / 40 * Derived Schedule Constraints [in this case, its 1.0] [Net required hours = base hours / [1-Total Shrinkage] [Base hours = Forecast volume / planned TpH]
	SELECT @NetRequiredHours = [dbo].[udf_GetNetReqHours](@SiteID,@CampaignID,@LobID,@Date)
	
	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc21Perc = @ahc21/100

	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc13=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,9)
	--'= 'Assumptions and Headcount'!D60 / 40 * 'Assumptions and Headcount'!D65 / 1-'Assumptions and Headcount'!D21 * ('Assumptions and Headcount'!D10 / 'Assumptions and Headcount'!D13)
	
	SELECT @Value=((((@ahc60/ 40) * @ahc65) / NULLIF((1-@ahc21Perc),0)) * @ahc10) / NULLIF(@ahc13,0)
--@ahc60/ 40 * @ahc65 / NULLIF((1-@ahc21),0) * (@ahc10 / NULLIF(@ahc13,0))

	--SELECT @Value = @NetRequiredHours

	RETURN ISNULL(@Value,0)
END
