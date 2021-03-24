/******************************
** File: Buildscript_1.00.095.sql
** Name: Buildscript_1.00.095
** Auth: McNiel N Viray
** Date: 30 August 2018
**************************
** Change History
**************************
** Create New table [dbo].[CSVRawData]
** Create new procedure(s)
**     wfmpcp_CreateCSVRawData_sp,wfmpcp_ActivateDeactiviateCSV_sp,wfmpcp_GetCSVRawData
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[CSVRawData]...';


GO
CREATE TABLE [dbo].[CSVRawData] (
    [ID]           UNIQUEIDENTIFIER NOT NULL,
    [SiteID]       BIGINT           NULL,
    [CampaignID]   BIGINT           NULL,
    [LoBID]        BIGINT           NULL,
    [Filename]     NVARCHAR (15)    NULL,
    [RowNumber]    BIGINT           NULL,
    [ColumnNumber] BIGINT           NULL,
    [Data]         NVARCHAR (150)   NOT NULL,
    [CreatedBy]    NVARCHAR (150)   NULL,
    [DateCreated]  DATETIME         NOT NULL,
    [Active]       BIT              NOT NULL,
    CONSTRAINT [pk_CSVRawData_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating unnamed constraint on [dbo].[CSVRawData]...';


GO
ALTER TABLE [dbo].[CSVRawData]
    ADD DEFAULT NEWID() FOR [ID];


GO
PRINT N'Creating unnamed constraint on [dbo].[CSVRawData]...';


GO
ALTER TABLE [dbo].[CSVRawData]
    ADD DEFAULT ('0') FOR [Data];


GO
PRINT N'Creating unnamed constraint on [dbo].[CSVRawData]...';


GO
ALTER TABLE [dbo].[CSVRawData]
    ADD DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating unnamed constraint on [dbo].[CSVRawData]...';


GO
ALTER TABLE [dbo].[CSVRawData]
    ADD DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[wfmpcp_ActivateDeactiviateCSV_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_ActivateDeactiviateCSV_sp]
	@Active BIT=NULL,
	@SiteID BIGINT=NULL,
	@CampaignID BIGINT=NULL,
	@LoBID BIGINT=NULL
AS
BEGIN
	UPDATE CSVRawData
	SET Active=ISNULL(@Active,Active)
	WHERE ((SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((CampaignID=@CampaignID) OR (@CampaignID IS NULL))
		AND ((LoBID=@LoBID) OR (@LoBID IS NULL))
END
GO
PRINT N'Creating [dbo].[wfmpcp_CreateCSVRawData_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateCSVRawData_sp]
	@Data NVARCHAR(200),
	@CreatedBy NVARCHAR(150),
	@RowNumber BIGINT,
	@ColumnNumber BIGINT,
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LoBID BIGINT,
	@Filename NVARCHAR(150)
AS
BEGIN
	INSERT INTO CSVRawData(Data,CreatedBy,RowNumber,ColumnNumber,SiteID,CampaignID,LoBID,[Filename])
	VALUES(@Data,@CreatedBy,@RowNumber,@ColumnNumber,@SiteID,@CampaignID,@LoBID,@Filename)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetCSVRawData_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetCSVRawData_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
	,@Active BIT = NULL
AS
BEGIN
	SELECT 
	--ID,
	s.SiteID
	,s.CampaignID
	,s.LoBID
	,DatapointID=(s.RowNumber-1)
	,[Week]=(SELECT WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1))
	,[Data]=s.Data
	,[Date]=CAST((SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1) AS DATE)
	,s.CreatedBy
    ,s.DateCreated
	FROM CSVRawData s
	WHERE s.RowNumber <= 143--LastRow
		AND s.RowNumber > 1--Exclude Header
		AND s.ColumnNumber > 2--Exclude Segment
		AND ((s.SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((s.CampaignID=@CampaignID) OR (@CampaignID IS NULL))
        AND ((s.LoBID=@LoBID) OR (@LoBID IS NULL)) 
		AND ((Active=@Active) OR (@Active IS NULL))
	ORDER BY RowNumber,[Date]
END
GO

PRINT N'Creating [dbo].[wfmpcp_DeleteStagingAHWeeklyDatapoint_sp]...';

GO
CREATE PROCEDURE [dbo].[wfmpcp_DeleteStagingAHWeeklyDatapoint_sp]
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT
AS
BEGIN
	DELETE FROM StagingWeeklyAHDatapoint WHERE SiteID=@SiteID AND CampaignID=@CampaignID AND LoBID=@LobID
END
GO

CREATE PROCEDURE [dbo].[wfmpcp_CreateStagingWeeklyAHDatapoint_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
	,@Active BIT = NULL
AS
BEGIN
	INSERT INTO StagingWeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
	SELECT 
		s.SiteID
		,s.CampaignID
		,s.LoBID
		,DatapointID=(s.RowNumber-1)
		,[Week]=(SELECT WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1))
		,[Data]=s.Data
		,[Date]=CAST((SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1) AS DATE)
		,s.CreatedBy
		,s.DateCreated
	FROM CSVRawData s
	WHERE s.RowNumber <= 143--LastRow
		AND s.RowNumber > 1--Exclude Header
		AND s.ColumnNumber > 2--Exclude Segment
		AND ((s.SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((s.CampaignID=@CampaignID) OR (@CampaignID IS NULL))
		AND ((s.LoBID=@LoBID) OR (@LoBID IS NULL)) 
		AND ((Active=@Active) OR (@Active IS NULL))
	ORDER BY RowNumber,[Date]
END

GO
CREATE PROCEDURE [dbo].[wfmpcp_GetAllStagingAHDatapoint_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
AS
BEGIN
	SELECT 
		ID	
		,SiteID
		,CampaignID
		,LoBID
		,DatapointID
		,[Week]
		,[Data]
		,[Date]
		,CreatedBy
		,DateCreated
	FROM StagingWeeklyAHDatapoint
	WHERE SiteID=@SiteID AND CampaignID=@CampaignID AND LoBID=@LoBID
END

GO
PRINT N'Update complete.';


GO
