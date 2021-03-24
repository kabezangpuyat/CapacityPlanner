CREATE FUNCTION [dbo].[udf_GetGrossRequiredFTE]
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
		,@grossRequiredHours DECIMAL--StaffDatapointID: 9
		-- Gross Required Hours / 40

		SELECT @grossRequiredHours=[dbo].[udf_GetGrossRequiredHours](@SiteID,@CampaignID,@LobID,@Date)

		--DEFAULT FORMULA
		SELECT @Value=(@grossRequiredHours/40)
		
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
				DECLARE @NumberOfCalls NUMERIC(10,3)=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6) -- Forcasted Volume / C10  
				,@AHTInSeconds NUMERIC(10,3)=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,9)--Target AHT / c13 
				,@RequiredServiceLevelPerc NUMERIC(10,3)=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,1) -- Target Service Level / C5
				,@TargetAnswerTimeInSeconds NUMERIC(10,3)=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,3)--Service Time / c7
				,@ShrinkagePerc NUMERIC(18,3) =[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,53) --Projected and Actual Shrinkage Variance / c57
				,@NewN NUMERIC = null

				SELECT @Value = NumberOfAgentsRequired FROM udf_ErlangCFormula(@NumberOfCalls,@AHTInSeconds,@RequiredServiceLevelPerc,@TargetAnswerTimeInSeconds,@ShrinkagePerc,@NewN)
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