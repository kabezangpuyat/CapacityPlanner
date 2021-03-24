/******************************
** File: Buildscript_1.00.110.sql
** Name: Buildscript_1.00.110
** Auth: McNiel Viray
** Date: 09 May 2019
**************************
** Change History
**************************
** Modify [wfmpcp_GetCampaignMonthlyExcessDeficit_sp] and [wfmpcp_GetSiteMonthlyExcessDeficit_sp]
**   change AVG to SUM
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 110

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END


GO


ALTER FUNCTION [dbo].[udf_Dynamic_BillablePerHour]
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
	,@ahc60 DECIMAL (10,2) = 0
	,@ahc10 DECIMAL (10,2)= 0
    ,@ahc121 DECIMAL (10,2) = 0
    ,@ahc58 DECIMAL (10,2) = 0
	,@ahc21 DECIMAL(10,2) = 0
	,@ahc65 DECIMAL (10,2) = 0
	,@ahc21Perc DECIMAL (10,2) = 0

	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc121=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,116)
	SELECT @ahc58=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,54)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc21Perc = @ahc21/100
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	
	--FIRST DISPLAY
	--SELECT @ahc60,@ahc10,@ahc121,@ahc58,@ahc21,@ahc21Perc,@ahc65

	DECLARE @fvXpaht DECIMAL(10,2) = (@ahc10 *  @ahc21Perc)
		, @threesix DECIMAL(10,2) =  ISNULL((3600 / NULLIF(@ahc58,0)),0)
		, @minusOne  DECIMAL(10,2) = ISNULL(NULLIF((1 - @ahc21Perc),0),0)
		, @fvXpahtDIVthreesix DECIMAL(10,2) 
		, @fvXpahtDIVthreesixDIVmunusOne DECIMAL(10,2)
	
	SET @fvXpahtDIVthreesix = ISNULL((@fvXpaht/NULLIF(@threesix,0)),0)
	SET @fvXpahtDIVthreesixDIVmunusOne = ISNULL((@fvXpahtDIVthreesix/NULLIF(@minusOne,0)),0)

	--SECOND DISPLAY
	--SELECT @fvXpahtDIVthreesix,@fvXpahtDIVthreesixDIVmunusOne,@ahc60,(@fvXpahtDIVthreesixDIVmunusOne * @ahc65)

	--= Required Hours / (((Forecasted Volume *  Production AHT / 3600 / Derived Occupancy / (1 -	)) * Derived Schedule Constraints)
	--'= 'Assumptions and Headcount'!D60 / ((('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121 / 3600 / 'Assumptions and Headcount'!D58 / (1 - 'Assumptions and Headcount'!D21)) * 'Assumptions and Headcount'!D65))
	--SELECT @Value=@ahc60/ (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65))
	--SELECT @Value=@ahc60/NULLIF( (((@ahc10 * @ahc121 / 3600 / NULLIF(@ahc58,0) / NULLIF((1 - @ahc21),0)) * @ahc65)),0)
	
	SELECT @Value=@ahc60/NULLIF((@fvXpahtDIVthreesixDIVmunusOne * @ahc65),0)

	--SELECT @Value=@ahc60/(((@fvXpaht/@threesix)/@minusOne)* @ahc65) as of 03.12.2018

	--SELECT ISNULL(@Value,0)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_Dynamic_BillablePerUnit]...';


GO
ALTER FUNCTION [dbo].[udf_Dynamic_BillablePerUnit]
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
		,@NetRequiredHours DECIMAL
	    ,@ahc60 DECIMAL = 0
		,@ahc65 DECIMAL(10,2) = 0
		,@ahc21 DECIMAL(10,2) = 0
		,@ahc10 DECIMAL = 0
		,@ahc13 DECIMAL(10,2) = 0
		,@ahc21Perc DECIMAL(10,2) = 0
		
	--'= Required Hours / 40 * Derived Schedule Constraints [in this case, its 1.0] [Net required hours = base hours / [1-Total Shrinkage] [Base hours = Forecast volume / planned TpH]
	SELECT @NetRequiredHours = [dbo].[udf_GetNetReqHours](@SiteID,@CampaignID,@LobID,@Date)
	
	SELECT @ahc60=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,56)
	SELECT @ahc65=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,61)
	SELECT @ahc21=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,17)
	SELECT @ahc21Perc = @ahc21/100

	SELECT @ahc10=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,6)
	SELECT @ahc13=[dbo].[udf_GetAHCDatapointValue](@SiteID,@CampaignID,@LobID,@Date,9)
	--'= 'Assumptions and Headcount'!D60 / 40 * 'Assumptions and Headcount'!D65 / 1-'Assumptions and Headcount'!D21 * ('Assumptions and Headcount'!D10 / 'Assumptions and Headcount'!D13)
	
	SELECT @Value=((((@ahc60/ 40) * @ahc65) / NULLIF((1-@ahc21Perc),0)) * @ahc10) / NULLIF(@ahc13,0)
--@ahc60/ 40 * @ahc65 / NULLIF((1-@ahc21),0) * (@ahc10 / NULLIF(@ahc13,0))

	--SELECT @Value = @NetRequiredHours

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[udf_Dynamic_Straight]...';


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
	--= Forecasted Volume * Production AHT / 3600 / Derived Occupancy / 37.5/(1-(Overall Projected Production Shrinkage-Breaks of [Projected Production Shrinkage]))
	--'= ('Assumptions and Headcount'!D10 * 'Assumptions and Headcount'!D121) / 3600 / 'Assumptions and Headcount'!D58 / 37.5/(1-('Assumptions and Headcount'!D21-'Assumptions and Headcount'!D23))
	SELECT @Value=((((@ahc10 * @ahc121)/3600)/NULLIF(@ahc58Perc,0))/40)/NULLIF(@1minusahc21percminusahc23,0)

	RETURN ISNULL(@Value,0)
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetCampaignMonthlyExcessDeficit_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetCampaignMonthlyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE
		,@origstart DATE
		,@origend DATE
		,@origstartstring VARCHAR(25)
		,@origendstring VARCHAR(25)
		,@wfmstart VARCHAR(25)
		,@wfmend VARCHAR(25)

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @origstart = @startdate
	SET @origend = @enddate

	SET @origstartstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8))
	SET @origendstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	SET @wfmstart = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8)) 
	SET @wfmend = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @origstart AND @origend) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Campaign],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT w.CampaignID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
					 END [Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE([Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 AND w.DatapointID=23
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Campaign] s ON s.ID=A.CampaignID
		WHERE 1=1 
		ORDER BY s.Name
	'
	EXECUTE( @select )
END
GO
PRINT N'Altering [dbo].[wfmpcp_GetSiteMonthlyExcessDeficit_sp]...';


GO
ALTER PROCEDURE [dbo].[wfmpcp_GetSiteMonthlyExcessDeficit_sp]
	@Start NVARCHAR(20) = ''
	,@End  NVARCHAR(20) = ''
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
		,@select  AS NVARCHAR(MAX)
		,@startdate DATE
		,@enddate DATE
		,@origstart DATE
		,@origend DATE
		,@origstartstring VARCHAR(25)
		,@origendstring VARCHAR(25)
		,@wfmstart VARCHAR(25)
		,@wfmend VARCHAR(25)

	IF(@Start = '' AND @End = '')
	BEGIN	
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) 
		SET @enddate = DATEADD(DAY,-1,DATEADD(MONTH,3,@startdate))
	
	END
	ELSE
	BEGIN
		SET @startdate = DATEADD(m, DATEDIFF(m, 0, CAST( @Start AS DATE)), 0) 
		SET @enddate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST( @End AS DATE))+1,0))
	END

	SET @origstart = @startdate
	SET @origend = @enddate

	SET @origstartstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8))
	SET @origendstring = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))
	
	SET @startdate = [dbo].[udf_GetFirstMondayOfMonth](@startdate)
	SET @enddate = [dbo].[udf_GetLastMondayOfMonth](@enddate)

	SET @wfmstart = UPPER(RIGHT(CONVERT(VARCHAR(25), @startdate, 106), 8)) 
	SET @wfmend = UPPER(RIGHT(CONVERT(VARCHAR(25), @enddate, 106), 8))

	DECLARE @tblDate AS TABLE
	(
		[Date] DATE
	)
	INSERT INTO @tblDate ([Date])
	SELECT DISTINCT( CAST( UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8)) AS DATE) )
	FROM WeeklyHiringDatapoint
	WHERE ([Date] BETWEEN @origstart AND @origend) 

	SELECT @cols = STUFF((SELECT ',' + QUOTENAME(UPPER(RIGHT(CONVERT(VARCHAR, [Date], 106), 8))) 
								FROM @tblDate
								ORDER BY [Date]
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

	SET @select = '
		SELECT s.Name [Site],' + @cols +'
		FROM (
			SELECT *
			FROM
			(
				SELECT w.SiteID
					,CASE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
						WHEN ''' + @wfmstart + ''' THEN ''' + @origstartstring + ''' 
						WHEN ''' + @wfmend + ''' THEN ''' + @origendstring + '''
						ELSE UPPER(RIGHT(CONVERT(VARCHAR, w.[Date], 106), 8))
					 END [Date]
					,CEILING(CAST(ISNULL(NULLIF(LTRIM(RTRIM(REPLACE(w.[Data],''%'',''''))),''''),''0'') AS DECIMAL)) [Data]
				FROM WeeklyStaffDatapoint w
				INNER JOIN [Site] s ON s.ID=w.SiteID
				INNER JOIN [Campaign] c ON c.ID=w.CampaignID
				INNER JOIN [LoB] l ON l.ID=w.LoBID
				WHERE 1=1 AND s.Active=1 AND c.Active=1 AND l.Active=1 
					AND w.DatapointID=23
					AND (w.[Date] BETWEEN ''' + CAST(@startdate AS NVARCHAR) + ''' AND ''' + CAST(@enddate AS NVARCHAR) +''') 
			) x		
			PIVOT
			(
				SUM(Data)
				FOR [Date] IN (' + @cols +')
			)p
		) A
		INNER JOIN [Site] s ON s.ID=A.SiteID
		WHERE 1=1 
		ORDER BY s.Name
	'
	EXECUTE( @select )
END
GO
PRINT N'Update complete.';


GO
