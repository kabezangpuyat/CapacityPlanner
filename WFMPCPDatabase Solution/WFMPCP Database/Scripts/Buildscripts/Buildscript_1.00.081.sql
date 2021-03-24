/******************************
** File: Buildscript_1.00.081.sql
** Name: Buildscript_1.00.081
** Auth: McNiel Viray
** Date: 06 December 2017
**************************
** Change History
**************************
** add nullif to dynamic formula divisor.
*******************************/
USE WFMPCP
GO

PRINT N'Disabling all DDL triggers...'
GO
DISABLE TRIGGER ALL ON DATABASE
GO
PRINT N'Altering [dbo].[udf_Dynamic_BillablePerHour]...';


GO
ALTER FUNCTION [dbo].[udf_Dynamic_BillablePerHour]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL(10,2) = 0
	,@ahc60 DECIMAL = 0
	,@ahc10 DECIMAL = 0
    ,@ahc121 DECIMAL = 0
    ,@ahc58 DECIMAL = 0
	,@ahc21 DECIMAL = 0
	,@ahc65 DECIMAL = 0

	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)/100
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	
	--= Weekly Production Hours / (((Forecasted Volume *  Projected AHT / 3600 / Target Occupancy / (1 - Total Projected Production Shrinkage)) * Derived Schedule Constraints)
	--'= 'Assumptions and Headcount'!D60 / ((('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121 / 3600 / 'Assumptions and Headcount'!D58 / (1 - 'Assumptions and Headcount'!D21)) * 'Assumptions and Headcount'!D65))
	SELECT @Value=@ahc60/ (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65))

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_Dynamic_BillablePerUnit]...';


GO
ALTER FUNCTION [dbo].[udf_Dynamic_BillablePerUnit]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL(10,2) = 0
		,@NetRequiredHours DECIMAL
	    ,@ahc60 DECIMAL = 0
		,@ahc65 DECIMAL(10,2) = 0
		,@ahc21 DECIMAL(10,2) = 0
		,@ahc10 DECIMAL = 0
		,@ahc13 DECIMAL(10,2) = 0
		
	--'= Net Required Hours / 40 * Schedule Constraint [in this case, its 1.0] [Net required hours = base hours / [1-Total Shrinkage] [Base hours = Forecast volume / planned TpH]
	SELECT @NetRequiredHours = [dbo].[udf_GetNetReqHours](@SiteID,@CampaignID,@LobID,@Date)
	
	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)/100--%
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc13=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,9)
	--'= 'Assumptions and Headcount'!D60 / 40 * 'Assumptions and Headcount'!D65 / 1-'Assumptions and Headcount'!D21 * ('Assumptions and Headcount'!D10 / 'Assumptions and Headcount'!D13)
	
	SELECT @Value=@ahc60/ 40 * @ahc65 / NULLIF((1-@ahc21),0) * (@ahc10 / NULLIF(@ahc13,0))


	--SELECT @Value = @NetRequiredHours

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_Dynamic_Straight]...';


GO
ALTER FUNCTION [dbo].[udf_Dynamic_Straight]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL(10,2) = 0
	,@ahc121 DECIMAL = 0
    ,@ahc10 DECIMAL = 0
    ,@ahc58 DECIMAL = 0

	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)

	--= Volume * AHT / 3600 / Derived Occupancy / 37.5
	--'= ('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121) / 3600 / 'Assumptions and Headcount'!D58 / 37.5
	SELECT @Value=(@ahc10 * @ahc121) / 3600 / NULLIF(@ahc58,0) / 37.5
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Reenabling DDL triggers...'
GO
ENABLE TRIGGER [tr_DDL_SchemaChangeLog] ON DATABASE
GO
PRINT N'Update complete.';


GO
