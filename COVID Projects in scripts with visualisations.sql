
select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


-- Select Data

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths (with % of dying if you contract covid)
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'australia'
order by 1,2


-- Total Cases vs Population (shows % of population got covid)
select Location, date, population, total_cases, (total_cases/population)*100 as PerecentPopulationInfected
from PortfolioProject..CovidDeaths
where location like 'australia'
order by 1,2

-- Countries with Highest Infection Rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PerecentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PerecentPopulationInfected desc

-- Countires with Highest Death Count per population
select Location, max(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Continents with Highest Death Count per population
select continent, max(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers
select date, sum(new_cases) as total_cases, sum(cast( new_deaths as int)) as total_deaths, sum(cast( new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2



-- World's Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




-- Create View for visualisations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated



-- Visualisation 1
select sum(new_cases) as total_cases, sum(cast( new_deaths as int)) as total_deaths, sum(cast( new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Visualisation 2
select location, sum(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International', 'high income', 'upper middle income', 'lower middle income', 'low income')
Group by location
order by TotalDeathCount desc

-- Visualisation 3
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PerecentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PerecentPopulationInfected desc

-- Visualisation 4
select Location, population, date, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PerecentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population, date
order by PerecentPopulationInfected desc