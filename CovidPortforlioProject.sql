SELECT *
FROM PortforlioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

SELECT *
FROM PortforlioProject..CovidVacinations
order by 3,4

-- Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortforlioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortforlioProject..CovidDeaths
WHERE location like '%Viet%'
AND continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Show what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PositivePercentage
FROM PortforlioProject..CovidDeaths
WHERE location like '%Viet%'
AND continent is not NULL
ORDER BY 1,2

--Looking at country with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,
		MAX((total_cases/population))*100 as PositivePercentage
FROM PortforlioProject..CovidDeaths
--where location like '%Viet%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY 4 desc 

--Showing the country with Highest Death count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortforlioProject..CovidDeaths
--where location like '%Viet%'
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc

--Showing continent with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortforlioProject..CovidDeaths
--where location like '%Viet%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers

SELECT
	   SUM(new_cases) as "Total cases",
	   SUM(cast(new_deaths as int)) as "Total deaths",
	   SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortforlioProject..CovidDeaths
--where location like '%Viet%'
WHERE continent is not null
HAVING SUM(new_cases) <> 0
ORDER BY 1,2

--Looking at Total Population va Vacinations

SELECT dead.continent, dead.location, dead.date, dead.population, vacin.new_vaccinations,
SUM(cast(vacin.new_vaccinations as float)) OVER (PARTITION BY dead.location ORDER BY dead.location,
dead.Date) as RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dead
JOIN PortforlioProject..CovidVacinations vacin
	ON dead.location = vacin.location
	AND dead.date = vacin.date
WHERE dead.continent is not null
ORDER BY 2,3

--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as(
SELECT dead.continent, dead.location, dead.date, dead.population, vacin.new_vaccinations,
SUM(cast(vacin.new_vaccinations as float)) OVER (PARTITION BY dead.location ORDER BY dead.location,
dead.Date) as RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dead
JOIN PortforlioProject..CovidVacinations vacin
	ON dead.location = vacin.location
	AND dead.date = vacin.date
WHERE dead.continent is not null
--ORDER BY 2,3
)

SELECT *
FROM PopvsVac

--Temp table

DROP TABLE IF EXISTS #PercentegePopulationVaccinated
CREATE TABLE #PercentegePopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentegePopulationVaccinated
SELECT dead.continent, dead.location, dead.date, dead.population, vacin.new_vaccinations,
SUM(cast(vacin.new_vaccinations as float)) OVER (PARTITION BY dead.location ORDER BY dead.location,
dead.Date) as RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dead
JOIN PortforlioProject..CovidVacinations vacin
	ON dead.location = vacin.location
	AND dead.date = vacin.date
WHERE dead.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulationVaccinated
FROM #PercentegePopulationVaccinated
ORDER BY 7 DESC

--Creating View to store data for later visualizations

CREATE VIEW PercentegePopulationVaccinated as
SELECT dead.continent, dead.location, dead.date, dead.population, vacin.new_vaccinations,
SUM(cast(vacin.new_vaccinations as float)) OVER (PARTITION BY dead.location ORDER BY dead.location,
dead.Date) as RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dead
JOIN PortforlioProject..CovidVacinations vacin
	ON dead.location = vacin.location
	AND dead.date = vacin.date
WHERE dead.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentegePopulationVaccinated