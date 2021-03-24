--DROP TABLE CSVRawData
--CREATE TABLE CSVRawData
--(
--ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() CONSTRAINT [pk_CSVRawData_ID] PRIMARY KEY([ID]),
--SiteID BIGINT,
--CampaignID BIGINT,
--LoBID BIGINT,
--[Filename] NVARCHAR(15),
--RowNumber BIGINT,
--ColumnNumber BIGINT,
--Data NVARCHAR(150) NULL,
--CreatedBy NVARCHAR(150),
--DateCreated DATETIME NOT NULL  DEFAULT GETDATE(),
--Active BIT NOT NULL DEFAULT(1)
--);



--CREATE PROCEDURE [dbo].[wfmpcp_CreateCSVRawData_sp]
--	@Data NVARCHAR(200),
--	@CreatedBy NVARCHAR(150),
--	@RowNumber BIGINT,
--	@ColumnNumber BIGINT,
--	@SiteID BIGINT,
--	@CampaignID BIGINT,
--	@LoBID BIGINT,
--	@Filename NVARCHAR(150)
--AS
--BEGIN
--	INSERT INTO CSVRawData(Data,CreatedBy,RowNumber,ColumnNumber,SiteID,CampaignID,LoBID,[Filename])
--	VALUES(@Data,@CreatedBy,@RowNumber,@ColumnNumber,@SiteID,@CampaignID,@LoBID,@Filename)
--END
--GO

--CREATE PROCEDURE [dbo].[wfmpcp_ActivateDeactiviateCSV_sp]
--	@Active BIT=NULL,
--	@SiteID BIGINT=NULL,
--	@CampaignID BIGINT=NULL,
--	@LoBID BIGINT=NULL
--AS
--BEGIN
--	UPDATE CSVRawData
--	SET Active=ISNULL(@Active,Active)
--	WHERE ((SiteID=@SiteID) OR (@SiteID IS NULL))
--		AND ((CampaignID=@CampaignID) OR (@CampaignID IS NULL))
--		AND ((LoBID=@LoBID) OR (@LoBID IS NULL))

--END
--GO

CREATE PROCEDURE [dbo].[wfmpcp_GetCSVRawData]
	@SiteID BIGINT=2
	,@CampaignID BIGINT=41
	,@LoBID BIGINT=135
	,@Active BIT = NULL
AS
BEGIN
	SELECT 
	ID,
	s.SiteID
	,s.CampaignID
	,s.LoBID
	,DatapointID=(s.RowNumber-1)
	,[Week]=(SELECT WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber))
	,Data=s.Data
	,[Date]=CAST((SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber) AS DATE)
	,s.CreatedBy
	FROM CSVRawData s
	WHERE s.RowNumber <= 143--LastRow
		AND s.RowNumber > 1--Exclude Header
		AND s.ColumnNumber > 2--Exclude Segment
		AND s.SiteID=@SiteID AND s.CampaignID=@CampaignID AND s.LoBID=@LoBID  
		AND ((Active=@Active) OR (@Active IS NULL))
	ORDER BY RowNumber,[Date]
END

DECLARE @SiteID BIGINT=2
	,@CampaignID BIGINT=41
	,@LoBID BIGINT=135
	
SELECT 
ID,
s.SiteID
,s.CampaignID
,s.LoBID
,DatapointID=(s.RowNumber-1)
,[Week]=(SELECT WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber))
,Data=s.Data
,[Date]=CAST((SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber) AS DATE)
,s.CreatedBy
FROM CSVRawData s
WHERE s.RowNumber <= 143--LastRow
	AND s.RowNumber > 1--Exclude Header
	AND s.ColumnNumber > 2--Exclude Segment
	AND s.SiteID=@SiteID AND s.CampaignID=@CampaignID AND s.LoBID=@LoBID  
ORDER BY RowNumber,[Date]

--rownumber  <= 143
--truncate table CSVRawData
