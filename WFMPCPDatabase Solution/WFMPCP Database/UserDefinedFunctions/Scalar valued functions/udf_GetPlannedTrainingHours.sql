CREATE FUNCTION [dbo].[udf_GetPlannedTrainingHours]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	--C13
	DECLARE @Value DECIMAL
		,@ah72 DECIMAL
	
	--= [['Assumptions and Headcount'!D72]]*37.5 (2018.07.20 FORMULA)
	--= [['Assumptions and Headcount'!D77]]*37.5
	
	--Assumptions and Headcount'!D77
	--ah67
	SELECT @ah72=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,72) 

	SELECT @Value=@ah72*37.5

	RETURN ISNULL(@Value,0)
END