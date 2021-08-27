/*
Covid 19 Data Exploration 
Skills used: 
JOINs, CTEs, TEMP TABLE, Windows Functions, AGGREGATE, GREATE VIEW, CONVERT
*/


USE PortfolioProject
GO

SELECT 
	*
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 
	3, 4


-- Select columns that will be used

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	1,2

-- Total Cases vs Total Deaths
-- Shows likehood of dying if one contracts covid in the US

SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths / total_cases) * 100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	location LIKE '%states%'
	AND continent IS NOT NULL
ORDER BY 
	1, 2

-- Total Cases vs Total Population
-- Shows what percentage of population infected with Covid

SELECT 
	location,
	date,
	population,
	total_cases,
	(total_cases / population) * 100 AS PercentPopulationInfected
FROM 
	PortfolioProject..CovidDeaths
ORDER BY 
	1,2

-- Countries with Hightest Infection Rate compared to Population

SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(total_cases / population)*100 as PercentPopulationInfected
FROM
	PortfolioProject..CovidDeaths
GROUP BY 
	location,
	population
ORDER BY 
	PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT 
	location,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	TotalDeathCount DESC

-- BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

SELECT 
	continent,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY 
	TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid vaccine

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (
		PARTITION BY 
			dea.location,
			dea.Date
		ORDER BY 
			dea.location, 
			dea.date
			) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac 
	ON	
		dea.location = vac.location 
		AND dea.date = vac.date
WHERE 
	dea.continent is not null
ORDER BY 
	2, 3

-- Use CTE to perform calculation on PARTITION BY in previous query

WITH PopvsVac (
		Continent, 
		Locaiton, 
		Date, 
		Population, 
		New_Vaccinations, 
		RollingPeopleVaccinated
		) AS (
			SELECT 
				dea.continent, 
				dea.location, 
				dea.date, 
				dea.population,
				vac.new_vaccinations,
				SUM(CONVERT(int, vac.new_vaccinations)) OVER (
					PARTITION BY 
						dea.location 
					ORDER BY 
						dea.location, 
						dea.date
					) AS RollingPeopleVaccinated
			FROM 
				PortfolioProject..CovidDeaths dea
			JOIN 
				PortfolioProject..CovidVaccinations vac 
					ON dea.location = vac.location 
						AND dea.date = vac.date
			WHERE 
				dea.continent IS NOT NULL
			)
SELECT 
	*,
	(RollingPeopleVaccinated / Population) * 100
FROM 
	PopvsVac

-- Use temp table to perform calculation on PARTITION BY in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric, 
	New_vaccinations numeric, 
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, new_vaccinations)) OVER (
		PARTITION BY 
			dea.location
		ORDER BY 
			dea.location, 
			dea.date
		) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
	ON 
	dea.location = vac.location
	AND dea.date = vac.date

SELECT 
	*,
	(RollingPeopleVaccinated / Population) * 100
FROM 
	#PercentPopulationVaccinated


-- Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
		PARTITION BY 
			dea.location 
		ORDER BY 
			dea.location, 
			dea.date
		) AS RollingPenpleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
	ON 
		dea.location = vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
