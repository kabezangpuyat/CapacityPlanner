CREATE PROCEDURE [dbo].[mgmtsp_IncrementDbVersion]
(
	@i_Major INT = NULL,
	@i_Minor INT = NULL,
	@i_Build INT = NULL
)
AS
	BEGIN
		SET NOCOUNT ON
	
		DECLARE @m_CurrentMajor INT,
				@m_CurrentMinor INT,
				@m_CurrentBuild INT,
				@m_ID INT,
				@m_Error INT,
				@m_NewMajor INT,
				@m_NewMinor INT,
				@m_NewBuild INT
		
		SELECT	@m_CurrentMajor = Major,
				@m_CurrentMinor = Minor,
				@m_CurrentBuild = Build,
				@m_NewMajor = @i_Major,
				@m_NewMinor = @i_Minor,
				@m_NewBuild = @i_Build,
				@m_Error = 0
		FROM	[mgmt_DbVersions]
		WHERE	CurrentVersion = 1
		
		IF @m_NewMajor is null
			BEGIN
				SELECT	@m_NewMajor = @m_CurrentMajor				

				IF @m_NewMinor is null
					BEGIN
						SELECT	@m_NewMinor = @m_CurrentMinor

						IF @m_NewBuild is null
							BEGIN
								SELECT	@m_NewBuild = @m_CurrentBuild + 1
							END
					END
				ELSE
					BEGIN
						IF @m_NewMinor <> @m_CurrentMinor
							BEGIN
								SELECT	@m_NewBuild = 0
							END
					END
			END
		ELSE
			BEGIN
				IF @m_NewMajor <> @m_CurrentMajor
					BEGIN
						SELECT	@m_NewMinor = 0,
								@m_NewBuild = 0
					END
				IF @m_NewMinor <> @m_CurrentMinor
							BEGIN
								SELECT	@m_NewBuild = 0
							END
			END
		
		IF (	( (	@m_CurrentBuild = @m_NewBuild - 1 ) and (@m_CurrentMinor = @m_NewMinor) and (@m_CurrentMajor = @m_NewMajor))
			 or	( (	@m_CurrentMinor = @m_NewMinor - 1 ) and (@m_CurrentMajor = @m_NewMajor) )
			 or	(	@m_CurrentMajor = @m_NewMajor - 1 )	)
			BEGIN
				
				UPDATE	[mgmt_DbVersions]
				SET		CurrentVersion = 0
				WHERE	CurrentVersion = 1
				
				INSERT	[mgmt_DbVersions]
				(	Major,
					Minor,
					Build		)
				VALUES
				(	@m_NewMajor,
					@m_NewMinor,
					@m_NewBuild	)
					
				SELECT	Major,
						Minor,
						Build,
						DeployDate
				FROM	[mgmt_DbVersions]
				WHERE	CurrentVersion = 1
			END
		ELSE
			BEGIN
				-- if build number in db is not 1 less than new value build
				-- scripts are being applied out of order - Throw error so 
				-- rest of work can be skipped.
				SELECT	@m_Error = 1
				GOTO ToReTuRn			
			END
				
ToReTuRn: 
		
		RETURN @m_Error
	END


