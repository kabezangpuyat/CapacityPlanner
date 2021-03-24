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