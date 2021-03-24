/******************************
** File: Buildscript_1.00.105.sql
** Name: Buildscript_1.00.105
** Auth: McNiel Viray
** Date: 22 April 2019
**************************
** Change History
**************************
** modify udf_ErlangCFormula, added shrinkage as input parameter
*******************************/
USE WFMPCP
GO

DECLARE @rc INT

Exec @rc = mgmtsp_IncrementDBVersion
	@i_Major = 1,
	@i_Minor = 0,
	@i_Build = 105

IF @rc <> 0
BEGIN
	RAISERROR('Build Being Applied in wrong order', 20, 101)  WITH LOG
	RETURN
END

GO




DROP FUNCTION [dbo].[udf_ErlangCFormula]
GO

CREATE FUNCTION [dbo].[udf_ErlangCFormula]
(
     @NumberOfCalls NUMERIC(10,3)
	,@AHTInSeconds NUMERIC(10,3)
	,@RequiredServiceLevelPerc NUMERIC(10,3)
	,@TargetAnswerTimeInSeconds NUMERIC(10,3)
	,@ShrinkagePerc NUMERIC(18,3)
	,@NewN NUMERIC = NULL
)
RETURNS @returntable TABLE
(
	NumberOfAgentsRequired NUMERIC(18,0)
	,ServiceLevel NUMERIC(18,2)
	,ServiceLevelPerc NUMERIC(18,2)
	,[Pw/Erlang] NUMERIC(18,2)
	,ProbabilityOfCallToWaitPerc NUMERIC(18,2)
	,ASA NUMERIC(18,4)
	,ImmediateAnswerPerc NUMERIC(18,2)
	,TargetAnswerTimeInSeconds NUMERIC(10,3)
	,AHTInSeconds NUMERIC(10,3)	
	,RequiredServiceLevelPerc NUMERIC(10,3)
	,N NUMERIC(18,0)
	,X NUMERIC(18,3)
	,Y NUMERIC(18,2)
	,A NUMERIC(18,0)
	,AHTSec  NUMERIC(10,3)	
	,OccupancyPerc NUMERIC(18,2)	
)
AS
BEGIN

	DECLARE @A NUMERIC -- TRAFFIC INTESITY / ERLANG
		,@N NUMERIC -- RAW NUMBER OF AGENTS REQUIRED
		,@NumberOfCallsPerHour NUMERIC
		,@ServiceLevelPerc NUMERIC(10,3)=0
		,@X NUMERIC(18,3)
		,@Y NUMERIC(18,3)
		,@Pw NUMERIC(18,2)
		,@PwPerc NUMERIC(18,2)
		,@SL NUMERIC(18,2)
		,@SLPerc NUMERIC(18,2)
		,@ASA NUMERIC(18,2) --Average Speed of Answer
		,@ImmediateAnswerPerc NUMERIC(18,2)
		,@OccupancyPerc NUMERIC(18,2)
		,@NumberOfAgentsRequired NUMERIC(18,0)

	--2. Work Out the Number of Calls Per Hour
	SET @NumberOfCallsPerHour = @NumberOfCalls
	
	--3. Work Out the Traffic Intensity (A)
	DECLARE @AHTInMinutes NUMERIC(10,3)=@AHTInSeconds/60
	SET  @A = (@NumberOfCallsPerHour*(@AHTInMinutes))/60
	
	--4. Estimate the Raw Number of Agents Required (N)
	--   Initial value is A+1
	--   TODO: loop until we meet @RequiredServiceLevelPerc compare to @ServiceLevelPerc
	SET @N=ISNULL(@NewN,(@A+1))
	
	
	--5. Calculate the Erlang Formula for Probability a Call Waits (SKIP)
	--6. Work Out N! (N Factorial) (SKIP)
	--7. Be Careful With Large Factorials (SKIP)
	--                           n
	--8. Work Out the Powers – A   (SKIP) 
	--9. Let’s Simplify the Erlang C Formula
	--       X  / ( Y + X )


	--10. Let’s Work Out the Top Row of the Erlang Formula (X)
	--NUMERATOR FIRST (X)
	--   n
	-- A      *  N
	--___       ___
	-- N!        N-A

	DECLARE @NumeratorA NUMERIC(10,3)
			,@NumeratorB NUMERIC(10,3)			

	SET @NumeratorA = POWER(@A,@N)/[dbo].[udf_Fact](@N);
	SET @NumeratorB = @N/NULLIF((@N-@A),0);
	SET @X = @NumeratorA*@NumeratorB;

	---11. Work Out the Sum of a Series (Y) or ΣApowerofI/i!
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

	--12. Put X and Y into the Erlang C Formula (The probability a call has to wait)
	SET @Pw = @X/NULLIF((@Y+@X),0)
	SET @PwPerc = @Pw*100


	--13. Calculate the Service Level
		-- 13.1 Let’s work out -(N – A) * (TargetTime / AHT)
		DECLARE @exponent NUMERIC(18,3)
		SET @exponent = -((@N-@A)*(@TargetAnswerTimeInSeconds/@AHTInSeconds))
		
	--SELECT @exponent,@TargetAnswerTimeInSeconds,@AHTInSeconds,(@TargetAnswerTimeInSeconds/@AHTInSeconds)
	SET @SL = 1-(@Pw*EXP(@exponent))
	SET @SLPerc = @SL*100

	IF(@SLPerc<@RequiredServiceLevelPerc)
	BEGIN
		DECLARE @NIncrement NUMERIC 
		SET @NIncrement = @N + 1

		INSERT @returntable
		SELECT * FROM [dbo].[udf_ErlangCFormula](@NumberOfCalls,@AHTInSeconds,@RequiredServiceLevelPerc,@TargetAnswerTimeInSeconds,@ShrinkagePerc,@NIncrement)
	END
	ELSE
	BEGIN

		--15.  Average Speed of Answer (ASA)
		-- ASA = Pw(AHT)/(No.of Agents-Traffic Intesity)
		SET @ASA = (@Pw*@AHTInSeconds)/(@N-@A)

		--16. Percentage of Calls Answered Immediately
		--Immediate Answer = (1-Pw)x100
		SET @ImmediateAnswerPerc = (1-@Pw)*100

		--17. Check Maximum Occupancy
		--Occupancy = (([TrafficIntensity or A])/[RawAgents or N] )* 100
		SET @OccupancyPerc = (@A/@N) * 100
		IF @OccupancyPerc>85
		BEGIN
			SET @OccupancyPerc= @A/(@OccupancyPerc/100)
		END

		--18. Factor In Shrinkage
		--DECLARE @ShrinkagePerc NUMERIC(18,3) = 30 --The industry average is around 30–35%, in this case we used 30%. Note that we can change it
		--NumberOfAgentsRequired = [Raw Agents or N]/(1-(Shrinkage/100))
		SET @NumberOfAgentsRequired = @N/(1-(@ShrinkagePerc/100))

		DELETE FROM @returntable

		INSERT @returntable
		SELECT 
			@NumberOfAgentsRequired
			,@SL ServiceLevel
			,@SLPerc [Service Level %]
		    ,@Pw [Pw/Erlang/Probability Call has to wait]
			,@PwPerc PwPerc
			,@ASA ASA
			,@ImmediateAnswerPerc ImmediateAnswerPerc
			,@TargetAnswerTimeInSeconds [ServiceTime(sec)]
			,@AHTInSeconds [AHT (sec)]			
			,@RequiredServiceLevelPerc [TargetServiceLevel %]			
			,@N [FTE or N]
			,@X X
			,@Y Y
			,@A A
			,@AHTInSeconds  AHTSec			
			,@OccupancyPerc
			
	END

	

	RETURN
END
GO
