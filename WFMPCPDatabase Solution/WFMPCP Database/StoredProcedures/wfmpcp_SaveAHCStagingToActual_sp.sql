CREATE PROCEDURE [dbo].[wfmpcp_SaveAHCStagingToActual_sp]
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT
AS
BEGIN
	DECLARE @tableParam AS WeeklyDatapointTableType

	INSERT INTO @tableParam(datapointid,siteid,campaignid,lobid,[date],datavalue,username,datemodified)
	SELECT datapointid
	,siteid
	,campaignid
	,lobid
	,[date]
	,CASE WHEN [data]='-' THEN '0'  ELSE [data] END
	,CreatedBy
	,DateCreated
	FROM StagingWeeklyAHDatapoint
	WHERE siteid=@SiteID and CampaignID=@CampaignID and lobid=@LobID

	EXEC [wfmpcp_SaveWeeklyAHDatapointDatatable_sp] @tableParam
END







