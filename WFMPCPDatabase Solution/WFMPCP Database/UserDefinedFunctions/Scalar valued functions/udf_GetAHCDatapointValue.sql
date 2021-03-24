CREATE FUNCTION [dbo].[udf_GetAHCDatapointValue]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE,
	@DatapointID BIGINT
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL

	SELECT @Value=CASE WHEN ISNUMERIC(LTRIM(RTRIM(REPLACE([Data],'%','')))) = 0 THEN '0' 
			ELSE CAST(LTRIM(RTRIM(REPLACE([Data],'%',''))) AS DECIMAL) END
	FROM WeeklyAHDatapoint 
	WHERE LoBID=@LobID 
		AND SiteID=@SiteID
		AND CampaignID=@CampaignID
		AND [Date]=@Date  
		AND DatapointID=@DatapointID

	RETURN ISNULL(@Value,0)
END
