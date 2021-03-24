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


