--Covid 19 Data Exploration

SELECT *
FROM [Portfolio projects].dbo.CovidDeaths;

SELECT *
FROM [Portfolio projects].dbo. CovidVaccinations;

--data cleaning

-- Converting blanks to NULL in the CovidDeaths table

SELECT 
    NULLIF(continent, '') AS continent, 
    location, date, 
    NULLIF(total_cases, '') AS total_cases, 
    NULLIF(new_cases, '') AS new_cases, 
    NULLIF(total_deaths, '') AS total_deaths, 
    NULLIF(population, '') AS population
FROM [Portfolio projects].dbo.CovidDeaths;

UPDATE [Portfolio projects].dbo.CovidDeaths
SET 
    continent = NULLIF(continent, ''),
    total_cases = NULLIF(total_cases, ''),
    new_cases = NULLIF(new_cases, ''),
    total_deaths = NULLIF(total_deaths, ''),
    population = NULLIF(population, '');


-- Converting blanks to NULL in the CovidVaccinations table

SELECT 
    NULLIF(continent, '') AS continent, 
    location, date, 
    NULLIF(total_tests, '') AS total_tests, 
    NULLIF(new_tests, '') AS new_tests, 
    NULLIF(total_vaccinations, '') AS total_vaccinations, 
    NULLIF(people_vaccinated, '') AS people_vaccinated
FROM [Portfolio projects].dbo.CovidVaccinations;

UPDATE [Portfolio projects].dbo.CovidVaccinations
SET 
    continent = NULLIF(continent, ''),
    total_tests = NULLIF(total_tests, ''),
    new_tests = NULLIF(new_tests, ''),
    total_vaccinations = NULLIF(total_vaccinations, ''),
    people_vaccinated = NULLIF(people_vaccinated, '');

--validating the changes

SELECT 
    COUNT(CASE WHEN continent = '' THEN 1 END) AS blank_continent,
    COUNT(CASE WHEN total_cases = '' THEN 1 END) AS blank_total_cases,
    COUNT(CASE WHEN new_cases = '' THEN 1 END) AS blank_new_cases,
    COUNT(CASE WHEN total_deaths = '' THEN 1 END) AS blank_total_deaths,
    COUNT(CASE WHEN population = '' THEN 1 END) AS blank_population
FROM [Portfolio projects].dbo.CovidDeaths;

SELECT 
    COUNT(CASE WHEN continent = '' THEN 1 END) AS blank_continent,
    COUNT(CASE WHEN total_tests = '' THEN 1 END) AS blank_total_tests,
    COUNT(CASE WHEN new_tests = '' THEN 1 END) AS blank_new_tests,
    COUNT(CASE WHEN total_vaccinations = '' THEN 1 END) AS blank_total_vaccinations,
    COUNT(CASE WHEN people_vaccinated = '' THEN 1 END) AS blank_people_vaccinated
FROM [Portfolio projects].dbo.CovidVaccinations;


-- checking the date column data type

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths' AND COLUMN_NAME = 'date';

-- Convert varchar to datetime

SELECT 
    CONVERT(DATETIME, date, 101) AS converted_date 
FROM [Portfolio projects].dbo.CovidDeaths;

UPDATE [Portfolio projects].dbo.CovidDeaths
SET date = CONVERT(DATETIME, date, 101);

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidVaccinations' AND COLUMN_NAME = 'date';

-- Convert varchar to datetime

SELECT 
    CONVERT(DATETIME, date, 101) AS converted_date 
FROM [Portfolio projects].dbo.CovidVaccinations;

UPDATE [Portfolio projects].dbo.CovidVaccinations
SET date = CONVERT(DATETIME, date, 101);

--selecting the data I will start working with
SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio projects].dbo.CovidDeaths
WHERE continent is not NULL;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM [Portfolio projects].dbo.CovidDeaths
WHERE continent is not NULL
	  AND location like '%states%';

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS infected_percentage
FROM [Portfolio projects].dbo.CovidDeaths
WHERE continent is not NULL
	  AND location like '%states%';

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection, 
		MAX(total_cases/population)*100 AS infected_percentage
FROM [Portfolio projects].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY infected_percentage DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX (total_deaths) AS total_death_count
FROM [Portfolio projects].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- BREAKING THINGS DOWN BY CONTINENT
-- contintents with the highest death count per population

Select continent, MAX(total_deaths) AS total_death_count
From [Portfolio projects].dbo.CovidDeaths
Where continent is not null 
Group by continent
order by total_death_count desc;

SELECT location, MAX (total_deaths) AS total_death_count
FROM [Portfolio projects].dbo.CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- global numbers

SELECT date,
	   SUM(CAST(new_cases AS INT)) AS total_cases, 
       SUM(CAST(new_deaths AS INT)) AS total_deaths, 
       (SUM(CAST(new_deaths AS INT)) * 1.0 / SUM(CAST(new_cases AS INT)) * 100) AS death_percentage
FROM [Portfolio projects].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 2;

SELECT SUM(CAST(new_cases AS INT)) AS total_cases, 
       SUM(CAST(new_deaths AS INT)) AS total_deaths, 
       (SUM(CAST(new_deaths AS INT)) * 1.0 / SUM(CAST(new_cases AS INT)) * 100) AS death_percentage
FROM [Portfolio projects].dbo.CovidDeaths
WHERE continent IS NOT NULL;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY CAST(dea.date AS DATE)) AS rolling_people_vaccinated
FROM [Portfolio projects].dbo.CovidDeaths dea
JOIN [Portfolio projects].dbo.CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, CAST(dea.date AS DATE);

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopulationvsVaccination AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY CAST(dea.date AS DATE)) AS rolling_people_vaccinated
    FROM [Portfolio projects].dbo.CovidDeaths dea
    JOIN [Portfolio projects].dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated / population) * 100 AS vaccination_percentage
FROM PopulationvsVaccination;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS DATE)) AS rolling_people_vaccinated
    FROM [Portfolio projects].dbo.CovidDeaths dea
    JOIN [Portfolio projects].dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
	ORDER BY 2, 3

SELECT *, (rolling_people_vaccinated / population) * 100 AS vaccination_percentage
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopnVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY CAST(dea.date AS DATE)) AS rolling_people_vaccinated
FROM [Portfolio projects].dbo.CovidDeaths dea
JOIN [Portfolio projects].dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopnVaccinated;


