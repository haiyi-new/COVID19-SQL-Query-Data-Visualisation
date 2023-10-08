SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs ToTal Deaths
-- Show likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL AND location LIKE '%states'
ORDER BY total_cases DESC

--Looking at Total Cases vs Population
-- 1. this shows percentage of population got covid
-- 2. this shows the probability of population to contract covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM CovidDeaths
WHERE continent is NOT NULL AND location LIKE '%states'
ORDER BY total_cases DESC

--Looking at Highest infection Rate
SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS InfectionPerPopulation
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY InfectionPerPopulation DESC

-- Showing Country with Highest Death per Population
-- some datatypes should be in int to get the MAX, but the total_deaths data types in varchar thus need to change it
-- we use cast to change the data types.
SELECT location, population,MAX(cast(total_deaths as int)) as DeathCount, MAX((total_deaths/population))*100 as HighestDeathPerPopulation
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY DeathCount DESC

-- Break down to Continent
-- this one kinda not accurate since we take continent only, whereas some data has data at location not continent
SELECT continent, MAX(cast(total_deaths as int)) as DeathCount, MAX((total_deaths/population))*100 as HighestDeathPerPopulation
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC

--this one is the accurate one, this data sources summarise it in location not continent
SELECT location, MAX(cast(total_deaths as int)) as DeathCount, MAX((total_deaths/population))*100 as HighestDeathPerPopulation
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY DeathCount DESC

-- Global Numbers
-- for Global we will do date, since we group by all date, thus we cannot use total death, total cases it need Aggregate meaning creating 
-- new colum using function, thus we will take diffrent data.
-- new death should be in int, but the data types is varchar so cannot SUM thus we would use cast

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeath, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 
AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1

-- before is for date,everday, if want to finalize using above query is
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeath, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 
AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1

/*
 TABLE DEATH JOIN TABLE VACCINE
*/
-- Looking at Total Population VS Vaccinations
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Now lets add total of new vaccination based on location
-- Also, the vac.new_vaccinations is in varchar, other than CAST we can use CONVERT to change it to INT
-- Inside Partition By it will resulted the total sum for each location each day,thus it will have multiple row, to check the increment each
-- day, we add ORDER BY
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccination
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- now lets add new column, which using TotalVaccination/Population to see the ratio of people getting vaccine over their population
-- since Total Vaccination is created y alias, we cannot use it for another column, thus need to use CTE or Temp_Table. 
-- CTE

WITH VacVsPop (Continent, Location, Date, Population, New_Vaccinations, TotalVaccination)
AS
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccination
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent is NOT NULL
)
SELECT Continent, Location, Date, Population, New_Vaccinations, TotalVaccination, (TotalVaccination/Population)*100 AS VacPeoplePerPopulation
FROM VacVsPop

-- TEMP_TABLE

CREATE TABLE #VaccinatedPeople
(
Continent varchar(255),
Location varchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccination numeric
)

INSERT INTO #VaccinatedPeople
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccination
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent is NOT NULL

SELECT Continent, Location, Date, Population, New_Vaccinations, TotalVaccination, (TotalVaccination/Population)*100 AS VacPeoplePerPopulation
FROM #VaccinatedPeople

-- Creating View to store data for later visualizations|

CREATE VIEW TotalVaccinatedEveryday AS
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccination
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent is NOT NULL

SELECT *
FROM TotalVaccinatedEveryday
