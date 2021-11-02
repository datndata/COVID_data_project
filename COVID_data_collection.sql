--Name: Dat Nguyen
--Date: 20/10/2021
--Project aim: collect COVID data to create visualisation dashboard to show the impact of COVID on world's population 
--Data source: https://ourworldindata.org/covid-deaths
--Methodology: Use SQL to explore and extract meaningful data from source and prepare datasets to be ready for Tableau visualisation 

--Explore all data 
Select *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select the data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%australia%'
Where continent is not null
Order by 1,2

-- Looking at total cases vs population 
-- Shows what percentage of populaton got COVID
Select Location, date, Population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where Location like '%australia%'
Order by 1,2

-- Looking at country with highest infection rate compared to population 
Select Location, Population, MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 as CasePercentage
From PortfolioProject..CovidDeaths
--Where Location like '%australia%'
Group by Location, Population
Order by CasePercentage desc

-- Showing contry with the highest death count per population 
Select Location, MAX(cast(total_deaths as int)) AS DeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by DeathCount desc

-- LET's BREAK THINGS DOWNS BY CONTINENT
--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) AS DeathCount 
From CovidDeaths
Where continent is not null
Group by continent
Order by DeathCount desc

-- GLOBAL NUMBERS 
-- Of total cases, total deaths and death rate 
 
Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations 
-- Joining the 2 datasets CovidDeath as dea and CovidVaccinations as vac
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, CONVERT(int, vac.new_vaccinations),
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- Use bigint as sumvalue exceeded 2B
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
AND vac.location like '%australia%'
)
Select *, (RollingPeopleVaccinated/Population)*100

From PopvsVac
order by date desc

-- TEMP TABLE 
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualisation 
From #PercentPopulationVaccinated
DROP view if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
