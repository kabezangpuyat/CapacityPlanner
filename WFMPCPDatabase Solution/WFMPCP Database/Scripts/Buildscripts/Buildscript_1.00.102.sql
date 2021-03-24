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


