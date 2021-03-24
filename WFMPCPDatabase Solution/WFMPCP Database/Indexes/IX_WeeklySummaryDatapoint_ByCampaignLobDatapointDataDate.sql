CREATE INDEX [IX_WeeklySummaryDatapoint_ByCampaignLobDatapointDataDate]
ON [dbo].[WeeklySummaryDatapoint] ([SiteID],[CampaignID],[LoBID],[DatapointID],[Date])
INCLUDE ([Data])
