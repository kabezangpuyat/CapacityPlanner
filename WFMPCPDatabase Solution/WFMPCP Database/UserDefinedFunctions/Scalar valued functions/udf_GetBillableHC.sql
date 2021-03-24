CREATE FUNCTION [dbo].[udf_GetBillableHC]
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
	
	--ahc67/(1-ahc23)
	--SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,67)/NULLIF((1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,23)),0)
	
	DECLARE @ahc67 DECIMAL(10,2)
	,@ahc23 DECIMAL(10,2)
	,@dividend DECIMAL(10,2)

	SELECT @ahc67 = [dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,67)
	SELECT @ahc23 = [dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,23)/100 --divide to 100 because it's %

	--(1-ahc23)
	SELECT @dividend =  1-@ahc23
	
	--ahc67/(1-ahc23)
     SELECT @Value=@ahc67/NULLIF(@dividend,0)

	RETURN ISNULL(@Value,0)
END