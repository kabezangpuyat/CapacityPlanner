/******************************
** File: Buildscript_1.00.101.sql
** Name: Buildscript_1.00.101
** Auth: McNiel Viray
** Date: 15 October 2018
**************************
** Change History
**************************
** Modify function [dbo].[udf_GetGrossRequiredHours]
** Modify function [dbo].[udf_GetRequiredNetFTE]
** Modify function [dbo].[udf_GetPlannedNetFTE]
** Modify function [dbo].[udf_GetExcessDeficitFTE]
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 101

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
GO
ALTER FUNCTION [dbo].[udf_GetGrossRequiredHours]
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
		,@ah54 DECIMAL
		,@ah17 DECIMAL
		,@basehours DECIMAL
		,@ah61 DECIMAL

		-- C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C65]]/(1 - [['Assumptions and Headcount'!C21]])  This is the formula before the rollback

		--C11 Base Hours (Workload)
		SELECT @basehours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
		
		--[['Assumptions and Headcount'!C65]] DatapointId: 61
		SELECT @ah61=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
		DECLARE @ah61perc DECIMAL(10,3)=@ah61/100

		--[['Assumptions and Headcount'!C58]] : Derived Occupancy, Occupancy [from Assumptions and Headcount tab]
		SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
		DECLARE @ah54perc DECIMAL(10,3) = @ah54/100

		--( [['Assumptions and Headcount'!C21])
		SELECT @ah17=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
		DECLARE @ah17perc DECIMAL(10,3) = @ah17/100
		
		
		--'= C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C21]])
		SELECT @Value=NULLIF((((@basehours/@ah54perc)/(1-@ah61perc))/(1-@ah17perc)),0)
		
	RETURN ISNULL(@Value,0)
END
GO
ALTER  FUNCTION [dbo].[udf_GetRequiredNetFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	,@c1 DECIMAL -- c1 of staff planner
	,@ah21 DECIMAL(10,2)--AH DatapointId = 17
    ,@ah21Perc DECIMAL(10,2)

	--c1
	--8  = [['Assumptions and Headcount'!C60]] ah56
	SELECT @c1=[dbo].[udf_Dynamic_Straight](@SiteID,@CampaignID,@LobID,@Date)--[dbo].[udf_GetGrossRequiredFTE](@SiteID,@CampaignID,@LoBID,@Date)
	SELECT @ah21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,17)
	SELECT @ah21Perc = @ah21/100
	
	SELECT @Value = @c1*(1-@ah21Perc)	

	RETURN ISNULL(@Value,0)
END
GO
ALTER  FUNCTION [dbo].[udf_GetPlannedNetFTE]
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
	,@ah21 DECIMAL--datapoint 17 of AHC
	,@ah21perc DECIMAL(10,3)
	,@c2 DECIMAL(10,2) --FROM Staff planner
	
	--= (C2 *(1 - [['Assumptions and Headcount'!C21]])
	SELECT @c2=[dbo].[udf_GetCurrentGrossFTE](@SiteID,@CampaignID,@LobID,@Date)

	SELECT @ah21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ah21perc=@ah21/100

	SELECT @Value=@c2*(1-@ah21perc)

	RETURN ISNULL(@Value,0)
END
GO
ALTER FUNCTION [dbo].[udf_GetExcessDeficitFTE]
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
		,@plannedFTE DECIMAL(10,3) 
		,@netFTE DECIMAL(10,3)
	--'= C8 - C7
	
	SELECT @plannedFTE=[dbo].[udf_GetPlannedNetFTE](@SiteID,@CampaignID,@LobID,@Date)
	SELECT @netFTE=[dbo].[udf_GetRequiredNetFTE](@SiteID,@CampaignID,@LobID,@Date)

	SELECT @Value=@plannedFTE-@netFTE

	RETURN ISNULL(@Value,0)
END
GO

