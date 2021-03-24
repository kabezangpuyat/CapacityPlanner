CREATE INDEX [IX_WeeklyHiringDatapoint_ByCampaignLobDatapointDataDate]
ON [dbo].[WeeklyHiringDatapoint] ([SiteID],[CampaignID],[LoBID],[DatapointID],[Date])
INCLUDE ([Data])
