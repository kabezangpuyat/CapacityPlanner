/******************************
** File: Buildscript_1.00.036.sql
** Name: Buildscript_1.00.036
** Auth: McNiel Viray
** Date: 12 July 2017
**************************
** Change History
**************************
** Alter [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
** Alter [dbo].[WeeklyDatapointTableType]
** Alter User Defined Functions 
*******************************/
USE WFMPCP
GO

PRINT N'Dropping [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
DROP PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetActualToForecastPerc_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetActualToForecastPerc_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetAnsweredToCapacityPerc_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetAnsweredToCapacityPerc_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetAnsweredToForecastPerc_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetAnsweredToForecastPerc_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetBillableExcessDeficit_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetBillableExcessDeficit_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetBillableHC_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetBillableHC_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetCapacityToForecastPerc_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetCapacityToForecastPerc_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetExcessDeficitHC_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetExcessDeficitHC_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetProjectedCapacity_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetProjectedCapacity_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetRequiredHC_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetRequiredHC_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetExcessDeficitFTE_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetExcessDeficitFTE_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetPlannedFTE_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetPlannedFTE_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetNetReqHours_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetNetReqHours_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetRequiredFTE_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetRequiredFTE_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetPlannedProdHrs_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetPlannedProdHrs_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetProdProdHrs_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetProdProdHrs_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetSMEProdHrs_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetSMEProdHrs_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_NestingProdHrs_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_NestingProdHrs_udf];


GO
PRINT N'Dropping [dbo].[wfmpcp_GetAHCDatapointValue_udf]...';


GO
DROP FUNCTION [dbo].[wfmpcp_GetAHCDatapointValue_udf];


GO
PRINT N'Dropping [dbo].[WeeklyDatapointTableType]...';


GO
DROP TYPE [dbo].[WeeklyDatapointTableType];


GO
PRINT N'Creating [dbo].[WeeklyDatapointTableType]...';


GO
CREATE TYPE [dbo].[WeeklyDatapointTableType] AS TABLE (
    [DatapointID]  BIGINT         NULL,
    [SiteID]       BIGINT         NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [Date]         DATE           NULL,
    [DataValue]    NVARCHAR (MAX) NULL,
    [UserName]     NVARCHAR (50)  NULL,
    [DateModified] DATETIME       NULL);


GO
PRINT N'Creating [dbo].[udf_GetAHCDatapointValue]...';


GO
CREATE FUNCTION [dbo].[udf_GetAHCDatapointValue]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE,
	@DatapointID BIGINT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)

	SELECT @Value=CAST(LTRIM(RTRIM(REPLACE([Data],'%',''))) AS DECIMAL(10,2))
	FROM WeeklyAHDatapoint 
	WHERE LoBID=@LobID 
		AND SiteID=@SiteID
		AND CampaignID=@CampaignID
		AND [Date]=@Date  
		AND DatapointID=@DatapointID

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetAnsweredToForecastPerc]...';


GO
CREATE FUNCTION [dbo].[udf_GetAnsweredToForecastPerc]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--(ahc8-ahc6)/ahc6
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,8)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetBillableHC]...';


GO
CREATE FUNCTION [dbo].[udf_GetBillableHC]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--ahc67/(1-ahc23)
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,67)/NULLIF((1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,23)),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetNetReqHours]...';


GO
CREATE FUNCTION [dbo].[udf_GetNetReqHours]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@ah54 DECIMAL(10,2)
		,@ah17 DECIMAL(10,2)
		,@basehours DECIMAL(10,2)

		SELECT @basehours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
		
		SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)

		SELECT @ah17=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
		
		SELECT @Value=(@BaseHours/NULLIF(@ah54,0))/NULLIF((1-@ah17),0)
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetProdProdHrs]...';


GO
CREATE FUNCTION [dbo].[udf_GetProdProdHrs]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@a DECIMAL(10,2)
		,@b DECIMAL(10,2)
		,@c DECIMAL(10,2)
		,@d DECIMAL(10,2)
	
	SELECT @a=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,13) * 40
	SELECT @b=1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,23)
	SELECT @c=1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,18)
	SELECT @d=1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,31)

	SELECT @Value=@a*@b*@c*@d
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetRequiredFTE]...';


GO
CREATE FUNCTION [dbo].[udf_GetRequiredFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@baseHours DECIMAL(10,2)

	SELECT @baseHours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @Value=@baseHours/40
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetRequiredHC]...';


GO
CREATE FUNCTION [dbo].[udf_GetRequiredHC]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@ahc61 DECIMAL(10,2)
		,@netReqHours DECIMAL(10,2)

		SELECT @netReqHours=[dbo].[udf_GetNetReqHours](@SiteID,@CampaignID,@LobID,@Date)
		
		SELECT @ahc61=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
				
		SELECT @Value=(@netReqHours/40)*@ahc61
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetSMEProdHrs]...';


GO
CREATE FUNCTION [dbo].[udf_GetSMEProdHrs]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)

	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,58) * 20
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_NestingProdHrs]...';


GO
CREATE FUNCTION [dbo].[udf_NestingProdHrs]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@ah71 DECIMAL(10,2)
		,@ah26 DECIMAL(10,2)
		,@ah54 DECIMAL(10,2)
	
	SELECT @ah71=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,71) * 40 
	SELECT @ah26=1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,26)
	SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)

	SELECT @Value=@ah71*@ah26*@ah54

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetActualToForecastPerc]...';


GO
CREATE FUNCTION [dbo].[udf_GetActualToForecastPerc]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--(ahc7-ahc6)/ahc6
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,7)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetBillableExcessDeficit]...';


GO
CREATE FUNCTION [dbo].[udf_GetBillableExcessDeficit]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	-- @CurrentBillableHC-@BillableHC	
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,66)-[dbo].[udf_GetBillableHC](@SiteID,@CampaignID,@LobID,@Date)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetExcessDeficitHC]...';


GO
CREATE FUNCTION [dbo].[udf_GetExcessDeficitHC]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@currentHC DECIMAL(10,2)
		,@requiredHC DECIMAL(10,2)

		SELECT @requiredHC = [dbo].[udf_GetRequiredHC](@SiteID,@CampaignID,@LobID,@Date)
		SELECT @currentHC = [dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,69)
		SELECT @Value=@currentHC-@requiredHC
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetPlannedProdHrs]...';


GO
CREATE FUNCTION [dbo].[udf_GetPlannedProdHrs]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	

	SELECT @Value=[dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)
		+[dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)
		+[dbo].[udf_NestingProdHrs](@SiteID,@CampaignID,@LobID,@Date)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetProjectedCapacity]...';


GO
CREATE FUNCTION [dbo].[udf_GetProjectedCapacity]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--(@ProdProdHrs*3600/ahc5)+(@SMEProdHrs*3600/ahc5)
	SELECT @Value=([dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)*3600/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,5),0))
				+([dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)*3600/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,5),0))
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetAnsweredToCapacityPerc]...';


GO
CREATE FUNCTION [dbo].[udf_GetAnsweredToCapacityPerc]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--(ahc8-@ProjectedCapacity)/@ProjectedCapacity
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,8)-[dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date))/NULLIF([dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetCapacityToForecastPerc]...';


GO
CREATE FUNCTION [dbo].[udf_GetCapacityToForecastPerc]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	-- (@ProjectedCapacity-ahc6)/ahc6	
	SELECT @Value= ([dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetPlannedFTE]...';


GO
CREATE FUNCTION [dbo].[udf_GetPlannedFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	

	SELECT @Value=[dbo].[udf_GetPlannedProdHrs](@SiteID,@CampaignID,@LobID,@Date)*40

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetExcessDeficitFTE]...';


GO
CREATE FUNCTION [dbo].[udf_GetExcessDeficitFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	

	SELECT @Value=[dbo].[udf_GetPlannedFTE](@SiteID,@CampaignID,@LobID,@Date)-[dbo].[udf_GetRequiredFTE](@SiteID,@CampaignID,@LobID,@Date)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
	@WeeklyDatapointTableType [dbo].[WeeklyDatapointTableType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
	BEGIN TRY
		BEGIN TRANSACTION
		--UPDATE FIRST Related Data
		UPDATE w
		SET w.[Data]=wt.DataValue,
			w.ModifiedBy=wt.UserName,
			w.DateModified=wt.DateModified
		FROM WeeklyAHDatapoint w
		INNER JOIN @WeeklyDatapointTableType wt ON wt.DatapointID=w.DatapointID	
			AND wt.[Date]=w.[Date]
			AND wt.LoBID=w.LoBID
			AND wt.SiteID=w.SiteID
			AND wt.CampaignID=w.CampaignID

		--cascade to remaining data.

		DECLARE @Date DATE

		SELECT @Date = MAX([Date]) FROM @WeeklyDatapointTableType
		DECLARE @tbl AS TABLE
		(
			DatapointID BIGINT,
			SiteID BIGINT,
			CampaignID BIGINT,
			LobID BIGINT,
			DataValue NVARCHAR(MAX),
			DateMofidifed DATETIME,
			ModifiedBy NVARCHAR(50)
		)

		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LoBID,DataValue,DateModified,UserName,SiteID,CampaignID
		FROM @WeeklyDatapointTableType
		WHERE [Date]=@Date

		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyAHDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date

		--*****************************************
		-- CREATE AND COMPUTE WeeklyStaffDatapoint*
		--*****************************************
		--check if WeeklyStaffDatapoint is empty
		DECLARE @LobID BIGINT=0
			,@CampaignID BIGINT=0
			,@SiteID BIGINT=0
			,@Date2 DATE
			,@DateModified DATETIME
			,@Username NVARCHAR(20)

		--SELECT DISTINCT @LobID=LoBID 
		--	,@DateModified=DateModified
		--	,@Username=Username
		--FROM @WeeklyDatapointTableType
		
		--SELECT @CampaignID=CampaignID FROM LoB WHERE ID=@LobID

		SELECT TOP 1 @LobID=w.LoBID
			,@CampaignID=w.CampaignID 
			,@SiteID=w.SiteID
			,@Username=w.UserName
			,@DateModified=w.DateModified
		FROM @WeeklyDatapointTableType w
		--INNER JOIN LoB l ON l.ID=w.LoBID

		--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		--Set up and compute weeklystaffdatapoint
		DECLARE @StaffDatapoint AS TABLE
		(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,RequiredHC DECIMAL(10,2)			
			,CurrentHC DECIMAL(10,2)
			,ExcessDeficitHC DECIMAL(10,2)
			,RequiredFTE DECIMAL(10,2)
			,PlannedFTE DECIMAL(10,2)
			,TeleoptiRequiredFTE DECIMAL(10,2)
			,ExcessDeficitFTE DECIMAL(10,2)
			,BaseHours DECIMAL(10,2)
			,NetReqHours DECIMAL(10,2)
			,PlannedProdHrs DECIMAL(10,2)
			,ProdProdHrs DECIMAL(10,2)
			,SMEProdHrs DECIMAL(10,2)
			,NestingProdHrs DECIMAL(10,2)
			,PlannedTrainingHrs DECIMAL(10,2)
			,RequiredVolFTE DECIMAL(10,2)
			,ProjectedCapacity DECIMAL(10,2)
			,CapacityToForecastPerc DECIMAL(10,2)					
			,ActualToForecastPerc DECIMAL(10,2)
			,AnsweredToForecastPerc DECIMAL(10,2)
			,AnsweredToCapacityPerc DECIMAL(10,2)
			,BillableHC DECIMAL(10,2)								
			,CurrentBillableHC DECIMAL(10,2)
			,BillableExcessDeficit DECIMAL(10,2)
		)
		INSERT INTO @StaffDatapoint
			SELECT  
				DISTINCT(w.[Date]) 
				,w.SiteID
				,w.CampaignID
				,w.LoBID
				,[dbo].[udf_GetRequiredHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--3
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],69)
				,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--4
				,[dbo].[udf_GetRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--5
				,[dbo].[udf_GetPlannedFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--10
				,0
				,[dbo].[udf_GetExcessDeficitFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--11
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56) --1
				,[dbo].[udf_GetNetReqHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date]) --2
				,[dbo].[udf_GetPlannedProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--9
				,[dbo].[udf_GetProdProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--6
				,[dbo].[udf_GetSMEProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--7
				,[dbo].[udf_NestingProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--8
				,0
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)
				,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--12
				,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--13
				,[dbo].[udf_GetActualToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--14
				,[dbo].[udf_GetAnsweredToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--15
				,[dbo].[udf_GetAnsweredToCapacityPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--16
				,[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--17
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],66)
				,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--18
			FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.BaseHours,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(MAX)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(MAX)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(MAX)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(MAX)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		--xxxxxxx
		--CASCADE DATA 
		--xxxxxxx
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,Data,@DateModified,@Username,SiteID,CampaignID
		FROM WeeklyStaffDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID 
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyStaffDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date

		--end set up and compute weeklystaffdatapoint
		--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



		--*****************************************
		-- CREATE AND COMPUTE WeeklyHiringDatapoint*
		--*****************************************
		DECLARE @HiringDatapoint AS TABLE(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,NewCapacity NVARCHAR(MAX)
			,AttritionBackfill NVARCHAR(MAX)
		)

		INSERT INTO @HiringDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,CAST(CEILING([dbo].[wfmpcp_GetAHCDatapointValue_udf](w.LoBID,w.[Date],92)) AS NVARCHAR(MAX))
			,CAST(CEILING([dbo].[wfmpcp_GetAHCDatapointValue_udf](w.LoBID,w.[Date],93)) AS NVARCHAR(MAX))
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=NewCapacity
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyHiringDatapoint w
		INNER JOIN @HiringDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=AttritionBackfill
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyHiringDatapoint w
		INNER JOIN @HiringDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		--xxxxxxx
		--CASCADE DATA (hiring)
		--xxxxxxx
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username,SiteID,CampaignID
		FROM WeeklyHiringDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyHiringDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date
		--*****************************************
		-- END CREATE AND COMPUTE WeeklyHiringDatapoint*
		--*****************************************

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	    DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        IF @xstate = -1
             ROLLBACK TRANSACTION;
        if @xstate = 1 and @trancount = 0
             ROLLBACK TRANSACTION;
        if @xstate = 1 and @trancount > 0
            ROLLBACK TRANSACTION

        RAISERROR ('[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]: %d: %s', 16, 1, @error, @message) ;

		--IF @@TRANCOUNT > 0
		--	ROLLBACK TRANSACTION --RollBack in case of Error

		--RAISERROR(15600,-1,-1,'[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]')
	END CATCH
END
GO
PRINT N'Update complete.';


GO
