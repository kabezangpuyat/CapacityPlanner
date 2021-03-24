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
		,[Week]=(SELECT TOP 1 WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT TOP 1 Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1))
		,[Data]=s.Data
		,[Date]=CAST((SELECT TOP 1 Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1) AS DATE)
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
