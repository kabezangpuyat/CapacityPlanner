CREATE INDEX [IX_WeeklyAHDatapoint_ByLobDatapointDataDate]
ON [dbo].[WeeklyAHDatapoint] ([SiteID],[CampaignID],[LoBID],[DatapointID],[Date])
INCLUDE ([Data])
