/******************************
** File: Buildscript_1.00.029.sql
** Name: Buildscript_1.00.029
** Auth: McNiel Viray
** Date: 07 July 2017
**************************
** Change History
**************************
** Create data for [dbo].[HiringDatapoint]
** Create data for [dbo].[WeeklyHiringDatapoint]
*******************************/
USE WFMPCP
GO

PRINT N'Creating Hiring datapoint data...'
GO
INSERT INTO HiringDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('New Capacity','Reference',1,'McNiel Viray',GETDATE())
GO
INSERT INTO HiringDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Attrition Backfill','Reference',2,'McNiel Viray',GETDATE())
GO

PRINT N'Creating WeeklyHiringDatapoint data...'
GO

		--INSERT Using cursor
		DECLARE @ID INT
			,@WeekStartDatetime SMALLDATETIME
			,@WeekOfYear SMALLINT
			,@CampaignID BIGINT 
			,@LobID BIGINT

		DECLARE week_cursor CURSOR FOR
		SELECT ID, WeekStartdate, WeekOfYear FROM [Week] 
		ORDER BY WeekStartdate

		OPEN week_cursor

		FETCH FROM week_cursor
		INTO @ID,@WeekStartDatetime,@WeekOfYear

		WHILE @@FETCH_STATUS=0
		BEGIN
				--lob cursor
				DECLARE lob_cursor CURSOR FOR
				SELECT ID,CampaignID FROM LoB
				ORDER BY ID

				OPEN lob_cursor
				FETCH FROM lob_cursor
				INTO @LobID,@CampaignID

				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT
						INSERT INTO WeeklyHiringDatapoint(CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
						SELECT 
							@CampaignID
							,@LoBID
							,d.ID
							,@WeekOfYear
							,'0'--data
							,CAST(@WeekStartDatetime AS DATE)
							,'McNiel Viray'
							,GETDATE()		
						FROM HiringDatapoint d
						--END INSERT

					FETCH NEXT FROM lob_cursor
					INTO @LobID,@CampaignID
				END	
				CLOSE lob_cursor;
				DEALLOCATE lob_cursor;
				--end lob cursor
			FETCH NEXT FROM week_cursor
			INTO @ID,@WeekStartDatetime,@WeekOfYear
		END
		CLOSE week_cursor;
		DEALLOCATE week_cursor;
GO

PRINT N'Done Creating initial data...'
GO
