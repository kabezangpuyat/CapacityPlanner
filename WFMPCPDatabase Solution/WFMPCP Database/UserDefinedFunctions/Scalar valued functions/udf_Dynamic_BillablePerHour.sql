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

	--= Required Hours / (((Forecasted Volume *  Production AHT / 3600 / Derived Occupancy / (1 -	)) * Derived Schedule Constraints)
	--'= 'Assumptions and Headcount'!D60 / ((('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121 / 3600 / 'Assumptions and Headcount'!D58 / (1 - 'Assumptions and Headcount'!D21)) * 'Assumptions and Headcount'!D65))
	--SELECT @Value=@ahc60/ (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65))
	--SELECT @Value=@ahc60/NULLIF( (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65)),0)
	
	SELECT @Value=@ahc60/NULLIF((@fvXpahtDIVthreesixDIVmunusOne * @ahc65),0)

	--SELECT @Value=@ahc60/(((@fvXpaht/@threesix)/@minusOne)* @ahc65) as of 03.12.2018

	--SELECT ISNULL(@Value,0)

	RETURN ISNULL(@Value,0)
END
