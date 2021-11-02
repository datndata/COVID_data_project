
-- Name: Dat Nguyen 
-- Project aim: COVID-19 Dashboard as at 20 Oct 2021 
-- Data source: https://ourworldindata.org/covid-deaths

--1. Global number of cases and deaths 
Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--2. Sum all new_deaths and organise by location 
Select location,
	SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
AND location not in ('World', 'European Union', 'International')
-- Excluded 'European Union' as it is part of Europe
Group by location 
order by TotalDeathCount desc


-- 3.  Find out what is higest infection rate and  proportion of this on total population for each country 
Select location, population, MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected DESC

-- 4. 
Select location, population, date, MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected DESC