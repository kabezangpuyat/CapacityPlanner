/******************************
** File: Buildscript_1.00.046.sql
** Name: Buildscript_1.00.046
** Auth: McNiel Viray
** Date: 31 July 2017
**************************
** Change History
**************************
** Create index IX_WeeklySummaryDatapoint_ByCampaignLobDatapointDataDate
*******************************/
USE WFMPCP
GO
CREATE INDEX [IX_WeeklySummaryDatapoint_ByCampaignLobDatapointDataDate]
ON [dbo].[WeeklySummaryDatapoint] ([SiteID],[CampaignID],[LoBID],[DatapointID],[Date])
INCLUDE ([Data])
GO
