CREATE FUNCTION [dbo].[udf_GetTotalNestingFullTime]
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
	,@ah133 DECIMAL
	,@ah134 DECIMAL
	,@ah135 DECIMAL
	
	--= [['Assumptions and Headcount'!D138]]+[['Assumptions and Headcount'!D139]]+[['Assumptions and Headcount'!D140]]

	--[['Assumptions and Headcount'!D138]]
	--133
	SELECT @ah133=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,133)

	--[['Assumptions and Headcount'!D139]]
	--134
	SELECT @ah134=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,134)

	--[['Assumptions and Headcount'!D140]]
	--135
	SELECT @ah135=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,135)

	SELECT @Value=@ah133+@ah134+@ah135

	RETURN ISNULL(@Value,0)
END