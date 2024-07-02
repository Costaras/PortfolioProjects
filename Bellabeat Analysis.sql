-- Tracking the sleep of the users -- 

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

/* ////////////////////////////////////////////////////////////////////////////////////////////// */

-- Tracking Daily Calories of Users --

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
