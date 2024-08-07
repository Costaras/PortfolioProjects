--PREPARATION PROCESS--

-- Inspecting tables for nulls, missing values and invalid values
SELECT TOP (1000) [Id]
      ,[SleepDay]
      ,[TotalSleepRecords]
      ,[TotalMinutesAsleep]
      ,[TotalTimeInBed]
FROM [Portfolio Projects].[dbo].[sleepDay_merged_Apr_May]

-- Converting data types from nvarchar(max) to reduce future errors and increase performace  

ALTER TABLE dbo.sleepDay_merged_Apr_May
ALTER COLUMN Id BIGINT;
ALTER TABLE dbo.sleepDay_merged_Apr_May
ALTER COLUMN SleepDay DATETIME;
ALTER TABLE dbo.sleepDay_merged_Apr_May
ALTER COLUMN TotalSleepRecords INT;
ALTER TABLE dbo.sleepDay_merged_Apr_May
ALTER COLUMN TotalMinutesAsleep INT;
ALTER TABLE dbo.sleepDay_merged_Apr_May
ALTER COLUMN TotalTimeInBed INT;

-- Tables dbo.weightLogInfo_merged_Apr_May and dbo.weightLogInfo_merged_Mar_Apr 
-- had column LogId which due to its scientific format caused issues.

SELECT TOP (1000) [Id]
      ,[Date]
      ,[WeightKg]
      ,[WeightPounds]
      ,[Fat]
      ,[BMI]
      ,[IsManualReport]
      ,[LogId]
  FROM [Portfolio Projects].[dbo].[weightLogInfo_merged_Mar_Apr]

ALTER TABLE dbo.weightLogInfo_merged_Mar_Apr
ALTER COLUMN LogId BIGINT;

-- Checking for non-numerics and NULLS
SELECT *
FROM dbo.weightLogInfo_merged_Apr_May
WHERE ISNUMERIC(LogId) = 0;

SELECT *
FROM dbo.weightLogInfo_merged_Apr_May
WHERE TRY_CAST(LogId AS BIGINT) IS NULL;

-- Adding a new LogId_New to populate with the transformed LogID since the original column could not be converted
ALTER TABLE dbo.weightLogInfo_merged_Apr_May
ADD LogId_New BIGINT;

-- Updating LogId_New by casting LogId to FLOAT first, then to BIGINT (WORKED)
UPDATE dbo.weightLogInfo_merged_Apr_May
SET LogId_New = CAST(CAST(LogId AS FLOAT) AS BIGINT);

-- Selecting top 1000 records to check the transformation
SELECT TOP 1000 Id, LogId, LogId_New
FROM dbo.weightLogInfo_merged_Apr_May;

-- Since it would not have any effect on the analysis, it was decided that the extra zeros were redundant.
-- So LogId_New was kept as is with 5 less zeroes than the original.

-- Turned LogId_New into the new LogId
ALTER TABLE dbo.weightLogInfo_merged_Apr_May
DROP COLUMN LogId;
EXEC sp_rename 'dbo.weightLogInfo_merged_Apr_May.LogId_New', 'LogId', 'COLUMN';
[dbo].[weightLogInfo_merged_Mar_Apr]

/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

--CLEANING PROCESS--

-- Checking for unwanted NULL values in the table

DECLARE @tableName NVARCHAR(128) = 'Testing_Table';  -- Insert table name to be checked
DECLARE @schemaName NVARCHAR(128) = 'dbo';
DECLARE @nullCheckStatement NVARCHAR(MAX);

-- Generate the NULL check statement
SELECT @nullCheckStatement = STRING_AGG(COLUMN_NAME + ' IS NULL', ' OR ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schemaName AND TABLE_NAME = @tableName;

-- Print the NULL check statement to see how it looks
PRINT 'Generated NULL Check Statement:';
PRINT @nullCheckStatement;

-- Generate the final query
DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM ' + @schemaName + '.' + @tableName + ' WHERE ' + @nullCheckStatement;

-- Print the final query for debugging purposes
PRINT 'Generated SQL Query:';
PRINT @sql;

-- Execute the final query and display the results
EXEC sp_executesql @sql;

-- Table with NULL values created to test the script

CREATE TABLE Testing_Table (
	FakeID INT
	,FakeDate DATE
	,Fakenumber float
	,Fakeword nvarchar(50)
	)

INSERT INTO Testing_Table
VALUES
(1, '2020-02-15', 35.5, 'GIAGIA'),
(NULL, '2020-02-16', 35.6, 'GIAGI'),
(3, NULL, 35.7, 'GIAG'),
(4, '2020-02-18', NULL, 'GIA'),
(5, '2020-02-19', 35.8, NULL);

-- Testing_table gave all 4 rows that had NULL values in them 

-- No NULL values were found

/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

-- Creating stored procedures to FIND and DELETE duplicate rows --

-- Stored procedure that FINDS and DISPLAYS duplicates for inspection

CREATE PROCEDURE FindDuplicates
	@tableName NVARCHAR(128)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX);
	DECLARE @columns NVARCHAR(MAX);
	DECLARE @schema NVARCHAR(128);
    DECLARE @table NVARCHAR(128);

	-- Parse schema and table names

	SET @table = PARSENAME(@tableName, 1);
	SET @schema = PARSENAME(@tableName, 2);
	
    --Getting the list of columns in the specified table
	SELECT 
		@columns = STRING_AGG(COLUMN_NAME, ', ') WITHIN GROUP(ORDER BY ORDINAL_POSITION)
	FROM 
		INFORMATION_SCHEMA.COLUMNS
	WHERE 
		TABLE_NAME = @table
		AND TABLE_SCHEMA = @schema;

	-- Query that uses a CTE to label duplicate rows, then SELECTS all labeled duplicates
		SET @sql = N'
	;WITH dup_CTE AS(
		SELECT 
			ROW_NUMBER() OVER (PARTITION BY ' + @columns + ' ORDER BY (SELECT NULL)) AS Row_num, 
			*
		FROM
			' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + '  
	)
	-- Select duplicate rows to review
	SELECT
		*
	FROM 
		dup_CTE
	WHERE 
		Row_num > 1;
	';

	-- 	Print the dynamic SQL for debugging
	print @sql;

	-- Execute the dynamic SQL query
	EXEC sp_executesql @sql;
END;

-- Stored procedure that FINDS and DELETES duplicates, (meant to be used after FindDuplicates)

CREATE PROCEDURE DeleteDuplicates
	@tableName NVARCHAR(128)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX);
	DECLARE @columns NVARCHAR(MAX);
	DECLARE @schema NVARCHAR(128);
    DECLARE @table NVARCHAR(128);

	-- Parse schema and table names

	SET @table = PARSENAME(@tableName, 1);
	SET @schema = PARSENAME(@tableName, 2);
	
    --Getting the list of columns in the specified table
	SELECT 
		@columns = STRING_AGG(COLUMN_NAME, ', ') WITHIN GROUP(ORDER BY ORDINAL_POSITION)
	FROM 
		INFORMATION_SCHEMA.COLUMNS
	WHERE 
		TABLE_NAME = @table
		AND TABLE_SCHEMA = @schema;

	-- Query that uses a CTE to label duplicate rows, then DELETES all labeled duplicates
		SET @sql = N'
	;WITH dup_CTE AS(
		SELECT 
			ROW_NUMBER() OVER (PARTITION BY ' + @columns + ' ORDER BY (SELECT NULL)) AS Row_num,
			*
		FROM
			' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + '  
	)
	-- Delete duplicate rows to review
	DELETE 
	FROM
		' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + '
	WHERE (' + @columns + ') IN (
		SELECT 
			' + @columns + '
		FROM
			dup_CTE
		WHERE
			Row_num > 1
		);
	';

	-- 	Print the dynamic SQL for debugging
	print @sql;

	-- Execute the dynamic SQL query
	EXEC sp_executesql @sql;
END;

/*
    Execute to:
    1. FIND and INSPECT the duplicates
    2. DELETE duplicates AFTER VERIFYING they are indeed redundant duplicates

    Remember to back up tables before altering them.
*/

-- Find and inspect duplicates in the specified table
EXEC FindDuplicates '[Daily_Tables].[dailyActivity_merged_Apr_May]';

-- Delete duplicates after verification
EXEC DeleteDuplicates '[Daily_Tables].[dailyActivity_merged_Apr_May]';
