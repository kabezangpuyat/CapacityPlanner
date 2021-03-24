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

