-- Section: Tracking Daily Calories of Users --

-- This section examines whether the daily and hourly tables represent the same data.
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
    [Portfolio Projects].[Daily_Tables].[dailyCalories_merged_Apr_May] AS daily
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
	[Portfolio Projects].[Daily_Tables].[sleepDay_merged_Apr_May]

-- Inspecting the data to see how to find any patterns or inconsistencies
SELECT 
	DISTINCT Id
    ,CAST(SleepDay AS DATE) AS SleepDate
    ,ROUND(CAST(TotalMinutesAsleep / 60.0 AS FLOAT), 1) AS TotalHoursAsleep
    ,ROUND(CAST(TotalTimeInBed / 60.0 AS FLOAT), 1) AS TotalHoursInBed
FROM 
	[Portfolio Projects].[Daily_Tables].[sleepDay_merged_Apr_May]
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
        [Portfolio Projects].[Daily_Tables].[sleepDay_merged_Apr_May]
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

-- Only 16 out of 35 users track their sleep consistently, 7 have tried it and stopped. 

--------------------------------------------------------------------------------------------------------------

-- Section: Usage Analysis of Activity tracking.

-- This section focuses on the number of users that utilize different functions of the smart device.

-- The code is repeated for the two time periods. It does the following.
-- The following CTE counts the number of days each user actively used the activity tracking function.
-- Display users who use the activity tracker consistently (more than 15 days per month)

-- March to April
WITH acte1 AS (
    SELECT
        Id,
        COUNT(Id) AS NoOfRecords
    FROM
        [Portfolio Projects].[Daily_Tables].[dailyActivity_merged_Mar_Apr]
    WHERE
        SedentaryMinutes <> 1440 -- Filter out records where the device was not worn (1440 minutes = 24 hours)
    GROUP BY 
        Id
)
SELECT
    *
FROM 
    acte1 
ORDER BY 
	NoOfRecords
WHERE
    NoOfRecords > 15; 

-- April to May
WITH acte2 AS (
    SELECT
        Id,
        COUNT(Id) AS NoOfRecords
    FROM
        [Portfolio Projects].Daily_Tables.dailyActivity_merged_Apr_May
    WHERE
        SedentaryMinutes <> 1440 -- Filter out records where the device was not worn (1440 minutes = 24 hours)
    GROUP BY 
        Id
)
SELECT
    *
FROM 
    acte2
WHERE
    NoOfRecords > 15;


-- Verify the total number of records from the CTE matches the table rows
SELECT
    SUM(NoOfRecords) AS TotalRecords
FROM 
    acte;

-- Display all records from the daily activity table for comparison

SELECT
    DISTINCT(Id)
FROM
	[Portfolio Projects].[Daily_Tables].[dailyActivity_merged_Mar_Apr]

SELECT
    DISTINCT(Id)
FROM
	[Portfolio Projects].[Daily_Tables].[dailyActivity_merged_Apr_May]

-- Result: 
-- 4 out of 35 users utilised the Activity Tracker function from March to April. However, ALL 35 tried it.
-- 32 out of 35 users utilised the Activity Tracker function from April to May.


-- Conclusion:
-- The Activity Tracker is one of the main functionalities used by the majority of smart device users.
-- The function might need some getting used to before users can stay consistent.
-- This indicates its importance and frequent usage among the users.

--------------------------------------------------------------------------------------------------------------

-- Section: Usage Analysis of Heart Rate Tracking

-- This section focuses on the number of users utilizing the heart rate tracking function.
-- The below queries retrieve the number of unique users who used heart rate tracking.

-- March to April
SELECT 
    DISTINCT(Id)
FROM
    [Portfolio Projects].[dbo].[heartrate_minutes_merged_Mar_Apr]

-- April to May
SELECT 
    DISTINCT(Id)
FROM
    [Portfolio Projects].[dbo].[heartrate_minutes_merged_Apr_May]

-- Result: 
-- 13 out of 35 users used the heart rate tracking function in March - April.
-- 7 out of 35 users used it in April - May.

-- Conclusion:
-- The heart rate tracking function is less popular than other more conventional functions.

--------------------------------------------------------------------------------------------------------------

-- Section: Usage and Analysis of Calorie Tracking.

-- The code is repeated for the two time periods. It does the following.
-- CTE to convert the hourly table to daily.
-- Display users who use the calorie tracker consistently (more than 15 days per month)

-- March to April
WITH HtoDCTE1 AS (
    SELECT
        Id,
        CAST(ActivityHour AS DATE) AS ActivityDateCTE,
        SUM(Calories) AS ConvertedCalories
    FROM 
        [Portfolio Projects].[Hourly_Tables].[hourlyCalories_merged_Mar_Apr]
    GROUP BY
        Id,
        CAST(ActivityHour AS DATE)
)
SELECT 
	Id
FROM 
	HtoDCTE1
GROUP BY
	Id
HAVING
	COUNT(Id) > 15

-- April to May
WITH HtoDCTE2 AS (
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
SELECT 
	Id
FROM 
	HtoDCTE2
GROUP BY
	Id
HAVING
	COUNT(Id) > 15

-- Result: 
-- 33 out of 35 users used the heart rate tracking function in March - April.
-- 32 out of 35 users used it in April - May.

-- Conclusion:
-- The majority of users also use calorie tracking. 
-- It is possible that activity tracking covers other functions such as Calories, Steps, Distance and intensity. 

--------------------------------------------------------------------------------------------------------------

-- Section: Usage and Analysis of Weight and BMI Tracking.

-- Research has shown that people weighting themselves more than once a week have more control over their weight long term.
-- The code below shows individuals that use the Weight and BMI functionality 1 or more times a week. 


-- March to April
SELECT
	Id
	,COUNT(Id)
FROM
	[Portfolio Projects].[dbo].[weightLogInfo_merged_Mar_Apr]
GROUP BY 
	Id
HAVING
	COUNT(Id) >= 4

-- April to May
SELECT
	Id
	,COUNT(Id)
FROM
	[Portfolio Projects].[dbo].[weightLogInfo_merged_Apr_May]
GROUP BY 
	Id
HAVING
	COUNT(Id) >= 4

-- Result: 
-- 2 out of 35 utilised the Weight and BMI functionality consistently in March to April. 11 out of 35 tried it at least once.
-- 3 out of 35 utilised the Weight and BMI functionality consistently in April to May. 8 out of 35 tried it at least once.
-- One user logged all 30 days from April to May. Most of the users have 1-2 logs per month.

-- Conclusion:
-- Weight and BMI logging has a small userbase but there are some really consistent users that enjoy this feature.

--------------------------------------------------------------------------------------------------------------
	
-- Section: Usage and Analysis of MET Tracking.

-- The code below shows individuals that use the MET functionality regularly.
-- A CTE will be used to convert the minute data to daily data. This will make filtering the results easier. 
-- Users of MET with less than 15 days a month will be filtered out.

-- March to April
WITH dailymet1 AS (
SELECT
	Id
	,CAST(ActivityMinute AS DATE) AS newdate
FROM
	[Portfolio Projects].[MinuteTables].[minuteMETsNarrow_merged_Mar_Apr]
GROUP BY 
	Id
	,CAST(ActivityMinute AS DATE)
)
SELECT
	Id
FROM
	dailymet1
GROUP BY
	Id
HAVING 
	COUNT(Id) > 15

	
-- April to May
WITH dailymet2 AS (
SELECT
	Id
	,CAST(ActivityMinute AS DATE) AS newdate
FROM
	[Portfolio Projects].[MinuteTables].[minuteMETsNarrow_merged_Mar_Apr]
GROUP BY 
	Id
	,CAST(ActivityMinute AS DATE)
)
SELECT
	Id
FROM
	dailymet2
GROUP BY
	Id
HAVING 
	COUNT(Id) > 15

-- Result: 
-- 24 out of 35 users utilise the MET function consistently. 
-- An additional 2 have used it less frequently.

-- Conclusion:
-- The MET feature is one that is frequently used. Therefore it is worth investing resources to.

/* ////////////////////////////////////////////////////////////////////////////////////////////// */

-- Ranking Users by Activity Level
-- This will show what how active the userbase is in order to cater to their needs.

SELECT 
	Id
	,ROUND(AVG(TotalSteps), 2) AS AvgTotalSteps
	,ROUND(AVG(TotalDistance), 2) AS AvgTotalDistance
	,(1440 - AVG(SedentaryMinutes)) AS AvgActiveMin
	,AVG(FairlyActiveMinutes) AS AvgModActiveMin -- 30 minutes of moderate exercise is advised for general fitness
	,AVG(LightlyActiveMinutes) AS AvgLightActiveMin -- For reference 
	,AVG(Calories) AS AvgCalories
FROM	
	[Portfolio Projects].[Daily_Tables].[dailyActivity_merged_Apr_May]
GROUP BY 
	Id
ORDER BY 
	5 DESC
	,4
	,2
	,3 
-- Comment out the code below to filter for each activity group.
--OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY -- Very Active Users: Top 5
--OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY -- Moderately Active Users: Ranked 6 to 10
--OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY -- Average Active Users: Ranked 11 to 20
--OFFSET 20 ROWS FETCH NEXT 13 ROWS ONLY -- Sedentary Users: Ranked below 20

-- Result: 
-- Very Active: Top 5 users
-- Moderately Active: Users ranked 6 to 10
-- Average Active: Users ranked 11 to 20
-- Sedentary: Users ranked below 20

-- Conclusion:
-- The activity of users is very mixed.
-- Therefore, the needs of all activity groups should be considered when implementing features to the Leaf smart device.

--------------------------------------------------------------------------------------------------------------

-- Section: Relationships between sleep and calorie output.

-- Exploring data to find the relationship (if any) between sleep and calorie output.

WITH RankedSleepData AS ( 
    SELECT 
        Id
		,SleepDay
        ,TotalMinutesAsleep / 60.0 AS TotalHoursAsleep
		,TotalTimeInBed / 60.0 AS TotalHoursInBed
		,PERCENT_RANK() OVER (ORDER BY TotalMinutesAsleep / 60.0) AS PercentRank
    FROM 
        [Portfolio Projects].[Daily_Tables].[sleepDay_merged_Apr_May]
)
, avgcal AS (
	SELECT
		Id
		,AVG(Calories) AS CalPerDay
	FROM
		[Portfolio Projects].[Daily_Tables].[dailyCalories_merged_Apr_May]
	GROUP BY
		Id
)
SELECT 
	sleep.Id
    ,ROUND(CAST(AVG(sleep.TotalHoursAsleep) AS FLOAT),1) AS TrimmedMeanTotalHoursAsleep
	--,ROUND(CAST(AVG(sleep.TotalHoursInBed) AS FLOAT),1) AS TrimmedMeanTotalHoursInBed -- Remove comment for TotalHoursInBed to be included.
	,CalPerDay
FROM 
	RankedSleepData AS sleep
JOIN avgcal AS cal ON 
	sleep.Id = cal.Id
WHERE
	PercentRank BETWEEN 0.005 AND 0.995  -- Exclude the top and bottom 0.5%
GROUP BY
	sleep.Id, CalPerDay
HAVING
	COUNT(sleep.Id) > 5
ORDER BY
	TrimmedMeanTotalHoursAsleep DESC

-- Result:
-- No significant link between hours of sleep and calorie output

-- Conclusion:
-- Explore other avenues to encourage use of the sleep feature.

--------------------------------------------------------------------------------------------------------------

-- Section: Relationships between sleep, activity and self-tracking consistency

-- Comparing the activity and sleep of users.
-- Additionally comparing their tracking behaviours between sleep and activity.

WITH RankedSleepData AS (
    SELECT 
        Id,
        SleepDay,
        TotalMinutesAsleep / 60.0 AS TotalHoursAsleep,
        TotalTimeInBed / 60.0 AS TotalHoursInBed,
        PERCENT_RANK() OVER (ORDER BY TotalMinutesAsleep / 60.0) AS PercentRank
    FROM 
        [Portfolio Projects].[Daily_Tables].[sleepDay_merged_Apr_May]
),
AvgActivity AS (
    SELECT 
        Id,
        ROUND(AVG(TotalSteps), 2) AS AvgTotalSteps,
        ROUND(AVG(TotalDistance), 2) AS AvgTotalDistance,
        (1440 - AVG(SedentaryMinutes)) AS AvgActiveMin,
        AVG(FairlyActiveMinutes) AS AvgModActiveMin,
        AVG(LightlyActiveMinutes) AS AvgLightActiveMin,
        AVG(Calories) AS AvgCalories
    FROM    
        [Portfolio Projects].[Daily_Tables].[dailyActivity_merged_Apr_May]
    GROUP BY 
        Id
)
SELECT 
    act.Id,
    AvgTotalSteps,
    AvgTotalDistance,
    AvgActiveMin,
    AvgModActiveMin,
    AvgLightActiveMin,
    AvgCalories,
    ROUND(CAST(AVG(sleep.TotalHoursAsleep) AS FLOAT), 1) AS TrimmedMeanTotalHoursAsleep,
    COUNT(sleep.Id) AS SleepRecordCount -- To check the count of sleep records for each user
    -- ,ROUND(CAST(AVG(sleep.TotalHoursInBed) AS FLOAT), 1) AS TrimmedMeanTotalHoursInBed
FROM 
    AvgActivity AS act
LEFT JOIN RankedSleepData AS sleep ON 
    act.Id = sleep.Id
GROUP BY
    act.Id,
    AvgTotalSteps,
    AvgTotalDistance,
    AvgActiveMin,
    AvgModActiveMin,
    AvgLightActiveMin,
    AvgCalories
ORDER BY
    AvgModActiveMin DESC,
    AvgTotalSteps DESC,
    AvgTotalDistance DESC,
    TrimmedMeanTotalHoursAsleep DESC;

-- Results:
-- No significant relationship between sleep and activity from this data.
-- However there is a correlation between sleep tracking consistency and activity throughout the day.

-- Conclusion:
-- The relationship between sleep tracking consistency and activity should be examined more in depth
-- In addition to general tracking consistency and activity.
-- Adding a feature to encourage consistent tracking should be considered.
