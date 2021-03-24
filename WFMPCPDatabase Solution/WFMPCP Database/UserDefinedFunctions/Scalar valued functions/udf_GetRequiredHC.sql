CREATE FUNCTION [dbo].[udf_GetRequiredHC]
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
		,@ahc61 DECIMAL
		,@netReqHours DECIMAL
		-- Net Required Hours / 40 * Derived Scheduled Constraints [from Assumptions and Headcount tab]

		SELECT @netReqHours=[dbo].[udf_GetNetReqHours](@SiteID,@CampaignID,@LobID,@Date)
		
		SELECT @ahc61=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
		
		--DEFAULT FORMULA
		SELECT @Value=(@netReqHours/40)*@ahc61
		
		--CHECK the formula assigned to Site,Campaign, and LoB
		IF EXISTS (SELECT f.ID FROM DynamicFormula f 
						INNER JOIN SiteCampaignLobFormula sclf ON sclf.DynamicFormulaID=f.ID
						WHERE sclf.SiteID=@SiteID 
							AND sclf.CampaignID=@CampaignID
							AND sclf.LoBID=@LobID
							AND sclf.Active = 1
							AND f.Active = 1)
		BEGIN
			DECLARE @FormulaID BIGINT = 0

			SELECT @FormulaID = f.ID FROM DynamicFormula f 
			INNER JOIN SiteCampaignLobFormula sclf ON sclf.DynamicFormulaID=f.ID
			WHERE sclf.SiteID=@SiteID 
				AND sclf.CampaignID=@CampaignID
				AND sclf.LoBID=@LobID
				AND sclf.Active = 1
				AND f.Active = 1

			IF(@FormulaID=2)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_Erlang](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=3)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_Straight](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=4)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerHour](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=5)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerUnit](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=6)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerMinute](@SiteID,@CampaignID,@LobID,@Date)
			END
		END

	RETURN ISNULL(@Value,0)
END