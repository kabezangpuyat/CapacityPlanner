CREATE FUNCTION [dbo].[udf_GetGrossRequiredHours]
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
		,@ah54 DECIMAL
		,@ah17 DECIMAL
		,@basehours DECIMAL
		,@ah61 DECIMAL

		-- C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C65]]/(1 - [['Assumptions and Headcount'!C21]])  This is the formula before the rollback

		--C11 Base Hours (Workload)
		SELECT @basehours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
		
		--[['Assumptions and Headcount'!C65]] DatapointId: 61
		SELECT @ah61=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
		DECLARE @ah61perc DECIMAL(10,3)=@ah61/100

		--[['Assumptions and Headcount'!C58]] : Derived Occupancy, Occupancy [from Assumptions and Headcount tab]
		SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
		DECLARE @ah54perc DECIMAL(10,3) = @ah54/100

		--( [['Assumptions and Headcount'!C21])
		SELECT @ah17=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
		DECLARE @ah17perc DECIMAL(10,3) = @ah17/100
		
		
		--'= C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C21]])
		SELECT @Value=NULLIF((((@basehours/@ah54perc)/(1-@ah61perc))/(1-@ah17perc)),0)
		
	RETURN ISNULL(@Value,0)
END