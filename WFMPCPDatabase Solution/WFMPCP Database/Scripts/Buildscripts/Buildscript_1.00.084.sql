/******************************
** File: Buildscript_1.00.084.sql
** Name: Buildscript_1.00.084
** Auth: McNiel Viray	
** Date: 08 March 2018
**************************
** Change History
**************************
**
*******************************/
USE WFMPCP
GO
UPDATE Datapoint
SET [Name] = [Name] + ' <span style="color:red;">*</span>'
WHERE ID IN (2,6,10,19,20,21,22,24,25,54,
56,61,67,82,92,93)
GO
