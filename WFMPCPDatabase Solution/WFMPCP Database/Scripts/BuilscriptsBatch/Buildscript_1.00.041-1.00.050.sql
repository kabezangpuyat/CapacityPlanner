--41 to 45
/******************************
** File: Buildscript_1.00.041.sql
** Name: Buildscript_1.00.041
** Auth: McNiel Viray
** Date: 27 July 2017
**************************
** Change History
**************************
** Create table valued function[dbo].[udf_GetWeekToGenerate]
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[udf_GetWeekToGenerate]...';


GO
CREATE FUNCTION [dbo].[udf_GetWeekToGenerate]
(
	@DatapointTableName VARCHAR(100),
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LoBID BIGINT
)
RETURNS @returntable TABLE
(
	[Year] SMALLINT,
	[Month] VARCHAR(150),
	WeekOfYear SMALLINT,
	WeekNo  VARCHAR(100),
	WeekNoDate DATE
)
AS
BEGIN
	DELETE FROM @returntable
	IF(@DatapointTableName='ahc')
	BEGIN
		INSERT INTO @returntable([Year],[Month],WeekOfYear,WeekNo,WeekNoDate)
		SELECT [Year],[Month],WeekOfYear,WeekNo,CAST(WeekNoDate AS DATE) FROM [Week]
		WHERE LTRIM(RTRIM(WeekNoDate)) NOT IN (
			SELECT CAST(w.[Date] AS VARCHAR(12)) FROM WeeklyAHDatapoint w
			WHERE w.SiteID=@SiteID
				AND w.CampaignID=@CampaignID
				AND w.LobID=@LoBID
		)
		ORDER BY ID ASC
	END

	IF(@DatapointTableName='staffing')
	BEGIN
		INSERT INTO @returntable([Year],[Month],WeekOfYear,WeekNo,WeekNoDate)
		SELECT [Year],[Month],WeekOfYear,WeekNo,CAST(WeekNoDate AS DATE) FROM [Week]
		WHERE LTRIM(RTRIM(WeekNoDate)) NOT IN (
			SELECT CAST(w.[Date] AS VARCHAR(12)) FROM WeeklyStaffDatapoint w
			WHERE w.SiteID=@SiteID
				AND w.CampaignID=@CampaignID
				AND w.LobID=@LoBID
		)
		ORDER BY ID ASC
	END

	IF(@DatapointTableName='hiring')
	BEGIN
		INSERT INTO @returntable([Year],[Month],WeekOfYear,WeekNo,WeekNoDate)
		SELECT [Year],[Month],WeekOfYear,WeekNo,CAST(WeekNoDate AS DATE) FROM [Week]
		WHERE LTRIM(RTRIM(WeekNoDate)) NOT IN (
			SELECT CAST(w.[Date] AS VARCHAR(12)) FROM WeeklyHiringDatapoint w
			WHERE w.SiteID=@SiteID
				AND w.CampaignID=@CampaignID
				AND w.LobID=@LoBID
		)
		ORDER BY ID ASC
	END

	RETURN;
END
GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.042.sql
** Name: Buildscript_1.00.042
** Auth: McNiel Viray
** Date: 27 July 2017
**************************
** Change History
**************************
** Create [dbo].[WeeklySummaryDatapoint]
** Create [dbo].[SummaryDatapoint]
** Create stored procedure on creating Weekly Summary Datapoint([dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp])
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[SummaryDatapoint]...';


GO
CREATE TABLE [dbo].[SummaryDatapoint] (
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
    CONSTRAINT [PK_SummaryDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[WeeklySummaryDatapoint]...';


GO
CREATE TABLE [dbo].[WeeklySummaryDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SiteID]       BIGINT         NULL,
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
    CONSTRAINT [PK_WeeklySummaryDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_SummaryDatapoint_ReferenceID]...';


GO
ALTER TABLE [dbo].[SummaryDatapoint]
    ADD CONSTRAINT [DF_SummaryDatapoint_ReferenceID] DEFAULT (0) FOR [ReferenceID];


GO
PRINT N'Creating [dbo].[DF_SummaryDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[SummaryDatapoint]
    ADD CONSTRAINT [DF_SummaryDatapoint_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_SummaryDatapoint_Active]...';


GO
ALTER TABLE [dbo].[SummaryDatapoint]
    ADD CONSTRAINT [DF_SummaryDatapoint_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_SummaryDatapoint_Visible]...';


GO
ALTER TABLE [dbo].[SummaryDatapoint]
    ADD CONSTRAINT [DF_SummaryDatapoint_Visible] DEFAULT (1) FOR [Visible];


GO
PRINT N'Creating [dbo].[DF_WeeklySummaryDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklySummaryDatapoint]
    ADD CONSTRAINT [DF_WeeklySummaryDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Creating [dbo].[DF_WeeklySummaryDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklySummaryDatapoint]
    ADD CONSTRAINT [DF_WeeklySummaryDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Creating [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]
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
						INSERT INTO WeeklySummaryDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
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
						FROM SummaryDatapoint d
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
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.043.sql
** Name: Buildscript_1.00.043
** Auth: McNiel Viray
** Date: 27 July 2017
**************************
** Change History
**************************
** Create data for Summary Datapoint
** Execute [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]
*******************************/
USE WFMPCP
GO

INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target Service Level','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Projected Service Level','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Service Level','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Forecast','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Offered','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Handled','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Capacity','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Variance (Offered vs Forecast)','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target AHT','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual AHT','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('AHT Variance (Percentage to Goal)','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target Production Hours','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Production Hours','Formula',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Production Hours Variance','Formula',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Billable Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Required Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Production Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Nesting Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Training Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Billable Excess/Deficits','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Required Excess/Deficits','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Production Attrition','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Nesting + Training Attrition','Formula',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Nesting Attrition','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Training Attrition','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Total Target Shrinkage','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target In-center Shrinkage','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target Out-of center Shrinkage','',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Total Actual Shrinkage','',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual In-center Shrinkage','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Out-of center Shrinkage','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Shrinkage Variance (Target - Actual)','Formula',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target Occupancy','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Occupancy','Reference',1,'McNiel Viray',GETDATE())

GO

PRINT 'Execute [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]'
GO
EXEC [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]
GO
/******************************
** File: Buildscript_1.00.044.sql
** Name: Buildscript_1.00.044
** Auth: McNiel Viray
** Date: 28 July 2017
**************************
** Change History
**************************
** Modify stored procedure [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
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
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--32
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],54)--33
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],55)--34
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.TargetServiceLevel,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ProjectedServiceLevel,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ActualServiceLevel,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.VolumeForecast,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.VolumeOffered,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.VolumeHandled,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.VolumeCapacity,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.VolumeVarianceOfferedvsForecast,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.TargetAHT,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ActualAHT,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AHTVariancePercentagetoGoal,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.TargetProductionHours,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ActualProductionHours,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ProductionHoursVariance,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableHeadcount,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredHeadcount,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ActualProductionHeadcount,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ActualNestingHeadcount,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ActualTrainingHeadcount,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableExcessDeficits,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredExcessDeficits,0)) AS NVARCHAR(250))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ProductionAttrition,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NestingTrainingAttrition,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NestingAttrition,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.TrainingAttrition,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.TotalTargetShrinkage,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.TargetIncenterShrinkage,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.TargetOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.TotalActualShrinkage,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ActualIncenterShrinkage,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=30

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ActualOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=31

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ShrinkageVarianceTargetActual,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=32

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.TargetOccupancy,0) AS NVARCHAR(250)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=33

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ActualOccupancy,0) AS NVARCHAR(250)) + ' %'
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
** File: Buildscript_1.00.045.sql
** Name: Buildscript_1.00.045
** Auth: McNiel Viray
** Date: 28 July 2017
**************************
** Change History
**************************
** Create stored procedure [dbo].[wfmpcp_GetSummary1_sp]
*******************************/
USE WFMPCP
GO



PRINT N'Creating [dbo].[wfmpcp_GetSummary1_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetSummary1_sp]
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
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklySummaryDatapoint
					 ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN SummaryDatapoint d ON d.ID=A.DatapointID
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
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklySummaryDatapoint
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN SummaryDatapoint d ON d.ID=A.DatapointID
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
PRINT N'Update complete.';


GO

/******************************
** File: Buildscript_1.00.046.sql
** Name: Buildscript_1.00.046
** Auth: McNiel Viray
** Date: 31 July 2017
**************************
** Change History
**************************
** Create index IX_WeeklySummaryDatapoint_ByCampaignLobDatapointDataDate
*******************************/
USE WFMPCP
GO
CREATE INDEX [IX_WeeklySummaryDatapoint_ByCampaignLobDatapointDataDate]
ON [dbo].[WeeklySummaryDatapoint] ([SiteID],[CampaignID],[LoBID],[DatapointID],[Date])
INCLUDE ([Data])
GO


/******************************
** File: Buildscript_1.00.047.sql
** Name: Buildscript_1.00.047
** Auth: McNiel Viray
** Date: 31 July 2017
**************************
** Change History
**************************
** Create data for Summary1 module
*******************************/
USE WFMPCP
GO


PRINT N'Create MOdule..'
DECLARE @ModuleID BIGINT

INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(12,'Summary 1','fa-tag','/CapacityPlanner/Summary',4,'McNiel Viray')

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
/******************************
** File: Buildscript_1.00.048.sql
** Name: Buildscript_1.00.048
** Auth: McNiel Viray
** Date: 02 August 2017
**************************
** Change History
**************************
** Create Hiring Outlook Moduels
*******************************/
USE WFMPCP
GO


PRINT N'Create MOdule..'
UPDATE Module
SET SortOrder=6
WHERE ID=7
GO
DECLARE @ModuleID BIGINT
	,@ParentID BIGINT

INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(0,'Hiring Outlook','fa-tag','#',5,'McNiel Viray')

SELECT @ParentID = SCOPE_IDENTITY()

--Admin
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,1,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,2,'McNiel Viray',1)
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,1,3,'McNiel Viray',1)

--WFM
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,2,1,'McNiel Viray',1)

--OPerations
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,3,1,'McNiel Viray',1)

--Training
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,4,1,'McNiel Viray',1)

--Recruitment
INSERT INTO ModuleRolePermission(ModuleID,RoleID,PermissionID,CreatedBy,Active)
VALUES(@ParentID,5,1,'McNiel Viray',1)

--************************
--SUMMARY OVERALL
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Summary (Overall)','fa-tag','/HiringOutlook/SummaryOverall',1,'McNiel Viray')

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


--************************
--SITE WEEKLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Site - Weekly Summary','fa-tag','/HiringOutlook/SiteWeeklySummary',2,'McNiel Viray')

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


--************************
--SITE MONTHLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Site - Monhtly Summary','fa-tag','/HiringOutlook/SiteMonthlySummary',3,'McNiel Viray')

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

/******************************
** File: Buildscript_1.00.049.sql
** Name: Buildscript_1.00.049
** Auth: McNiel Viray
** Date: 03 August 2017
**************************
** Change History
**************************
** Create [dbo].[wfmpcp_GetSiteMonthlyHiringPlan_sp]
** Create [dbo].[wfmpcp_GetCampaignMonthlyHiringPlan_sp]
** Modify following sp [dbo].[wfmpcp_GetHiringRequirements_sp],[dbo].[wfmpcp_GetHiringRequirementsTotal_sp],[dbo].[wfmpcp_GetSummary1_sp]
*******************************/
USE WFMPCP
GO

PRINT N'[dbo].[wfmpcp_GetCampaignMonthlyHiringPlan_sp]'
GO

CREATE PROCEDURE [dbo].[wfmpcp_GetCampaignMonthlyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT CampaignID
					,UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) [Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name
	'
	EXECUTE( @select )
END

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
							FROM WeeklyHiringDatapoint
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
							FROM WeeklyHiringDatapoint
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
							FROM WeeklyHiringDatapoint
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
							FROM WeeklyHiringDatapoint
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
PRINT N'Altering [dbo].[wfmpcp_GetSummary1_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetSummary1_sp]
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
							FROM WeeklySummaryDatapoint
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
							FROM WeeklySummaryDatapoint
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
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklySummaryDatapoint
					 ) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN SummaryDatapoint d ON d.ID=A.DatapointID
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
						SELECT SiteID,CampaignID,LobID,datapointid,[Date],[Data] from WeeklySummaryDatapoint
					) x		
					PIVOT
					(
						MAX(Data)
						FOR [Date] IN ('+ @cols +')
					)p
				) A
				INNER JOIN SummaryDatapoint d ON d.ID=A.DatapointID
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
PRINT N'Creating [dbo].[wfmpcp_GetSiteMonthlyHiringPlan_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetSiteMonthlyHiringPlan_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @startdate AND @enddate) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT SiteID
					,UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) [Date]
					,CAST([Data] AS bigint) [Data]
				FROM WeeklyHiringDatapoint
				WHERE 1=1 
					AND ([Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
	'
	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO

/******************************
** File: Buildscript_1.00.050.sql
** Name: Buildscript_1.00.050
** Auth: McNiel Viray
** Date: 04 August 2017
**************************
** Change History
**************************
** Create Hiring Outlook Moduels
*******************************/
USE WFMPCP
GO
DECLARE @ModuleID BIGINT
	,@ParentID BIGINT

SELECT @ParentID = ID FROM Module WHERE Name='Hiring Outlook' AND ParentID=0 AND Active=1 


--************************
--CAMPAIGN WEEKLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Campaign - Weekly Summary','fa-tag','/HiringOutlook/CampaignWeeklySummary',4,'McNiel Viray')

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


--************************
--CAMPAIGN MONTHLY SUMMARY
INSERT INTO Module(ParentID,[Name],FontAwesome,[Route],SortOrder,CreatedBy)
VALUES(@ParentID,'Campaign - Monhtly Summary','fa-tag','/HiringOutlook/CampaignMonthlySummary',5,'McNiel Viray')

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