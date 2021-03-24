/******************************
** File: Buildscript_1.00.030.sql
** Name: Buildscript_1.00.030
** Auth: McNiel Viray
** Date: 07 July 2017
**************************
** Change History
**************************
** Modify [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp] by adding data to WeeklyHiringDatapoint table
** Modify [dbo].[wfmpcp_GetAHCDatapointValue_udf]
*******************************/
USE WFMPCP
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

		--cascade to remaining data.

		DECLARE @Date DATE

		SELECT @Date = MAX([Date]) FROM @WeeklyDatapointTableType
		DECLARE @tbl AS TABLE
		(
			DatapointID BIGINT,
			LobID BIGINT,
			DataValue NVARCHAR(MAX),
			DateMofidifed DATETIME,
			ModifiedBy NVARCHAR(50)
		)

		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy)
		SELECT DatapointID,LoBID,DataValue,DateModified,UserName
		FROM @WeeklyDatapointTableType
		WHERE [Date]=@Date

		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyAHDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
		WHERE w.[Date]>@Date

		--*****************************************
		-- CREATE AND COMPUTE WeeklyStaffDatapoint*
		--*****************************************
		--check if WeeklyStaffDatapoint is empty
		DECLARE @LobID BIGINT=0
			,@CampaignID BIGINT=0
			,@Date2 DATE
			,@DateModified DATETIME
			,@Username NVARCHAR(20)

		SELECT DISTINCT @LobID=LoBID 
			,@DateModified=DateModified
			,@Username=Username
		FROM @WeeklyDatapointTableType
		
		SELECT @CampaignID=CampaignID FROM LoB WHERE ID=@LobID

		SELECT TOP 1 @LobID=w.LoBID
			,@CampaignID=l.CampaignID 
		FROM @WeeklyDatapointTableType w
		INNER JOIN LoB l ON l.ID=w.LoBID

		--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		--Set up and compute weeklystaffdatapoint
		DECLARE @StaffDatapoint AS TABLE
		(
			[Date] DATE
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
				,w.LoBID
				,[dbo].[wfmpcp_GetRequiredHC_udf](w.LoBID,w.[Date])--3
				,[dbo].[wfmpcp_GetAHCDatapointValue_udf](w.LoBID,w.[Date],69)
				,[dbo].[wfmpcp_GetExcessDeficitHC_udf](w.LoBID,w.[Date])--4
				,[dbo].[wfmpcp_GetRequiredFTE_udf](w.LoBID,w.[Date])--5
				,[dbo].[wfmpcp_GetPlannedFTE_udf](w.LoBID,w.[Date])--10
				,0
				,[dbo].[wfmpcp_GetExcessDeficitFTE_udf](w.LoBID,w.[Date])--11
				,[dbo].[wfmpcp_GetAHCDatapointValue_udf](w.LoBID,w.[Date],56) --1
				,[dbo].[wfmpcp_GetNetReqHours_udf](w.LoBID,w.[Date]) --2
				,[dbo].[wfmpcp_GetPlannedProdHrs_udf](w.LoBID,w.[Date])--9
				,[dbo].[wfmpcp_GetProdProdHrs_udf](w.LoBID,w.[Date])--6
				,[dbo].[wfmpcp_GetSMEProdHrs_udf](w.LoBID,w.[Date])--7
				,[dbo].[wfmpcp_NestingProdHrs_udf](w.LoBID,w.[Date])--8
				,0
				,[dbo].[wfmpcp_GetAHCDatapointValue_udf](w.LoBID,w.[Date],6)
				,[dbo].[wfmpcp_GetProjectedCapacity_udf](w.LoBID,w.[Date])--12
				,[dbo].[wfmpcp_GetCapacityToForecastPerc_udf](w.LoBID,w.[Date])--13
				,[dbo].[wfmpcp_GetActualToForecastPerc_udf](w.LoBID,w.[Date])--14
				,[dbo].[wfmpcp_GetAnsweredToForecastPerc_udf](w.LoBID,w.[Date])--15
				,[dbo].[wfmpcp_GetAnsweredToCapacityPerc_udf](w.LoBID,w.[Date])--16
				,[dbo].[wfmpcp_GetBillableHC_udf](w.LoBID,w.[Date])--17
				,[dbo].[wfmpcp_GetAHCDatapointValue_udf](w.LoBID,w.[Date],66)
				,[dbo].[wfmpcp_GetBillableExcessDeficit_udf](w.LoBID,w.[Date])--18
			FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.BaseHours,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(MAX)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(MAX)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(MAX)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(MAX)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(MAX))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=23

		--xxxxxxx
		--CASCADE DATA 
		--xxxxxxx
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy)
		SELECT DatapointID,LobID,Data,@DateModified,@Username
		FROM WeeklyStaffDatapoint 
		WHERE [Date]=@Date AND LobID=@LobID 


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyStaffDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
		WHERE w.[Date]>@Date

		--end set up and compute weeklystaffdatapoint
		--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



		--*****************************************
		-- CREATE AND COMPUTE WeeklyHiringDatapoint*
		--*****************************************
		DECLARE @HiringDatapoint AS TABLE(
			[Date] DATE
			,LobID BIGINT	
			,NewCapacity NVARCHAR(MAX)
			,AttritionBackfill NVARCHAR(MAX)
		)

		INSERT INTO @HiringDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
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
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=AttritionBackfill
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyHiringDatapoint w
		INNER JOIN @HiringDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=2

		--xxxxxxx
		--CASCADE DATA (hiring)
		--xxxxxxx
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username
		FROM WeeklyHiringDatapoint 
		WHERE [Date]=@Date AND LobID=@LobID 


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyHiringDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
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
ALTER FUNCTION [dbo].[wfmpcp_GetAHCDatapointValue_udf]
(
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
	WHERE LoBID=@LobID AND [Date]=@Date  AND DatapointID=@DatapointID

	RETURN ISNULL(@Value,0)
END


GO
PRINT N'Update complete.';


GO
