SELECT *
FROM [Portfolio Project]..CovidVaccinations
  ORDER by 3, 4

SELECT * 
FROM [Portfolio Project]..CovidVaccinations
  ORDER BY 3, 4

-- Total Cases vs Total Deaths
-- Shows the likelyhood of death after contracting COVID-19 depending on the location and date

SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  ROUND((CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100, 6) AS DeathsPer100Cases
FROM [Portfolio Project]..CovidDeaths
  WHERE location = 'Greece'
  ORDER BY 1, 2

-- Total Cases vs Population
-- Shows what percentage of the population got infected

SELECT 
  location, 
  date, 
  total_cases, 
  population, 
  ROUND((CONVERT(float,total_cases)/CONVERT(float, population))*100,6) AS PopInfectedPercent
FROM [Portfolio Project]..CovidDeaths
  ORDER BY 1, 2

-- Highest infection ratios --
-- Ranks the countries with the top infection ratios in descending order.

WITH MaxCasesCTE AS (
  SELECT
    location,
    total_cases,
    population,
    date,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY CONVERT(float,total_cases) DESC) AS RowNum
  FROM
    [Portfolio Project]..CovidDeaths
)
SELECT
  location,
  total_cases AS HighestInfectionCount,
  population,
  date AS DateOfHighestInfection,
  ROUND((CONVERT(float, total_cases) / population) * 100, 6) AS MaxInfectedPercent
FROM
  MaxCasesCTE cte
WHERE
  cte.RowNum = 1 
ORDER BY
  5 DESC;

-- Highest DeathCount/Population ratio per country --
-- The worldwide DeathRate ranking of each country is also displayed. 

WITH MaxDeathsCTE AS (
  SELECT 
	location,
	date,
	total_deaths,
	population,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY CONVERT(float,total_deaths) DESC) AS RowNum
  FROM 
	[Portfolio Project]..CovidDeaths
),
DeathRankingCTE AS(
SELECT 
  location,
  total_deaths AS TotalDeaths,
  population,
  ROUND((CONVERT(float, total_deaths) / population) * 100, 3) AS DeathPerPopulation,
  date,
  RANK() OVER (ORDER BY (CONVERT(float, total_deaths) / population) * 100 DESC) AS RANKING
FROM
  MaxDeathsCTE
  WHERE 
  RowNum = 1
)
SELECT
  DR.location,
  DR.TotalDeaths,
  DR.population,
  DR.DeathPerPopulation,
  DR.Ranking
FROM
  DeathRankingCTE DR
WHERE -- Where statement can be used optionally when looking for a specific country
  DR.location = 'United States' OR location = 'Canada'; 

-- Continent Total Deathcount --

SELECT
  RANK () OVER (ORDER BY SUM(CONVERT(float, new_deaths)) DESC) AS RANKING,
  continent,
  SUM(CONVERT(float,new_deaths)) AS TotalDeathcount
FROM [Portfolio Project]..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY continent
  ORDER BY TotalDeathcount DESC

-- WorldCases, Deaths and Deathrate on each date --

SELECT 
  CAST(date AS date) AS Date,
  SUM(new_cases) AS WorldCases,
  SUM(CONVERT(float, new_deaths)) AS WorldDeaths,
  ROUND(SUM(CONVERT(float, new_deaths))/NULLIF(SUM(CONVERT(float, new_cases)), 0) * 100, 6) AS DeathsPer100Cases
FROM [Portfolio Project]..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY CAST(date AS DATE)
  ORDER BY Date

	-- Rolling WorldCases and WorldDeath counts can be added using a CTE. As well as the DeathRate up to the date stated.

	WITH GlobalCandD AS (
	SELECT 
	  CAST(date AS date) AS Date,
	  SUM(new_cases) AS WorldCases,
	  SUM(CONVERT(float, new_deaths)) AS WorldDeaths,
	  ROUND(SUM(CONVERT(float, new_deaths))/NULLIF(SUM(CONVERT(float, new_cases)), 0) * 100, 3) AS DeathsPer100Cases
	FROM [Portfolio Project]..CovidDeaths
	  WHERE continent IS NOT NULL
	  GROUP BY CAST(date AS DATE)
	),
	TotalGlobalCandD AS (
	SELECT 
	  Date,
	  SUM(WorldCases) OVER (ORDER BY Date) AS TotalGlobalCases, 
	  SUM(WorldDeaths) OVER (ORDER BY Date) AS TotalGlobalDeaths
	FROM GlobalCandD
	)
	SELECT *,
	  (TotalGlobalDeaths/NULLIF(TotalGlobalCases, 0))*100 AS CurrentDeathRate
	FROM TotalGlobalCandD
	  ORDER BY Date

-- Total Population vs Vaccinations (w/ Rolling Vaccination Sum) --

WITH RollingVaccinationSumCTE AS (
SELECT 
  dth.continent,
  dth.location,
  dth.date,
  dth.population,
  vac.new_vaccinations AS DailyVaccinations,
  SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS RollingVaccinationSum
FROM [Portfolio Project]..CovidDeaths dth
  JOIN [Portfolio Project]..CovidVaccinations vac
	ON dth.location = vac.location
	AND dth.date = vac.date
  WHERE dth.continent IS NOT NULL 
)
SELECT *
FROM RollingVaccinationSumCTE AS RLV
  WHERE RollingVaccinationSum IS NOT NULL
  ORDER BY 2, 3

-- Temp table created to make the use of subsequent select subqueries more convinient

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
  SELECT
    dth.continent,
    dth.location,
    dth.date,
    dth.population,
    vac.new_vaccinations AS DailyVaccinations,
    SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS RollingVaccinationSum
  FROM [Portfolio Project]..CovidDeaths dth
    JOIN [Portfolio Project]..CovidVaccinations vac
  	  ON dth.location = vac.location
	  AND dth.date = vac.date
    WHERE dth.continent IS NOT NULL 

SELECT *
FROM #PercentPopulationVaccinated
  WHERE RollingVaccinations IS NOT NULL
ORDER BY 2,3

SELECT Location, MAX(RollingVaccinations) AS TotalVaccinations
FROM #PercentPopulationVaccinated
GROUP BY Location
ORDER BY 2 DESC

SELECT *
FROM #PercentPopulationVaccinated
  WHERE Location = 'Canada' 
ORDER BY 2,3

-- Creating Views for later visualisation -- 

CREATE VIEW PercentPopulationVaccinated AS
  SELECT
    dth.continent,
    dth.location,
    dth.date,
    dth.population,
    vac.new_vaccinations AS DailyVaccinations,
    SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS RollingVaccinationSum
  FROM [Portfolio Project]..CovidDeaths dth
    JOIN [Portfolio Project]..CovidVaccinations vac
  	  ON dth.location = vac.location
	  AND dth.date = vac.date
    WHERE dth.continent IS NOT NULL

CREATE VIEW GlobalCovidCasualties AS
	WITH GlobalCandD AS (
	SELECT 
	  CAST(date AS date) AS Date,
	  SUM(new_cases) AS WorldCases,
	  SUM(CONVERT(float, new_deaths)) AS WorldDeaths,
	  ROUND(SUM(CONVERT(float, new_deaths))/NULLIF(SUM(CONVERT(float, new_cases)), 0) * 100, 3) AS DeathsPer100Cases
	FROM [Portfolio Project]..CovidDeaths
	  WHERE continent IS NOT NULL
	  GROUP BY CAST(date AS DATE)
	),
	TotalGlobalCandD AS (
	SELECT 
	  Date,
	  SUM(WorldCases) OVER (ORDER BY Date) AS TotalGlobalCases, 
	  SUM(WorldDeaths) OVER (ORDER BY Date) AS TotalGlobalDeaths
	FROM GlobalCandD
	)
	SELECT *,
	  (TotalGlobalDeaths/NULLIF(TotalGlobalCases, 0))*100 AS CurrentDeathRate
	FROM TotalGlobalCandD

CREATE VIEW ContinentCovidCasualties AS
SELECT
  continent,
  SUM(CONVERT(float,new_deaths)) AS TotalDeathcount
FROM [Portfolio Project]..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY continent

CREATE VIEW DeathPerPopulation AS
WITH MaxDeathsCTE AS (
  SELECT 
	location,
	date,
	total_deaths,
	population,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY CONVERT(float,total_deaths) DESC) AS RowNum
  FROM 
	[Portfolio Project]..CovidDeaths
),
DeathRankingCTE AS(
SELECT 
  location,
  total_deaths AS TotalDeaths,
  population,
  ROUND((CONVERT(float, total_deaths) / population) * 100, 3) AS DeathPerPopulation,
  date,
  RANK() OVER (ORDER BY (CONVERT(float, total_deaths) / population) * 100 DESC) AS RANKING
FROM
  MaxDeathsCTE
  WHERE 
  RowNum = 1
)
SELECT
  DR.location,
  DR.TotalDeaths,
  DR.population,
  DR.DeathPerPopulation,
  DR.Ranking
FROM
  DeathRankingCTE DR