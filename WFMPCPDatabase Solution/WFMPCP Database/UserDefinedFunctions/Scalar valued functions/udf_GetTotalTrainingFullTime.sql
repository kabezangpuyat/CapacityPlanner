CREATE FUNCTION [dbo].[udf_GetTotalTrainingFullTime]
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
	,@ah139 DECIMAL
	,@ah141 DECIMAL
	
	--= [['Assumptions and Headcount'!D144]]+[['Assumptions and Headcount'!D146]]

	--[['Assumptions and Headcount'!D144]]
	--139
	SELECT @ah139=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,139)

	--[['Assumptions and Headcount'!D146]]
	--141
	SELECT @ah141=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,141)

	SELECT @Value=@ah139+@ah141

	RETURN ISNULL(@Value,0)
END