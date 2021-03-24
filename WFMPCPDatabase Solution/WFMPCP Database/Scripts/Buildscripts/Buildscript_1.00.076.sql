/******************************
** File: Buildscript_1.00.076.sql
** Name: Buildscript_1.00.076
** Auth: McNiel Viray
** Date: 16 November 2017
**************************
** Change History
**************************
** Added UDF For dynamic fomula
** Modify udf_GetBillableHC
** Modify udf_GetRequiredHC
*******************************/
USE WFMPCP
GO


PRINT N'Disabling all DDL triggers...'
GO
DISABLE TRIGGER ALL ON DATABASE
GO
PRINT N'Altering [dbo].[udf_GetBillableHC]...';


GO
ALTER FUNCTION [dbo].[udf_GetBillableHC]
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
     SELECT @Value=@ahc67/@dividend

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_Dynamic_BillablePerHour]...';


GO
CREATE FUNCTION [dbo].[udf_Dynamic_BillablePerHour]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL = 0
	--= Weekly Production Hours / (((Forecasted Volume *  Projected AHT / 3600 / Target Occupancy / (1 - Total Projected Production Shrinkage)) * Derived Schedule Constraints)
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_Dynamic_BillablePerMinute]...';


GO
CREATE FUNCTION [dbo].[udf_Dynamic_BillablePerMinute]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL = 0

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_Dynamic_BillablePerUnit]...';


GO
CREATE FUNCTION [dbo].[udf_Dynamic_BillablePerUnit]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL = 0
		,@NetRequiredHours DECIMAL
		
	--'= Net Required Hours / 40 * Schedule Constraint [in this case, its 1.0] [Net required hours = base hours / [1-Total Shrinkage] [Base hours = Forecast volume / planned TpH]
	SELECT @NetRequiredHours = [dbo].[udf_GetNetReqHours](@SiteID,@CampaignID,@LobID,@Date)


	SELECT @Value = @NetRequiredHours

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_Dynamic_Erlang]...';


GO
CREATE FUNCTION [dbo].[udf_Dynamic_Erlang]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL = 0
	--= Teammates ASA (ASA, Weekly Calls/Operating Hours) * Operating Hours / 37.5
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_Dynamic_Straight]...';


GO
CREATE FUNCTION [dbo].[udf_Dynamic_Straight]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL = 0
	--= Volume * AHT / 3600 / Derived Occupancy / 37.5
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetRequiredHC]...';


GO
ALTER FUNCTION [dbo].[udf_GetRequiredHC]
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
GO
PRINT N'Refreshing [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]';


GO
PRINT N'Reenabling DDL triggers...'
GO
ENABLE TRIGGER [tr_DDL_SchemaChangeLog] ON DATABASE
GO
PRINT N'Update complete.';


GO

