CREATE FUNCTION [dbo].[udf_GetTotalNestingPartTime]
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
	,@ah136 DECIMAL
	,@ah137 DECIMAL
	,@ah138 DECIMAL
	
	--= [['Assumptions and Headcount'!D141]]+[['Assumptions and Headcount'!D142]]+[['Assumptions and Headcount'!D143]]

	--[['Assumptions and Headcount'!D141]]
	--136
	SELECT @ah136=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,136)

	--[['Assumptions and Headcount'!D142]]
	--137
	SELECT @ah137=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,137)

	--[['Assumptions and Headcount'!D143]]
	--138
	SELECT @ah138=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,138)

	SELECT @Value=@ah136+@ah137+@ah138


	RETURN ISNULL(@Value,0)
END