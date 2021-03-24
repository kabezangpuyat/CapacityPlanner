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