/******************************
** File: Buildscript_1.00.043.sql
** Name: Buildscript_1.00.043
** Auth: McNiel Viray
** Date: 27 July 2017
**************************
** Change History
**************************
** Create data for Summary Datapoint
** Execute [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]
*******************************/
USE WFMPCP
GO

INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target Service Level','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Projected Service Level','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Service Level','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Forecast','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Offered','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Handled','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Capacity','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Volume Variance (Offered vs Forecast)','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target AHT','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual AHT','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('AHT Variance (Percentage to Goal)','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target Production Hours','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Production Hours','Formula',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Production Hours Variance','Formula',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Billable Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Required Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Production Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Nesting Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Training Headcount','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Billable Excess/Deficits','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Required Excess/Deficits','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Production Attrition','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Nesting + Training Attrition','Formula',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Nesting Attrition','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Training Attrition','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Total Target Shrinkage','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target In-center Shrinkage','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target Out-of center Shrinkage','',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Total Actual Shrinkage','',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual In-center Shrinkage','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Out-of center Shrinkage','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Shrinkage Variance (Target - Actual)','Formula',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Target Occupancy','Reference',1,'McNiel Viray',GETDATE())
INSERT INTO SummaryDatapoint([Name],DataType,SortOrder,CreatedBy,DateCreated)
VALUES('Actual Occupancy','Reference',1,'McNiel Viray',GETDATE())

GO

PRINT 'Execute [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]'
GO
EXEC [dbo].[wfmpcp_CreateWeeklySummaryDatapoint_sp]
GO
