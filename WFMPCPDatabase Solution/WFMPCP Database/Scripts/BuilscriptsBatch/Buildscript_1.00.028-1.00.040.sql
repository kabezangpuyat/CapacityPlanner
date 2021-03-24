/******************************
** File: Buildscript_1.00.028.sql
** Name: Buildscript_1.00.028
** Auth: McNiel Viray
** Date: 07 July 2017
**************************
** Change History
**************************
** Create table [dbo].[HiringDatapoint]
** Create table [dbo].[WeeklyHiringDatapoint]
** Index for [dbo].[WeeklyHiringDatapoint]
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[HiringDatapoint]...';


GO
CREATE TABLE [dbo].[HiringDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentID]    BIGINT         NULL,
    [ReferenceID]  BIGINT         NOT NULL,
    [Name]         NVARCHAR (200) NOT NULL,
    [Datatype]     NVARCHAR (50)  NOT NULL,
    [SortOrder]    INT            NOT NULL,
    [CreatedBy]    NVARCHAR (250) NULL,
    [ModifiedBy]   NVARCHAR (250) NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    [Active]       BIT            NOT NULL,
    [Visible]      BIT            NOT NULL,
    CONSTRAINT [PK_HiringDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[WeeklyHiringDatapoint]...';


GO
CREATE TABLE [dbo].[WeeklyHiringDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Data]         NVARCHAR (200) NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [PK_WeeklyHiringDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[WeeklyHiringDatapoint].[IX_WeeklyHiringDatapoint_ByCampaignLobDatapointDataDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_WeeklyHiringDatapoint_ByCampaignLobDatapointDataDate]
    ON [dbo].[WeeklyHiringDatapoint]([CampaignID] ASC, [LoBID] ASC, [DatapointID] ASC, [Date] ASC)
    INCLUDE([Data]);


GO
PRINT N'Creating [dbo].[DF_HiringDatapoint_ReferenceID]...';


GO
ALTER TABLE [dbo].[HiringDatapoint]
    ADD CONSTRAINT [DF_HiringDatapoint_ReferenceID] DEFAULT (0) FOR [ReferenceID];


GO
PRINT N'Creating [dbo].[DF_HiringDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[HiringDatapoint]
    ADD CONSTRAINT [DF_HiringDatapoint_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_HiringDatapoint_Active]...';


GO
ALTER TABLE [dbo].[HiringDatapoint]
    ADD CONSTRAINT [DF_HiringDatapoint_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_HiringDatapoint_Visible]...';


GO
ALTER TABLE [dbo].[HiringDatapoint]
    ADD CONSTRAINT [DF_HiringDatapoint_Visible] DEFAULT (1) FOR [Visible];


GO
PRINT N'Creating [dbo].[DF_WeeklyHiringDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyHiringDatapoint]
    ADD CONSTRAINT [DF_WeeklyHiringDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Creating [dbo].[DF_WeeklyHiringDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyHiringDatapoint]
    ADD CONSTRAINT [DF_WeeklyHiringDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.029.sql
** Name: Buildscript_1.00.029
** Auth: McNiel Viray
** Date: 07 July 2017
**************************
** Change History
**************************
** Create data for [dbo].[HiringDatapoint]
** Create data for [dbo].[WeeklyHiringDatapoint]
*******************************/
USE WFMPCP
GO

PRINT N'Creating Hiring datapoint data...'
GO
INSERT INTO HiringDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('New Capacity','Reference',1,'McNiel Viray',GETDATE())
GO
INSERT INTO HiringDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Attrition Backfill','Reference',2,'McNiel Viray',GETDATE())
GO

PRINT N'Creating WeeklyHiringDatapoint data...'
GO

		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT ID,CampaignID FROM LoB
				ORDER BY ID

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @LobID,@CampaignID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyHiringDatapoint(CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM HiringDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @LobID,@CampaignID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
GO

PRINT N'Done Creating initial data...'
GO
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
/******************************
** File: Buildscript_1.00.031.sql
** Name: Buildscript_1.00.031
** Auth: McNiel Viray
** Date: 10 July 2017
**************************
** Change History
**************************
** Create [dbo].[wfmpcp_GetHiringRequirements_sp]...
** Create [dbo].[wfmpcp_GetHiringRequirementsTotal_sp]...
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[wfmpcp_GetHiringRequirements_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetHiringRequirements_sp]
	@campaignID AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1
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
						SELECT CampaignID,LobID,datapointid,[Date],[Data] from WeeklyHiringDatapoint
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
						SELECT CampaignID,LobID,datapointid,[Date],[Data] from WeeklyHiringDatapoint
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

	SET @orderBy = ' ORDER BY l.Name,d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetHiringRequirementsTotal_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetHiringRequirementsTotal_sp]
	@campaignID AS NVARCHAR(MAX)='',
	@start AS NVARCHAR(MAX)='',
	@end AS NVARCHAR(MAX)='',	
	@includeDatapoint BIT = 1
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
						SELECT CampaignID,datapointid,[Date],[Data]=CAST([Data] AS BIGINT) from WeeklyHiringDatapoint
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
						SELECT CampaignID,datapointid,[Date],[Data]=CAST([Data] AS BIGINT) from WeeklyHiringDatapoint
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

	SET @orderBy = ' ORDER BY d.SortOrder'
	SET @query = @select + @whereClause + @orderBy

	EXECUTE(@query);
END
GO
PRINT N'Update complete.';


GO

/******************************
** File: Buildscript_1.00.032.sql
** Name: Buildscript_1.00.032
** Auth: McNiel Viray
** Date: 10 July 2017
**************************
** Change History
**************************
** Create [dbo].[SiteCampaign]...
** Create [dbo].[SiteCampaignLob]...
** Deactive old Campaign...
** Add data to SiteCampaign table.
** Recreate camapign with duplicate..
*******************************/
USE WFMPCP
GO
PRINT N'Creating [dbo].[SiteCampaign]...';
GO
CREATE TABLE [dbo].[SiteCampaign]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT [PK_SiteCampaign_ID] PRIMARY KEY([ID]), 
	[SiteID] BIGINT NOT NULL , 
    [CampaignID] BIGINT NOT NULL,
	[Active] BIT  NOT NULL CONSTRAINT [DF_SiteCampaign_Active] DEFAULT(1)
)
GO
PRINT N'Creating [dbo].[SiteCampaignLoB]...';
GO
CREATE TABLE [dbo].[SiteCampaignLoB]
(
	[ID] BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT [PK_SiteCampaignLob_ID] PRIMARY KEY([ID]), 
	[SiteID] BIGINT NOT NULL , 
    [CampaignID] BIGINT NOT NULL, 
    [LobID] BIGINT NOT NULL,
	[Active] BIT  NOT NULL CONSTRAINT [DF_SiteCampaignLob_Active] DEFAULT(1)
)
GO
PRINT N'Create SiteCampaign record for single campaign...';
GO
INSERT INTO [SiteCampaign](SiteID,CampaignID)
SELECT 
c.SiteID
,c.ID
FROM Campaign c
WHERE Name IN (
	SELECT  
		c.Name
	FROM Campaign c
	INNER JOIN [Site] s on s.ID=c.SiteID
	GROUP BY c.Name
	HAVING COUNT(c.Name)=1
)
GO
PRINT N'Deactivate old Campaign with duplicate...';
GO
UPDATE Campaign
SET Active=0
WHERE Name IN (
	SELECT  
		c.Name
	FROM Campaign c
	INNER JOIN [Site] s on s.ID=c.SiteID
	GROUP BY c.Name
	HAVING COUNT(c.Name)>1
)
GO
PRINT N'Create new Campaign...';
GO
DECLARE @CampaignID BIGINT

INSERT INTO Campaign(SiteID,Name,Code,[Description],CreatedBy,DateCreated,Active)
VALUES(0,'HUDL','HUDL','','McNiel Viray',GETDATE(),1)
SELECT @CampaignID = SCOPE_IDENTITY()
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(3,@CampaignID)
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(4,@CampaignID)

INSERT INTO Campaign(SiteID,Name,Code,[Description],CreatedBy,DateCreated,Active)
VALUES(0,'MEDIAMAX','MEDIAMAX','','McNiel Viray',GETDATE(),1)
SELECT @CampaignID = SCOPE_IDENTITY()
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(3,@CampaignID)
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(4,@CampaignID)

INSERT INTO Campaign(SiteID,Name,Code,[Description],CreatedBy,DateCreated,Active)
VALUES(0,'POSTMATES','POSTMATES','','McNiel Viray',GETDATE(),1)
SELECT @CampaignID = SCOPE_IDENTITY()
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(2,@CampaignID)
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(4,@CampaignID)

INSERT INTO Campaign(SiteID,Name,Code,[Description],CreatedBy,DateCreated,Active)
VALUES(0,'WISH','WISH','','McNiel Viray',GETDATE(),1)
SELECT @CampaignID = SCOPE_IDENTITY()
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(3,@CampaignID)
	INSERT INTO SiteCampaign(SiteID,CampaignID) VALUES(5,@CampaignID)
GO
PRINT N'Update complete.'
GO
/******************************
** File: Buildscript_1.00.033.sql
** Name: Buildscript_1.00.033
** Auth: McNiel Viray
** Date: 11 July 2017
**************************
** Change History
**************************
** Create SiteCampaignLoB data...
*******************************/
USE WFMPCP
GO

DECLARE @tbl AS TABLE
(
SiteName NVARCHAR(150),
SiteID BIGINT,
CampaignName NVARCHAR(150),
CampaignID BIGINT NULL,
LobID BIGINT,
LobName NVARCHAR(150),
LobDesc NVARCHAR(300)
)

INSERT INTO @tbl(SiteName,SiteID,CampaignName,LobID,LobName,LobDesc)
SELECT
s.Name 
,s.ID
,c.Name 
,l.ID 
,l.Name 
,l.[Description] 
FROM LoB l
INNER JOIN Campaign c ON c.ID=l.CampaignID
INNER JOIN [Site] s ON s.ID=c.SiteID
ORDER BY l.Name

UPDATE t
SET t.CampaignID=c.ID
FROM @tbl t
INNER JOIN Campaign c ON c.Name=t.CampaignName
WHERE c.Active=1

--CREATE SiteCampaignLob (NON-Redundant Lob)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
SELECT SiteID,CampaignID,LobID
FROM @tbl
WHERE LobName IN
(
	SELECT  
		l.Name
	FROM Lob l
	GROUP BY l.Name
	HAVING COUNT(l.Name)=1
)

--CREATE SiteCampaignLob (Redundant - COUNT=2)
--HUDL Basketball - Full Time
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,21,50)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,21,50)
UPDATE LoB SET Active=0 WHERE ID=60
--ADORME Chat
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(1,2,32)
--TILE Chat
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,6,42)
--WISH Content Moderation
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(5,24,63)
--MERCARI Content Moderation
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,15,57)
--HUDL Football - Full Time
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,21,48)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,21,48)
UPDATE LoB SET Active=0 WHERE ID=58
--HUDL Football - Part Time
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,21,49)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,21,49)
UPDATE LoB SET Active=0 WHERE ID=59
--POSTMATES Full Time
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,23,43)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,23,43)
UPDATE LoB SET Active=0 WHERE ID=54
--MEDIAMAX
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,22,52)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,22,52)
UPDATE LoB SET Active=0 WHERE ID=53
--POSTMATES
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,23,44)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,23,44)
UPDATE LoB SET Active=0 WHERE ID=55
--Adorme Phone
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(1,2,30)
--Nimble Phone
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,4,36)
--Box Sales
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,5,40)
--Sparefood Sales
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(5,19,68)
--ADORME Email
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(1,2,31)
--NIMBLE EMail
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,4,37)
--TILE Email
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,6,41)
--WISH EMAIL
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,24,51)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(5,24,51)
UPDATE LoB SET Active=0 WHERE ID=61
GO
/******************************
** File: Buildscript_1.00.034.sql
** Name: Buildscript_1.00.034
** Auth: McNiel Viray
** Date: 11 July 2017
**************************
** Change History
**************************
** 1. add new column SiteID to [dbo].[WeeklyAHDatapoint],[dbo].[WeeklyAHDatapointLog]
** ,[dbo].[WeeklyHiringDatapoint],[dbo].[WeeklyStaffDatapoint],[dbo].[wfmpcp_GetAssumptionsHeadcount_sp]
** 2. Update indexes of each table.
*******************************/
USE WFMPCP
GO


PRINT N'Rename refactoring operation with key 1c83dedd-104e-4f96-90cb-a951e72267a0 is skipped, element [dbo].[SiteCampaign].[Id] (SqlSimpleColumn) will not be renamed to ID';


GO
PRINT N'Rename refactoring operation with key 1b1445e8-51d8-44de-bc8c-902de25858ee is skipped, element [dbo].[SiteCampaignLoB].[Id] (SqlSimpleColumn) will not be renamed to ID';


GO
PRINT N'Rename refactoring operation with key 414d8eb9-bba1-4ab4-b279-aa58e13631fb is skipped, element [dbo].[SiteCampaign].[ID] (SqlSimpleColumn) will not be renamed to SiteID';


GO
PRINT N'Rename refactoring operation with key 3fa055b1-568b-4e05-b44b-17a403302373 is skipped, element [dbo].[SiteCampaignLoB].[ID] (SqlSimpleColumn) will not be renamed to SiteID';


GO
PRINT N'Dropping [dbo].[DF_WeeklyAHDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint] DROP CONSTRAINT [DF_WeeklyAHDatapoint_DateCreated];


GO
PRINT N'Dropping [dbo].[DF_WeeklyAHDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint] DROP CONSTRAINT [DF_WeeklyAHDatapoint_Data];


GO
PRINT N'Dropping unnamed constraint on [dbo].[WeeklyAHDatapointLog]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapointLog] DROP CONSTRAINT [DF__WeeklyAHDa__Data__7E37BEF6];


GO
PRINT N'Dropping unnamed constraint on [dbo].[WeeklyAHDatapointLog]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapointLog] DROP CONSTRAINT [DF__WeeklyAHD__DateC__7F2BE32F];


GO
PRINT N'Dropping unnamed constraint on [dbo].[WeeklyAHDatapointLog]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapointLog] DROP CONSTRAINT [DF__WeeklyAHD__DateE__00200768];


GO
PRINT N'Dropping [dbo].[DF_WeeklyHiringDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyHiringDatapoint] DROP CONSTRAINT [DF_WeeklyHiringDatapoint_DateCreated];


GO
PRINT N'Dropping [dbo].[DF_WeeklyHiringDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyHiringDatapoint] DROP CONSTRAINT [DF_WeeklyHiringDatapoint_Data];


GO
PRINT N'Dropping [dbo].[DF_WeeklyStaffDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyStaffDatapoint] DROP CONSTRAINT [DF_WeeklyStaffDatapoint_Data];


GO
PRINT N'Dropping [dbo].[DF_WeeklyStaffDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyStaffDatapoint] DROP CONSTRAINT [DF_WeeklyStaffDatapoint_DateCreated];


GO
PRINT N'Starting rebuilding table [dbo].[WeeklyAHDatapoint]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_WeeklyAHDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SiteID]       BIGINT         NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Data]         NVARCHAR (200) CONSTRAINT [DF_WeeklyAHDatapoint_Data] DEFAULT ('') NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       CONSTRAINT [DF_WeeklyAHDatapoint_DateCreated] DEFAULT (getdate()) NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_WeeklyAHDatapoint_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[WeeklyAHDatapoint])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_WeeklyAHDatapoint] ON;
        INSERT INTO [dbo].[tmp_ms_xx_WeeklyAHDatapoint] ([ID], [CampaignID], [LoBID], [DatapointID], [Week], [Data], [Date], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified])
        SELECT   [ID],
                 [CampaignID],
                 [LoBID],
                 [DatapointID],
                 [Week],
                 [Data],
                 [Date],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified]
        FROM     [dbo].[WeeklyAHDatapoint]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_WeeklyAHDatapoint] OFF;
    END

DROP TABLE [dbo].[WeeklyAHDatapoint];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_WeeklyAHDatapoint]', N'WeeklyAHDatapoint';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_WeeklyAHDatapoint_ID1]', N'PK_WeeklyAHDatapoint_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [dbo].[WeeklyAHDatapoint].[IX_WeeklyAHDatapoint_ByLobDatapointDataDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_WeeklyAHDatapoint_ByLobDatapointDataDate]
    ON [dbo].[WeeklyAHDatapoint]([SiteID] ASC, [CampaignID] ASC, [LoBID] ASC, [DatapointID] ASC, [Date] ASC)
    INCLUDE([Data]);


GO
PRINT N'Starting rebuilding table [dbo].[WeeklyAHDatapointLog]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_WeeklyAHDatapointLog] (
    [ID]           BIGINT         NOT NULL,
    [SiteID]       BIGINT         NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Data]         NVARCHAR (200) DEFAULT ('') NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [DateModified] DATETIME       NULL,
    [DateEntered]  DATETIME       DEFAULT (getdate()) NOT NULL
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[WeeklyAHDatapointLog])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_WeeklyAHDatapointLog] ([ID], [CampaignID], [LoBID], [DatapointID], [Week], [Data], [Date], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified], [DateEntered])
        SELECT [ID],
               [CampaignID],
               [LoBID],
               [DatapointID],
               [Week],
               [Data],
               [Date],
               [CreatedBy],
               [ModifiedBy],
               [DateCreated],
               [DateModified],
               [DateEntered]
        FROM   [dbo].[WeeklyAHDatapointLog];
    END

DROP TABLE [dbo].[WeeklyAHDatapointLog];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_WeeklyAHDatapointLog]', N'WeeklyAHDatapointLog';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Starting rebuilding table [dbo].[WeeklyHiringDatapoint]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_WeeklyHiringDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SiteID]       BIGINT         NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Data]         NVARCHAR (200) CONSTRAINT [DF_WeeklyHiringDatapoint_Data] DEFAULT ('') NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       CONSTRAINT [DF_WeeklyHiringDatapoint_DateCreated] DEFAULT (getdate()) NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_WeeklyHiringDatapoint_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[WeeklyHiringDatapoint])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_WeeklyHiringDatapoint] ON;
        INSERT INTO [dbo].[tmp_ms_xx_WeeklyHiringDatapoint] ([ID], [CampaignID], [LoBID], [DatapointID], [Week], [Data], [Date], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified])
        SELECT   [ID],
                 [CampaignID],
                 [LoBID],
                 [DatapointID],
                 [Week],
                 [Data],
                 [Date],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified]
        FROM     [dbo].[WeeklyHiringDatapoint]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_WeeklyHiringDatapoint] OFF;
    END

DROP TABLE [dbo].[WeeklyHiringDatapoint];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_WeeklyHiringDatapoint]', N'WeeklyHiringDatapoint';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_WeeklyHiringDatapoint_ID1]', N'PK_WeeklyHiringDatapoint_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [dbo].[WeeklyHiringDatapoint].[IX_WeeklyHiringDatapoint_ByCampaignLobDatapointDataDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_WeeklyHiringDatapoint_ByCampaignLobDatapointDataDate]
    ON [dbo].[WeeklyHiringDatapoint]([SiteID] ASC, [CampaignID] ASC, [LoBID] ASC, [DatapointID] ASC, [Date] ASC)
    INCLUDE([Data]);


GO
PRINT N'Starting rebuilding table [dbo].[WeeklyStaffDatapoint]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_WeeklyStaffDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SiteID]       BIGINT         NULL,
    [CampaignID]   BIGINT         NULL,
    [LoBID]        BIGINT         NULL,
    [DatapointID]  BIGINT         NOT NULL,
    [Week]         INT            NOT NULL,
    [Data]         NVARCHAR (200) CONSTRAINT [DF_WeeklyStaffDatapoint_Data] DEFAULT ('') NOT NULL,
    [Date]         DATE           NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       CONSTRAINT [DF_WeeklyStaffDatapoint_DateCreated] DEFAULT (getdate()) NOT NULL,
    [DateModified] DATETIME       NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_WeeklyStaffDatapoint_ID1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[WeeklyStaffDatapoint])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_WeeklyStaffDatapoint] ON;
        INSERT INTO [dbo].[tmp_ms_xx_WeeklyStaffDatapoint] ([ID], [CampaignID], [LoBID], [DatapointID], [Week], [Data], [Date], [CreatedBy], [ModifiedBy], [DateCreated], [DateModified])
        SELECT   [ID],
                 [CampaignID],
                 [LoBID],
                 [DatapointID],
                 [Week],
                 [Data],
                 [Date],
                 [CreatedBy],
                 [ModifiedBy],
                 [DateCreated],
                 [DateModified]
        FROM     [dbo].[WeeklyStaffDatapoint]
        ORDER BY [ID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_WeeklyStaffDatapoint] OFF;
    END

DROP TABLE [dbo].[WeeklyStaffDatapoint];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_WeeklyStaffDatapoint]', N'WeeklyStaffDatapoint';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_WeeklyStaffDatapoint_ID1]', N'PK_WeeklyStaffDatapoint_ID', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [dbo].[WeeklyStaffDatapoint].[IX_WeeklyStaffDatapoint_ByLobDatapointDataDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_WeeklyStaffDatapoint_ByLobDatapointDataDate]
    ON [dbo].[WeeklyStaffDatapoint]([SiteID] ASC, [CampaignID] ASC, [LoBID] ASC, [DatapointID] ASC, [Date] ASC)
    INCLUDE([Data]);


GO
PRINT N'Creating [dbo].[TRG_WeeklyAHDatapoint_Update]...';


GO
CREATE TRIGGER TRG_WeeklyAHDatapoint_Update 
	ON [dbo].[WeeklyAHDatapoint] 
	FOR UPDATE
AS
BEGIN
	INSERT [dbo].[WeeklyAHDatapointLog] (ID,SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,ModifiedBy,DateCreated,DateModified)
	SELECT
	   d.ID,d.SiteID,d.CampaignID,d.LoBID,d.DatapointID,d.[Week],d.[Data],d.[Date],d.CreatedBy,d.ModifiedBy,d.DateCreated,d.DateModified
	FROM
	   DELETED d 
	--   JOIN INSERTED i ON d.ID = i.ID
	--WHERE
	--   d.[Data] <> i.[Data]
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]...';


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
				WHEN 1 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 2 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 3 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
				WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 5 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 7 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 8 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + '%'
				WHEN 13 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 14 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 21 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 22 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 23 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 24 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 25 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 26 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 27 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 28 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 29 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 30 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 31 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 32 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 33 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 34 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 35 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 36 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 37 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 38 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 39 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 40 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 41 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 42 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 43 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 44 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 45 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 46 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 47 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 48 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 49 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 50 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 51 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 52 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 53 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 54 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 55 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 56 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 57 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 58 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 59 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 60 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 61 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 62 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 63 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 64 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 65 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 66 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 67 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 68 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 69 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 70 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 71 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 72 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 73 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 74 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 75 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 76 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 77 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 78 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 79 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 80 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 81 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 82 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 83 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 84 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 85 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 86 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 87 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 91 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 92 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 93 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 94 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 95 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 96 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 97 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 98 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 99 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 100 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 101 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 102 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 103 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 104 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 105 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 106 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 107 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 108 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 109 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 110 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 111 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 112 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 113 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 114 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 115 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 116 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 117 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
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
				WHEN 1 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 2 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 3 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
				WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 5 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 7 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 8 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + '%'
				WHEN 13 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
				WHEN 14 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 21 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 22 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 23 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 24 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 25 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 26 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 27 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 28 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 29 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 30 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 31 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 32 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 33 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 34 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 35 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 36 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 37 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 38 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 39 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 40 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 41 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 42 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 43 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 44 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 45 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 46 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 47 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 48 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 49 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 50 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 51 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 52 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 53 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 54 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 55 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 56 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 57 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 58 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 59 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 60 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 61 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
				WHEN 62 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 63 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 64 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 65 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 66 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 67 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 68 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 69 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 70 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 71 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 72 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 73 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 74 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 75 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 76 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 77 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 78 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 79 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 80 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 81 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 82 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 83 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 84 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 85 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 86 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 87 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 91 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 92 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 93 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 94 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 95 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 96 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 97 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 98 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 99 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 100 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 101 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 102 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 103 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 104 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 105 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
				WHEN 106 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 107 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 108 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 109 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 110 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 111 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 112 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 113 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 114 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 115 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 116 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
				WHEN 117 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
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
PRINT N'Refreshing [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]';


GO
PRINT N'Refreshing [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]';


GO
PRINT N'Refreshing [dbo].[wfmpcp_SaveWeeklyAHDatapoint_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveWeeklyAHDatapoint_sp]';


GO
PRINT N'Refreshing [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]';


GO
PRINT N'Refreshing [dbo].[wfmpcp_GetHiringRequirements_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_GetHiringRequirements_sp]';


GO
PRINT N'Refreshing [dbo].[wfmpcp_GetHiringRequirementsTotal_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_GetHiringRequirementsTotal_sp]';


GO
PRINT N'Refreshing [dbo].[wfmpcp_GetStaffPlanner_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_GetStaffPlanner_sp]';


GO
-- Refactoring step to update target server with deployed transaction logs
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '1c83dedd-104e-4f96-90cb-a951e72267a0')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('1c83dedd-104e-4f96-90cb-a951e72267a0')
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '414d8eb9-bba1-4ab4-b279-aa58e13631fb')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('414d8eb9-bba1-4ab4-b279-aa58e13631fb')
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '1b1445e8-51d8-44de-bc8c-902de25858ee')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('1b1445e8-51d8-44de-bc8c-902de25858ee')
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '3fa055b1-568b-4e05-b44b-17a403302373')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('3fa055b1-568b-4e05-b44b-17a403302373')

GO

GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.035.sql
** Name: Buildscript_1.00.035
** Auth: McNiel Viray
** Date: 11 July 2017
**************************
** Change History
**************************
** Update wfmpcp_CreateWeeklyAHDatapoint_sp and wfmpcp_CreateWeeklyStaffDatapoint_sp
** Create wfmpcp_CreateWeeklyHiringDatapoint_sp
** Truncate table WeeklyAHDatapoint and WeeklyStaffDatapoint
** Create data to table(s) WeeklyAHDatapoint, WeeklyStaffDatapoint,WeeklyStaffDatapoint
*******************************/
USE WFMPCP
GO
PRINT N'Truncate table WeeklyAHDatapoint and WeeklyStaffDatapoint ...'
GO
TRUNCATE TABLE WeeklyAHDatapoint
TRUNCATE TABLE WeeklyStaffDatapoint
TRUNCATE TABLE WeeklyHiringDatapoint
GO

PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]
AS
BEGIN

	DECLARE @ID INT
	,@WeekStartDatetime SMALLDATETIME
	,@WeekOfYear SMALLINT
	,@CampaignID BIGINT
	,@LoBID BIGINT
	,@SiteID BIGINT

	DECLARE week_cursor CURSOR FOR
	SELECT ID, WeekStartdate, WeekOfYear FROM [Week]

	OPEN week_cursor

	FETCH FROM week_cursor
	INTO @ID,@WeekStartDatetime,@WeekOfYear

	WHILE @@FETCH_STATUS=0
	BEGIN

			DECLARE lob_cursor CURSOR FOR
			SELECT ID, CampaignID, LoBID, SiteID FROM SiteCampaignLoB
			--SELECT ID, CampaignID FROM LoB

			OPEN lob_cursor
	
			FETCH FROM lob_cursor
			INTO @ID,@LoBID,@CampaignID,@SiteID

			WHILE @@FETCH_STATUS=0
			BEGIN
				INSERT INTO WeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],Data,[Date],CreatedBy,DateCreated)
				SELECT 
					@SiteID
					,@CampaignID
					,@LoBID
					,d.ID
					,@WeekOfYear
					,'0'--data
					,CAST(@WeekStartDatetime AS DATE)
					,'McNiel Viray'
					,GETDATE()		
				FROM Datapoint d
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder


				FETCH NEXT FROM lob_cursor
				INTO @ID,@LoBID,@CampaignID,@SiteID
			END
			CLOSE lob_cursor;
			DEALLOCATE lob_cursor;

		FETCH NEXT FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear
	END
	CLOSE week_cursor;
	DEALLOCATE week_cursor;

END
GO
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]
AS
BEGIN
		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT
			,@SiteID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT ID, CampaignID, LoBID, SiteID FROM SiteCampaignLoB
				ORDER BY ID

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @ID,@LoBID,@CampaignID,@SiteID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyStaffDatapoint(CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM StaffDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @ID,@LoBID,@CampaignID,@SiteID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
END
GO
PRINT N'Creating [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]
AS
BEGIN
		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT
			,@SiteID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT ID, CampaignID, LoBID, SiteID FROM SiteCampaignLoB
				ORDER BY ID

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @ID,@LoBID,@CampaignID,@SiteID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyHiringDatapoint(CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM HiringDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @ID,@LoBID,@CampaignID,@SiteID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
END
GO
PRINT N'Creating data to WeeklyAHDatapoint...';
GO
EXEC wfmpcp_CreateWeeklyAHDatapoint_sp
GO
PRINT N'Creating data to WeeklyStaffDataoint...';
GO
EXEC wfmpcp_CreateWeeklyStaffDatapoint_sp
GO
PRINT N'Creating data to WeeklyHiringDatapoint...'
GO
EXEC wfmpcp_CreateWeeklyHiringDatapoint_sp

GO
PRINT N'Update complete.';


GO
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
/******************************
** File: Buildscript_1.00.035.sql
** Name: Buildscript_1.00.035
** Auth: McNiel Viray
** Date: 12 July 2017
**************************
** Change History
**************************
** Update wfmpcp_CreateWeeklyAHDatapoint_sp and wfmpcp_CreateWeeklyStaffDatapoint_sp
** Create wfmpcp_CreateWeeklyHiringDatapoint_sp
** Truncate table WeeklyAHDatapoint and WeeklyStaffDatapoint
** Create data to table(s) WeeklyAHDatapoint, WeeklyStaffDatapoint,WeeklyStaffDatapoint
*******************************/
USE WFMPCP
GO
PRINT N'Truncate table WeeklyAHDatapoint and WeeklyStaffDatapoint ...'
GO
TRUNCATE TABLE WeeklyAHDatapoint
TRUNCATE TABLE WeeklyStaffDatapoint
TRUNCATE TABLE WeeklyHiringDatapoint
GO

PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]
AS
BEGIN

	DECLARE @ID INT
	,@WeekStartDatetime SMALLDATETIME
	,@WeekOfYear SMALLINT
	,@CampaignID BIGINT
	,@LoBID BIGINT
	,@SiteID BIGINT

	DECLARE week_cursor CURSOR FOR
	SELECT ID, WeekStartdate, WeekOfYear FROM [Week]

	OPEN week_cursor

	FETCH FROM week_cursor
	INTO @ID,@WeekStartDatetime,@WeekOfYear

	WHILE @@FETCH_STATUS=0
	BEGIN

			DECLARE lob_cursor CURSOR FOR
			SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB
			--SELECT ID, CampaignID FROM LoB

			OPEN lob_cursor
	
			FETCH FROM lob_cursor
			INTO @SiteID,@CampaignID,@LoBID

			WHILE @@FETCH_STATUS=0
			BEGIN
				INSERT INTO WeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],Data,[Date],CreatedBy,DateCreated)
				SELECT 
					@SiteID
					,@CampaignID
					,@LoBID
					,d.ID
					,@WeekOfYear
					,'0'--data
					,CAST(@WeekStartDatetime AS DATE)
					,'McNiel Viray'
					,GETDATE()		
				FROM Datapoint d
				INNER JOIN Segment s ON s.ID=d.SegmentID
				INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
				ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder


				FETCH NEXT FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID
			END
			CLOSE lob_cursor;
			DEALLOCATE lob_cursor;

		FETCH NEXT FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear
	END
	CLOSE week_cursor;
	DEALLOCATE week_cursor;

END
GO
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyHiringDatapoint_sp]
AS
BEGIN
		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT
			,@SiteID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyHiringDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@SiteID
							,@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM HiringDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @SiteID,@CampaignID,@LoBID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
END
GO
PRINT N'Altering [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]
AS
BEGIN
		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT
			,@SiteID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT SiteID, CampaignID, LoBID FROM SiteCampaignLoB

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @SiteID,@CampaignID,@LoBID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyStaffDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@SiteID
							,@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM StaffDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @SiteID,@CampaignID,@LoBID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
END
GO

PRINT N'Creating data to WeeklyAHDatapoint...';
GO
EXEC wfmpcp_CreateWeeklyAHDatapoint_sp
GO
PRINT N'Creating data to WeeklyStaffDataoint...';
GO
EXEC wfmpcp_CreateWeeklyStaffDatapoint_sp
GO
PRINT N'Creating data to WeeklyHiringDatapoint...'
GO
EXEC wfmpcp_CreateWeeklyHiringDatapoint_sp
GO
PRINT N'Update complete.';

GO
/******************************
** File: Buildscript_1.00.038.sql
** Name: Buildscript_1.00.038
** Auth: McNiel Viray
** Date: 12 July 2017
**************************
** Change History
**************************
** Alter stored procedures wfmpcp_GetAssumptionsHeadcount_sp,wfmpcp_GetHiringRequirements_sp,wfmpcp_GetHiringRequirementsTotal_sp
** wfmpcp_GetStaffPlanner_sp
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[wfmpcp_GetHiringRequirements_sp]...';


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
						SELECT CampaignID,LobID,datapointid,[Date],[Data] from WeeklyHiringDatapoint
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
						SELECT CampaignID,datapointid,[Date],[Data]=CAST([Data] AS BIGINT) from WeeklyHiringDatapoint
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
PRINT N'Altering [dbo].[wfmpcp_GetStaffPlanner_sp]...';


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
					WHEN 1 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 2 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 3 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 5 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 7 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 8 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 13 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
					WHEN 14 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
					WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 21 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 22 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					ELSE CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(10)) END
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
					WHEN 1 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 2 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 3 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 4 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 5 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 6 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 7 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 8 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 9 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 10 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 11 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 12 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX))
					WHEN 13 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
					WHEN 14 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) 
					WHEN 15 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 16 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX))
					WHEN 17 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 18 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 19 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 20 THEN CAST(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0) AS NVARCHAR(MAX)) + ' %'
					WHEN 21 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					WHEN 22 THEN CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(MAX)) 
					ELSE CAST(CEILING(ROUND(CAST(LTRIM(RTRIM(REPLACE(Data,'%',''))) AS DECIMAL(10,2)),0)) AS NVARCHAR(10)) END
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
PRINT N'Update complete.';


GO
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
/******************************
** File: Buildscript_1.00.040.sql
** Name: Buildscript_1.00.040
** Auth: McNiel Viray
** Date: 14 July 2017
**************************
** Change History
**************************
** Alter stored procedure [dbo].[wfmpcp_GetHiringRequirements_sp]
*******************************/
USE WFMPCP
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
				SELECT a.DatapointID,l.ID LobID,l.Name [Lob], d.Name [Datapoint],' + @cols + '
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