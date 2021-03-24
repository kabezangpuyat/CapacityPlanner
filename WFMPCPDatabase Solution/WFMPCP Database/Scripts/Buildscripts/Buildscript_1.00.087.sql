/******************************
** File: Buildscript_1.00.087.sql
** Name: Buildscript_1.00.087
** Auth: McNiel Viray
** Date: 04 April 2018
**************************
** Change History
**************************
** Updated udf_Dynamic_Straigh by factoring derived occupancy
*******************************/
USE WFMPCP
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
	,@ahc58Perc DECIMAL = 0

	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc58Perc = @ahc58/100

	--= Volume * AHT / 3600 / Derived Occupancy / 37.5
	--'= ('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121) / 3600 / 'Assumptions and Headcount'!D58 / 37.5
	SELECT @Value=(((@ahc10 * @ahc121) / 3600) / NULLIF(@ahc58Perc,0)) / 37.5
--(@ahc10 * @ahc121) / 3600 / NULLIF(@ahc58,0) / 37.5
	RETURN ISNULL(@Value,0)
END
GO