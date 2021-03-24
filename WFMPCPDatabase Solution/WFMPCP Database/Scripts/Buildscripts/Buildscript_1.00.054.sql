/******************************
** File: Buildscript_1.00.054.sql
** Name: Buildscript_1.00.054
** Auth: McNiel Viray
** Date: 11 August 2017
**************************
** Change History
**************************
** Create scalar valued function to get First Monday and Last Monday of Month
*******************************/
USE WFMPCP
GO


PRINT N'Creating [dbo].[udf_GetFirstMondayOfMonth]...';


GO
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
GO
PRINT N'Creating [dbo].[udf_GetLastMondayOfMonth]...';


GO
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
GO
PRINT N'Update complete.';


GO
