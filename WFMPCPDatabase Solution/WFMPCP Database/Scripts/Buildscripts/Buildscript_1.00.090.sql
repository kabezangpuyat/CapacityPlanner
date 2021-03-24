/******************************
** File: Buildscript_1.00.090.sql
** Name: Buildscript_1.00.0090
** Auth: McNiel Viray
** Date: 24 July 2018
**************************
** Change History
**************************
** Corrections for Datapoints data type value
*******************************/
USE WFMPCP
GO

UPDATE Datapoint
SET Datatype='Inputted'
WHERE ID >= 131 

GO

UPDATE Datapoint
SET [Name]='Current Support HC'--Support HC
WHERE ID=16

GO

UPDATE Datapoint
SET Datatype='Inputted'
WHERE ID IN (70,71,72,82)

GO

UPDATE Datapoint
SET Datatype='Formula'
WHERE ID IN (83,84,85,92,93)
--92,93 original datatype = Inputted

GO



