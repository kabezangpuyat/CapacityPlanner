/******************************
** File: Buildscript_1.00.085.sql
** Name: Buildscript_1.00.085
** Auth: McNiel Viray	
** Date: 12 March 2018
**************************
** Change History
**************************
** Modify divide by zero
*******************************/
USE WFMPCP
GO




PRINT N'Disabling all DDL triggers...'
GO
--DISABLE TRIGGER ALL ON DATABASE
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
	,@ahc21 DECIMAL(10,2) = 0
	,@ahc65 DECIMAL = 0

	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)/100	
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	

	DECLARE @fvXpaht DECIMAL(10,2) = (@ahc10 *  @ahc121)
		, @threesix DECIMAL(10,2) =  ISNULL((3600 / NULLIF(@ahc58,0)),0)
		, @minusOne  DECIMAL(10,2) = ISNULL(NULLIF((1 - @ahc21),0),0)
		, @fvXpahtDIVthreesix DECIMAL(10,2) 
		, @fvXpahtDIVthreesixDIVmunusOne DECIMAL(10,2)
	
	SET @fvXpahtDIVthreesix = ISNULL((@fvXpaht/NULLIF(@threesix,0)),0)
	SET @fvXpahtDIVthreesixDIVmunusOne = ISNULL((@fvXpahtDIVthreesix/NULLIF(@minusOne,0)),0)

	--= Weekly Production Hours / (((Forecasted Volume *  Projected AHT / 3600 / Target Occupancy / (1 - Total Projected Production Shrinkage)) * Derived Schedule Constraints)
	--'= 'Assumptions and Headcount'!D60 / ((('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121 / 3600 / 'Assumptions and Headcount'!D58 / (1 - 'Assumptions and Headcount'!D21)) * 'Assumptions and Headcount'!D65))
	--SELECT @Value=@ahc60/ (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65))
	--SELECT @Value=@ahc60/NULLIF( (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65)),0)
	
	SELECT @Value=@ahc60/NULLIF((@fvXpahtDIVthreesixDIVmunusOne * @ahc65),0)

	--SELECT @Value=@ahc60/(((@fvXpaht/@threesix)/@minusOne)* @ahc65) as of 03.12.2018

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetProjectedCapacity]...';


GO
ALTER FUNCTION [dbo].[udf_GetProjectedCapacity]
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
	
	--(@ProdProdHrs*3600/ahc5)+(@SMEProdHrs*3600/ahc5)
	-- added formula (10.25.2017)
	-- + (@NestingProdHrs*3600/ahc100) 
	SELECT @Value=ISNULL(([dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)*3600/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,5),0)),0)
				+ISNULL(([dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)*3600/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,5),0)),0)
				+ISNULL(([dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)*3600/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,100),0)),0)
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Refreshing [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]';


GO
PRINT N'Reenabling DDL triggers...'
GO
--ENABLE TRIGGER [tr_DDL_SchemaChangeLog] ON DATABASE
GO
PRINT N'Update complete.';


GO
