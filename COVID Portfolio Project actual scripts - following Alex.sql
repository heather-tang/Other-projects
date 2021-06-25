select *
From PortfolioProject..CovidDeaths
order by 3,4


--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Total Population
-- Shows what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


-- Looking at Countries with Hightest Infection Rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Locaiton, Date, Population, New_Vaccinations, RollingpeopleVaccinate)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingpeopleVaccinate/Population)*100
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPenpleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, 
	dea.date) as RollingPenpleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPenpleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization
Use PortfolioProject
Go

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, 
	dea.date) as RollingPenpleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated