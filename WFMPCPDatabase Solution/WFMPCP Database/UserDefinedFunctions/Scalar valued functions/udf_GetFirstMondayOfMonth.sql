CREATE FUNCTION [dbo].[udf_GetFirstMondayOfMonth]
(
	@Now DATE
)
RETURNS DATETIME
AS
BEGIN	
	DECLARE @FirstDayOfMonth AS DATETIME
		,@Monday AS DATETIME
		,@ctr INT = 1
		,@Datename AS VARCHAR(20)


	SELECT @FirstDayOfMonth = DATEADD(m, DATEDIFF(m, 0, @Now), 0) 
	SELECT @Monday = @FirstDayOfMonth

	SELECT @Datename = UPPER( DATENAME(dw,@FirstDayOfMonth) )

	IF(@Datename = 'TUESDAY' OR @Datename = 'WEDNESDAY' OR @Datename = 'THURSDAY')
	BEGIN
		SET @ctr = -1;
	END

	WHILE(UPPER( DATENAME(dw,@Monday) ) != 'MONDAY')
	BEGIN
		SET @Monday = DATEADD(DAY,@ctr,@Monday)
	END

	RETURN @Monday
END