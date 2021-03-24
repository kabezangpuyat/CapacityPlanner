/******************************
** File: Buildscript_1.00.021.sql
** Name: Buildscript_1.00.021
** Auth: McNiel Viray
** Date: 20 June 2017
**************************
** Change History
**************************
** Create Table [dbo].[StaffSegment]
** Create Table [dbo].[StaffDatapoint]
** Create Table [dbo].[WeeklyStaffDatapoint]
*******************************/
USE WFMPCP
GO

PRINT N'Creating [dbo].[StaffDatapoint]...';


GO
CREATE TABLE [dbo].[StaffDatapoint] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentID]    BIGINT         NOT NULL,
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
    CONSTRAINT [PK_StaffDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[StaffSegment]...';


GO
CREATE TABLE [dbo].[StaffSegment] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [SegmentCategoryID] INT            NULL,
    [Name]              NVARCHAR (200) NOT NULL,
    [SortOrder]         INT            NOT NULL,
    [CreatedBy]         NVARCHAR (250) NULL,
    [ModifiedBy]        NVARCHAR (250) NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [DateModified]      DATETIME       NULL,
    [Active]            BIT            NOT NULL,
    [Visible]           BIT            NOT NULL,
    CONSTRAINT [PK_StaffSegment_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[WeeklyStaffDatapoint]...';


GO
CREATE TABLE [dbo].[WeeklyStaffDatapoint] (
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
    CONSTRAINT [PK_WeeklyStaffDatapoint_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating [dbo].[DF_StaffDatapoint_ReferenceID]...';


GO
ALTER TABLE [dbo].[StaffDatapoint]
    ADD CONSTRAINT [DF_StaffDatapoint_ReferenceID] DEFAULT (0) FOR [ReferenceID];


GO
PRINT N'Creating [dbo].[DF_StaffDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[StaffDatapoint]
    ADD CONSTRAINT [DF_StaffDatapoint_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_StaffDatapoint_Active]...';


GO
ALTER TABLE [dbo].[StaffDatapoint]
    ADD CONSTRAINT [DF_StaffDatapoint_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_StaffDatapoint_Visible]...';


GO
ALTER TABLE [dbo].[StaffDatapoint]
    ADD CONSTRAINT [DF_StaffDatapoint_Visible] DEFAULT (1) FOR [Visible];


GO
PRINT N'Creating [dbo].[DF_StaffSegment_DateCreated]...';


GO
ALTER TABLE [dbo].[StaffSegment]
    ADD CONSTRAINT [DF_StaffSegment_DateCreated] DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating [dbo].[DF_StaffSegment_Active]...';


GO
ALTER TABLE [dbo].[StaffSegment]
    ADD CONSTRAINT [DF_StaffSegment_Active] DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[DF_StaffSegment_Visible]...';


GO
ALTER TABLE [dbo].[StaffSegment]
    ADD CONSTRAINT [DF_StaffSegment_Visible] DEFAULT (1) FOR [Visible];


GO
PRINT N'Creating [dbo].[DF_WeeklyStaffDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyStaffDatapoint]
    ADD CONSTRAINT [DF_WeeklyStaffDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Creating [dbo].[DF_WeeklyStaffDatapoint_DateCreated]...';


GO
ALTER TABLE [dbo].[WeeklyStaffDatapoint]
    ADD CONSTRAINT [DF_WeeklyStaffDatapoint_DateCreated] DEFAULT (getdate()) FOR [DateCreated];


GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.022.sql
** Name: Buildscript_1.00.022
** Auth: McNiel Viray
** Date: 21 June 2017
**************************
** Change History
**************************
** Create data for [dbo].[StaffSegment]
** Create data for [dbo].[StaffDatapoint]
*******************************/
USE WFMPCP
GO

DECLARE @SegmentID BIGINT=NULL
,@DatapoinID BIGINT=NULL

INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('Headcount',1,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Required Headcount','Formula',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Current Headcount','Reference',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Excess/Deficits','Formula',3,'McNiel Viray',1,1)


INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('FTE',2,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Required FTE','Formula',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Planned FTE','Formula',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Teleopti Required FTE','Not Used',3,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Excess/Deficits','Formula',4,'McNiel Viray',1,1)


INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('HOURS',3,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Base Hours (Workload)','Formula',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Net Required Hours','Formula',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Planned Production Hrs','Formula',3,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Production Prod Hrs','Formula',4,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'SME Prod Hrs','Formula',5,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Nesting Prod Hrs','Formula',6,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Planned Training Hours','Formula',7,'McNiel Viray',1,1)



INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('VOLUME',4,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Required FTE','Reference',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Projected Capacity','Formula',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Capacity to Forecast %','Formula',3,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Actual to Forecast %','Formula',4,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Answered to Forecast %','Formula',5,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Answered to Capacity %','Formula',6,'McNiel Viray',1,1)


INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('Billable Headcount',5,'McNiel Viray',1,1)
SELECT @SegmentID = SCOPE_IDENTITY()
	--create staff datapoint
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Billable Headcount','Formula',1,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Current Headcount','Formula',2,'McNiel Viray',1,1)
	INSERT INTO StaffDatapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
	VALUES(@SegmentID,'Billable Excess/Deficits','Formula',3,'McNiel Viray',1,1)

GO
/******************************
** File: Buildscript_1.00.023.sql
** Name: Buildscript_1.00.023
** Auth: McNiel Viray
** Date: 23 June 2017
**************************
** Change History
**************************
* Create initial data to WeeklyStaffDatapoint
*******************************/
USE WFMPCP
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
GO
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
/******************************
** File: Buildscript_1.00.026.sql
** Name: Buildscript_1.00.026
** Auth: McNiel Viray
** Date: 04 July 2017
**************************
** Change History
**************************
** Modify sp [dbo].[wfmpcp_GetStaffPlanner_sp] and [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
*******************************/
USE WFMPCP
GO

PRINT N'Altering [dbo].[wfmpcp_GetStaffPlanner_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetStaffPlanner_sp]
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
	FROM WeeklyStaffDatapoint 
	WHERE Lobid=CAST(@lobid AS BIGINT)
		AND [Date] BETWEEN CAST(@start AS DATE) AND CAST(@end AS DATE)

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
						SELECT LobID,datapointid,[Date],[Data] from WeeklyStaffDatapoint
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
						SELECT LobID,datapointid,[Date],[Data] from WeeklyStaffDatapoint
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
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.BaseHours,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(10)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(10)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(10)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(10)) + ' %'
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(10))
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(10))
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
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.027.sql
** Name: Buildscript_1.00.027
** Auth: McNiel Viray
** Date: 06 July 2017
**************************
** Change History
**************************
** Modify sp [dbo].[wfmpcp_GetStaffPlanner_sp] and [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]

*******************************/
USE WFMPCP
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
						SELECT LobID,datapointid,[Date],Data from ' + @tablename + 
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
						SELECT LobID,datapointid,[Date],Data from ' + @tablename + 
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

	SET @orderBy = ' ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder'
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
						SELECT LobID,datapointid,[Date],[Data] from WeeklyStaffDatapoint
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
						SELECT LobID,datapointid,[Date],[Data] from WeeklyStaffDatapoint
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
PRINT N'Update complete.';


GO
