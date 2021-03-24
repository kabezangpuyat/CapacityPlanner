/******************************
** File: Buildscript_1.00.025.sql
** Name: Buildscript_1.00.025
** Auth: McNiel Viray
** Date: 29 June 2017
**************************
** Change History
**************************
* Alter [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp] by adding update on WeeklyStaffDatapoint and cascade remaining data
* Add index IX_WeeklyStaffDatapoint_ByLobDatapointDataDate to WeeklStaffDatapoint
* Hide Datapoint and Segment Manager module
*******************************/
USE WFMPCP
GO
PRINT N'Creating [dbo].[WeeklyStaffDatapoint].[IX_WeeklyStaffDatapoint_ByLobDatapointDataDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_WeeklyStaffDatapoint_ByLobDatapointDataDate]
    ON [dbo].[WeeklyStaffDatapoint]([LoBID] ASC, [DatapointID] ASC, [Date] ASC)
    INCLUDE([Data]);


GO
PRINT N'Altering [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
	@WeeklyDatapointTableType [dbo].[WeeklyDatapointTableType] READONLY
AS
BEGIN
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
		SET w.Data=s.RequiredHC
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.Data=s.CurrentHC
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.Data=s.ExcessDeficitHC
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.Data=s.RequiredFTE
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.Data=s.PlannedFTE
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.Data=s.TeleoptiRequiredFTE
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=6

		UPDATE w
		SET w.Data=s.ExcessDeficitFTE
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.Data=s.BaseHours
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.Data=s.NetReqHours
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.Data=s.PlannedProdHrs
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.Data=s.ProdProdHrs
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.Data=s.SMEProdHrs
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.Data=s.NestingProdHrs
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.Data=s.PlannedTrainingHrs
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.Data=s.RequiredVolFTE
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=15

		UPDATE w
		SET w.Data=s.ProjectedCapacity
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=16

		UPDATE w
		SET w.Data=s.CapacityToForecastPerc
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.Data=s.ActualToForecastPerc
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.Data=s.AnsweredToForecastPerc
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.Data=s.AnsweredToCapacityPerc
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.Data=s.BillableHC
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.Data=s.CurrentBillableHC
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.Data=s.BillableExcessDeficit
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

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION --RollBack in case of Error

		RAISERROR(15600,-1,-1,'[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]')
	END CATCH
END
GO
PRINT N'Hide Datapoint and Segment Manager module'
GO
UPDATE Module
SET Active=0
WHERE ID IN(9,10)
GO
PRINT N'Update complete.';


GO

PRINT N'Create [dbo].[wfmpcp_GetStaffPlanner_sp]'
GO
CREATE PROCEDURE [dbo].[wfmpcp_GetStaffPlanner_sp]
	@lobid AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1,
	@segmentid  AS NVARCHAR(MAX)=''
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
				SELECT s.ID SegmentID, d.ID DatapointID, s.Name Segment, d.Name [Datapoint],' + @cols + '
				FROM (
					SELECT *
					FROM
					(
						SELECT LobID,datapointid,[Date],Data from WeeklyStaffDatapoint 
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
						SELECT LobID,datapointid,[Date],Data from WeeklyStaffDatapoint 
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

	SET @orderBy = ' ORDER BY s.SortOrder,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO