/******************************
** File: Buildscript_1.00.099.sql
** Name: Buildscript_1.00.099
** Auth: McNiel Viray
** Date: 26 September 2018
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 99

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
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
	,@ahc21 DECIMAL = 0
	,@ahc23 DECIMAL = 0
	,@ahc58Perc DECIMAL(10,2) = 0
	,@ahc21Perc DECIMAL(10,2) = 0
	,@ahc23Perc DECIMAL(10,2) = 0	
	,@1minusahc21percminusahc23 DECIMAL(10,2) = 0

	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc23=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,19)

	SELECT @ahc58Perc = @ahc58/100
	SELECT @ahc21Perc = @ahc21/100
	SELECT @ahc23Perc = @ahc23/100
	SELECT @1minusahc21percminusahc23 = 1-(@ahc21Perc-@ahc23Perc)


	--select @ahc10,@ahc121,@ahc58,@ahc58Perc,@ahc21Perc,@1minusahc21percminusahc23
	--2018-09-26  UPDATED FORMULA
	--= Volume * AHT / 3600 / Derived Occupancy / 37.5/(1-(Overall Projected Production Shrinkage-Breaks))
	--'= ('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121) / 3600 / 'Assumptions and Headcount'!D58 / 37.5/(1-('Assumptions and Headcount'!D21-'Assumptions and Headcount'!D23))
	SELECT @Value=((((@ahc10 * @ahc121)/3600)/NULLIF(@ahc58Perc,0))/37.5)/NULLIF(@1minusahc21percminusahc23,0)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetCurrentGrossFTE]...';


GO
ALTER FUNCTION [dbo].[udf_GetCurrentGrossFTE]
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
	,@c28 DECIMAL
	,@c29 DECIMAL
	,@c30 DECIMAL
	,@c31 DECIMAL
	,@ah30 DECIMAL
	,@ah17 DECIMAL
	,@ah116 DECIMAL
	,@ah117 DECIMAL
    ,@ah30perc DECIMAL(10,2)
    ,@ah17perc DECIMAL(10,2)

	--(C28+(C29*0.5))+((C30+(C31*0.5))*(((1 - [['Assumptions and Headcount'!C43]])/(1 - [['Assumptions and Headcount'!C21]]))*(([['Assumptions and Headcount'!C121]])/([['Assumptions and Headcount'!C122]]))))
    --(@c28+(@c29*0.5))+((@c30+(@c31*0.5))*())
	--C28
	--24
	SELECT @c28=[dbo].[udf_GetTotalProductionFullTime](@SiteID,@CampaignID,@LoBID,@Date)
	
	--C29
	--25
	SELECT @c29=[dbo].[udf_GetTotalProductionPartTime](@SiteID,@CampaignID,@LoBID,@Date)

	--C30
	--26
	SELECT @c30=[dbo].[udf_GetTotalNestingFullTime](@SiteID,@CampaignID,@LoBID,@Date)

	--C31
	--27
	SELECT @c31=[dbo].[udf_GetTotalNestingPartTime](@SiteID,@CampaignID,@LoBID,@Date)

	--Assumptions and Headcount'!C30
	--26   %
	SELECT @ah30=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,26),0)
	SELECT @ah30perc = @ah30/100

	--Assumptions and Headcount'!C21
	--17   %
	SELECT @ah17=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,17),0)/100
	SELECT @ah17perc=@ah17/100

	--Assumptions and Headcount'!C121
	--117
	SELECT @ah116=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,116)

	--Assumptions and Headcount'!C122
	--117
	SELECT @ah117=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,117)

	--2018-09-26 UPDATED
	SELECT @Value=(@c28+(@c29*0.5))+((@c30+(@c31*0.5))*(((1-@ah30perc)/(1-@ah17perc))*((@ah116)/(@ah117))))

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetExcessDeficitHC]...';


GO
ALTER FUNCTION [dbo].[udf_GetExcessDeficitHC]
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
		,@currentHC DECIMAL
		,@requiredHC DECIMAL

		SELECT @requiredHC = [dbo].[udf_GetGrossRequiredFTE](@SiteID,@CampaignID,@LoBID,@Date)--StaffDatapointID: 1
		SELECT @currentHC =	[dbo].[udf_GetCurrentGrossFTE](@SiteID,@CampaignID,@LoBID,@Date)--StaffDatapointID: 2

		SELECT @Value=@currentHC-@requiredHC
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Refreshing [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]';


GO
PRINT N'Refreshing [dbo].[wfmpcp_SaveAHCStagingToActual_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveAHCStagingToActual_sp]';


GO
PRINT N'Update complete.';


GO




