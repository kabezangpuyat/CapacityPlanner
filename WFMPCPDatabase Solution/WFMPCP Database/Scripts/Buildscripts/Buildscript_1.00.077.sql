/******************************
** File: Buildscript_1.00.077.sql
** Name: Buildscript_1.00.077
** Auth: McNiel Viray
** Date: 17 November 2017
**************************
** Change History
**************************
** Add new Segment and Datapoint for Average Speed of Answer
** Create data for ASA
*******************************/
USE WFMPCP
GO


DECLARE @SegmentID BIGINT

INSERT INTO Segment(SegmentCategoryID,[Name],SortOrder,CreatedBy,Active,Visible)
VALUES(2,'ASA',7,'McNiel Viray',1,1)

SELECT @SegmentID = SCOPE_IDENTITY()

INSERT INTO Datapoint(SegmentID,[Name],Datatype,SortOrder,CreatedBy,Active,Visible)
VALUES(@SegmentID,'Average Speed of Answer','Inputted',1,'McNiel Viray',1,1)

GO
INSERT INTO WeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
SELECT  
SiteID
,CampaignID
,LoBID
,118 DatapointID
,[Week]
,'0' [Data]
,[Date]
,CreatedBy
,GETDATE() DateCreated
FROM WeeklyAHDatapoint
WHERE DatapointID=117
GO