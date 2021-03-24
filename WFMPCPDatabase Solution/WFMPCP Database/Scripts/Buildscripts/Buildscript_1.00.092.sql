/******************************
** File: Buildscript_1.00.092.sql
** Name: Buildscript_1.00.092
** Auth: McNiel Viray	
** Date: 24 July 2018
**************************
** Change History
**************************
** Add data to WeeklyAHDatapoint
*******************************/
USE WFMPCP
GO

--*************
-- Create weekly AH Datapoint
--*************
DECLARE @ID INT
,@WeekStartDatetime SMALLDATETIME
,@WeekOfYear SMALLINT

DECLARE week_cursor CURSOR FOR
SELECT ID, WeekStartdate, WeekOfYear FROM [Week]

OPEN week_cursor

FETCH FROM week_cursor
INTO @ID,@WeekStartDatetime,@WeekOfYear

WHILE @@FETCH_STATUS=0
BEGIN
	--loop SiteCampaignLoB
		DECLARE @SiteID INT 
			,@CampaignID INT
			,@LoBID INT

		DECLARE scl_cursor CURSOR FOR
		SELECT 
		scl.SiteID
		,scl.CampaignID
		,scl.LobID
		FROM sitecampaignlob scl
		INNER JOIN site s on s.id=scl.SiteID
		INNER JOIN Campaign c on c.ID=scl.CampaignID
		INNER JOIN lob l on l.id=scl.LobID
		WHERE scl.Active=1 --and s.active=1 and c.active=1 and l.active=1
		AND l.Active=1
		ORDER BY s.Name,c.Name,l.name

		OPEN scl_cursor
		FETCH FROM scl_cursor
		INTO @SiteID,@CampaignID,@LoBID
		WHILE @@FETCH_STATUS=0
		BEGIN
		--**************************************
			INSERT INTO WeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],Data,[Date],CreatedBy,DateCreated)
			SELECT 
			@SiteID
			,@CampaignID
			,@LoBID
			,d.ID
			,@WeekOfYear
			,'0'--data
			,CAST(@WeekStartDatetime AS DATE)
			,'McNiel Viray'
			,GETDATE()		
			FROM Datapoint d
			INNER JOIN Segment s ON s.ID=d.SegmentID
			INNER JOIN SegmentCategory sc ON sc.ID=s.SegmentCategoryID
			WHERE d.ID > 118
			ORDER BY sc.SortOrder,s.SortOrder,d.SortOrder
		--**************************************
		FETCH NEXT FROM scl_cursor
		INTO @SiteID,@CampaignID,@LoBID
		END
		CLOSE scl_cursor;
		DEALLOCATE scl_cursor;


	FETCH NEXT FROM week_cursor
	INTO @ID,@WeekStartDatetime,@WeekOfYear
END
CLOSE week_cursor;
DEALLOCATE week_cursor;
GO