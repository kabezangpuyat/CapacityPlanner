/******************************
** File: Buildscript_1.00.033.sql
** Name: Buildscript_1.00.033
** Auth: McNiel Viray
** Date: 11 July 2017
**************************
** Change History
**************************
** Create SiteCampaignLoB data...
*******************************/
USE WFMPCP
GO

DECLARE @tbl AS TABLE
(
SiteName NVARCHAR(150),
SiteID BIGINT,
CampaignName NVARCHAR(150),
CampaignID BIGINT NULL,
LobID BIGINT,
LobName NVARCHAR(150),
LobDesc NVARCHAR(300)
)

INSERT INTO @tbl(SiteName,SiteID,CampaignName,LobID,LobName,LobDesc)
SELECT
s.Name 
,s.ID
,c.Name 
,l.ID 
,l.Name 
,l.[Description] 
FROM LoB l
INNER JOIN Campaign c ON c.ID=l.CampaignID
INNER JOIN [Site] s ON s.ID=c.SiteID
ORDER BY l.Name

UPDATE t
SET t.CampaignID=c.ID
FROM @tbl t
INNER JOIN Campaign c ON c.Name=t.CampaignName
WHERE c.Active=1

--CREATE SiteCampaignLob (NON-Redundant Lob)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
SELECT SiteID,CampaignID,LobID
FROM @tbl
WHERE LobName IN
(
	SELECT  
		l.Name
	FROM Lob l
	GROUP BY l.Name
	HAVING COUNT(l.Name)=1
)

--CREATE SiteCampaignLob (Redundant - COUNT=2)
--HUDL Basketball - Full Time
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,21,50)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,21,50)
UPDATE LoB SET Active=0 WHERE ID=60
--ADORME Chat
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(1,2,32)
--TILE Chat
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,6,42)
--WISH Content Moderation
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(5,24,63)
--MERCARI Content Moderation
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,15,57)
--HUDL Football - Full Time
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,21,48)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,21,48)
UPDATE LoB SET Active=0 WHERE ID=58
--HUDL Football - Part Time
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,21,49)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,21,49)
UPDATE LoB SET Active=0 WHERE ID=59
--POSTMATES Full Time
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,23,43)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,23,43)
UPDATE LoB SET Active=0 WHERE ID=54
--MEDIAMAX
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,22,52)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,22,52)
UPDATE LoB SET Active=0 WHERE ID=53
--POSTMATES
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,23,44)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(4,23,44)
UPDATE LoB SET Active=0 WHERE ID=55
--Adorme Phone
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(1,2,30)
--Nimble Phone
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,4,36)
--Box Sales
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,5,40)
--Sparefood Sales
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(5,19,68)
--ADORME Email
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(1,2,31)
--NIMBLE EMail
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,4,37)
--TILE Email
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(2,6,41)
--WISH EMAIL
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(3,24,51)
INSERT INTO SiteCampaignLoB(SiteID,CampaignID,LobID)
VALUES(5,24,51)
UPDATE LoB SET Active=0 WHERE ID=61
GO
