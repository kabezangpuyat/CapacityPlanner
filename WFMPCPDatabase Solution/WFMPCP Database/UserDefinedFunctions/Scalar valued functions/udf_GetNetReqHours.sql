CREATE FUNCTION [dbo].[udf_GetNetReqHours]
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

		--Base Hours (Workload) / Derived Occupancy, Occupancy [from Assumptions and Headcount tab] / (1 - Projection based on Goal, Production Shrinkage [from the Assumptions and Headcount tab])
		
		--C11 Base Hours (Workload)
		SELECT @basehours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
		
		--[['Assumptions and Headcount'!C58]] : Derived Occupancy, Occupancy [from Assumptions and Headcount tab]
		SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)

		--[['Assumptions and Headcount'!C21]]
		SELECT @ah17=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
		
		--'= C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C21]])
		SELECT @Value=(@BaseHours/NULLIF(@ah54,0))/NULLIF((1-@ah17),0)
		
	RETURN ISNULL(@Value,0)
END