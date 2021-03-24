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
	