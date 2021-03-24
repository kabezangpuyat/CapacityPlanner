/******************************
** File: Buildscript_1.00.083.sql
** Name: Buildscript_1.00.083
** Auth: McNiel Viray
** Date: 20 February 2018
**************************
** Change History
**************************
** Modify [udf_Dynamic_BillablePerHour] ==> @ahc21 DECIMAL to @ahc21 DECIMAL(10,2)
*******************************/
USE WFMPCP
GO


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
		, @threesix DECIMAL(10,2) =  (3600 / NULLIF(@ahc58,0))
		, @minusOne  DECIMAL(10,2) = NULLIF((1 - @ahc21),0)

	--= Weekly Production Hours / (((Forecasted Volume *  Projected AHT / 3600 / Target Occupancy / (1 - Total Projected Production Shrinkage)) * Derived Schedule Constraints)
	--'= 'Assumptions and Headcount'!D60 / ((('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121 / 3600 / 'Assumptions and Headcount'!D58 / (1 - 'Assumptions and Headcount'!D21)) * 'Assumptions and Headcount'!D65))
	--SELECT @Value=@ahc60/ (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65))
	--SELECT @Value=@ahc60/NULLIF( (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65)),0)
	SELECT @Value=@ahc60/(((@fvXpaht/@threesix)/@minusOne)* @ahc65)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Update complete.';


GO
