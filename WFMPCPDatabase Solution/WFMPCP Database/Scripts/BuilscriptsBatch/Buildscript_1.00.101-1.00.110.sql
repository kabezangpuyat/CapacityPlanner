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

/******************************
** File: Buildscript_1.00.102.sql
** Name: Buildscript_1.00.102
** Auth: McNiel Viray	
** Date: 29 October 2018
**************************
** Change History
**************************
** Modify [dbo].[udf_Dynamic_Straight]
** Modify [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
** Modify [dbo].[udf_GetExcessDeficitFTE]
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 102

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
	SELECT @Value=((((@ahc10 * @ahc121)/3600)/NULLIF(@ahc58Perc,0))/40)/NULLIF(@1minusahc21percminusahc23,0)

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
		,@plannedFTE DECIMAL(10,3) 
		,@netFTE DECIMAL(10,3)
	--'= C8 - C7
	
	SELECT @plannedFTE=[dbo].[udf_GetPlannedNetFTE](@SiteID,@CampaignID,@LobID,@Date)
	SELECT @netFTE=[dbo].[udf_GetRequiredNetFTE](@SiteID,@CampaignID,@LobID,@Date)

	SELECT @Value=@plannedFTE-@netFTE

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
			,RequiredHC DECIMAL--1
			,CurrentHC DECIMAL--2
			,ExcessDeficitHC DECIMAL--3
			,RequiredFTE DECIMAL--4
			,PlannedFTE DECIMAL--5
			,TeleoptiRequiredFTE DECIMAL--6
			,ExcessDeficitFTE DECIMAL--7
			,BaseHours DECIMAL--8
			,NetReqHours DECIMAL--9
			,PlannedProdHrs DECIMAL--10
			,ProdProdHrs DECIMAL--11
			,SMEProdHrs DECIMAL--12
			,NestingProdHrs DECIMAL--13
			,PlannedTrainingHrs DECIMAL--14
			,RequiredVolFTE DECIMAL--15
			,ProjectedCapacity DECIMAL--16
			,CapacityToForecastPerc DECIMAL--17				
			,ActualToForecastPerc DECIMAL--18
			,AnsweredToForecastPerc DECIMAL--19
			,AnsweredToCapacityPerc DECIMAL--20
			,BillableHC DECIMAL--21				
			,CurrentBillableHC DECIMAL--22
			,BillableExcessDeficit DECIMAL--23
			,TotalProductionFullTime DECIMAL--24
			,TotalProductionPartTime DECIMAL--25
			,TotalNestingFullTime DECIMAL--26
			,TotalNestingPartTime DECIMAL--27
			,TotalTrainingFullTime DECIMAL--28
			,TotalTrainingPartTime DECIMAL--29
		)
		INSERT INTO @StaffDatapoint
			SELECT  
				DISTINCT(w.[Date]) 
				,w.SiteID
				,w.CampaignID
				,w.LoBID
				,[dbo].[udf_GetGrossRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 1
				,[dbo].[udf_GetCurrentGrossFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 2
				,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 3
				,[dbo].[udf_GetRequiredNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:4
				,[dbo].[udf_GetPlannedNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:5
				,0--StaffDatapointID: 6
				,[dbo].[udf_GetExcessDeficitFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 7
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56) --StaffDatapointID: 8
				,[dbo].[udf_GetGrossRequiredHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date]) --StaffDatapointID: 9
				,[dbo].[udf_GetPlannedProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 10
				,[dbo].[udf_GetProdProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 11
				,[dbo].[udf_GetSMEProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 12
				,[dbo].[udf_NestingProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 13
				,[dbo].[udf_GetPlannedTrainingHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 14
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--StaffDatapointID: 15
				,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 16
				,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 17
				,[dbo].[udf_GetActualToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 18
				,[dbo].[udf_GetAnsweredToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 19
				,[dbo].[udf_GetAnsweredToCapacityPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 20
				,[dbo].[udf_GetGrossRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 21
				,[dbo].[udf_GetCurrentGrossFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],66)--StaffDatapointID: 22
				,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 23
				,[dbo].[udf_GetTotalProductionFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:24
				,[dbo].[udf_GetTotalProductionPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:25
				,[dbo].[udf_GetTotalNestingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:26
				,[dbo].[udf_GetTotalNestingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:27
				,[dbo].[udf_GetTotalTrainingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:28
				,[dbo].[udf_GetTotalTrainingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:29
			FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.RequiredHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.CurrentHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitHC) = 0 THEN '0'
				ELSE CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredFTE) = 0 THEN '0'
				ELSE CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TeleoptiRequiredFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitFTE) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BaseHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.BaseHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NetReqHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProdProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.SMEProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NestingProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedTrainingHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredVolFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProjectedCapacity) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CapacityToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ActualToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=
			CASE
				WHEN ISNUMERIC(s.AnsweredToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.AnsweredToCapacityPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CurrentBillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableExcessDeficit) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

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
		

		--***************************************
		-- CREATE WeeklySummaryDatapoint
		--***************************************
		DECLARE @SummaryDatapoint AS TABLE(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,TargetServiceLevel DECIMAL--1
			,ProjectedServiceLevel DECIMAL--2
			,ActualServiceLevel DECIMAL--3
			,VolumeForecast DECIMAL--4
			,VolumeOffered DECIMAL--5
			,VolumeHandled DECIMAL--6
			,VolumeCapacity DECIMAL--7
			,VolumeVarianceOfferedvsForecast DECIMAL--8
			,TargetAHT DECIMAL--9
			,ActualAHT DECIMAL--10
			,AHTVariancePercentagetoGoal DECIMAL--11
			,TargetProductionHours DECIMAL--12
			,ActualProductionHours DECIMAL--13
			,ProductionHoursVariance DECIMAL--14
			,BillableHeadcount DECIMAL--15
			,RequiredHeadcount DECIMAL--16
			,ActualProductionHeadcount DECIMAL--17
			,ActualNestingHeadcount DECIMAL--18
			,ActualTrainingHeadcount DECIMAL--19
			,BillableExcessDeficits DECIMAL--20
			,RequiredExcessDeficits DECIMAL--21
			,ProductionAttrition DECIMAL--22
			,NestingTrainingAttrition DECIMAL--23
			,NestingAttrition DECIMAL--24
			,TrainingAttrition DECIMAL--25
			,TotalTargetShrinkage DECIMAL--26
			,TargetIncenterShrinkage DECIMAL--27
			,TargetOutofcenterShrinkage DECIMAL--28
			,TotalActualShrinkage DECIMAL--29
			,ActualIncenterShrinkage DECIMAL--30
			,ActualOutofcenterShrinkage DECIMAL--31
			,ShrinkageVarianceTargetActual DECIMAL--32
			,TargetOccupancy DECIMAL--33
			,ActualOccupancy DECIMAL--34
		)

		INSERT INTO @SummaryDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],1)--1
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],2)--2
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],4)--3
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--4
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],7)--5
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],8)--6
			,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--7
			,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--8
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],9)--9
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],11)--10
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],12)--11
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56)--12
			,0--13
			,0--14
			,[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--15
			,[dbo].[udf_GetRequiredHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--16
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],80)--17
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],81)--18
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],86)--19
			,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--20
			,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--21
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],95)--22
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--23
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)--24
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--25
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)--26
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--27
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],23)--28
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],35)--29
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],36)--30
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],41)--31
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],26)-[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],29)--32--Original as of 10.26.2017 [dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--32
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],54)--33
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],55)--34
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProjectedServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProjectedServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeForecast) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeForecast,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeOffered) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeOffered,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeHandled) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeHandled,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeCapacity) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeCapacity,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeVarianceOfferedvsForecast) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.VolumeVarianceOfferedvsForecast,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.AHTVariancePercentagetoGoal) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.AHTVariancePercentagetoGoal,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionHoursVariance) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionHoursVariance,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualNestingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualNestingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualTrainingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualTrainingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingTrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingTrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalTargetShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TotalTargetShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOutofcenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalActualShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.TotalActualShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=30

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOutofcenterShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.ActualOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=31

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ShrinkageVarianceTargetActual) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ShrinkageVarianceTargetActual,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=32

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=33

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=34

		--CASCADE Summary data
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username,SiteID,CampaignID
		FROM WeeklySummaryDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklySummaryDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date
		--***************************************
		-- END CREATE WeeklySummaryDatapoint
		--***************************************

		SELECT TOP 1 @Username = UserName
			,@DateModified = DateModified
	    FROM @WeeklyDatapointTableType

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyAHDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyHiringDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyStaffDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklySummaryDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

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
PRINT N'Refreshing [dbo].[wfmpcp_SaveAHCStagingToActual_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveAHCStagingToActual_sp]';


GO
PRINT N'Update complete.';


GO


/******************************
** File: Buildscript_1.00.103.sql
** Name: Buildscript_1.00.103
** Auth: McNiel Viray	
** Date: 29 October 2018
**************************
** Change History
**************************
** Modify [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 103

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
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
			,RequiredHC DECIMAL--1
			,CurrentHC DECIMAL--2
			,ExcessDeficitHC DECIMAL--3
			,RequiredFTE DECIMAL--4
			,PlannedFTE DECIMAL--5
			,TeleoptiRequiredFTE DECIMAL--6
			,ExcessDeficitFTE DECIMAL--7
			,BaseHours DECIMAL--8
			,NetReqHours DECIMAL--9
			,PlannedProdHrs DECIMAL--10
			,ProdProdHrs DECIMAL--11
			,SMEProdHrs DECIMAL--12
			,NestingProdHrs DECIMAL--13
			,PlannedTrainingHrs DECIMAL--14
			,RequiredVolFTE DECIMAL--15
			,ProjectedCapacity DECIMAL--16
			,CapacityToForecastPerc DECIMAL--17				
			,ActualToForecastPerc DECIMAL--18
			,AnsweredToForecastPerc DECIMAL--19
			,AnsweredToCapacityPerc DECIMAL--20
			,BillableHC DECIMAL--21				
			,CurrentBillableHC DECIMAL--22
			,BillableExcessDeficit DECIMAL--23
			,TotalProductionFullTime DECIMAL--24
			,TotalProductionPartTime DECIMAL--25
			,TotalNestingFullTime DECIMAL--26
			,TotalNestingPartTime DECIMAL--27
			,TotalTrainingFullTime DECIMAL--28
			,TotalTrainingPartTime DECIMAL--29
		)
		INSERT INTO @StaffDatapoint
			SELECT  
				DISTINCT(w.[Date]) 
				,w.SiteID
				,w.CampaignID
				,w.LoBID
				,[dbo].[udf_GetGrossRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 1
				,[dbo].[udf_GetCurrentGrossFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 2
				,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 3
				,[dbo].[udf_GetRequiredNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:4
				,[dbo].[udf_GetPlannedNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:5
				,0--StaffDatapointID: 6
				,[dbo].[udf_GetExcessDeficitFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 7
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56) --StaffDatapointID: 8
				,[dbo].[udf_GetGrossRequiredHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date]) --StaffDatapointID: 9
				,[dbo].[udf_GetPlannedProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 10
				,[dbo].[udf_GetProdProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 11
				,[dbo].[udf_GetSMEProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 12
				,[dbo].[udf_NestingProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 13
				,[dbo].[udf_GetPlannedTrainingHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 14
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--StaffDatapointID: 15
				,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 16
				,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 17
				,[dbo].[udf_GetActualToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 18
				,[dbo].[udf_GetAnsweredToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 19
				,[dbo].[udf_GetAnsweredToCapacityPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 20
				,[dbo].[udf_GetGrossRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 21
				,[dbo].[udf_GetCurrentGrossFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],66)--StaffDatapointID: 22
				,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 23
				,[dbo].[udf_GetTotalProductionFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:24
				,[dbo].[udf_GetTotalProductionPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:25
				,[dbo].[udf_GetTotalNestingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:26
				,[dbo].[udf_GetTotalNestingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:27
				,[dbo].[udf_GetTotalTrainingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:28
				,[dbo].[udf_GetTotalTrainingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:29
			FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.RequiredHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.CurrentHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitHC) = 0 THEN '0'
				ELSE CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredFTE) = 0 THEN '0'
				ELSE CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TeleoptiRequiredFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitFTE) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BaseHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.BaseHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NetReqHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProdProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.SMEProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NestingProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedTrainingHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredVolFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProjectedCapacity) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CapacityToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ActualToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=
			CASE
				WHEN ISNUMERIC(s.AnsweredToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.AnsweredToCapacityPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CurrentBillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableExcessDeficit) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

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
		

		--***************************************
		-- CREATE WeeklySummaryDatapoint
		--***************************************
		DECLARE @SummaryDatapoint AS TABLE(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,TargetServiceLevel DECIMAL--1
			,ProjectedServiceLevel DECIMAL--2
			,ActualServiceLevel DECIMAL--3
			,VolumeForecast DECIMAL--4
			,VolumeOffered DECIMAL--5
			,VolumeHandled DECIMAL--6
			,VolumeCapacity DECIMAL--7
			,VolumeVarianceOfferedvsForecast DECIMAL--8
			,TargetAHT DECIMAL--9
			,ActualAHT DECIMAL--10
			,AHTVariancePercentagetoGoal DECIMAL--11
			,TargetProductionHours DECIMAL--12
			,ActualProductionHours DECIMAL--13
			,ProductionHoursVariance DECIMAL--14
			,BillableHeadcount DECIMAL--15
			,RequiredHeadcount DECIMAL--16
			,ActualProductionHeadcount DECIMAL--17
			,ActualNestingHeadcount DECIMAL--18
			,ActualTrainingHeadcount DECIMAL--19
			,BillableExcessDeficits DECIMAL--20
			,RequiredExcessDeficits DECIMAL--21
			,ProductionAttrition DECIMAL--22
			,NestingTrainingAttrition DECIMAL--23
			,NestingAttrition DECIMAL--24
			,TrainingAttrition DECIMAL--25
			,TotalTargetShrinkage DECIMAL--26
			,TargetIncenterShrinkage DECIMAL--27
			,TargetOutofcenterShrinkage DECIMAL--28
			,TotalActualShrinkage DECIMAL--29
			,ActualIncenterShrinkage DECIMAL--30
			,ActualOutofcenterShrinkage DECIMAL--31
			,ShrinkageVarianceTargetActual DECIMAL--32
			,TargetOccupancy DECIMAL--33
			,ActualOccupancy DECIMAL--34
		)

		INSERT INTO @SummaryDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],1)--1
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],2)--2
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],4)--3
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--4
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],7)--5
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],8)--6
			,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--7
			,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--8
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],9)--9
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],11)--10
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],12)--11
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56)--12
			,0--13
			,0--14
			,[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--15
			,[dbo].[udf_GetRequiredHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--16
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],80)--17
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],81)--18
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],86)--19
			,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--20
			,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--21
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],95)--22
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--23
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)--24
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--25
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)--26
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--27
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],23)--28
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],35)--29
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],36)--30
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],41)--31
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],26)-[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],29)--32--Original as of 10.26.2017 [dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--32
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],54)--33
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],55)--34
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProjectedServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProjectedServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeForecast) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeForecast,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeOffered) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeOffered,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeHandled) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeHandled,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeCapacity) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeCapacity,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeVarianceOfferedvsForecast) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.VolumeVarianceOfferedvsForecast,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.AHTVariancePercentagetoGoal) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.AHTVariancePercentagetoGoal,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionHoursVariance) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionHoursVariance,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualNestingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualNestingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualTrainingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualTrainingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingTrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingTrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalTargetShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TotalTargetShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOutofcenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalActualShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.TotalActualShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=30

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOutofcenterShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.ActualOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=31

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ShrinkageVarianceTargetActual) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ShrinkageVarianceTargetActual,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=32

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=33

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=34

		--CASCADE Summary data
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username,SiteID,CampaignID
		FROM WeeklySummaryDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklySummaryDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date
		--***************************************
		-- END CREATE WeeklySummaryDatapoint
		--***************************************

		SELECT TOP 1 @Username = UserName
			,@DateModified = DateModified
	    FROM @WeeklyDatapointTableType

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyAHDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyHiringDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyStaffDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklySummaryDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

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



/******************************
** File: Buildscript_1.00.104.sql
** Name: Buildscript_1.00.104
** Auth: McNiel Viray
** Date: 22 April 2019
**************************
** Change History
**************************
** Modified ErlangC formula
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 104

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END


GO

DROP FUNCTION [dbo].[udf_ErlangC_Formula];

GO

DROP FUNCTION [dbo].[udf_ErlangCFormula]
GO

CREATE FUNCTION [dbo].[udf_ErlangCFormula]
(
     @NumberOfCalls NUMERIC(10,3)=200 --OR VOLUME 100 # of calls are per hour basis, no need to include perioofcallsinminutes
	--,@PeriodOfCallsInMinutes NUMERIC(10,3)=30 --INTERVAL // period of calls in not needed
	,@AHTInSeconds NUMERIC(10,3)=180--(3 minutes)
	,@RequiredServiceLevelPerc NUMERIC(10,3)=80 -- TARGET SERVICE LEVEL
	,@TargetAnswerTimeInSeconds NUMERIC(10,3)=20
	,@NewN NUMERIC = NULL
)
RETURNS @returntable TABLE
(
	NumberOfAgentsRequired NUMERIC(18,0)
	,ServiceLevel NUMERIC(18,2)
	,ServiceLevelPerc NUMERIC(18,2)
	,[Pw/Erlang] NUMERIC(18,2)
	,ProbabilityOfCallToWaitPerc NUMERIC(18,2)
	,ASA NUMERIC(18,4)
	,ImmediateAnswerPerc NUMERIC(18,2)
	,TargetAnswerTimeInSeconds NUMERIC(10,3)
	,AHTInSeconds NUMERIC(10,3)	
	,RequiredServiceLevelPerc NUMERIC(10,3)
	,N NUMERIC(18,0)
	,X NUMERIC(18,3)
	,Y NUMERIC(18,2)
	,A NUMERIC(18,0)
	,AHTSec  NUMERIC(10,3)	
	,OccupancyPerc NUMERIC(18,2)	
)
AS
BEGIN

	DECLARE @A NUMERIC -- TRAFFIC INTESITY / ERLANG
		,@N NUMERIC -- RAW NUMBER OF AGENTS REQUIRED
		,@NumberOfCallsPerHour NUMERIC
		,@ServiceLevelPerc NUMERIC(10,3)=0
		,@X NUMERIC(18,3)
		,@Y NUMERIC(18,3)
		,@Pw NUMERIC(18,2)
		,@PwPerc NUMERIC(18,2)
		,@SL NUMERIC(18,2)
		,@SLPerc NUMERIC(18,2)
		,@ASA NUMERIC(18,2) --Average Speed of Answer
		,@ImmediateAnswerPerc NUMERIC(18,2)
		,@OccupancyPerc NUMERIC(18,2)
		,@NumberOfAgentsRequired NUMERIC(18,0)

	--2. Work Out the Number of Calls Per Hour
	SET @NumberOfCallsPerHour = @NumberOfCalls
	
	--3. Work Out the Traffic Intensity (A)
	DECLARE @AHTInMinutes NUMERIC(10,3)=@AHTInSeconds/60
	SET  @A = (@NumberOfCallsPerHour*(@AHTInMinutes))/60
	
	--4. Estimate the Raw Number of Agents Required (N)
	--   Initial value is A+1
	--   TODO: loop until we meet @RequiredServiceLevelPerc compare to @ServiceLevelPerc
	SET @N=ISNULL(@NewN,(@A+1))
	
	
	--5. Calculate the Erlang Formula for Probability a Call Waits (SKIP)
	--6. Work Out N! (N Factorial) (SKIP)
	--7. Be Careful With Large Factorials (SKIP)
	--                           n
	--8. Work Out the Powers – A   (SKIP) 
	--9. Let’s Simplify the Erlang C Formula
	--       X  / ( Y + X )


	--10. Let’s Work Out the Top Row of the Erlang Formula (X)
	--NUMERATOR FIRST (X)
	--   n
	-- A      *  N
	--___       ___
	-- N!        N-A

	DECLARE @NumeratorA NUMERIC(10,3)
			,@NumeratorB NUMERIC(10,3)			

	SET @NumeratorA = POWER(@A,@N)/[dbo].[udf_Fact](@N);
	SET @NumeratorB = @N/NULLIF((@N-@A),0);
	SET @X = @NumeratorA*@NumeratorB;

	---11. Work Out the Sum of a Series (Y) or ΣApowerofI/i!
	--LOOP @N
	DECLARE @i NUMERIC = 0
		,@EaPowOfiDivIFact NUMERIC(18,2)=0

	DECLARE @tblY AS TABLE(
		i NUMERIC(18,2)
		,iFactorial NUMERIC(18,2)
	 	,APowerofI NUMERIC(18,2)
		,APowerofIDivideIFactorial NUMERIC(18,2)
		,SumOfAPowerofIDivideIFactorial NUMERIC(18,2)
	);
	WHILE(@i <= (@N-1))
	BEGIN
		DECLARE @iFact NUMERIC(18,2)
			,@aPowI NUMERIC(18,2)
			,@aPowOfiDivIFact NUMERIC(18,2)
			

		SET @iFact = [dbo].[udf_Fact](@i)
		SET @aPowI = POWER(@A,@i)
		SET @aPowOfiDivIFact = @aPowI/@iFact
		SET @EaPowOfiDivIFact = @EaPowOfiDivIFact + @aPowOfiDivIFact

		--SELECT @i,@iFact,@aPowI,@aPowOfiDivIFact,@EaPowOfiDivIFact

		INSERT INTO @tblY(i,iFactorial,APowerofI,APowerofIDivideIFactorial,SumOfAPowerofIDivideIFactorial)
		VALUES(@i,@iFact,@aPowI,@aPowOfiDivIFact,@EaPowOfiDivIFact);

		SET @i = @i + 1
		
	END

	SELECT TOP 1 @Y = SumOfAPowerofIDivideIFactorial
	FROM @tblY ORDER BY i DESC

	--12. Put X and Y into the Erlang C Formula (The probability a call has to wait)
	SET @Pw = @X/NULLIF((@Y+@X),0)
	SET @PwPerc = @Pw*100


	--13. Calculate the Service Level
		-- 13.1 Let’s work out -(N – A) * (TargetTime / AHT)
		DECLARE @exponent NUMERIC(18,3)
		SET @exponent = -((@N-@A)*(@TargetAnswerTimeInSeconds/@AHTInSeconds))
		
	--SELECT @exponent,@TargetAnswerTimeInSeconds,@AHTInSeconds,(@TargetAnswerTimeInSeconds/@AHTInSeconds)
	SET @SL = 1-(@Pw*EXP(@exponent))
	SET @SLPerc = @SL*100

	IF(@SLPerc<@RequiredServiceLevelPerc)
	BEGIN
		DECLARE @NIncrement NUMERIC 
		SET @NIncrement = @N + 1

		INSERT @returntable
		SELECT * FROM [dbo].[udf_ErlangCFormula](@NumberOfCalls,@AHTInSeconds,@RequiredServiceLevelPerc,@TargetAnswerTimeInSeconds,@NIncrement)
	END
	ELSE
	BEGIN

		--15.  Average Speed of Answer (ASA)
		-- ASA = Pw(AHT)/(No.of Agents-Traffic Intesity)
		SET @ASA = (@Pw*@AHTInSeconds)/(@N-@A)

		--16. Percentage of Calls Answered Immediately
		--Immediate Answer = (1-Pw)x100
		SET @ImmediateAnswerPerc = (1-@Pw)*100

		--17. Check Maximum Occupancy
		--Occupancy = (([TrafficIntensity or A])/[RawAgents or N] )* 100
		SET @OccupancyPerc = (@A/@N) * 100
		IF @OccupancyPerc>85
		BEGIN
			SET @OccupancyPerc= @A/(@OccupancyPerc/100)
		END

		--18. Factor In Shrinkage
		DECLARE @ShrinkagePerc NUMERIC(18,3) = 30 --The industry average is around 30–35%, in this case we used 30%. Note that we can change it
		--NumberOfAgentsRequired = [Raw Agents or N]/(1-(Shrinkage/100))
		SET @NumberOfAgentsRequired = @N/(1-(@ShrinkagePerc/100))

		DELETE FROM @returntable

		INSERT @returntable
		SELECT 
			@NumberOfAgentsRequired
			,@SL ServiceLevel
			,@SLPerc [Service Level %]
		    ,@Pw [Pw/Erlang/Probability Call has to wait]
			,@PwPerc PwPerc
			,@ASA ASA
			,@ImmediateAnswerPerc ImmediateAnswerPerc
			,@TargetAnswerTimeInSeconds [ServiceTime(sec)]
			,@AHTInSeconds [AHT (sec)]			
			,@RequiredServiceLevelPerc [TargetServiceLevel %]			
			,@N [FTE or N]
			,@X X
			,@Y Y
			,@A A
			,@AHTInSeconds  AHTSec			
			,@OccupancyPerc
			
	END

	

	RETURN
END
GO
/******************************
** File: Buildscript_1.00.105.sql
** Name: Buildscript_1.00.105
** Auth: McNiel Viray
** Date: 22 April 2019
**************************
** Change History
**************************
** modify udf_ErlangCFormula, added shrinkage as input parameter
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 105

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END

GO




DROP FUNCTION [dbo].[udf_ErlangCFormula]
GO

CREATE FUNCTION [dbo].[udf_ErlangCFormula]
(
     @NumberOfCalls NUMERIC(10,3)
	,@AHTInSeconds NUMERIC(10,3)
	,@RequiredServiceLevelPerc NUMERIC(10,3)
	,@TargetAnswerTimeInSeconds NUMERIC(10,3)
	,@ShrinkagePerc NUMERIC(18,3)
	,@NewN NUMERIC = NULL
)
RETURNS @returntable TABLE
(
	NumberOfAgentsRequired NUMERIC(18,0)
	,ServiceLevel NUMERIC(18,2)
	,ServiceLevelPerc NUMERIC(18,2)
	,[Pw/Erlang] NUMERIC(18,2)
	,ProbabilityOfCallToWaitPerc NUMERIC(18,2)
	,ASA NUMERIC(18,4)
	,ImmediateAnswerPerc NUMERIC(18,2)
	,TargetAnswerTimeInSeconds NUMERIC(10,3)
	,AHTInSeconds NUMERIC(10,3)	
	,RequiredServiceLevelPerc NUMERIC(10,3)
	,N NUMERIC(18,0)
	,X NUMERIC(18,3)
	,Y NUMERIC(18,2)
	,A NUMERIC(18,0)
	,AHTSec  NUMERIC(10,3)	
	,OccupancyPerc NUMERIC(18,2)	
)
AS
BEGIN

	DECLARE @A NUMERIC -- TRAFFIC INTESITY / ERLANG
		,@N NUMERIC -- RAW NUMBER OF AGENTS REQUIRED
		,@NumberOfCallsPerHour NUMERIC
		,@ServiceLevelPerc NUMERIC(10,3)=0
		,@X NUMERIC(18,3)
		,@Y NUMERIC(18,3)
		,@Pw NUMERIC(18,2)
		,@PwPerc NUMERIC(18,2)
		,@SL NUMERIC(18,2)
		,@SLPerc NUMERIC(18,2)
		,@ASA NUMERIC(18,2) --Average Speed of Answer
		,@ImmediateAnswerPerc NUMERIC(18,2)
		,@OccupancyPerc NUMERIC(18,2)
		,@NumberOfAgentsRequired NUMERIC(18,0)

	--2. Work Out the Number of Calls Per Hour
	SET @NumberOfCallsPerHour = @NumberOfCalls
	
	--3. Work Out the Traffic Intensity (A)
	DECLARE @AHTInMinutes NUMERIC(10,3)=@AHTInSeconds/60
	SET  @A = (@NumberOfCallsPerHour*(@AHTInMinutes))/60
	
	--4. Estimate the Raw Number of Agents Required (N)
	--   Initial value is A+1
	--   TODO: loop until we meet @RequiredServiceLevelPerc compare to @ServiceLevelPerc
	SET @N=ISNULL(@NewN,(@A+1))
	
	
	--5. Calculate the Erlang Formula for Probability a Call Waits (SKIP)
	--6. Work Out N! (N Factorial) (SKIP)
	--7. Be Careful With Large Factorials (SKIP)
	--                           n
	--8. Work Out the Powers – A   (SKIP) 
	--9. Let’s Simplify the Erlang C Formula
	--       X  / ( Y + X )


	--10. Let’s Work Out the Top Row of the Erlang Formula (X)
	--NUMERATOR FIRST (X)
	--   n
	-- A      *  N
	--___       ___
	-- N!        N-A

	DECLARE @NumeratorA NUMERIC(10,3)
			,@NumeratorB NUMERIC(10,3)			

	SET @NumeratorA = POWER(@A,@N)/[dbo].[udf_Fact](@N);
	SET @NumeratorB = @N/NULLIF((@N-@A),0);
	SET @X = @NumeratorA*@NumeratorB;

	---11. Work Out the Sum of a Series (Y) or ΣApowerofI/i!
	--LOOP @N
	DECLARE @i NUMERIC = 0
		,@EaPowOfiDivIFact NUMERIC(18,2)=0

	DECLARE @tblY AS TABLE(
		i NUMERIC(18,2)
		,iFactorial NUMERIC(18,2)
	 	,APowerofI NUMERIC(18,2)
		,APowerofIDivideIFactorial NUMERIC(18,2)
		,SumOfAPowerofIDivideIFactorial NUMERIC(18,2)
	);
	WHILE(@i <= (@N-1))
	BEGIN
		DECLARE @iFact NUMERIC(18,2)
			,@aPowI NUMERIC(18,2)
			,@aPowOfiDivIFact NUMERIC(18,2)
			

		SET @iFact = [dbo].[udf_Fact](@i)
		SET @aPowI = POWER(@A,@i)
		SET @aPowOfiDivIFact = @aPowI/@iFact
		SET @EaPowOfiDivIFact = @EaPowOfiDivIFact + @aPowOfiDivIFact

		--SELECT @i,@iFact,@aPowI,@aPowOfiDivIFact,@EaPowOfiDivIFact

		INSERT INTO @tblY(i,iFactorial,APowerofI,APowerofIDivideIFactorial,SumOfAPowerofIDivideIFactorial)
		VALUES(@i,@iFact,@aPowI,@aPowOfiDivIFact,@EaPowOfiDivIFact);

		SET @i = @i + 1
		
	END

	SELECT TOP 1 @Y = SumOfAPowerofIDivideIFactorial
	FROM @tblY ORDER BY i DESC

	--12. Put X and Y into the Erlang C Formula (The probability a call has to wait)
	SET @Pw = @X/NULLIF((@Y+@X),0)
	SET @PwPerc = @Pw*100


	--13. Calculate the Service Level
		-- 13.1 Let’s work out -(N – A) * (TargetTime / AHT)
		DECLARE @exponent NUMERIC(18,3)
		SET @exponent = -((@N-@A)*(@TargetAnswerTimeInSeconds/@AHTInSeconds))
		
	--SELECT @exponent,@TargetAnswerTimeInSeconds,@AHTInSeconds,(@TargetAnswerTimeInSeconds/@AHTInSeconds)
	SET @SL = 1-(@Pw*EXP(@exponent))
	SET @SLPerc = @SL*100

	IF(@SLPerc<@RequiredServiceLevelPerc)
	BEGIN
		DECLARE @NIncrement NUMERIC 
		SET @NIncrement = @N + 1

		INSERT @returntable
		SELECT * FROM [dbo].[udf_ErlangCFormula](@NumberOfCalls,@AHTInSeconds,@RequiredServiceLevelPerc,@TargetAnswerTimeInSeconds,@ShrinkagePerc,@NIncrement)
	END
	ELSE
	BEGIN

		--15.  Average Speed of Answer (ASA)
		-- ASA = Pw(AHT)/(No.of Agents-Traffic Intesity)
		SET @ASA = (@Pw*@AHTInSeconds)/(@N-@A)

		--16. Percentage of Calls Answered Immediately
		--Immediate Answer = (1-Pw)x100
		SET @ImmediateAnswerPerc = (1-@Pw)*100

		--17. Check Maximum Occupancy
		--Occupancy = (([TrafficIntensity or A])/[RawAgents or N] )* 100
		SET @OccupancyPerc = (@A/@N) * 100
		IF @OccupancyPerc>85
		BEGIN
			SET @OccupancyPerc= @A/(@OccupancyPerc/100)
		END

		--18. Factor In Shrinkage
		--DECLARE @ShrinkagePerc NUMERIC(18,3) = 30 --The industry average is around 30–35%, in this case we used 30%. Note that we can change it
		--NumberOfAgentsRequired = [Raw Agents or N]/(1-(Shrinkage/100))
		SET @NumberOfAgentsRequired = @N/(1-(@ShrinkagePerc/100))

		DELETE FROM @returntable

		INSERT @returntable
		SELECT 
			@NumberOfAgentsRequired
			,@SL ServiceLevel
			,@SLPerc [Service Level %]
		    ,@Pw [Pw/Erlang/Probability Call has to wait]
			,@PwPerc PwPerc
			,@ASA ASA
			,@ImmediateAnswerPerc ImmediateAnswerPerc
			,@TargetAnswerTimeInSeconds [ServiceTime(sec)]
			,@AHTInSeconds [AHT (sec)]			
			,@RequiredServiceLevelPerc [TargetServiceLevel %]			
			,@N [FTE or N]
			,@X X
			,@Y Y
			,@A A
			,@AHTInSeconds  AHTSec			
			,@OccupancyPerc
			
	END

	

	RETURN
END
GO
/******************************
** File: Buildscript_1.00.106.sql
** Name: Buildscript_1.00.106
** Auth: McNiel Viray
** Date: 23 April 2019
**************************
** Change History
**************************
** modify udf_ErlangCFormula, added shrinkage as input parameter
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 106

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END

GO


DROP FUNCTION [dbo].[udf_ErlangCFormula]
GO

CREATE FUNCTION [dbo].[udf_ErlangCFormula]
(
     @NumberOfCalls NUMERIC(18,0)
	,@AHTInSeconds NUMERIC(18,0)
	,@RequiredServiceLevelPerc NUMERIC(20,2)
	,@TargetAnswerTimeInSeconds NUMERIC(18,0)
	,@ShrinkagePerc NUMERIC(20,2)
	,@NewN NUMERIC(20,2) = NULL
)
RETURNS @returntable TABLE
(
	NumberOfAgentsRequired NUMERIC(18,0)
	,ServiceLevel NUMERIC(20,2)
	,ServiceLevelPerc NUMERIC(20,2)
	,[Pw/Erlang] NUMERIC(20,2)
	,ProbabilityOfCallToWaitPerc NUMERIC(20,2)
	,ASA NUMERIC(20,2)
	,ImmediateAnswerPerc NUMERIC(20,2)
	,TargetAnswerTimeInSeconds NUMERIC(18,0)
	,AHTInSeconds NUMERIC(18,0)	
	,RequiredServiceLevelPerc NUMERIC(20,2)
	,N NUMERIC(18,0)
	,X NUMERIC(20,2)
	,Y NUMERIC(20,2)
	,A NUMERIC(18,0)
	,AHTSec  NUMERIC(18,0)	
	,OccupancyPerc NUMERIC(20,2)	
)
AS
BEGIN

	DECLARE @A NUMERIC(18,0) -- TRAFFIC INTESITY / ERLANG
		,@N NUMERIC(18,0) -- RAW NUMBER OF AGENTS REQUIRED
		,@NumberOfCallsPerHour NUMERIC(18,0)
		--,@ServiceLevelPerc NUMERIC(20,2)=0
		,@X NUMERIC(20,2)
		,@Y NUMERIC(20,2)
		,@Pw NUMERIC(20,2)
		,@PwPerc NUMERIC(20,2)
		,@SL NUMERIC(20,2)
		,@SLPerc NUMERIC(20,2)
		,@ASA NUMERIC(20,2) --Average Speed of Answer
		,@ImmediateAnswerPerc NUMERIC(20,2)
		,@OccupancyPerc NUMERIC(20,2)
		,@NumberOfAgentsRequired NUMERIC(18,0)

	--2. Work Out the Number of Calls Per Hour
	SET @NumberOfCallsPerHour = @NumberOfCalls
	
	--3. Work Out the Traffic Intensity (A)
	DECLARE @AHTInMinutes NUMERIC(20,2)=@AHTInSeconds/60
	SET  @A = (@NumberOfCallsPerHour*(@AHTInMinutes))/60
	
	--4. Estimate the Raw Number of Agents Required (N)
	--   Initial value is A+1
	--   TODO: loop until we meet @RequiredServiceLevelPerc compare to @ServiceLevelPerc
	SET @N=ISNULL(@NewN,(@A+1))
	
	
	--5. Calculate the Erlang Formula for Probability a Call Waits (SKIP)
	--6. Work Out N! (N Factorial) (SKIP)
	--7. Be Careful With Large Factorials (SKIP)
	--                           n
	--8. Work Out the Powers – A   (SKIP) 
	--9. Let’s Simplify the Erlang C Formula
	--       X  / ( Y + X )


	--10. Let’s Work Out the Top Row of the Erlang Formula (X)
	--NUMERATOR FIRST (X)
	--   n
	-- A      *  N
	--___       ___
	-- N!        N-A

	DECLARE @NumeratorA NUMERIC(20,2)
			,@NumeratorB NUMERIC(20,2)			

	SET @NumeratorA = POWER(@A,@N)/[dbo].[udf_Fact](@N);
	SET @NumeratorB = @N/NULLIF((@N-@A),0);
	SET @X = @NumeratorA*@NumeratorB;

	---11. Work Out the Sum of a Series (Y) or ΣApowerofI/i!
	--LOOP @N
	DECLARE @i NUMERIC = 0
		,@EaPowOfiDivIFact NUMERIC(20,2)=0

	DECLARE @tblY AS TABLE(
		i NUMERIC(18,2)
		,iFactorial NUMERIC(18,2)
	 	,APowerofI NUMERIC(18,2)
		,APowerofIDivideIFactorial NUMERIC(18,2)
		,SumOfAPowerofIDivideIFactorial NUMERIC(18,2)
	);
	WHILE(@i <= (@N-1))
	BEGIN
		DECLARE @iFact NUMERIC(20,2)
			,@aPowI NUMERIC(20,2)
			,@aPowOfiDivIFact NUMERIC(20,2)
			

		SET @iFact = [dbo].[udf_Fact](@i)
		SET @aPowI = POWER(@A,@i)
		SET @aPowOfiDivIFact = @aPowI/@iFact
		SET @EaPowOfiDivIFact = @EaPowOfiDivIFact + @aPowOfiDivIFact

		--SELECT @i,@iFact,@aPowI,@aPowOfiDivIFact,@EaPowOfiDivIFact

		INSERT INTO @tblY(i,iFactorial,APowerofI,APowerofIDivideIFactorial,SumOfAPowerofIDivideIFactorial)
		VALUES(@i,@iFact,@aPowI,@aPowOfiDivIFact,@EaPowOfiDivIFact);

		SET @i = @i + 1
		
	END

	SELECT TOP 1 @Y = SumOfAPowerofIDivideIFactorial
	FROM @tblY ORDER BY i DESC

	--12. Put X and Y into the Erlang C Formula (The probability a call has to wait)
	SET @Pw = @X/NULLIF((@Y+@X),0)
	SET @PwPerc = @Pw*100


	--13. Calculate the Service Level
		-- 13.1 Let’s work out -(N – A) * (TargetTime / AHT)
		DECLARE @exponent NUMERIC(20,2)
		SET @exponent = -((@N-@A)*(@TargetAnswerTimeInSeconds/@AHTInSeconds))
		
	--SELECT @exponent,@TargetAnswerTimeInSeconds,@AHTInSeconds,(@TargetAnswerTimeInSeconds/@AHTInSeconds)
	SET @SL = 1-(@Pw*EXP(@exponent))
	SET @SLPerc = @SL*100

	IF(@SLPerc<@RequiredServiceLevelPerc)
	BEGIN
		DECLARE @NIncrement NUMERIC 
		SET @NIncrement = @N + 1

		INSERT @returntable
		SELECT * FROM [dbo].[udf_ErlangCFormula](@NumberOfCalls,@AHTInSeconds,@RequiredServiceLevelPerc,@TargetAnswerTimeInSeconds,@ShrinkagePerc,@NIncrement)
	END
	ELSE
	BEGIN

		--15.  Average Speed of Answer (ASA)
		-- ASA = Pw(AHT)/(No.of Agents-Traffic Intesity)
		SET @ASA = (@Pw*@AHTInSeconds)/(@N-@A)

		--16. Percentage of Calls Answered Immediately
		--Immediate Answer = (1-Pw)x100
		SET @ImmediateAnswerPerc = (1-@Pw)*100

		--17. Check Maximum Occupancy
		--Occupancy = (([TrafficIntensity or A])/[RawAgents or N] )* 100
		SET @OccupancyPerc = (@A/@N) * 100
		IF @OccupancyPerc>85
		BEGIN
			SET @OccupancyPerc= @A/(@OccupancyPerc/100)
		END

		--18. Factor In Shrinkage
		--DECLARE @ShrinkagePerc NUMERIC(18,3) = 30 --The industry average is around 30–35%, in this case we used 30%. Note that we can change it
		--NumberOfAgentsRequired = [Raw Agents or N]/(1-(Shrinkage/100))
		SET @NumberOfAgentsRequired = @N/(1-(@ShrinkagePerc/100))

		DELETE FROM @returntable

		INSERT @returntable
		SELECT 
			@NumberOfAgentsRequired
			,@SL ServiceLevel
			,@SLPerc [Service Level %]
		    ,@Pw [Pw/Erlang/Probability Call has to wait]
			,@PwPerc PwPerc
			,@ASA ASA
			,@ImmediateAnswerPerc ImmediateAnswerPerc
			,@TargetAnswerTimeInSeconds [ServiceTime(sec)]
			,@AHTInSeconds [AHT (sec)]			
			,@RequiredServiceLevelPerc [TargetServiceLevel %]			
			,@N [FTE or N]
			,@X X
			,@Y Y
			,@A A
			,@AHTInSeconds  AHTSec			
			,@OccupancyPerc
			
	END

	

	RETURN
END

GO
/******************************
** File: Buildscript_1.00.107.sql
** Name: Buildscript_1.00.107
** Auth: McNiel Viray
** Date: 23 April 2019
**************************
** Change History
**************************
**  modified [dbo].[udf_GetGrossRequiredFTE], added implementation of Erlang C
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 107

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
GO


ALTER FUNCTION [dbo].[udf_GetGrossRequiredFTE]
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
		,@grossRequiredHours DECIMAL--StaffDatapointID: 9
		-- Gross Required Hours / 40

		SELECT @grossRequiredHours=[dbo].[udf_GetGrossRequiredHours](@SiteID,@CampaignID,@LobID,@Date)

		--DEFAULT FORMULA
		SELECT @Value=(@grossRequiredHours/40)
		
		--CHECK the formula assigned to Site,Campaign, and LoB
		IF EXISTS (SELECT f.ID FROM DynamicFormula f 
						INNER JOIN SiteCampaignLobFormula sclf ON sclf.DynamicFormulaID=f.ID
						WHERE sclf.SiteID=@SiteID 
							AND sclf.CampaignID=@CampaignID
							AND sclf.LoBID=@LobID
							AND sclf.Active = 1
							AND f.Active = 1)
		BEGIN
			DECLARE @FormulaID BIGINT = 0

			SELECT @FormulaID = f.ID FROM DynamicFormula f 
			INNER JOIN SiteCampaignLobFormula sclf ON sclf.DynamicFormulaID=f.ID
			WHERE sclf.SiteID=@SiteID 
				AND sclf.CampaignID=@CampaignID
				AND sclf.LoBID=@LobID
				AND sclf.Active = 1
				AND f.Active = 1

			IF(@FormulaID=2)
			BEGIN
				DECLARE @NumberOfCalls NUMERIC(10,3)=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6) -- Forcasted Volume / C10  
				,@AHTInSeconds NUMERIC(10,3)=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,9)--Target AHT / c13 
				,@RequiredServiceLevelPerc NUMERIC(10,3)=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,1) -- Target Service Level / C5
				,@TargetAnswerTimeInSeconds NUMERIC(10,3)=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,3)--Service Time / c7
				,@ShrinkagePerc NUMERIC(18,3) =[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,53) --Projected and Actual Shrinkage Variance / c57
				,@NewN NUMERIC = null

				SELECT @Value = NumberOfAgentsRequired FROM udf_ErlangCFormula(@NumberOfCalls,@AHTInSeconds,@RequiredServiceLevelPerc,@TargetAnswerTimeInSeconds,@ShrinkagePerc,@NewN)
			END
			IF(@FormulaID=3)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_Straight](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=4)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerHour](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=5)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerUnit](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=6)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerMinute](@SiteID,@CampaignID,@LobID,@Date)
			END
		END

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
			,RequiredHC DECIMAL--1
			,CurrentHC DECIMAL--2
			,ExcessDeficitHC DECIMAL--3
			,RequiredFTE DECIMAL--4
			,PlannedFTE DECIMAL--5
			,TeleoptiRequiredFTE DECIMAL--6
			,ExcessDeficitFTE DECIMAL--7
			,BaseHours DECIMAL--8
			,NetReqHours DECIMAL--9
			,PlannedProdHrs DECIMAL--10
			,ProdProdHrs DECIMAL--11
			,SMEProdHrs DECIMAL--12
			,NestingProdHrs DECIMAL--13
			,PlannedTrainingHrs DECIMAL--14
			,RequiredVolFTE DECIMAL--15
			,ProjectedCapacity DECIMAL--16
			,CapacityToForecastPerc DECIMAL--17				
			,ActualToForecastPerc DECIMAL--18
			,AnsweredToForecastPerc DECIMAL--19
			,AnsweredToCapacityPerc DECIMAL--20
			,BillableHC DECIMAL--21				
			,CurrentBillableHC DECIMAL--22
			,BillableExcessDeficit DECIMAL--23
			,TotalProductionFullTime DECIMAL--24
			,TotalProductionPartTime DECIMAL--25
			,TotalNestingFullTime DECIMAL--26
			,TotalNestingPartTime DECIMAL--27
			,TotalTrainingFullTime DECIMAL--28
			,TotalTrainingPartTime DECIMAL--29
		)
		INSERT INTO @StaffDatapoint
			SELECT  
				DISTINCT(w.[Date]) 
				,w.SiteID
				,w.CampaignID
				,w.LoBID
				,[dbo].[udf_GetGrossRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 1
				,[dbo].[udf_GetCurrentGrossFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 2
				,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 3
				,[dbo].[udf_GetRequiredNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:4
				,[dbo].[udf_GetPlannedNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:5
				,0--StaffDatapointID: 6
				,[dbo].[udf_GetExcessDeficitFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 7
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56) --StaffDatapointID: 8
				,[dbo].[udf_GetGrossRequiredHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date]) --StaffDatapointID: 9
				,[dbo].[udf_GetPlannedProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 10
				,[dbo].[udf_GetProdProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 11
				,[dbo].[udf_GetSMEProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 12
				,[dbo].[udf_NestingProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 13
				,[dbo].[udf_GetPlannedTrainingHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 14
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--StaffDatapointID: 15
				,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 16
				,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 17
				,[dbo].[udf_GetActualToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 18
				,[dbo].[udf_GetAnsweredToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 19
				,[dbo].[udf_GetAnsweredToCapacityPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 20
				,[dbo].[udf_GetGrossRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 21   //DYNAMIC FORMULA HERE
				,[dbo].[udf_GetCurrentGrossFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],66)--StaffDatapointID: 22
				,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 23
				,[dbo].[udf_GetTotalProductionFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:24
				,[dbo].[udf_GetTotalProductionPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:25
				,[dbo].[udf_GetTotalNestingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:26
				,[dbo].[udf_GetTotalNestingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:27
				,[dbo].[udf_GetTotalTrainingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:28
				,[dbo].[udf_GetTotalTrainingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:29
			FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.RequiredHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.CurrentHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitHC) = 0 THEN '0'
				ELSE CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredFTE) = 0 THEN '0'
				ELSE CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TeleoptiRequiredFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitFTE) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BaseHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.BaseHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NetReqHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProdProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.SMEProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NestingProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedTrainingHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredVolFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProjectedCapacity) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CapacityToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ActualToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=
			CASE
				WHEN ISNUMERIC(s.AnsweredToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.AnsweredToCapacityPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CurrentBillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableExcessDeficit) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

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
		

		--***************************************
		-- CREATE WeeklySummaryDatapoint
		--***************************************
		DECLARE @SummaryDatapoint AS TABLE(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,TargetServiceLevel DECIMAL--1
			,ProjectedServiceLevel DECIMAL--2
			,ActualServiceLevel DECIMAL--3
			,VolumeForecast DECIMAL--4
			,VolumeOffered DECIMAL--5
			,VolumeHandled DECIMAL--6
			,VolumeCapacity DECIMAL--7
			,VolumeVarianceOfferedvsForecast DECIMAL--8
			,TargetAHT DECIMAL--9
			,ActualAHT DECIMAL--10
			,AHTVariancePercentagetoGoal DECIMAL--11
			,TargetProductionHours DECIMAL--12
			,ActualProductionHours DECIMAL--13
			,ProductionHoursVariance DECIMAL--14
			,BillableHeadcount DECIMAL--15
			,RequiredHeadcount DECIMAL--16
			,ActualProductionHeadcount DECIMAL--17
			,ActualNestingHeadcount DECIMAL--18
			,ActualTrainingHeadcount DECIMAL--19
			,BillableExcessDeficits DECIMAL--20
			,RequiredExcessDeficits DECIMAL--21
			,ProductionAttrition DECIMAL--22
			,NestingTrainingAttrition DECIMAL--23
			,NestingAttrition DECIMAL--24
			,TrainingAttrition DECIMAL--25
			,TotalTargetShrinkage DECIMAL--26
			,TargetIncenterShrinkage DECIMAL--27
			,TargetOutofcenterShrinkage DECIMAL--28
			,TotalActualShrinkage DECIMAL--29
			,ActualIncenterShrinkage DECIMAL--30
			,ActualOutofcenterShrinkage DECIMAL--31
			,ShrinkageVarianceTargetActual DECIMAL--32
			,TargetOccupancy DECIMAL--33
			,ActualOccupancy DECIMAL--34
		)

		INSERT INTO @SummaryDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],1)--1
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],2)--2
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],4)--3
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--4
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],7)--5
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],8)--6
			,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--7
			,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--8
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],9)--9
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],11)--10
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],12)--11
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56)--12
			,0--13
			,0--14
			,[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--15
			,[dbo].[udf_GetRequiredHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--16
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],80)--17
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],81)--18
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],86)--19
			,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--20
			,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--21
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],95)--22
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--23
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)--24
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--25
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)--26
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--27
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],23)--28
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],35)--29
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],36)--30
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],41)--31
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],26)-[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],29)--32--Original as of 10.26.2017 [dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--32
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],54)--33
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],55)--34
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProjectedServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProjectedServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeForecast) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeForecast,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeOffered) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeOffered,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeHandled) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeHandled,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeCapacity) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeCapacity,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeVarianceOfferedvsForecast) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.VolumeVarianceOfferedvsForecast,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.AHTVariancePercentagetoGoal) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.AHTVariancePercentagetoGoal,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionHoursVariance) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionHoursVariance,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualNestingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualNestingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualTrainingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualTrainingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingTrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingTrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalTargetShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TotalTargetShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOutofcenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalActualShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.TotalActualShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=30

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOutofcenterShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.ActualOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=31

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ShrinkageVarianceTargetActual) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ShrinkageVarianceTargetActual,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=32

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=33

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=34

		--CASCADE Summary data
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username,SiteID,CampaignID
		FROM WeeklySummaryDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklySummaryDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date
		--***************************************
		-- END CREATE WeeklySummaryDatapoint
		--***************************************

		SELECT TOP 1 @Username = UserName
			,@DateModified = DateModified
	    FROM @WeeklyDatapointTableType

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyAHDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyHiringDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyStaffDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklySummaryDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

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
PRINT N'Refreshing [dbo].[wfmpcp_SaveAHCStagingToActual_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveAHCStagingToActual_sp]';


GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.108.sql
** Name: Buildscript_1.00.108
** Auth: McNiel Viray	
** Date: 25 April 2019
**************************
** Change History
**************************
** Add new column 'MenuIcon' to table Module
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 108

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
GO

GO
PRINT N'Dropping [dbo].[DF_Module_ParentID]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF_Module_ParentID];


GO
PRINT N'Dropping unnamed constraint on [dbo].[Module]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF__tmp_ms_xx__SortO__4222D4EF];


GO
PRINT N'Dropping [dbo].[DF_Module_DateCreated]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF_Module_DateCreated];


GO
PRINT N'Dropping [dbo].[DF_Module_Active]...';


GO
ALTER TABLE [dbo].[Module] DROP CONSTRAINT [DF_Module_Active];


GO
PRINT N'Starting rebuilding table [dbo].[Module]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Module] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [ParentID]     BIGINT         CONSTRAINT [DF_Module_ParentID] DEFAULT (0) NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
    [FontAwesome]  NVARCHAR (100) NULL,
    [MenuIcon]     NVARCHAR (100) NULL,
    [Route]        NVARCHAR (MAX) NOT NULL,
    [SortOrder]    INT            DEFAULT 0 NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       CONSTRAINT [DF_Module_DateCreated] DEFAULT GETDATE() NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            CONSTRAINT [DF_Module_Active] DEFAULT (1) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_Module_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Module])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Module] ON;
        INSERT INTO [dbo].[tmp_ms_xx_Module] ([ID], [ParentID], [Name], [FontAwesome], [Route], [SortOrder], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified], [Active])
        SELECT   [ID],
                 [ParentID],
                 [Name],
                 [FontAwesome],
                 [Route],
                 [SortOrder],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified],
                 [Active]
        FROM     [dbo].[Module]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Module] OFF;
    END

DROP TABLE [dbo].[Module];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Module]', N'Module';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_Module_ID1]', N'PK_Module_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-group'
WHERE ID=1
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-pencil-square-o'
WHERE  ID=2 -- Data Management
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-list-ul'
WHERE  ID=8 -- PCP Management
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-calendar'
WHERE  ID=12 -- Capacity Planner
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-eye'
WHERE  ID=17 -- Hiring Outlook
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-code'
WHERE  ID=23 -- Excess Deficit
GO
UPDATE Module
SET MenuIcon='menu-icon fa fa-support'
WHERE  ID=7 -- Help
GO
PRINT N'Update complete.';


GO



