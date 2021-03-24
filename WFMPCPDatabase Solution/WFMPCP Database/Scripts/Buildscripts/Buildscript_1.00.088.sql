/******************************
** File: Buildscript_1.00.088.sql
** Name: Buildscript_1.00.088
** Auth: McNiel Viray	
** Date: 04 April 2018
**************************
** Change History
**************************
** Modified Dynamic formula erlang,billable perunit and billable per hour
*******************************/
USE WFMPCP
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
	,@ahc21Perc DECIMAL = 0

	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc21Perc = @ahc21/100
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	

	DECLARE @fvXpaht DECIMAL(10,2) = (@ahc10 *  @ahc21Perc)
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
		,@ahc21Perc DECIMAL(10,2) = 0
		
	--'= Net Required Hours / 40 * Schedule Constraint [in this case, its 1.0] [Net required hours = base hours / [1-Total Shrinkage] [Base hours = Forecast volume / planned TpH]
	SELECT @NetRequiredHours = [dbo].[udf_GetNetReqHours](@SiteID,@CampaignID,@LobID,@Date)
	
	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc21Perc = @ahc21/100

	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc13=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,9)
	--'= 'Assumptions and Headcount'!D60 / 40 * 'Assumptions and Headcount'!D65 / 1-'Assumptions and Headcount'!D21 * ('Assumptions and Headcount'!D10 / 'Assumptions and Headcount'!D13)
	
	SELECT @Value=((((@ahc60/ 40) * @ahc65) / NULLIF((1-@ahc21Perc),0)) * @ahc10) / NULLIF(@ahc13,0)
--@ahc60/ 40 * @ahc65 / NULLIF((1-@ahc21),0) * (@ahc10 / NULLIF(@ahc13,0))

	--SELECT @Value = @NetRequiredHours

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_Dynamic_Erlang]...';


GO
ALTER FUNCTION [dbo].[udf_Dynamic_Erlang]
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
	,@ahc123 DECIMAL = 0
    ,@ahc10 DECIMAL = 0
    ,@ahc60 DECIMAL = 0
	,@ahc10Perc DECIMAL = 0
	--= Teammates ASA (ASA, Weekly Calls/Operating Hours) * Operating Hours / 37.5
	    
	SELECT @ahc123=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,118)
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)

	SELECT @ahc10Perc = @ahc10/100

	--= (('Assumptions and Headcount'!D123 * 'Assumptions and Headcount'!D10) * 'Assumptions and Headcount'!D60) / 37.5
	SELECT @Value=((@ahc123 * @ahc10Perc) * @ahc60) / 37.5

	RETURN ISNULL(@Value,0)
END
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
	,@ahc21Perc DECIMAL = 0

	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc21Perc = @ahc21/100
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	

	DECLARE @fvXpaht DECIMAL(10,2) = (@ahc10 *  @ahc21Perc)
		, @threesix DECIMAL(10,2) =  ISNULL((3600 / NULLIF(@ahc58,0)),0)
		, @minusOne  DECIMAL(10,2) = ISNULL(NULLIF((1 - @ahc21Perc),0),0)
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
	,@ahc60 DECIMAL (10,2) = 0
	,@ahc10 DECIMAL (10,2)= 0
    ,@ahc121 DECIMAL (10,2) = 0
    ,@ahc58 DECIMAL (10,2) = 0
	,@ahc21 DECIMAL(10,2) = 0
	,@ahc65 DECIMAL (10,2) = 0
	,@ahc21Perc DECIMAL (10,2) = 0

	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc21Perc = @ahc21/100
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	
	--FIRST DISPLAY
	--SELECT @ahc60,@ahc10,@ahc121,@ahc58,@ahc21,@ahc21Perc,@ahc65

	DECLARE @fvXpaht DECIMAL(10,2) = (@ahc10 *  @ahc21Perc)
		, @threesix DECIMAL(10,2) =  ISNULL((3600 / NULLIF(@ahc58,0)),0)
		, @minusOne  DECIMAL(10,2) = ISNULL(NULLIF((1 - @ahc21Perc),0),0)
		, @fvXpahtDIVthreesix DECIMAL(10,2) 
		, @fvXpahtDIVthreesixDIVmunusOne DECIMAL(10,2)
	
	SET @fvXpahtDIVthreesix = ISNULL((@fvXpaht/NULLIF(@threesix,0)),0)
	SET @fvXpahtDIVthreesixDIVmunusOne = ISNULL((@fvXpahtDIVthreesix/NULLIF(@minusOne,0)),0)

	--SECOND DISPLAY
	--SELECT @fvXpahtDIVthreesix,@fvXpahtDIVthreesixDIVmunusOne,@ahc60,(@fvXpahtDIVthreesixDIVmunusOne * @ahc65)

	--= Weekly Production Hours / (((Forecasted Volume *  Projected AHT / 3600 / Target Occupancy / (1 - Total Projected Production Shrinkage)) * Derived Schedule Constraints)
	--'= 'Assumptions and Headcount'!D60 / ((('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121 / 3600 / 'Assumptions and Headcount'!D58 / (1 - 'Assumptions and Headcount'!D21)) * 'Assumptions and Headcount'!D65))
	--SELECT @Value=@ahc60/ (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65))
	--SELECT @Value=@ahc60/NULLIF( (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65)),0)
	
	SELECT @Value=@ahc60/NULLIF((@fvXpahtDIVthreesixDIVmunusOne * @ahc65),0)

	--SELECT @Value=@ahc60/(((@fvXpaht/@threesix)/@minusOne)* @ahc65) as of 03.12.2018

	--SELECT ISNULL(@Value,0)

	RETURN ISNULL(@Value,0)
END
GO