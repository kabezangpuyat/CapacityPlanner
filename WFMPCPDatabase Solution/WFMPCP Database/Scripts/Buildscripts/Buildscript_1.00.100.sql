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