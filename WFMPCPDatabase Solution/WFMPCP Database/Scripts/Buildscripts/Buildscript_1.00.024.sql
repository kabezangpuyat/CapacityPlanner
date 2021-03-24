/******************************
** File: Buildscript_1.00.024.sql
** Name: Buildscript_1.00.024
** Auth: McNiel Viray
** Date: 29 June 2017
**************************
** Change History
**************************
* Create index to WeeklyAHDatapoint 
* Create scalar udf for WeeklyStaffDatapoint computation
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[WeeklyAHDatapoint].[IX_WeeklyAHDatapoint_ByLobDatapointDataDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_WeeklyAHDatapoint_ByLobDatapointDataDate]
    ON [dbo].[WeeklyAHDatapoint]([LoBID] ASC, [DatapointID] ASC, [Date] ASC)
    INCLUDE([Data]);


GO
PRINT N'Creating [dbo].[wfmpcp_GetAHCDatapointValue_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetAHCDatapointValue_udf]
(
	@LobID BIGINT,
	@Date DATE,
	@DatapointID BIGINT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)

	SELECT @Value=CAST([Data] AS DECIMAL(10,2))
	FROM WeeklyAHDatapoint 
	WHERE LoBID=@LobID AND [Date]=@Date  AND DatapointID=@DatapointID

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetAnsweredToForecastPerc_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetAnsweredToForecastPerc_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--(ahc8-ahc6)/ahc6
	SELECT @Value=([dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,8)-[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,6))/NULLIF([dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,6),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetBillableHC_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetBillableHC_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--ahc67/(1-ahc23)
	SELECT @Value=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,67)/NULLIF((1-[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,23)),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetNetReqHours_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetNetReqHours_udf]
(
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

		SELECT @basehours=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,56)
		
		SELECT @ah54=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,54)

		SELECT @ah17=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,17)
		
		SELECT @Value=(@BaseHours/NULLIF(@ah54,0))/NULLIF((1-@ah17),0)
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetProdProdHrs_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetProdProdHrs_udf]
(
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
	
	SELECT @a=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,13) * 40
	SELECT @b=1-[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,23)
	SELECT @c=1-[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,18)
	SELECT @d=1-[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,31)

	SELECT @Value=@a*@b*@c*@d
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetRequiredFTE_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetRequiredFTE_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@baseHours DECIMAL(10,2)

	SELECT @baseHours=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,56)
	SELECT @Value=@baseHours/40
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetRequiredHC_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetRequiredHC_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@ahc61 DECIMAL(10,2)
		,@netReqHours DECIMAL(10,2)

		SELECT @netReqHours=[dbo].[wfmpcp_GetNetReqHours_udf](@LobID,@Date)
		
		SELECT @ahc61=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,61)
				
		SELECT @Value=(@netReqHours/40)*@ahc61
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetSMEProdHrs_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetSMEProdHrs_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)

	SELECT @Value=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,58) * 20
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_NestingProdHrs_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_NestingProdHrs_udf]
(
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
	
	SELECT @ah71=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,71) * 40 
	SELECT @ah26=1-[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,26)
	SELECT @ah54=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,54)

	SELECT @Value=@ah71*@ah26*@ah54

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetActualToForecastPerc_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetActualToForecastPerc_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--(ahc7-ahc6)/ahc6
	SELECT @Value=([dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,7)-[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,6))/NULLIF([dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,6),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetBillableExcessDeficit_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetBillableExcessDeficit_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	-- @CurrentBillableHC-@BillableHC	
	SELECT @Value=[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,66)-[dbo].[wfmpcp_GetBillableHC_udf](@LobID,@Date)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetExcessDeficitHC_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetExcessDeficitHC_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@currentHC DECIMAL(10,2)
		,@requiredHC DECIMAL(10,2)

		SELECT @requiredHC = [dbo].[wfmpcp_GetRequiredHC_udf](@LobID,@Date)
		SELECT @currentHC = [dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,69)
		SELECT @Value=@currentHC-@requiredHC
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetPlannedProdHrs_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetPlannedProdHrs_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	

	SELECT @Value=[dbo].[wfmpcp_GetProdProdHrs_udf](@LobID,@Date)+[dbo].[wfmpcp_GetSMEProdHrs_udf](@LobID,@Date)
		+[dbo].[wfmpcp_NestingProdHrs_udf](@LobID,@Date)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetProjectedCapacity_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetProjectedCapacity_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--(@ProdProdHrs*3600/ahc5)+(@SMEProdHrs*3600/ahc5)
	SELECT @Value=([dbo].[wfmpcp_GetProdProdHrs_udf](@LobID,@Date)*3600/NULLIF([dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,5),0))
				+([dbo].[wfmpcp_GetSMEProdHrs_udf](@LobID,@Date)*3600/NULLIF([dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,5),0))
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetAnsweredToCapacityPerc_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetAnsweredToCapacityPerc_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	--(ahc8-@ProjectedCapacity)/@ProjectedCapacity
	SELECT @Value=([dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,8)-[dbo].[wfmpcp_GetProjectedCapacity_udf](@LobID,@Date))/NULLIF([dbo].[wfmpcp_GetProjectedCapacity_udf](@LobID,@Date),0)
	
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetCapacityToForecastPerc_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetCapacityToForecastPerc_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	
	-- (@ProjectedCapacity-ahc6)/ahc6	
	SELECT @Value= ([dbo].[wfmpcp_GetProjectedCapacity_udf](@LobID,@Date)-[dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,6))/NULLIF([dbo].[wfmpcp_GetAHCDatapointValue_udf](@LobID,@Date,6),0)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetPlannedFTE_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetPlannedFTE_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	

	SELECT @Value=[dbo].[wfmpcp_GetPlannedProdHrs_udf](@LobID,@Date)*40

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetExcessDeficitFTE_udf]...';


GO
CREATE FUNCTION [dbo].[wfmpcp_GetExcessDeficitFTE_udf]
(
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	

	SELECT @Value=[dbo].[wfmpcp_GetPlannedFTE_udf](@LobID,@Date)-[dbo].[wfmpcp_GetRequiredFTE_udf](@LobID,@Date)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklyAHDatapoint_sp]
AS
BEGIN

	DECLARE @ID INT
	,@WeekStartDatetime SMALLDATETIME
	,@WeekOfYear SMALLINT
	,@CampaignID BIGINT
	,@LoBID BIGINT

	DECLARE week_cursor CURSOR FOR
	SELECT ID, WeekStartdate, WeekOfYear FROM [Week]

	OPEN week_cursor

	FETCH FROM week_cursor
	INTO @ID,@WeekStartDatetime,@WeekOfYear

	WHILE @@FETCH_STATUS=0
	BEGIN

			DECLARE lob_cursor CURSOR FOR
			SELECT ID, CampaignID FROM LoB

			OPEN lob_cursor
	
			FETCH FROM lob_cursor
			INTO @LoBID,@CampaignID

			WHILE @@FETCH_STATUS=0
			BEGIN
				INSERT INTO WeeklyAHDatapoint(CampaignID,LoBID,DatapointID,[Week],Data,[Date],CreatedBy,DateCreated)
				SELECT 
					@CampaignID
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
				INTO @LoBID,@CampaignID
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
PRINT N'Creating [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateWeeklyStaffDatapoint_sp]
AS
BEGIN
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
END
GO
PRINT N'Update complete.';


GO
