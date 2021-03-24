CREATE FUNCTION [dbo].[udf_GetLastMondayOfMonth]
(
	@Now DATE
)
RETURNS DATETIME
AS
BEGIN	
	DECLARE @LastDayOfMonth DATETIME
		,@Monday DATETIME
		,@DateDiff INT = 0 

	SELECT @LastDayOfMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Now)+1,0))
	SELECT @Monday = @LastDayOfMonth

	WHILE(UPPER( DATENAME(dw,@Monday) ) != 'MONDAY')
	BEGIN
		SET @Monday = DATEADD(DAY,-1,@Monday)
	END

	SET @DateDiff = DATEDIFF(DAY,@Monday,@LastDayOfMonth) + 1

	IF(@DateDiff < 4)
	BEGIN
		SET @Monday = DATEADD(DAY,-1,@Monday)
		WHILE(UPPER( DATENAME(dw,@Monday) ) != 'MONDAY')
		BEGIN
			SET @Monday = DATEADD(DAY,-1,@Monday)
		END
	END
	
	RETURN @Monday
END