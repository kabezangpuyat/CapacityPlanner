CREATE INDEX [IX_WeeklyStaffDatapoint_ByLobDatapointDataDate]
ON [dbo].[WeeklyStaffDatapoint] ([SiteID],[CampaignID],[LoBID],[DatapointID],[Date])
INCLUDE ([Data])
