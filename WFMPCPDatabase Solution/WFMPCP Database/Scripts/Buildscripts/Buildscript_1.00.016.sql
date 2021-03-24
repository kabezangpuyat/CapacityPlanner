/******************************
** File: Buildscript_1.00.016.sql
** Name: Buildscript_1.00.016
** Auth: McNiel Viray
** Date: 24 May 2017
**************************
** Change History
**************************
** Change [dbo].[WeeklyAHDatapoint] column [Data] 
** data type from Float to NVARCHAR
*******************************/
USE WFMPCP
GO
PRINT N'Altering [dbo].[WeeklyAHDatapoint]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint] ALTER COLUMN [Data] NVARCHAR (200) NOT NULL;


GO
PRINT N'Creating [dbo].[DF_WeeklyAHDatapoint_Data]...';


GO
ALTER TABLE [dbo].[WeeklyAHDatapoint]
    ADD CONSTRAINT [DF_WeeklyAHDatapoint_Data] DEFAULT ('') FOR [Data];


GO
PRINT N'Refreshing [dbo].[wfmpcp_GetAssumptionsHeadcount_sp]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[wfmpcp_GetAssumptionsHeadcount_sp]';


GO
PRINT N'Update complete.';


GO