/******************************
** File: Buildscript_1.00.039.sql
** Name: Buildscript_1.00.039
** Auth: McNiel Viray
** Date: 12 July 2017
**************************
** Change History
**************************
** Alter stored procedures wfmpcp_SaveWeeklyAHDatapointDatatable_sp,[dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
** Alter user defined functions
** Create New Module and its association to role and user
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[udf_GetAHCDatapointValue]...';


GO
ALTER FUNCTION [dbo].[udf_GetAHCDatapointValue]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE,
	@DatapointID BIGINT
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL

	SELECT @Value=CAST(LTRIM(RTRIM(REPLACE([Data],'%',''))) AS DECIMAL)
	FROM WeeklyAHDatapoint 
	WHERE LoBID=@LobID 
		AND SiteID=@SiteID
		AND CampaignID=@CampaignID
		AND [Date]=@Date  
		AND DatapointID=@DatapointID

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetAnsweredToForecastPerc]...';


GO
ALTER FUNCTION [dbo].[udf_GetAnsweredToForecastPerc]
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
	
	--(ahc8-ahc6)/ahc6
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,8)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)
	
	RETURN ISNULL(@Value,0)
END
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
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,67)/NULLIF((1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,23)),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetNetReqHours]...';


GO
ALTER FUNCTION [dbo].[udf_GetNetReqHours]
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

		SELECT @basehours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
		
		SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)

		SELECT @ah17=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
		
		SELECT @Value=(@BaseHours/NULLIF(@ah54,0))/NULLIF((1-@ah17),0)
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetProdProdHrs]...';


GO
ALTER FUNCTION [dbo].[udf_GetProdProdHrs]
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
		,@a DECIMAL
		,@b DECIMAL
		,@c DECIMAL
		,@d DECIMAL
	
	SELECT @a=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,13) * 40
	SELECT @b=1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,23)
	SELECT @c=1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,18)
	SELECT @d=1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,31)

	SELECT @Value=@a*@b*@c*@d
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetRequiredFTE]...';


GO
ALTER FUNCTION [dbo].[udf_GetRequiredFTE]
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
		,@baseHours DECIMAL

	SELECT @baseHours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @Value=@baseHours/40
		
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

		SELECT @netReqHours=[dbo].[udf_GetNetReqHours](@SiteID,@CampaignID,@LobID,@Date)
		
		SELECT @ahc61=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
				
		SELECT @Value=(@netReqHours/40)*@ahc61
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetSMEProdHrs]...';


GO
ALTER FUNCTION [dbo].[udf_GetSMEProdHrs]
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

	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,58) * 20
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_NestingProdHrs]...';


GO
ALTER FUNCTION [dbo].[udf_NestingProdHrs]
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
		,@ah71 DECIMAL
		,@ah26 DECIMAL
		,@ah54 DECIMAL
	
	SELECT @ah71=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,71) * 40 
	SELECT @ah26=1-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,26)
	SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)

	SELECT @Value=@ah71*@ah26*@ah54

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetActualToForecastPerc]...';


GO
ALTER FUNCTION [dbo].[udf_GetActualToForecastPerc]
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
	
	--(ahc7-ahc6)/ahc6
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,7)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetBillableExcessDeficit]...';


GO
ALTER FUNCTION [dbo].[udf_GetBillableExcessDeficit]
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
	
	-- @CurrentBillableHC-@BillableHC	
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,66)-[dbo].[udf_GetBillableHC](@SiteID,@CampaignID,@LobID,@Date)

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

		SELECT @requiredHC = [dbo].[udf_GetRequiredHC](@SiteID,@CampaignID,@LobID,@Date)
		SELECT @currentHC = [dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,69)
		SELECT @Value=@currentHC-@requiredHC
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetPlannedProdHrs]...';


GO
ALTER FUNCTION [dbo].[udf_GetPlannedProdHrs]
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
	

	SELECT @Value=[dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)
		+[dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)
		+[dbo].[udf_NestingProdHrs](@SiteID,@CampaignID,@LobID,@Date)

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
	SELECT @Value=([dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)*3600/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,5),0))
				+([dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)*3600/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,5),0))
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetAnsweredToCapacityPerc]...';


GO
ALTER FUNCTION [dbo].[udf_GetAnsweredToCapacityPerc]
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
	
	--(ahc8-@ProjectedCapacity)/@ProjectedCapacity
	SELECT @Value=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,8)-[dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date))/NULLIF([dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetCapacityToForecastPerc]...';


GO
ALTER FUNCTION [dbo].[udf_GetCapacityToForecastPerc]
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
	
	-- (@ProjectedCapacity-ahc6)/ahc6	
	SELECT @Value= ([dbo].[udf_GetProjectedCapacity](@SiteID,@CampaignID,@LobID,@Date)-[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6))/NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6),0)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetPlannedFTE]...';


GO
ALTER FUNCTION [dbo].[udf_GetPlannedFTE]
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
	

	SELECT @Value=[dbo].[udf_GetPlannedProdHrs](@SiteID,@CampaignID,@LobID,@Date)*40

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetExcessDeficitFTE]...';


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
	

	SELECT @Value=[dbo].[udf_GetPlannedFTE](@SiteID,@CampaignID,@LobID,@Date)-[dbo].[udf_GetRequiredFTE](@SiteID,@CampaignID,@LobID,@Date)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
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
			DataValue NVARCHAR(250),
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
			,RequiredHC DECIMAL			
			,CurrentHC DECIMAL
			,ExcessDeficitHC DECIMAL
			,RequiredFTE DECIMAL
			,PlannedFTE DECIMAL
			,TeleoptiRequiredFTE DECIMAL
			,ExcessDeficitFTE DECIMAL
			,BaseHours DECIMAL
			,NetReqHours DECIMAL
			,PlannedProdHrs DECIMAL
			,ProdProdHrs DECIMAL
			,SMEProdHrs DECIMAL
			,NestingProdHrs DECIMAL
			,PlannedTrainingHrs DECIMAL
			,RequiredVolFTE DECIMAL
			,ProjectedCapacity DECIMAL
			,CapacityToForecastPerc DECIMAL					
			,ActualToForecastPerc DECIMAL
			,AnsweredToForecastPerc DECIMAL
			,AnsweredToCapacityPerc DECIMAL
			,BillableHC DECIMAL								
			,CurrentBillableHC DECIMAL
			,BillableExcessDeficit DECIMAL
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
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.BaseHours,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(250))
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
			,NewCapacity NVARCHAR(250)
			,AttritionBackfill NVARCHAR(250)
		)

		INSERT INTO @HiringDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,CAST(CEILING([dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],92)) AS NVARCHAR(250))
			,CAST(CEILING([dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],93)) AS NVARCHAR(250))
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
PRINT N'ALtering [dbo].[wfmpcp_GetStaffPlanner_sp]...'
GO
ALTER PROCEDURE [dbo].[wfmpcp_GetStaffPlanner_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@segmentid  AS NVARCHAR(MAX)='',
	@siteID AS NVARCHAR(MAX)='',
	@campaignID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyStaffDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')


		UPDATE WeeklyStaffDatapoint
		SET [Data]=
				CASE DatapointID 
					WHEN 1 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 2 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 3 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 5 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 7 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 8 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 13 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
					WHEN 14 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
					WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 21 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 22 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					ELSE CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(10)) END
		--FROM WeeklyStaffDatapoint 
		WHERE Lobid=CAST(@lobid AS BIGINT)
			AND SiteID=CAST(@siteID AS BIGINT)
			AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyStaffDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')


		UPDATE WeeklyStaffDatapoint
		SET [Data]=
				CASE DatapointID 
					WHEN 1 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 2 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 3 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 5 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 7 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 8 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
					WHEN 13 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
					WHEN 14 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
					WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
					WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 21 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 22 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
					ELSE CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(10)) END
		--FROM WeeklyStaffDatapoint 
		WHERE Lobid=CAST(@lobid AS BIGINT)
			AND SiteID=CAST(@siteID AS BIGINT)
			AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklyStaffDatapoint
					 ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN StaffDatapoint d ON d.ID=A.DatapointID
				INNER JOIN StaffSegment s ON s.ID=d.SegmentID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklyStaffDatapoint
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN StaffDatapoint d ON d.ID=A.DatapointID
				INNER JOIN StaffSegment s ON s.ID=d.SegmentID
				WHERE 1=1 '
	END
	
	IF(@segmentid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.ID=' + @segmentid
	END

	IF(@lobid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.LoBID=' + @lobid
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.CampaignID=' + @campaignID
	END	

	SET @orderBy = ' ORDER BY s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]...'
GO
ALTER PROCEDURE [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@tablename AS NVARCHAR(MAX)='WeeklyAHDatapoint',
	@segmentcategoryid  AS NVARCHAR(MAX)='',
	@segmentid  AS NVARCHAR(MAX)='',
	@siteID AS NVARCHAR(MAX)='',
	@campaignID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		UPDATE WeeklyAHDatapoint
			SET [Data]=
			CASE DatapointID 
				WHEN 1 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 2 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 3 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
				WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 5 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 7 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 8 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + '%'
				WHEN 13 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 14 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 21 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 22 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 23 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 24 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 25 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 26 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 27 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 28 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 29 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 30 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 31 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 32 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 33 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 34 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 35 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 36 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 37 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 38 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 39 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 40 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 41 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 42 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 43 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 44 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 45 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 46 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 47 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 48 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 49 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 50 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 51 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 52 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 53 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 54 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 55 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 56 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 57 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 58 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 59 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 60 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 61 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 62 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 63 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 64 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 65 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 66 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 67 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 68 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 69 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 70 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 71 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 72 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 73 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 74 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 75 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 76 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 77 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 78 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 79 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 80 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 81 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 82 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 83 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 84 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 85 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 86 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 87 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 91 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 92 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 93 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 94 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 95 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 96 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 97 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 98 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 99 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 100 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 101 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 102 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 103 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 104 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 105 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 106 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 107 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 108 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 109 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 110 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 111 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 112 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 113 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 114 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 115 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 116 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 117 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				ELSE [Data]	END
			WHERE Lobid=CAST(@lobid AS BIGINT)
				AND SiteID=CAST(@siteID AS BIGINT)
				AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyAHDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		UPDATE WeeklyAHDatapoint
			SET [Data]=
			CASE DatapointID 
				WHEN 1 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 2 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 3 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) 
				WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 5 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 7 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 8 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + '%'
				WHEN 13 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 14 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 21 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 22 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 23 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 24 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 25 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 26 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 27 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 28 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 29 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 30 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 31 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 32 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 33 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 34 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 35 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 36 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 37 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 38 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 39 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 40 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 41 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 42 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 43 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 44 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 45 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 46 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 47 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 48 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 49 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 50 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 51 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 52 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 53 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 54 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 55 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 56 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 57 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 58 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 59 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 60 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 61 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX))
				WHEN 62 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 63 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 64 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 65 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 66 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 67 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 68 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 69 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 70 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 71 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 72 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 73 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 74 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 75 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 76 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 77 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 78 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 79 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 80 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 81 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 82 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 83 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 84 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 85 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 86 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 87 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 91 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 92 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 93 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 94 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 95 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 96 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 97 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 98 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 99 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 100 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 101 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 102 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 103 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 104 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 105 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 106 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 107 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 108 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 109 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 110 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 111 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 112 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 113 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 114 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 115 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 116 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				WHEN 117 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(ISNULL(NULLIF(Data,''),'0'),'%',''))) AS DECIMAL(38,2)),0)) AS NVARCHAR(MAX))
				ELSE [Data]	END
			WHERE Lobid=CAST(@lobid AS BIGINT)
				AND SiteID=CAST(@siteID AS BIGINT)
				AND CampaignID=CAST(@campaignID AS BIGINT)
			AND [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],Data from ' + @tablename + 
					' ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN Datapoint d ON d.ID=A.DatapointID
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],Data from ' + @tablename + 
					' ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN Datapoint d ON d.ID=A.DatapointID
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				WHERE 1=1 '
	END

	IF(@segmentcategoryid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.SegmentCategoryID=' + @segmentcategoryid
	END

	IF(@segmentid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND s.ID=' + @segmentid
	END

	IF(@lobid != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.LoBID=' + @lobid
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.CampaignID=' + @campaignID
	END	

	SET @orderBy = ' ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetHiringRequirements_sp]...'
GO
ALTER PROCEDURE [dbo].[wfmpcp_GetHiringRequirements_sp]
	@campaignID AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@siteID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyStaffDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyStaffDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT l.Name [Lob], d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklyHiringDatapoint
					 ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN HiringDatapoint d ON d.ID=A.DatapointID
				INNER JOIN Lob l ON l.ID=A.LobID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklyHiringDatapoint
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN HiringDatapoint d ON d.ID=A.DatapointID
				INNER JOIN Lob l ON l.ID=A.LobID
				WHERE 1=1 '
	END
	
	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND A.CampaignID=' + @campaignID
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	SET @orderBy = ' ORDER BY l.Name,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetHiringRequirementsTotal_sp]...';
GO
ALTER PROCEDURE [dbo].[wfmpcp_GetHiringRequirementsTotal_sp]
	@campaignID AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@siteID AS NVARCHAR(MAX)=''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@whereClause AS NVARCHAR(MAX) = ' '
		,@orderBy AS NVARCHAR(MAX)

	IF(@start <> '' AND @end <> '')
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyStaffDatapoint
							WHERE [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
	ELSE
	BEGIN
		SELECT @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
							FROM WeeklyStaffDatapoint
							WHERE [Date] BETWEEN DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AND DATEADD(MONTH,12,GETDATE())
							GROUP BY [Date]
							ORDER BY [Date]
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')
	END
		
	IF(@includeDatapoint=1)
	BEGIN
		SET @select = '
				SELECT d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,datapointid,[Date],[Data]=CAST([Data] AS BIGINT) from WeeklyHiringDatapoint
					 ) x		
					PIVOT
					(
						SUM(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN HiringDatapoint d ON d.ID=A.DatapointID
				WHERE 1=1 '
	END
	ELSE
	BEGIN
		SET @select = '
				SELECT ' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT SiteID,CampaignID,datapointid,[Date],[Data]=CAST([Data] AS BIGINT) from WeeklyHiringDatapoint
					) x		
					PIVOT
					(
						SUM(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN HiringDatapoint d ON d.ID=A.DatapointID
				WHERE 1=1 '
	END
	
	IF(@campaignID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND A.CampaignID=' + @campaignID
	END	

	IF(@siteID != '')
	BEGIN
		SET @whereClause = @whereClause + ' AND a.SiteID=' + @siteID
	END	

	SET @orderBy = ' ORDER BY d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Create MOdule..'
DECLARE @ModuleID BIGINT

INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(12,'Hiring Requirements','fa-tag','/CapacityPlanner/HiringRequirements',3,'McNiel Viray')

SELECT @ModuleID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ModuleID,5,1,'McNiel Viray',1)

GO
PRINT N'Update complete.';


GO
