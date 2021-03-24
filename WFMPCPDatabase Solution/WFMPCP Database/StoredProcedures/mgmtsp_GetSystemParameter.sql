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