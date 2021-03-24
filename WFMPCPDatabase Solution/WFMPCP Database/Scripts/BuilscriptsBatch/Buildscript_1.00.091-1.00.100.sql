/******************************
** File: Buildscript_1.00.091.sql
** Name: Buildscript_1.00.091
** Auth: McNiel Viray
** Date: 24 July 2018
**************************
** Change History
**************************
** Add new StaffDatapoint
** Update name of StaffDatapoint
*******************************/
USE WFMPCP
GO

UPDATE StaffDatapoint
SET [Name]='Gross Required FTE'
WHERE ID=1-- old: Required Headcount
GO

UPDATE StaffDatapoint
SET [Name]='Current  Gross FTE'
WHERE ID=2-- old: Current Headcount
GO

UPDATE StaffDatapoint
SET [Name]='Required Net FTE'
WHERE ID=4 -- old: Required FTE
GO

UPDATE StaffDatapoint
SET [Name]='Planned Net FTE'
WHERE ID=5 -- old: Planned FTE
GO

UPDATE StaffDatapoint
SET [Name]='Gross Required Hours'
WHERE ID=9 -- old: Net Required Hours
GO

UPDATE StaffDatapoint
SET [Name]='Production Prod Hrs'
WHERE ID=11 -- old: Production Prod Hrs
GO

UPDATE StaffDatapoint
SET [Name]='SME Prod Hrs'
WHERE ID=12 -- old: SME Prod Hrs
GO

UPDATE StaffDatapoint
SET [Name]='Nesting Prod Hrs'
WHERE ID=13 -- old: Nesting Prod Hrs
GO

UPDATE StaffDatapoint
SET [Name]='Planned Training Hours'
WHERE ID=14 -- old: Planned Training Hours
GO

UPDATE StaffDatapoint
SET [Name]='Projected Capacity'
WHERE ID=16 -- old: Projected Capacity
GO

-- Add new staff datapoint
--**************
--SEGMENT Staff and Datapoint
--**************

DECLARE @SegmentID BIGINT

INSERT INTO StaffSegment([Name],SortOrder,CreatedBy,Active,Visible)
VALUES('Head Count Details',6,'McNiel Viray',1,1)

SELECT @SegmentID = SCOPE_IDENTITY()

	INSERT INTO StaffDatapoint([Name],SortOrder,CreatedBy,SegmentID,Datatype)
	VALUES('Total Production Full Time',1,'McNiel Viray',@SegmentID,'Formula')
		,('Total Production Part Time',2,'McNiel Viray',@SegmentID,'Formula')
		,('Total Nesting Full Time',3,'McNiel Viray',@SegmentID,'Formula')
		,('Total Nesting Part Time',4,'McNiel Viray',@SegmentID,'Formula')
		,('Total Training Full Time',5,'McNiel Viray',@SegmentID,'Formula')
		,('Total Training Part Time',6,'McNiel Viray',@SegmentID,'Formula')
GO



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
/******************************
** File: Buildscript_1.00.093.sql
** Name: Buildscript_1.00.093
** Auth: McNiel Viray	
** Date: 24 July 2018
**************************
** Change History
**************************
** Add data to WeeklyStaffDatapoint
*******************************/
USE WFMPCP
GO

--*************
-- Create weekly Staff Datapoint
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
			INSERT INTO WeeklyStaffDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],Data,[Date],CreatedBy,DateCreated)
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
			FROM StaffDatapoint d
			INNER JOIN StaffSegment s ON s.ID=d.SegmentID
			WHERE d.ID > 23
			ORDER BY s.SortOrder,d.SortOrder
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
/******************************
** File: Buildscript_1.00.094.sql
** Name: Buildscript_1.00.094
** Auth: McNiel Viray
** Date: 25 July 2018
**************************
** Change History
**************************
** Create new udf to cater the new Staff Planner formula
** Modify wfmpcp_SaveWeeklyAHDatapointDatatable_sp
*******************************/
USE WFMPCP
GO


PRINT N'Altering [dbo].[udf_GetProdProdHrs]...';


GO
ALTER FUNCTION [dbo].[udf_GetProdProdHrs]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
		,@ah13 DECIMAL
		,@ah17 DECIMAL
		,@ah54 DECIMAL
	
	--= (([['Assumptions and Headcount'!C17]] * 40) * (1 - [[Assumptions and Headcount!C21]]))* [['Assumptions and Headcount'!C58]]

	--Assumptions and Headcount'!C17
	--ah13
	SELECT @ah13=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,13)

	--Assumptions and Headcount!C21
	--ah17 %
	SELECT @ah17=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)/100)

	--Assumptions and Headcount'!C58
	--ah54 %
	SELECT @ah54=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)/100)

	SELECT @Value=((@ah13 * 40) * (1 - @ah17))* @ah54
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetSMEProdHrs]...';


GO
ALTER FUNCTION [dbo].[udf_GetSMEProdHrs]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@ah113 DECIMAL
	,@ah17 DECIMAL
	,@ah54 DECIMAL

	--= (([['Assumptions and Headcount'!C118]] * 20) * (1 - [[Assumptions and Headcount!C21]]))* [['Assumptions and Headcount'!C58]]

	--Assumptions and Headcount'!C118
	--ah113
	SELECT @ah113=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,113)

	--Assumptions and Headcount!C21
	--ah17 %
	SELECT @ah17=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,58)/100)

	--Assumptions and Headcount'!C58
	--ah54 %
	SELECT @ah54=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,58)/100)

	SELECT @Value=((@ah113 * 20) * (1 - @ah17))* @ah54
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_NestingProdHrs]...';


GO
ALTER FUNCTION [dbo].[udf_NestingProdHrs]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
		,@ah71 DECIMAL
		,@ah44 DECIMAL
		,@ah54 DECIMAL
	

	--= [['Assumptions and Headcount'!C76]] * 40 * (1 - [['Assumptions and Headcount'!C48]]) * [['Assumptions and Headcount'!C58]]


	--Assumptions and Headcount'!C76
	--ah71
	SELECT @ah71=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,71) 

	--Assumptions and Headcount'!C48
	--ah44 %
	SELECT @ah44=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,44)/100)

	--Assumptions and Headcount'!C58
	--ah54 %
	SELECT @ah54=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)/100)


	SELECT @Value=@ah71 * 40 * (1 - @ah44) * @ah54
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetGrossRequiredHours]...';


GO
CREATE FUNCTION [dbo].[udf_GetGrossRequiredHours]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
		,@ah54 DECIMAL
		,@ah17 DECIMAL
		,@basehours DECIMAL

		-- C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C65]]/(1 - [['Assumptions and Headcount'!C21]])  This is the formula before the rollback
		-- C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C21]])

		--C11 Base Hours (Workload)
		SELECT @basehours=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
		
		--[['Assumptions and Headcount'!C58]] : Derived Occupancy, Occupancy [from Assumptions and Headcount tab]
		SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)

		--( [['Assumptions and Headcount'!C21])
		SELECT @ah17=NULLIF(([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)/100),0)
		
		--'= C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C21]])
		SELECT @Value=(@basehours/NULLIF(@ah54,0))/(1-NULLIF(@ah17,0))
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetPlannedNetFTE]...';


GO
CREATE FUNCTION [dbo].[udf_GetPlannedNetFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@c13 DECIMAL
	,@c14 DECIMAL
	,@c15 DECIMAL
	,@c16 DECIMAL
	,@ah54 DECIMAL
	
	--= = (C13/(1-(1- Derived Occupancy, Occupancy [from Assumptions and Headcount tab]!C58)/ 37.5  [2018.07.20 Formula]
	--  = (C13/(1-(1- Derived Occupancy, Occupancy [from Assumptions and Headcount tab])/ 37.5
	-- NOTE: Derived Occupancy, Occupancy is AHC ID 54

	--c13 (c14 + c15 + c16)
	SELECT @c14=[dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)
	SELECT @c15=[dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)
	SELECT @c16=[dbo].[udf_NestingProdHrs](@SiteID,@CampaignID,@LobID,@Date)

	SELECT @c13=@c14+@c15+@c16

	--Derived Occupancy, Occupancy [from Assumptions and Headcount tab]!C58
	--ah54 %
	SELECT @ah54=([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)/100)

	SELECT @Value=@c13/NULLIF((1-(1-@ah54)),0)/37.5

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetPlannedTrainingHours]...';


GO
CREATE FUNCTION [dbo].[udf_GetPlannedTrainingHours]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	--C13
	DECLARE @Value DECIMAL
		,@ah72 DECIMAL
	
	--= [['Assumptions and Headcount'!D72]]*37.5 (2018.07.20 FORMULA)
	--= [['Assumptions and Headcount'!D77]]*37.5
	
	--Assumptions and Headcount'!D77
	--ah67
	SELECT @ah72=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,72) 

	SELECT @Value=@ah72*37.5

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetRequiredNetFTE]...';


GO
CREATE FUNCTION [dbo].[udf_GetRequiredNetFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@c11 DECIMAL
	,@ah54 DECIMAL
	,@ah61 DECIMAL

	--= (C11 / [['Assumptions and Headcount'!C58]] / (1 - [['Assumptions and Headcount'!C65]]) / 37.5

	--c11
	--8  = [['Assumptions and Headcount'!C60]] ah56
	SELECT @c11=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,56)
	
	--'Assumptions and Headcount'!C58
	--54 %
	SELECT @ah54=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,54)/100

	--'Assumptions and Headcount'!C65
	--61
	SELECT @ah61=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,61)


	SELECT @Value=@c11/ NULLIF(@ah54,0) / NULLIF((1 - @ah61),0) / 37.5

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetTotalNestingFullTime]...';


GO
CREATE FUNCTION [dbo].[udf_GetTotalNestingFullTime]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@ah133 DECIMAL
	,@ah134 DECIMAL
	,@ah135 DECIMAL
	
	--= [['Assumptions and Headcount'!D138]]+[['Assumptions and Headcount'!D139]]+[['Assumptions and Headcount'!D140]]

	--[['Assumptions and Headcount'!D138]]
	--133
	SELECT @ah133=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,133)

	--[['Assumptions and Headcount'!D139]]
	--134
	SELECT @ah134=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,134)

	--[['Assumptions and Headcount'!D140]]
	--135
	SELECT @ah135=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,135)

	SELECT @Value=@ah133+@ah134+@ah135

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetTotalNestingPartTime]...';


GO
CREATE FUNCTION [dbo].[udf_GetTotalNestingPartTime]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@ah136 DECIMAL
	,@ah137 DECIMAL
	,@ah138 DECIMAL
	
	--= [['Assumptions and Headcount'!D141]]+[['Assumptions and Headcount'!D142]]+[['Assumptions and Headcount'!D143]]

	--[['Assumptions and Headcount'!D141]]
	--136
	SELECT @ah136=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,136)

	--[['Assumptions and Headcount'!D142]]
	--137
	SELECT @ah137=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,137)

	--[['Assumptions and Headcount'!D143]]
	--138
	SELECT @ah138=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,138)

	SELECT @Value=@ah136+@ah137+@ah138


	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetTotalProductionFullTime]...';


GO
CREATE FUNCTION [dbo].[udf_GetTotalProductionFullTime]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	
	--[['Assumptions and Headcount'!D136]]
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,131)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetTotalProductionPartTime]...';


GO
CREATE FUNCTION [dbo].[udf_GetTotalProductionPartTime]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	
	-- [['Assumptions and Headcount'!D137]]	
	SELECT @Value=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,132)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetTotalTrainingFullTime]...';


GO
CREATE FUNCTION [dbo].[udf_GetTotalTrainingFullTime]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@ah139 DECIMAL
	,@ah141 DECIMAL
	
	--= [['Assumptions and Headcount'!D144]]+[['Assumptions and Headcount'!D146]]

	--[['Assumptions and Headcount'!D144]]
	--139
	SELECT @ah139=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,139)

	--[['Assumptions and Headcount'!D146]]
	--141
	SELECT @ah141=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,141)

	SELECT @Value=@ah139+@ah141

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetTotalTrainingPartTime]...';


GO
CREATE FUNCTION [dbo].[udf_GetTotalTrainingPartTime]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@ah140 DECIMAL
	,@ah142 DECIMAL
	
	--= = [['Assumptions and Headcount'!D145]]+[['Assumptions and Headcount'!D147]]
	--' = [['Assumptions and Headcount'!D145]]+[['Assumptions and Headcount'!D147]]

	--[['Assumptions and Headcount'!D145]]
	--140
	SELECT @ah140=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,140)

	--[['Assumptions and Headcount'!D147]]
	--142
	SELECT @ah142=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,142)

	SELECT @Value=@ah140+@ah142

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetProjectedCapacity]...';


GO
ALTER FUNCTION [dbo].[udf_GetProjectedCapacity]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@c14 DECIMAL
	,@c15 DECIMAL
	,@c16 DECIMAL
	,@ah9 DECIMAL
	,@ah117 DECIMAL


	--= (C14 * 3600 / [['Assumptions and Headcount'!C13]]) + (C15 * 3600 / [['Assumptions and Headcount'!C13]]) + (C16 * 3600 / [['Assumptions and Headcount'!C122]])
	--C14
	SELECT @c14=[dbo].[udf_GetProdProdHrs](@SiteID,@CampaignID,@LobID,@Date)
	--C15
	SELECT @c15=[dbo].[udf_GetSMEProdHrs](@SiteID,@CampaignID,@LobID,@Date)
	--C16
	SELECT @c16=[dbo].[udf_NestingProdHrs](@SiteID,@CampaignID,@LobID,@Date)
	

	--Assumptions and Headcount'!C13
	--ah9
	SELECT @ah9=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,9)

	--Assumptions and Headcount'!C122
	--ah117
	SELECT @ah117=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,117)

	SELECT @Value=(@c14 * 3600 / NULLIF(@ah9,0)) + (@c15 * 3600 / NULLIF(@ah9,0)) + (@c16 * 3600 / NULLIF(@ah117,0))

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetCurrentGrossFTE]...';


GO
CREATE FUNCTION [dbo].[udf_GetCurrentGrossFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@c28 DECIMAL
	,@c29 DECIMAL
	,@c30 DECIMAL
	,@c31 DECIMAL
	,@ah39 DECIMAL
	,@ah17 DECIMAL
	,@ah117 DECIMAL

	--(C28+(C29*0.5))+((C30+(C31*0.5))*(((1 - [['Assumptions and Headcount'!C43]])/(1 - [['Assumptions and Headcount'!C21]]))*((1 - [['Assumptions and Headcount'!C121]])/(1 - [['Assumptions and Headcount'!C122]]))))
    
	--C28
	--24
	SELECT @c28=[dbo].[udf_GetTotalProductionFullTime](@SiteID,@CampaignID,@LoBID,@Date)
	
	--C29
	--25
	SELECT @c29=[dbo].[udf_GetTotalProductionPartTime](@SiteID,@CampaignID,@LoBID,@Date)

	--C30
	--26
	SELECT @c30=[dbo].[udf_GetTotalNestingFullTime](@SiteID,@CampaignID,@LoBID,@Date)

	--C31
	--27
	SELECT @c31=[dbo].[udf_GetTotalNestingPartTime](@SiteID,@CampaignID,@LoBID,@Date)

	--Assumptions and Headcount'!C43
	--39   %
	SELECT @ah39=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,39),0)/100

	--Assumptions and Headcount'!C21
	--17   %
	SELECT @ah17=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,17),0)/100

	--Assumptions and Headcount'!C122
	--117
	SELECT @ah117=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,117)

	SELECT @Value=(@c28+(@c29*0.5))+((@c30+(@c31*0.5))*(((1 - @ah39)/NULLIF((1 - @ah17),0))*((1 - @ah17)/NULLIF((1 - @ah117),0))))

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_GetGrossRequiredFTE]...';


GO
CREATE FUNCTION [dbo].[udf_GetGrossRequiredFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
		,@grossRequiredHours DECIMAL--StaffDatapointID: 9
		-- Gross Required Hours / 40

		SELECT @grossRequiredHours=[dbo].[udf_GetGrossRequiredHours](@SiteID,@CampaignID,@LobID,@Date)

		--DEFAULT FORMULA
		SELECT @Value=(@grossRequiredHours/40)
		
		--CHECK the formula assigned to Site,Campaign, and LoB
		IF EXISTS (SELECT f.ID FROM DynamicFormula f 
						INNER JOIN SiteCampaignLobFormula sclf ON sclf.DynamicFormulaID=f.ID
						WHERE sclf.SiteID=@SiteID 
							AND sclf.CampaignID=@CampaignID
							AND sclf.LoBID=@LobID
							AND sclf.Active = 1
							AND f.Active = 1)
		BEGIN
			DECLARE @FormulaID BIGINT = 0

			SELECT @FormulaID = f.ID FROM DynamicFormula f 
			INNER JOIN SiteCampaignLobFormula sclf ON sclf.DynamicFormulaID=f.ID
			WHERE sclf.SiteID=@SiteID 
				AND sclf.CampaignID=@CampaignID
				AND sclf.LoBID=@LobID
				AND sclf.Active = 1
				AND f.Active = 1

			IF(@FormulaID=2)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_Erlang](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=3)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_Straight](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=4)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerHour](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=5)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerUnit](@SiteID,@CampaignID,@LobID,@Date)
			END
			IF(@FormulaID=6)
			BEGIN
				SELECT @Value = [dbo].[udf_Dynamic_BillablePerMinute](@SiteID,@CampaignID,@LobID,@Date)
			END
		END

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
	@WeeklyDatapointTableType [dbo].[WeeklyDatapointTableType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
	BEGIN TRY
		BEGIN TRANSACTION
		--UPDATE FIRST Related Data
		UPDATE w
		SET w.[Data]=wt.DataValue,
			w.ModifiedBy=wt.UserName,
			w.DateModified=wt.DateModified
		FROM WeeklyAHDatapoint w
		INNER JOIN @WeeklyDatapointTableType wt ON wt.DatapointID=w.DatapointID	
			AND wt.[Date]=w.[Date]
			AND wt.LoBID=w.LoBID
			AND wt.SiteID=w.SiteID
			AND wt.CampaignID=w.CampaignID

		--cascade to remaining data.

		DECLARE @Date DATE

		SELECT @Date = MAX([Date]) FROM @WeeklyDatapointTableType
		DECLARE @tbl AS TABLE
		(
			DatapointID BIGINT,
			SiteID BIGINT,
			CampaignID BIGINT,
			LobID BIGINT,
			DataValue NVARCHAR(250),
			DateMofidifed DATETIME,
			ModifiedBy NVARCHAR(50)
		)

		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LoBID,DataValue,DateModified,UserName,SiteID,CampaignID
		FROM @WeeklyDatapointTableType
		WHERE [Date]=@Date

		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyAHDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date

		--*****************************************
		-- CREATE AND COMPUTE WeeklyStaffDatapoint*
		--*****************************************
		--check if WeeklyStaffDatapoint is empty
		DECLARE @LobID BIGINT=0
			,@CampaignID BIGINT=0
			,@SiteID BIGINT=0
			,@Date2 DATE
			,@DateModified DATETIME
			,@Username NVARCHAR(20)

		--SELECT DISTINCT @LobID=LoBID 
		--	,@DateModified=DateModified
		--	,@Username=Username
		--FROM @WeeklyDatapointTableType
		
		--SELECT @CampaignID=CampaignID FROM LoB WHERE ID=@LobID

		SELECT TOP 1 @LobID=w.LoBID
			,@CampaignID=w.CampaignID 
			,@SiteID=w.SiteID
			,@Username=w.UserName
			,@DateModified=w.DateModified
		FROM @WeeklyDatapointTableType w
		--INNER JOIN LoB l ON l.ID=w.LoBID	

		--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		--Set up and compute weeklystaffdatapoint
		DECLARE @StaffDatapoint AS TABLE
		(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,RequiredHC DECIMAL--1
			,CurrentHC DECIMAL--2
			,ExcessDeficitHC DECIMAL--3
			,RequiredFTE DECIMAL--4
			,PlannedFTE DECIMAL--5
			,TeleoptiRequiredFTE DECIMAL--6
			,ExcessDeficitFTE DECIMAL--7
			,BaseHours DECIMAL--8
			,NetReqHours DECIMAL--9
			,PlannedProdHrs DECIMAL--10
			,ProdProdHrs DECIMAL--11
			,SMEProdHrs DECIMAL--12
			,NestingProdHrs DECIMAL--13
			,PlannedTrainingHrs DECIMAL--14
			,RequiredVolFTE DECIMAL--15
			,ProjectedCapacity DECIMAL--16
			,CapacityToForecastPerc DECIMAL--17				
			,ActualToForecastPerc DECIMAL--18
			,AnsweredToForecastPerc DECIMAL--19
			,AnsweredToCapacityPerc DECIMAL--20
			,BillableHC DECIMAL--21				
			,CurrentBillableHC DECIMAL--22
			,BillableExcessDeficit DECIMAL--23
			,TotalProductionFullTime DECIMAL--24
			,TotalProductionPartTime DECIMAL--25
			,TotalNestingFullTime DECIMAL--26
			,TotalNestingPartTime DECIMAL--27
			,TotalTrainingFullTime DECIMAL--28
			,TotalTrainingPartTime DECIMAL--29
		)
		INSERT INTO @StaffDatapoint
			SELECT  
				DISTINCT(w.[Date]) 
				,w.SiteID
				,w.CampaignID
				,w.LoBID
				,[dbo].[udf_GetGrossRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 1
				,[dbo].[udf_GetCurrentGrossFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 2
				,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 3
				,[dbo].[udf_GetRequiredNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:4
				,[dbo].[udf_GetPlannedNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:5
				,0--StaffDatapointID: 6
				,[dbo].[udf_GetExcessDeficitFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 7
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56) --StaffDatapointID: 8
				,[dbo].[udf_GetGrossRequiredHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date]) --StaffDatapointID: 9
				,[dbo].[udf_GetPlannedProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 10
				,[dbo].[udf_GetProdProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 11
				,[dbo].[udf_GetSMEProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 12
				,[dbo].[udf_NestingProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 13
				,[dbo].[udf_GetPlannedTrainingHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 14
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--StaffDatapointID: 15
				,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 16
				,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 17
				,[dbo].[udf_GetActualToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 18
				,[dbo].[udf_GetAnsweredToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 19
				,[dbo].[udf_GetAnsweredToCapacityPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 20
				,[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 21
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],66)--StaffDatapointID: 22
				,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 23
				,[dbo].[udf_GetTotalProductionFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:24
				,[dbo].[udf_GetTotalProductionPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:25
				,[dbo].[udf_GetTotalNestingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:26
				,[dbo].[udf_GetTotalNestingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:27
				,[dbo].[udf_GetTotalTrainingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:28
				,[dbo].[udf_GetTotalTrainingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:29
			FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.RequiredHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.CurrentHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitHC) = 0 THEN '0'
				ELSE CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredFTE) = 0 THEN '0'
				ELSE CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TeleoptiRequiredFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitFTE) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BaseHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.BaseHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NetReqHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProdProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.SMEProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NestingProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedTrainingHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredVolFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProjectedCapacity) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CapacityToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ActualToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=
			CASE
				WHEN ISNUMERIC(s.AnsweredToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.AnsweredToCapacityPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CurrentBillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableExcessDeficit) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

		--xxxxxxx
		--CASCADE DATA 
		--xxxxxxx
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,Data,@DateModified,@Username,SiteID,CampaignID
		FROM WeeklyStaffDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID 
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyStaffDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date

		--end set up and compute weeklystaffdatapoint
		--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



		--*****************************************
		-- CREATE AND COMPUTE WeeklyHiringDatapoint*
		--*****************************************
		DECLARE @HiringDatapoint AS TABLE(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,NewCapacity NVARCHAR(250)
			,AttritionBackfill NVARCHAR(250)
		)

		INSERT INTO @HiringDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,CAST(CEILING([dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],92)) AS NVARCHAR(250))
			,CAST(CEILING([dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],93)) AS NVARCHAR(250))
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=NewCapacity
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyHiringDatapoint w
		INNER JOIN @HiringDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=AttritionBackfill
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyHiringDatapoint w
		INNER JOIN @HiringDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		--xxxxxxx
		--CASCADE DATA (hiring)
		--xxxxxxx
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username,SiteID,CampaignID
		FROM WeeklyHiringDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyHiringDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date
		--*****************************************
		-- END CREATE AND COMPUTE WeeklyHiringDatapoint*
		--*****************************************
		

		--***************************************
		-- CREATE WeeklySummaryDatapoint
		--***************************************
		DECLARE @SummaryDatapoint AS TABLE(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,TargetServiceLevel DECIMAL--1
			,ProjectedServiceLevel DECIMAL--2
			,ActualServiceLevel DECIMAL--3
			,VolumeForecast DECIMAL--4
			,VolumeOffered DECIMAL--5
			,VolumeHandled DECIMAL--6
			,VolumeCapacity DECIMAL--7
			,VolumeVarianceOfferedvsForecast DECIMAL--8
			,TargetAHT DECIMAL--9
			,ActualAHT DECIMAL--10
			,AHTVariancePercentagetoGoal DECIMAL--11
			,TargetProductionHours DECIMAL--12
			,ActualProductionHours DECIMAL--13
			,ProductionHoursVariance DECIMAL--14
			,BillableHeadcount DECIMAL--15
			,RequiredHeadcount DECIMAL--16
			,ActualProductionHeadcount DECIMAL--17
			,ActualNestingHeadcount DECIMAL--18
			,ActualTrainingHeadcount DECIMAL--19
			,BillableExcessDeficits DECIMAL--20
			,RequiredExcessDeficits DECIMAL--21
			,ProductionAttrition DECIMAL--22
			,NestingTrainingAttrition DECIMAL--23
			,NestingAttrition DECIMAL--24
			,TrainingAttrition DECIMAL--25
			,TotalTargetShrinkage DECIMAL--26
			,TargetIncenterShrinkage DECIMAL--27
			,TargetOutofcenterShrinkage DECIMAL--28
			,TotalActualShrinkage DECIMAL--29
			,ActualIncenterShrinkage DECIMAL--30
			,ActualOutofcenterShrinkage DECIMAL--31
			,ShrinkageVarianceTargetActual DECIMAL--32
			,TargetOccupancy DECIMAL--33
			,ActualOccupancy DECIMAL--34
		)

		INSERT INTO @SummaryDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],1)--1
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],2)--2
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],4)--3
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--4
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],7)--5
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],8)--6
			,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--7
			,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--8
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],9)--9
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],11)--10
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],12)--11
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56)--12
			,0--13
			,0--14
			,[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--15
			,[dbo].[udf_GetRequiredHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--16
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],80)--17
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],81)--18
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],86)--19
			,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--20
			,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--21
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],95)--22
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--23
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)--24
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--25
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)--26
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--27
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],23)--28
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],35)--29
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],36)--30
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],41)--31
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],26)-[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],29)--32--Original as of 10.26.2017 [dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--32
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],54)--33
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],55)--34
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProjectedServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProjectedServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeForecast) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeForecast,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeOffered) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeOffered,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeHandled) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeHandled,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeCapacity) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeCapacity,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeVarianceOfferedvsForecast) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.VolumeVarianceOfferedvsForecast,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.AHTVariancePercentagetoGoal) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.AHTVariancePercentagetoGoal,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionHoursVariance) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionHoursVariance,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualNestingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualNestingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualTrainingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualTrainingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingTrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingTrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalTargetShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TotalTargetShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOutofcenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalActualShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.TotalActualShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=30

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOutofcenterShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.ActualOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=31

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ShrinkageVarianceTargetActual) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ShrinkageVarianceTargetActual,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=32

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=33

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=34

		--CASCADE Summary data
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username,SiteID,CampaignID
		FROM WeeklySummaryDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklySummaryDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date
		--***************************************
		-- END CREATE WeeklySummaryDatapoint
		--***************************************

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	    DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        IF @xstate = -1
             ROLLBACK TRANSACTION;
        if @xstate = 1 and @trancount = 0
             ROLLBACK TRANSACTION;
        if @xstate = 1 and @trancount > 0
            ROLLBACK TRANSACTION

        RAISERROR ('[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]: %d: %s', 16, 1, @error, @message) ;

		--IF @@TRANCOUNT > 0
		--	ROLLBACK TRANSACTION --RollBack in case of Error

		--RAISERROR(15600,-1,-1,'[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]')
	END CATCH
END
GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.095.sql
** Name: Buildscript_1.00.095
** Auth: McNiel N Viray
** Date: 30 August 2018
** Current: Yes
**************************
** Change History
**************************
** Create New table [dbo].[CSVRawData]
** Create new procedure(s)
**     wfmpcp_CreateCSVRawData_sp,wfmpcp_ActivateDeactiviateCSV_sp,wfmpcp_GetCSVRawData
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[CSVRawData]...';


GO
CREATE TABLE [dbo].[CSVRawData] (
    [ID]           UNIQUEIDENTIFIER NOT NULL,
    [SiteID]       BIGINT           NULL,
    [CampaignID]   BIGINT           NULL,
    [LoBID]        BIGINT           NULL,
    [Filename]     NVARCHAR (15)    NULL,
    [RowNumber]    BIGINT           NULL,
    [ColumnNumber] BIGINT           NULL,
    [Data]         NVARCHAR (150)   NOT NULL,
    [CreatedBy]    NVARCHAR (150)   NULL,
    [DateCreated]  DATETIME         NOT NULL,
    [Active]       BIT              NOT NULL,
    CONSTRAINT [pk_CSVRawData_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
PRINT N'Creating unnamed constraint on [dbo].[CSVRawData]...';


GO
ALTER TABLE [dbo].[CSVRawData]
    ADD DEFAULT NEWID() FOR [ID];


GO
PRINT N'Creating unnamed constraint on [dbo].[CSVRawData]...';


GO
ALTER TABLE [dbo].[CSVRawData]
    ADD DEFAULT ('0') FOR [Data];


GO
PRINT N'Creating unnamed constraint on [dbo].[CSVRawData]...';


GO
ALTER TABLE [dbo].[CSVRawData]
    ADD DEFAULT GETDATE() FOR [DateCreated];


GO
PRINT N'Creating unnamed constraint on [dbo].[CSVRawData]...';


GO
ALTER TABLE [dbo].[CSVRawData]
    ADD DEFAULT (1) FOR [Active];


GO
PRINT N'Creating [dbo].[wfmpcp_ActivateDeactiviateCSV_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_ActivateDeactiviateCSV_sp]
	@Active BIT=NULL,
	@SiteID BIGINT=NULL,
	@CampaignID BIGINT=NULL,
	@LoBID BIGINT=NULL
AS
BEGIN
	UPDATE CSVRawData
	SET Active=ISNULL(@Active,Active)
	WHERE ((SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((CampaignID=@CampaignID) OR (@CampaignID IS NULL))
		AND ((LoBID=@LoBID) OR (@LoBID IS NULL))
END
GO
PRINT N'Creating [dbo].[wfmpcp_CreateCSVRawData_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_CreateCSVRawData_sp]
	@Data NVARCHAR(200),
	@CreatedBy NVARCHAR(150),
	@RowNumber BIGINT,
	@ColumnNumber BIGINT,
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LoBID BIGINT,
	@Filename NVARCHAR(150)
AS
BEGIN
	INSERT INTO CSVRawData(Data,CreatedBy,RowNumber,ColumnNumber,SiteID,CampaignID,LoBID,[Filename])
	VALUES(@Data,@CreatedBy,@RowNumber,@ColumnNumber,@SiteID,@CampaignID,@LoBID,@Filename)
END
GO
PRINT N'Creating [dbo].[wfmpcp_GetCSVRawData_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_GetCSVRawData_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
	,@Active BIT = NULL
AS
BEGIN
	SELECT 
	--ID,
	s.SiteID
	,s.CampaignID
	,s.LoBID
	,DatapointID=(s.RowNumber-1)
	,[Week]=(SELECT WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1))
	,[Data]=s.Data
	,[Date]=CAST((SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1) AS DATE)
	,s.CreatedBy
    ,s.DateCreated
	FROM CSVRawData s
	WHERE s.RowNumber <= 143--LastRow
		AND s.RowNumber > 1--Exclude Header
		AND s.ColumnNumber > 2--Exclude Segment
		AND ((s.SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((s.CampaignID=@CampaignID) OR (@CampaignID IS NULL))
        AND ((s.LoBID=@LoBID) OR (@LoBID IS NULL)) 
		AND ((Active=@Active) OR (@Active IS NULL))
	ORDER BY RowNumber,[Date]
END
GO

PRINT N'Creating [dbo].[wfmpcp_DeleteStagingAHWeeklyDatapoint_sp]...';

GO
CREATE PROCEDURE [dbo].[wfmpcp_DeleteStagingAHWeeklyDatapoint_sp]
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT
AS
BEGIN
	DELETE FROM StagingWeeklyAHDatapoint WHERE SiteID=@SiteID AND CampaignID=@CampaignID AND LoBID=@LobID
END
GO

CREATE PROCEDURE [dbo].[wfmpcp_CreateStagingWeeklyAHDatapoint_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
	,@Active BIT = NULL
AS
BEGIN
	INSERT INTO StagingWeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
	SELECT 
		s.SiteID
		,s.CampaignID
		,s.LoBID
		,DatapointID=(s.RowNumber-1)
		,[Week]=(SELECT WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1))
		,[Data]=s.Data
		,[Date]=CAST((SELECT Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1) AS DATE)
		,s.CreatedBy
		,s.DateCreated
	FROM CSVRawData s
	WHERE s.RowNumber <= 143--LastRow
		AND s.RowNumber > 1--Exclude Header
		AND s.ColumnNumber > 2--Exclude Segment
		AND ((s.SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((s.CampaignID=@CampaignID) OR (@CampaignID IS NULL))
		AND ((s.LoBID=@LoBID) OR (@LoBID IS NULL)) 
		AND ((Active=@Active) OR (@Active IS NULL))
	ORDER BY RowNumber,[Date]
END

GO
CREATE PROCEDURE [dbo].[wfmpcp_GetAllStagingAHDatapoint_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
AS
BEGIN
	SELECT 
		ID	
		,SiteID
		,CampaignID
		,LoBID
		,DatapointID
		,[Week]
		,[Data]
		,[Date]
		,CreatedBy
		,DateCreated
	FROM StagingWeeklyAHDatapoint
	WHERE SiteID=@SiteID AND CampaignID=@CampaignID AND LoBID=@LoBID
END

GO
PRINT N'Update complete.';


GO
/******************************
** File: Buildscript_1.00.096.sql
** Name: Buildscript_1.00.096
** Auth: McNiel Viray
** Date: 31 August 2018
**************************
** Change History
**************************
** Created table to manage DB Version
** Create new procedure
** Alter procedure saving data
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[mgmt_DbVersions]...';


GO
CREATE TABLE [dbo].[mgmt_DbVersions] (
    [DbVersionID]    INT      IDENTITY (1, 1) NOT NULL,
    [Major]          INT      NOT NULL,
    [Minor]          INT      NOT NULL,
    [Build]          INT      NOT NULL,
    [DeployDate]     DATETIME NOT NULL,
    [CurrentVersion] BIT      NOT NULL,
    [Created]        DATETIME NOT NULL,
    CONSTRAINT [PK_Mgmt_DbVersions] PRIMARY KEY CLUSTERED ([DbVersionID] ASC)
);


GO
PRINT N'Creating [dbo].[mgmt_SystemParameters]...';


GO
CREATE TABLE [dbo].[mgmt_SystemParameters] (
    [SystemParameterId] INT             IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (255)  NOT NULL,
    [Value]             NVARCHAR (4000) NOT NULL,
    [Description]       NVARCHAR (2000) NULL,
    [DeployDate]        DATETIME        NOT NULL,
    [Created]           DATETIME        NOT NULL,
    CONSTRAINT [PK_Mgmt_SystemParameters] PRIMARY KEY CLUSTERED ([SystemParameterId] ASC)
);


GO
PRINT N'Creating [dbo].[DF_mgmt_DbVersions_DeployDate]...';


GO
ALTER TABLE [dbo].[mgmt_DbVersions]
    ADD CONSTRAINT [DF_mgmt_DbVersions_DeployDate] DEFAULT ( getdate() ) FOR [DeployDate];


GO
PRINT N'Creating [dbo].[DF_mgmt_DbVersions_CurrentVersion]...';


GO
ALTER TABLE [dbo].[mgmt_DbVersions]
    ADD CONSTRAINT [DF_mgmt_DbVersions_CurrentVersion] DEFAULT ( 1 ) FOR [CurrentVersion];


GO
PRINT N'Creating [dbo].[DF_mgmt_DbVersions_Created]...';


GO
ALTER TABLE [dbo].[mgmt_DbVersions]
    ADD CONSTRAINT [DF_mgmt_DbVersions_Created] DEFAULT ( getdate() ) FOR [Created];


GO
PRINT N'Creating [dbo].[DF_mgmt_SystemParameters_DeployDate]...';


GO
ALTER TABLE [dbo].[mgmt_SystemParameters]
    ADD CONSTRAINT [DF_mgmt_SystemParameters_DeployDate] DEFAULT ( getdate() ) FOR [DeployDate];


GO
PRINT N'Creating [dbo].[DF_mgmt_SystemParameters_Created]...';


GO
ALTER TABLE [dbo].[mgmt_SystemParameters]
    ADD CONSTRAINT [DF_mgmt_SystemParameters_Created] DEFAULT ( getdate() ) FOR [Created];


GO
PRINT N'Altering [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]
	@WeeklyDatapointTableType [dbo].[WeeklyDatapointTableType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
	BEGIN TRY
		BEGIN TRANSACTION
		--UPDATE FIRST Related Data
		UPDATE w
		SET w.[Data]=wt.DataValue,
			w.ModifiedBy=wt.UserName,
			w.DateModified=wt.DateModified
		FROM WeeklyAHDatapoint w
		INNER JOIN @WeeklyDatapointTableType wt ON wt.DatapointID=w.DatapointID	
			AND wt.[Date]=w.[Date]
			AND wt.LoBID=w.LoBID
			AND wt.SiteID=w.SiteID
			AND wt.CampaignID=w.CampaignID

		--cascade to remaining data.

		DECLARE @Date DATE

		SELECT @Date = MAX([Date]) FROM @WeeklyDatapointTableType
		DECLARE @tbl AS TABLE
		(
			DatapointID BIGINT,
			SiteID BIGINT,
			CampaignID BIGINT,
			LobID BIGINT,
			DataValue NVARCHAR(250),
			DateMofidifed DATETIME,
			ModifiedBy NVARCHAR(50)
		)

		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LoBID,DataValue,DateModified,UserName,SiteID,CampaignID
		FROM @WeeklyDatapointTableType
		WHERE [Date]=@Date

		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyAHDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date

		--*****************************************
		-- CREATE AND COMPUTE WeeklyStaffDatapoint*
		--*****************************************
		--check if WeeklyStaffDatapoint is empty
		DECLARE @LobID BIGINT=0
			,@CampaignID BIGINT=0
			,@SiteID BIGINT=0
			,@Date2 DATE
			,@DateModified DATETIME
			,@Username NVARCHAR(20)

		--SELECT DISTINCT @LobID=LoBID 
		--	,@DateModified=DateModified
		--	,@Username=Username
		--FROM @WeeklyDatapointTableType
		
		--SELECT @CampaignID=CampaignID FROM LoB WHERE ID=@LobID

		SELECT TOP 1 @LobID=w.LoBID
			,@CampaignID=w.CampaignID 
			,@SiteID=w.SiteID
			,@Username=w.UserName
			,@DateModified=w.DateModified
		FROM @WeeklyDatapointTableType w
		--INNER JOIN LoB l ON l.ID=w.LoBID	

		--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		--Set up and compute weeklystaffdatapoint
		DECLARE @StaffDatapoint AS TABLE
		(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,RequiredHC DECIMAL--1
			,CurrentHC DECIMAL--2
			,ExcessDeficitHC DECIMAL--3
			,RequiredFTE DECIMAL--4
			,PlannedFTE DECIMAL--5
			,TeleoptiRequiredFTE DECIMAL--6
			,ExcessDeficitFTE DECIMAL--7
			,BaseHours DECIMAL--8
			,NetReqHours DECIMAL--9
			,PlannedProdHrs DECIMAL--10
			,ProdProdHrs DECIMAL--11
			,SMEProdHrs DECIMAL--12
			,NestingProdHrs DECIMAL--13
			,PlannedTrainingHrs DECIMAL--14
			,RequiredVolFTE DECIMAL--15
			,ProjectedCapacity DECIMAL--16
			,CapacityToForecastPerc DECIMAL--17				
			,ActualToForecastPerc DECIMAL--18
			,AnsweredToForecastPerc DECIMAL--19
			,AnsweredToCapacityPerc DECIMAL--20
			,BillableHC DECIMAL--21				
			,CurrentBillableHC DECIMAL--22
			,BillableExcessDeficit DECIMAL--23
			,TotalProductionFullTime DECIMAL--24
			,TotalProductionPartTime DECIMAL--25
			,TotalNestingFullTime DECIMAL--26
			,TotalNestingPartTime DECIMAL--27
			,TotalTrainingFullTime DECIMAL--28
			,TotalTrainingPartTime DECIMAL--29
		)
		INSERT INTO @StaffDatapoint
			SELECT  
				DISTINCT(w.[Date]) 
				,w.SiteID
				,w.CampaignID
				,w.LoBID
				,[dbo].[udf_GetGrossRequiredFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 1
				,[dbo].[udf_GetCurrentGrossFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 2
				,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 3
				,[dbo].[udf_GetRequiredNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:4
				,[dbo].[udf_GetPlannedNetFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID:5
				,0--StaffDatapointID: 6
				,[dbo].[udf_GetExcessDeficitFTE](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 7
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56) --StaffDatapointID: 8
				,[dbo].[udf_GetGrossRequiredHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date]) --StaffDatapointID: 9
				,[dbo].[udf_GetPlannedProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 10
				,[dbo].[udf_GetProdProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 11
				,[dbo].[udf_GetSMEProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 12
				,[dbo].[udf_NestingProdHrs](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 13
				,[dbo].[udf_GetPlannedTrainingHours](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 14
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--StaffDatapointID: 15
				,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 16
				,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 17
				,[dbo].[udf_GetActualToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 18
				,[dbo].[udf_GetAnsweredToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 19
				,[dbo].[udf_GetAnsweredToCapacityPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 20
				,[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 21
				,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],66)--StaffDatapointID: 22
				,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--StaffDatapointID: 23
				,[dbo].[udf_GetTotalProductionFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:24
				,[dbo].[udf_GetTotalProductionPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:25
				,[dbo].[udf_GetTotalNestingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:26
				,[dbo].[udf_GetTotalNestingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:27
				,[dbo].[udf_GetTotalTrainingFullTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:28
				,[dbo].[udf_GetTotalTrainingPartTime](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--id:29
			FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.RequiredHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.RequiredHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1
		
		UPDATE w
		SET w.[Data]=
				CASE 
					WHEN ISNUMERIC(s.CurrentHC) = 0 THEN '0'
					ELSE CAST(CEILING(ROUND(s.CurrentHC,0)) AS NVARCHAR(250))
				END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitHC) = 0 THEN '0'
				ELSE CAST(CEILING(ROUND(s.ExcessDeficitHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredFTE) = 0 THEN '0'
				ELSE CAST(ROUND(s.RequiredFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.PlannedFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TeleoptiRequiredFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TeleoptiRequiredFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ExcessDeficitFTE) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ExcessDeficitFTE,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BaseHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.BaseHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NetReqHours) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NetReqHours,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProdProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.ProdProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.SMEProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.SMEProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.NestingProdHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.NestingProdHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.PlannedTrainingHrs) = 0 THEN '0' 
				ELSE CAST(ROUND(s.PlannedTrainingHrs,0) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.RequiredVolFTE) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.RequiredVolFTE,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ProjectedCapacity) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.ProjectedCapacity,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16
		
		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CapacityToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.CapacityToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.ActualToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.ActualToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=
			CASE
				WHEN ISNUMERIC(s.AnsweredToForecastPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToForecastPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.AnsweredToCapacityPerc) = 0 THEN '0 %' 
				ELSE CAST(ROUND(s.AnsweredToCapacityPerc,0) AS NVARCHAR(250)) + ' %'
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.CurrentBillableHC) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.CurrentBillableHC,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.BillableExcessDeficit) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.BillableExcessDeficit,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalProductionPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalProductionPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalNestingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalNestingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingFullTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingFullTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=
			CASE 
				WHEN ISNUMERIC(s.TotalTrainingPartTime) = 0 THEN '0' 
				ELSE CAST(CEILING(ROUND(s.TotalTrainingPartTime,0)) AS NVARCHAR(250))
			END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyStaffDatapoint w
		INNER JOIN @StaffDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

		--xxxxxxx
		--CASCADE DATA 
		--xxxxxxx
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,Data,@DateModified,@Username,SiteID,CampaignID
		FROM WeeklyStaffDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID 
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyStaffDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date

		--end set up and compute weeklystaffdatapoint
		--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



		--*****************************************
		-- CREATE AND COMPUTE WeeklyHiringDatapoint*
		--*****************************************
		DECLARE @HiringDatapoint AS TABLE(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,NewCapacity NVARCHAR(250)
			,AttritionBackfill NVARCHAR(250)
		)

		INSERT INTO @HiringDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,CAST(CEILING([dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],92)) AS NVARCHAR(250))
			,CAST(CEILING([dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],93)) AS NVARCHAR(250))
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=NewCapacity
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyHiringDatapoint w
		INNER JOIN @HiringDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=AttritionBackfill
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklyHiringDatapoint w
		INNER JOIN @HiringDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		--xxxxxxx
		--CASCADE DATA (hiring)
		--xxxxxxx
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username,SiteID,CampaignID
		FROM WeeklyHiringDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklyHiringDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date
		--*****************************************
		-- END CREATE AND COMPUTE WeeklyHiringDatapoint*
		--*****************************************
		

		--***************************************
		-- CREATE WeeklySummaryDatapoint
		--***************************************
		DECLARE @SummaryDatapoint AS TABLE(
			[Date] DATE
			,SiteID BIGINT
			,CampaignID BIGINT
			,LobID BIGINT	
			,TargetServiceLevel DECIMAL--1
			,ProjectedServiceLevel DECIMAL--2
			,ActualServiceLevel DECIMAL--3
			,VolumeForecast DECIMAL--4
			,VolumeOffered DECIMAL--5
			,VolumeHandled DECIMAL--6
			,VolumeCapacity DECIMAL--7
			,VolumeVarianceOfferedvsForecast DECIMAL--8
			,TargetAHT DECIMAL--9
			,ActualAHT DECIMAL--10
			,AHTVariancePercentagetoGoal DECIMAL--11
			,TargetProductionHours DECIMAL--12
			,ActualProductionHours DECIMAL--13
			,ProductionHoursVariance DECIMAL--14
			,BillableHeadcount DECIMAL--15
			,RequiredHeadcount DECIMAL--16
			,ActualProductionHeadcount DECIMAL--17
			,ActualNestingHeadcount DECIMAL--18
			,ActualTrainingHeadcount DECIMAL--19
			,BillableExcessDeficits DECIMAL--20
			,RequiredExcessDeficits DECIMAL--21
			,ProductionAttrition DECIMAL--22
			,NestingTrainingAttrition DECIMAL--23
			,NestingAttrition DECIMAL--24
			,TrainingAttrition DECIMAL--25
			,TotalTargetShrinkage DECIMAL--26
			,TargetIncenterShrinkage DECIMAL--27
			,TargetOutofcenterShrinkage DECIMAL--28
			,TotalActualShrinkage DECIMAL--29
			,ActualIncenterShrinkage DECIMAL--30
			,ActualOutofcenterShrinkage DECIMAL--31
			,ShrinkageVarianceTargetActual DECIMAL--32
			,TargetOccupancy DECIMAL--33
			,ActualOccupancy DECIMAL--34
		)

		INSERT INTO @SummaryDatapoint
		SELECT 
			DISTINCT(w.[Date]) 
			,w.SiteID
			,w.CampaignID
			,w.LoBID
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],1)--1
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],2)--2
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],4)--3
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],6)--4
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],7)--5
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],8)--6
			,[dbo].[udf_GetProjectedCapacity](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--7
			,[dbo].[udf_GetCapacityToForecastPerc](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--8
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],9)--9
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],11)--10
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],12)--11
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],56)--12
			,0--13
			,0--14
			,[dbo].[udf_GetBillableHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--15
			,[dbo].[udf_GetRequiredHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--16
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],80)--17
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],81)--18
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],86)--19
			,[dbo].[udf_GetBillableExcessDeficit](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--20
			,[dbo].[udf_GetExcessDeficitHC](w.SiteID,w.CampaignID,w.LoBID,w.[Date])--21
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],95)--22
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--23
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],99)--24
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],103)--25
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)--26
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--27
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],23)--28
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],35)--29
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],36)--30
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],41)--31
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],26)-[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],29)--32--Original as of 10.26.2017 [dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],17)+[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],18)--32
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],54)--33
			,[dbo].[udf_GetAHCDatapointValue](w.SiteID,w.CampaignID,w.LoBID,w.[Date],55)--34
		FROM @WeeklyDatapointTableType w

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=1

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProjectedServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProjectedServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=2

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualServiceLevel) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualServiceLevel,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=3

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeForecast) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeForecast,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=4

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeOffered) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeOffered,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=5

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeHandled) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeHandled,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=6

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeCapacity) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.VolumeCapacity,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=7

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.VolumeVarianceOfferedvsForecast) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.VolumeVarianceOfferedvsForecast,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=8

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=9

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualAHT) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualAHT,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=10

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.AHTVariancePercentagetoGoal) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.AHTVariancePercentagetoGoal,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=11

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.TargetProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=12

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHours) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHours,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=13

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionHoursVariance) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionHoursVariance,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=14

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=15

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=16

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualProductionHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualProductionHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=17

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualNestingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualNestingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=18

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualTrainingHeadcount) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.ActualTrainingHeadcount,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=19

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.BillableExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.BillableExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=20

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.RequiredExcessDeficits) = 0 THEN '0' 
			ELSE CAST(CEILING(ROUND(s.RequiredExcessDeficits,0)) AS NVARCHAR(250)) END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=21

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ProductionAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ProductionAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=22

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingTrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingTrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=23

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.NestingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.NestingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=24

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TrainingAttrition) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TrainingAttrition,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=25

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalTargetShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TotalTargetShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=26

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=27

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOutofcenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=28

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TotalActualShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.TotalActualShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=29

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualIncenterShrinkage) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualIncenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=30

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOutofcenterShrinkage) = 0 THEN '0' 
			ELSE CAST(ROUND(s.ActualOutofcenterShrinkage,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=31

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ShrinkageVarianceTargetActual) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ShrinkageVarianceTargetActual,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=32

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.TargetOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.TargetOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=33

		UPDATE w
		SET w.[Data]=CASE WHEN ISNUMERIC(s.ActualOccupancy) = 0 THEN '0 %' 
			ELSE CAST(ROUND(s.ActualOccupancy,0) AS NVARCHAR(250)) + ' %' END
			,w.DateModified=@DateModified
			,w.ModifiedBy=@Username
		FROM WeeklySummaryDatapoint w
		INNER JOIN @SummaryDatapoint s ON s.[Date]=w.[Date]
			AND s.LobID=w.LoBID
			AND s.SiteID=w.SiteID
			AND s.CampaignID=w.CampaignID
		WHERE w.DatapointID=34

		--CASCADE Summary data
		DELETE FROM @tbl
		INSERT INTO @tbl(DatapointID,LobID,DataValue,DateMofidifed,ModifiedBy,SiteID,CampaignID)
		SELECT DatapointID,LobID,[Data],@DateModified,@Username,SiteID,CampaignID
		FROM WeeklySummaryDatapoint 
		WHERE [Date]=@Date 
			AND LobID=@LobID 
			AND SiteID=@SiteID
			AND CampaignID=@CampaignID


		UPDATE w
		SET w.[Data]=t.DataValue
			,w.ModifiedBy=t.ModifiedBy
			,w.DateModified=t.DateMofidifed
		FROM WeeklySummaryDatapoint w
		INNER JOIN @tbl t ON t.DatapointID=w.DatapointID
			AND t.LobID=w.LoBID
			AND t.SiteID=w.SiteID
			AND t.CampaignID=w.CampaignID
		WHERE w.[Date]>@Date
		--***************************************
		-- END CREATE WeeklySummaryDatapoint
		--***************************************

		SELECT TOP 1 @Username = UserName
			,@DateModified = DateModified
	    FROM @WeeklyDatapointTableType

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyAHDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyHiringDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklyStaffDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		UPDATE w
		SET w.ModifiedBy=@Username
			,w.DateModified=@DateModified
		FROM WeeklySummaryDatapoint w
		WHERE w.SiteID=@SiteID AND w.CampaignID=@CampaignID AND w.LoBID=@LobID

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	    DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        IF @xstate = -1
             ROLLBACK TRANSACTION;
        if @xstate = 1 and @trancount = 0
             ROLLBACK TRANSACTION;
        if @xstate = 1 and @trancount > 0
            ROLLBACK TRANSACTION

        RAISERROR ('[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]: %d: %s', 16, 1, @error, @message) ;

		--IF @@TRANCOUNT > 0
		--	ROLLBACK TRANSACTION --RollBack in case of Error

		--RAISERROR(15600,-1,-1,'[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]')
	END CATCH
END
GO
PRINT N'Creating [dbo].[mgmtsp_GetDbVersion]...';


GO
CREATE PROCEDURE [dbo].[mgmtsp_GetDbVersion]
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT	Major, 
			Minor,
			Build,
			DeployDate
	FROM	[mgmt_DbVersions] ( NOLOCK )
	WHERE	CurrentVersion = 1
	
	RETURN 0
END
GO
PRINT N'Creating [dbo].[mgmtsp_GetSystemParameter]...';


GO
CREATE PROCEDURE [dbo].[mgmtsp_GetSystemParameter]
	@Name NVARCHAR(255),
	@o_Value NVARCHAR(4000) OUTPUT
AS
BEGIN
	DECLARE	@_Error INT
		
	SELECT	@_Error = 0

	SELECT	@o_Value = Value
	FROM	[mgmt_SystemParameters] ( NOLOCK )
	WHERE	Name = @Name
		
	RETURN	@_Error
END
GO
PRINT N'Creating [dbo].[mgmtsp_IncrementDbVersion]...';


GO
CREATE PROCEDURE [dbo].[mgmtsp_IncrementDbVersion]
(
	@i_Major INT = NULL,
	@i_Minor INT = NULL,
	@i_Build INT = NULL
)
AS
	BEGIN
		SET NOCOUNT ON
	
		DECLARE @m_CurrentMajor INT,
				@m_CurrentMinor INT,
				@m_CurrentBuild INT,
				@m_ID INT,
				@m_Error INT,
				@m_NewMajor INT,
				@m_NewMinor INT,
				@m_NewBuild INT
		
		SELECT	@m_CurrentMajor = Major,
				@m_CurrentMinor = Minor,
				@m_CurrentBuild = Build,
				@m_NewMajor = @i_Major,
				@m_NewMinor = @i_Minor,
				@m_NewBuild = @i_Build,
				@m_Error = 0
		FROM	[mgmt_DbVersions]
		WHERE	CurrentVersion = 1
		
		IF @m_NewMajor is null
			BEGIN
				SELECT	@m_NewMajor = @m_CurrentMajor				

				IF @m_NewMinor is null
					BEGIN
						SELECT	@m_NewMinor = @m_CurrentMinor

						IF @m_NewBuild is null
							BEGIN
								SELECT	@m_NewBuild = @m_CurrentBuild + 1
							END
					END
				ELSE
					BEGIN
						IF @m_NewMinor <> @m_CurrentMinor
							BEGIN
								SELECT	@m_NewBuild = 0
							END
					END
			END
		ELSE
			BEGIN
				IF @m_NewMajor <> @m_CurrentMajor
					BEGIN
						SELECT	@m_NewMinor = 0,
								@m_NewBuild = 0
					END
				IF @m_NewMinor <> @m_CurrentMinor
							BEGIN
								SELECT	@m_NewBuild = 0
							END
			END
		
		IF (	( (	@m_CurrentBuild = @m_NewBuild - 1 ) and (@m_CurrentMinor = @m_NewMinor) and (@m_CurrentMajor = @m_NewMajor))
			 or	( (	@m_CurrentMinor = @m_NewMinor - 1 ) and (@m_CurrentMajor = @m_NewMajor) )
			 or	(	@m_CurrentMajor = @m_NewMajor - 1 )	)
			BEGIN
				
				UPDATE	[mgmt_DbVersions]
				SET		CurrentVersion = 0
				WHERE	CurrentVersion = 1
				
				INSERT	[mgmt_DbVersions]
				(	Major,
					Minor,
					Build		)
				VALUES
				(	@m_NewMajor,
					@m_NewMinor,
					@m_NewBuild	)
					
				SELECT	Major,
						Minor,
						Build,
						DeployDate
				FROM	[mgmt_DbVersions]
				WHERE	CurrentVersion = 1
			END
		ELSE
			BEGIN
				-- if build number in db is not 1 less than new value build
				-- scripts are being applied out of order - Throw error so 
				-- rest of work can be skipped.
				SELECT	@m_Error = 1
				GOTO ToReTuRn			
			END
				
ToReTuRn: 
		
		RETURN @m_Error
	END
GO
PRINT N'Creating [dbo].[mgmtsp_UpdateSystemParameter]...';


GO
CREATE PROCEDURE [dbo].[mgmtsp_UpdateSystemParameter]
	@Name NVARCHAR(255),
	@Value NVARCHAR(4000)
AS
BEGIN
	DECLARE	@_Error INT
		
	SELECT	@_Error = 0

	UPDATE	[mgmt_SystemParameters]
	SET		Value = @Value
	WHERE	Name = @Name
		
	SELECT  @_Error = @@Error
		
	ToReTuRn:	
		RETURN	@_Error
END
GO
PRINT N'Creating [dbo].[wfmpcp_SaveAHCStagingToActual_sp]...';


GO
CREATE PROCEDURE [dbo].[wfmpcp_SaveAHCStagingToActual_sp]
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT
AS
BEGIN
	DECLARE @tableParam AS WeeklyDatapointTableType

	INSERT INTO @tableParam(datapointid,siteid,campaignid,lobid,[date],datavalue,username,datemodified)
	SELECT datapointid
	,siteid
	,campaignid
	,lobid
	,[date]
	,CASE WHEN [data]='-' THEN '0'  ELSE [data] END
	,CreatedBy
	,DateCreated
	FROM StagingWeeklyAHDatapoint
	WHERE siteid=@SiteID and CampaignID=@CampaignID and lobid=@LobID

	EXEC [wfmpcp_SaveWeeklyAHDatapointDatatable_sp] @tableParam
END
GO
PRINT N'Update complete.';


GO


/******************************
** File: Buildscript_1.00.097.sql
** Name: Buildscript_1.00.097
** Auth: McNiel Viray
** Date: 31 August 2018
**************************
** Change History
**************************
** Data for mgmt_DBVersions
*******************************/
USE WFMPCP
GO

DECLARE @ctr INT = 0
WHILE @ctr < 97
BEGIN
	SET @ctr = @ctr + 1
	INSERT INTO mgmt_DbVersions(Major,Minor,Build,DeployDate,CurrentVersion,Created)
	VALUES(1,0,@ctr,GETDATE(),0,GETDATE());
END
GO
UPDATE mgmt_DbVersions
SET CurrentVersion=1
WHERE DBVersionID=(SELECT MAX(DBVersionID) FROM mgmt_DbVersions)
GO

/******************************
** File: Buildscript_1.00.098.sql
** Name: Buildscript_1.00.098
** Auth: McNiel Viray
** Date: 31 August 2018
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 98

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
GO

ALTER PROCEDURE [dbo].[wfmpcp_GetCSVRawData_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
	,@Active BIT = NULL
AS
BEGIN
	SELECT 
	--ID,
	s.SiteID
	,s.CampaignID
	,s.LoBID
	,DatapointID=(s.RowNumber-1)
	,[Week]=(SELECT TOP 1 WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT TOP 1 Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1))
	,[Data]=s.Data
	,[Date]=CAST((SELECT TOP 1 Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1) AS DATE)
	,s.CreatedBy
    ,s.DateCreated
	FROM CSVRawData s
	WHERE s.RowNumber <= 143--LastRow
		AND s.RowNumber > 1--Exclude Header
		AND s.ColumnNumber > 2--Exclude Segment
		AND ((s.SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((s.CampaignID=@CampaignID) OR (@CampaignID IS NULL))
        AND ((s.LoBID=@LoBID) OR (@LoBID IS NULL)) 
		AND ((Active=@Active) OR (@Active IS NULL))
	ORDER BY RowNumber,[Date]
END
GO
ALTER PROCEDURE [dbo].[wfmpcp_CreateStagingWeeklyAHDatapoint_sp]
	@SiteID BIGINT=NULL
	,@CampaignID BIGINT=NULL
	,@LoBID BIGINT=NULL
	,@Active BIT = NULL
AS
BEGIN
	INSERT INTO StagingWeeklyAHDatapoint(SiteID,CampaignID,LoBID,DatapointID,[Week],[Data],[Date],CreatedBy,DateCreated)
	SELECT 
		s.SiteID
		,s.CampaignID
		,s.LoBID
		,DatapointID=(s.RowNumber-1)
		,[Week]=(SELECT TOP 1 WeekOfYear FROM [week] WHERE WeekNoDate=(SELECT TOP 1 Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1))
		,[Data]=s.Data
		,[Date]=CAST((SELECT TOP 1 Data FROM CSVRawData WHERE RowNumber=1 AND ColumnNumber=s.ColumnNumber AND Active=1) AS DATE)
		,s.CreatedBy
		,s.DateCreated
	FROM CSVRawData s
	WHERE s.RowNumber <= 143--LastRow
		AND s.RowNumber > 1--Exclude Header
		AND s.ColumnNumber > 2--Exclude Segment
		AND ((s.SiteID=@SiteID) OR (@SiteID IS NULL))
		AND ((s.CampaignID=@CampaignID) OR (@CampaignID IS NULL))
		AND ((s.LoBID=@LoBID) OR (@LoBID IS NULL)) 
		AND ((Active=@Active) OR (@Active IS NULL))
	ORDER BY RowNumber,[Date]
END
GO

/******************************
** File: Buildscript_1.00.099.sql
** Name: Buildscript_1.00.099
** Auth: McNiel Viray
** Date: 26 September 2018
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 99

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
GO

ALTER FUNCTION [dbo].[udf_Dynamic_Straight]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
DECLARE @Value DECIMAL(10,2) = 0
	,@ahc121 DECIMAL = 0
    ,@ahc10 DECIMAL = 0
    ,@ahc58 DECIMAL = 0
	,@ahc21 DECIMAL = 0
	,@ahc23 DECIMAL = 0
	,@ahc58Perc DECIMAL(10,2) = 0
	,@ahc21Perc DECIMAL(10,2) = 0
	,@ahc23Perc DECIMAL(10,2) = 0	
	,@1minusahc21percminusahc23 DECIMAL(10,2) = 0

	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc23=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,19)

	SELECT @ahc58Perc = @ahc58/100
	SELECT @ahc21Perc = @ahc21/100
	SELECT @ahc23Perc = @ahc23/100
	SELECT @1minusahc21percminusahc23 = 1-(@ahc21Perc-@ahc23Perc)


	--select @ahc10,@ahc121,@ahc58,@ahc58Perc,@ahc21Perc,@1minusahc21percminusahc23
	--2018-09-26  UPDATED FORMULA
	--= Volume * AHT / 3600 / Derived Occupancy / 37.5/(1-(Overall Projected Production Shrinkage-Breaks))
	--'= ('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121) / 3600 / 'Assumptions and Headcount'!D58 / 37.5/(1-('Assumptions and Headcount'!D21-'Assumptions and Headcount'!D23))
	SELECT @Value=((((@ahc10 * @ahc121)/3600)/NULLIF(@ahc58Perc,0))/37.5)/NULLIF(@1minusahc21percminusahc23,0)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetCurrentGrossFTE]...';


GO
ALTER FUNCTION [dbo].[udf_GetCurrentGrossFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
	,@c28 DECIMAL
	,@c29 DECIMAL
	,@c30 DECIMAL
	,@c31 DECIMAL
	,@ah30 DECIMAL
	,@ah17 DECIMAL
	,@ah116 DECIMAL
	,@ah117 DECIMAL
    ,@ah30perc DECIMAL(10,2)
    ,@ah17perc DECIMAL(10,2)

	--(C28+(C29*0.5))+((C30+(C31*0.5))*(((1 - [['Assumptions and Headcount'!C43]])/(1 - [['Assumptions and Headcount'!C21]]))*(([['Assumptions and Headcount'!C121]])/([['Assumptions and Headcount'!C122]]))))
    --(@c28+(@c29*0.5))+((@c30+(@c31*0.5))*())
	--C28
	--24
	SELECT @c28=[dbo].[udf_GetTotalProductionFullTime](@SiteID,@CampaignID,@LoBID,@Date)
	
	--C29
	--25
	SELECT @c29=[dbo].[udf_GetTotalProductionPartTime](@SiteID,@CampaignID,@LoBID,@Date)

	--C30
	--26
	SELECT @c30=[dbo].[udf_GetTotalNestingFullTime](@SiteID,@CampaignID,@LoBID,@Date)

	--C31
	--27
	SELECT @c31=[dbo].[udf_GetTotalNestingPartTime](@SiteID,@CampaignID,@LoBID,@Date)

	--Assumptions and Headcount'!C30
	--26   %
	SELECT @ah30=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,26),0)
	SELECT @ah30perc = @ah30/100

	--Assumptions and Headcount'!C21
	--17   %
	SELECT @ah17=NULLIF([dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,17),0)/100
	SELECT @ah17perc=@ah17/100

	--Assumptions and Headcount'!C121
	--117
	SELECT @ah116=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,116)

	--Assumptions and Headcount'!C122
	--117
	SELECT @ah117=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,117)

	--2018-09-26 UPDATED
	SELECT @Value=(@c28+(@c29*0.5))+((@c30+(@c31*0.5))*(((1-@ah30perc)/(1-@ah17perc))*((@ah116)/(@ah117))))

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetExcessDeficitHC]...';


GO
ALTER FUNCTION [dbo].[udf_GetExcessDeficitHC]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL
		,@currentHC DECIMAL
		,@requiredHC DECIMAL

		SELECT @requiredHC = [dbo].[udf_GetGrossRequiredFTE](@SiteID,@CampaignID,@LoBID,@Date)--StaffDatapointID: 1
		SELECT @currentHC =	[dbo].[udf_GetCurrentGrossFTE](@SiteID,@CampaignID,@LoBID,@Date)--StaffDatapointID: 2

		SELECT @Value=@currentHC-@requiredHC
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Refreshing [dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveWeeklyAHDatapointDatatable_sp]';


GO
PRINT N'Refreshing [dbo].[wfmpcp_SaveAHCStagingToActual_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_SaveAHCStagingToActual_sp]';


GO
PRINT N'Update complete.';


GO




/******************************
** File: Buildscript_1.00.100.sql
** Name: Buildscript_1.00.100
** Auth: McNiel Viray
** Date: 15 October 2018
**************************
** Change History
**************************
** Modify Required Net FTE
** Modify Gross Required Hours
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 100

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END
GO

PRINT N'Altering [dbo].[udf_GetGrossRequiredHours]...';


GO
ALTER FUNCTION [dbo].[udf_GetGrossRequiredHours]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
		,@grossRequiredFTE DECIMAL

		--C1 of Staff PLanner (2018.10.15)
		SELECT  @grossRequiredFTE = [dbo].[udf_GetGrossRequiredFTE](@SiteID,@CampaignID,@LobID,@Date)
		
		--'= C1 * 40
		SELECT @Value=@grossRequiredFTE*40
		
	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_GetRequiredNetFTE]...';


GO
ALTER FUNCTION [dbo].[udf_GetRequiredNetFTE]
(
	@SiteID BIGINT,
	@CampaignID BIGINT,
	@LobID BIGINT,
	@Date DATE
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @Value DECIMAL(10,2)
	,@c1 DECIMAL -- c1 of staff planner
	,@ah21 DECIMAL(10,2)--AH DatapointId = 17
    ,@ah21Perc DECIMAL(10,2)

	--= (C1 *(1 - [['Assumptions and Headcount'!C21]])

	--c1
	--8  = [['Assumptions and Headcount'!C60]] ah56
	SELECT @c1=[dbo].[udf_GetGrossRequiredFTE](@SiteID,@CampaignID,@LoBID,@Date)
	SELECT @ah21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LoBID,@Date,17)
	SELECT @ah21Perc = @ah21/100
	
	SELECT @Value = @c1*(1-@ah21Perc)	

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Creating [dbo].[udf_Fact]...';


GO
CREATE FUNCTION [dbo].[udf_Fact]
(
	@Target NUMERIC(18,3)
)
RETURNS NUMERIC
AS
BEGIN
	DECLARE @i  NUMERIC(18,3)

    IF @Target <= 1
        SET @i = 1
    ELSE
        SET @i = @Target * [dbo].[udf_Fact]( @Target - 1 )

	RETURN @i
END;
GO
PRINT N'Creating [dbo].[udf_ErlangC_Formula]...';


GO
CREATE FUNCTION [dbo].[udf_ErlangC_Formula]
(
	@NumberOfCalls NUMERIC(10,3)
	,@PeriodOfCallsInMinutes NUMERIC(10,3)
	,@AHTInSeconds NUMERIC(10,3)
	,@RequiredServiceLevelPerc NUMERIC(10,3)
	,@TargetAnswerTimeInSeconds NUMERIC(10,3)
	,@MaximumOccupancyPerc NUMERIC(10,3)
	,@ShrinkagePerc NUMERIC(10,3)
)
RETURNS NUMERIC(10,2)
AS
BEGIN

	DECLARE @A NUMERIC, -- TRAFFIC INTESITY
	@N NUMERIC -- RAW NUMBER OF AGENTS REQUIRED
	--NUMERATOR FIRST
	--   n
	-- A      *  N
	--___       ___
	-- N!        N-A

	DECLARE @NumeratorA NUMERIC(10,3)
			,@NumeratorB NUMERIC(10,3)
			,@Numerator NUMERIC(10,2)

	SET @NumeratorA = POWER(@A,@N)/[dbo].[udf_Fact](@N);
	SET @NumeratorB = @N/NULLIF((@N-@A),0);
	SET @Numerator = @NumeratorA*@NumeratorB;
	
	RETURN @A + @N
END
GO
PRINT N'Creating [dbo].[udf_ErlangCFormula]...';


GO
CREATE FUNCTION [dbo].[udf_ErlangCFormula]
(
	@A NUMERIC -- TRAFFIC INTESITY
	,@N NUMERIC -- RAW NUMBER OF AGENTS REQUIRED
	,@AHTInSeconds NUMERIC(10,3)
	,@TargetAnswerTimeInSeconds NUMERIC(10,3)--SERVICE TIME
)
RETURNS @returntable TABLE
(
	Pw NUMERIC(18,2)
	,ServiceTimeInSec NUMERIC(10,2)
	,AHTInSec NUMERIC(10,3)
	,ServiceLevel NUMERIC(18,3)
	,ServiceLevelPerc NUMERIC(18,3)
	,FTE NUMERIC
)
AS
BEGIN

	DECLARE @NumeratorA NUMERIC(10,3)
			,@NumeratorB NUMERIC(10,3)
			,@ServiceLevelPerc NUMERIC(10,3)=0
			,@X NUMERIC(18,3)
			,@Y NUMERIC(18,3)
			,@Pw NUMERIC(18,2)
			,@PwPerc NUMERIC(18,2)
			,@SL NUMERIC(18,2)
			,@SLPerc NUMERIC(18,2)
			

	SET @NumeratorA = POWER(@A,@N)/[dbo].[udf_Fact](@N);
	SET @NumeratorB = @N/NULLIF((@N-@A),0);
	SET @X = @NumeratorA*@NumeratorB;

	--4. WORK ON Y  or ΣApowerofI/i!
	--LOOP @N
	DECLARE @i NUMERIC = 0
		,@EaPowOfiDivIFact NUMERIC(18,2)=0

	DECLARE @tblY AS TABLE(
		i NUMERIC(18,2)	
		,iFactorial NUMERIC(18,2)
		,APowerofI NUMERIC(18,2)
		,APowerofIDivideIFactorial NUMERIC(18,2)
		,SumOfAPowerofIDivideIFactorial NUMERIC(18,2)
	);
	WHILE(@i <= (@N-1))
	BEGIN
		DECLARE @iFact NUMERIC(18,2)
			,@aPowI NUMERIC(18,2)
			,@aPowOfiDivIFact NUMERIC(18,2)
			

		SET @iFact = [dbo].[udf_Fact](@i)
		SET @aPowI = POWER(@A,@i)
		SET @aPowOfiDivIFact = @aPowI/@iFact
		SET @EaPowOfiDivIFact = @EaPowOfiDivIFact + @aPowOfiDivIFact

		--SELECT @i,@iFact,@aPowI,@aPowOfiDivIFact,@EaPowOfiDivIFact

		INSERT INTO @tblY(i,iFactorial,APowerofI,APowerofIDivideIFactorial,SumOfAPowerofIDivideIFactorial)
		VALUES(@i,@iFact,@aPowI,@aPowOfiDivIFact,@EaPowOfiDivIFact);

		SET @i = @i + 1
		
	END

	SELECT TOP 1 @Y = SumOfAPowerofIDivideIFactorial
	FROM @tblY ORDER BY i DESC

	--5. Put X and Y into the Erlang C Formula (The probability a call has to wait)
	SET @Pw = @X/NULLIF((@Y+@X),0)
	SET @PwPerc = @Pw*100

	--6. Calculate the Service Level
		-- 6.1 Let’s work out -(N – A) * (TargetTime / AHT)
		DECLARE @exponent NUMERIC(18,3)
		SET @exponent = -((@N-@A)*(@TargetAnswerTimeInSeconds/@AHTInSeconds))
		
	SET @SL = 1-(0.6821*EXP(@exponent))
	SET @SLPerc = @SL*100
	

	INSERT @returntable
	SELECT 	@Pw
	,@TargetAnswerTimeInSeconds
	,@AHTInSeconds
	,@SL
	,@SLPerc
	,@N
	RETURN
END
GO