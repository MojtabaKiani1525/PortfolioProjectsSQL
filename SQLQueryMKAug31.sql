Select * 
From PortfolioProject.dbo.CovidDeaths
Order by 3,4;

--Select * 
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2 

-- Looking at the total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
Order by 1,2 

-- Looking at the total cases vs population
Select Location, date, total_cases, population, 
(total_cases/population)*100 as CasePecrcent
From PortfolioProject..CovidDeaths
Where location like '%States%'
Order by 1,2

-- Looking at countries with highest infection raet compared to population
Select Location, MAX(total_cases) as HighestInfectCount, 
MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected Desc

--Showing countries with highest deathcount per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathCount Desc

-- Break Things Down by Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount Desc

-- Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCountPerContinent 
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCountPerContinent  Desc


-- GLOBAL NUMBERS
Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/Sum(New_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
where continent is not null
--Group by date
Order by 1,2 

-- Vacination Data Exploration

-- Looking at total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, 
sum(cast (vac.new_vaccinations as int)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
      On dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
order by 2,3

------------------------
-- LETS USE CTE
---------------------------
With Popvsvac( 
Continent, 
locatio, 
date, 
population, new_vaccinations,
RollingPeopleVaccinated
)
as
(
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, 
sum(cast (vac.new_vaccinations as int)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
      On dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From Popvsvac
-----------------------
--Temporary Table
--------------
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, 
sum(cast (vac.new_vaccinations as int)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
      On dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated




-- Creating View to Store data for later visualizations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, 
sum(cast (vac.new_vaccinations as int)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
      On dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentagePopulationVaccinated