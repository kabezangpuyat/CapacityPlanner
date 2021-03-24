CREATE FUNCTION [dbo].[udf_GetBillableExcessDeficit]
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
	
	-- @CurrentBillableHC-@BillableHC	
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,66)-[dbo].[udf_GetBillableHC](@SiteID,@CampaignID,@LobID,@Date)

	RETURN ISNULL(@Value,0)
END