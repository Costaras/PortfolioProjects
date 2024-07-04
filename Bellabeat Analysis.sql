-- Section: Tracking Daily Calories of Users --

-- This section aims to examine if the daily and hourly tables represent the same data.
-- We will convert the hourly data to daily data and compare it with the existing daily data.

-- CTE to Convert Hourly Data to Daily Data
WITH HtoDCTE AS (
    SELECT
        Id,
        CAST(ActivityHour AS DATE) AS ActivityDateCTE,
        SUM(Calories) AS ConvertedCalories
    FROM 
        [Portfolio Projects].[Hourly_Tables].[hourlyCalories_merged_Apr_May]
    GROUP BY
        Id,
        CAST(ActivityHour AS DATE)
)

-- Join the Daily Table and the Converted Hourly Data to Identify Differences
SELECT 
    daily.Id,
    daily.ActivityDay,
    HtoDCTE.ActivityDateCTE,
    daily.Calories,
    HtoDCTE.ConvertedCalories
FROM 
    [Daily_Tables].[dailyCalories_merged_Apr_May] AS daily
JOIN HtoDCTE ON
    daily.Id = HtoDCTE.Id
WHERE
    daily.ActivityDay = HtoDCTE.ActivityDateCTE
    AND (daily.Calories > HtoDCTE.ConvertedCalories + 300 OR daily.Calories < HtoDCTE.ConvertedCalories - 300) -- OPTIONAL: Filter to see outliers OR use AND NOT to filter them OUT

-- Result: Daily and Hourly Data Comparison
-- The comparison shows that the daily and hourly tables represent the same data.
-- The hourly table is updated more frequently and has more consistent values.
-- Therefore, the converted hourly data (HtoDCTE) will be used instead of the daily table for further analysis.

-- Conclusion:
-- The hourly table provides more granular and accurate data.
-- For future analyses, we will rely on the hourly table converted to daily data as shown in HtoDCTE.

/* ////////////////////////////////////////////////////////////////////////////////////////////// */

-- Sections Below: Consistent Users of Each Function
-- These sections identify users who consistently use specific functions of the smart device.
-- Each section focuses on a different function and highlights users who have used the function regularly and correctly over the specified period.

	
-- Section: Tracking the sleep of the users -- 

SELECT
	*
FROM 
	[Daily_Tables].[sleepDay_merged_Apr_May]

-- Inspecting the data to see how to find any patterns, or inconsistencies
SELECT 
	DISTINCT Id
    ,CAST(SleepDay AS DATE) AS SleepDate
    ,ROUND(CAST(TotalMinutesAsleep / 60.0 AS FLOAT), 1) AS TotalHoursAsleep
    ,ROUND(CAST(TotalTimeInBed / 60.0 AS FLOAT), 1) AS TotalHoursInBed
FROM 
	[Daily_Tables].[sleepDay_merged_Apr_May]
ORDER BY 
	Id
	,TotalHoursAsleep
	ASC;

/* After inspection of the data it was found that sleep hours were varying but mostly consistent.
However, outliers from misuse of the sleep monitoring functionality or extreme cases were discovered. The results will be filtered below */

-- The code below gives a list of the average time of sleep from users that consistently used the sleep tracking functionality --

-- This CTE is ranking the hours of sleep in percentages and counts the number of rows for each Id
WITH RankedSleepData AS (
    SELECT 
        Id
        ,TotalMinutesAsleep / 60.0 AS TotalHoursAsleep
		,TotalTimeInBed / 60.0 AS TotalHoursInBed
		,PERCENT_RANK() OVER (ORDER BY TotalMinutesAsleep / 60.0) AS PercentRank -- Replicating the TRIMMEAN functionality usin percent rank
    FROM 
        [Daily_Tables].[sleepDay_merged_Apr_May]
)
SELECT 
	Id
    ,ROUND(CAST(AVG(TotalHoursAsleep) AS FLOAT),1) AS TrimmedMeanTotalHoursAsleep
	,ROUND(CAST(AVG(TotalHoursInBed) AS FLOAT),1) AS TrimmedMeanTotalHoursInBed
	,COUNT(Id) AS NoOfRecords
FROM 
    RankedSleepData
WHERE 
    PercentRank BETWEEN 0.005 AND 0.995  -- Exclude the top and bottom 0.5%
GROUP BY 
	Id
HAVING
	COUNT(Id) > 5
ORDER BY 
	TrimmedMeanTotalHoursAsleep

-- Only 16 out of 33 users track their sleep consistently, 7 have tried it and stopped. 

--------------------------------------------------------------------------------------------------------------

-- Section: Usage Analysis of Different Smart Device Functions

-- This section focuses on the number of users that utilize different functions of the smart device.

-- Activity Tracking
-- The following CTE counts the number of days each user actively used the activity tracking function.

WITH acte AS (
    SELECT
        Id,
        COUNT(Id) AS NoOfRecords
    FROM
        Daily_Tables.dailyActivity_merged_Apr_May
    WHERE
        SedentaryMinutes <> 1440 -- Filter out records where the device was not worn (1440 minutes = 24 hours)
    GROUP BY 
        Id
)

-- Display users who use the activity tracker consistently (more than 10 days)
SELECT
    *
FROM 
    acte
WHERE
    NoOfRecords > 10;

-- Verify the total number of records from the CTE matches the table rows
SELECT
    SUM(NoOfRecords) AS TotalRecords
FROM 
    acte;

-- Display all records from the daily activity table for comparison
SELECT
    *
FROM
    Daily_Tables.dailyActivity_merged_Apr_May;

-- Result: 32 out of 33 users utilize the Activity Tracker function.

-- Conclusion:
-- The Activity Tracker is one of the main functionalities used by the majority of smart device users.
-- This indicates its importance and frequent usage among the users.

--------------------------------------------------------------------------------------------------------------

-- Section: Usage Analysis of Heart Rate Tracking

-- This section focuses on the number of users utilizing the heart rate tracking function.

-- Heart Rate Tracking Usage

-- The below queries retrieve the number of unique users who used heart rate tracking.
-- March to April
SELECT 
    Id
FROM
    [dbo].[heartrate_minutes_merged_Mar_Apr]
GROUP BY
    Id;

-- April to May
SELECT 
    Id
FROM
    [dbo].[heartrate_minutes_merged_Apr_May]
GROUP BY
    Id;

-- Result: 
-- 13 out of 33 users used the heart rate tracking function in March - April.
-- 7 out of 33 users used it in April - May.

-- Conclusion:
-- The heart rate tracking function is not as popular as other more conventional functions.
