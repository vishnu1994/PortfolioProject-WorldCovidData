select *
From ProjectPortfolio..CovidDeaths
where continent is not null
order by 3,4



--select *
--From ProjectPortfolio..CovidVaccinations
--order by 3,4 
--
-- select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in India
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
where location like '%India%'
order by 1,2


-- Looking at Total cases vs Population
-- Shows what percentage of population got covid
select Location, date, population,total_cases,  (total_cases/population)*100 as CovidPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
--where location like '%India%'
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population
select Location, population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as InfectionPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
Group by Location, population
order by InfectionPercentage desc

-- Showing Countries with Highest Death count population

select Location, population, max(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null
Group by Location, population
order by TotalDeathCount desc



-- Let's Break things by Continent

-- Showing the continents with Highest Death Counts

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentageWorld
from ProjectPortfolio..CovidDeaths
where continent is not null
--Group by date
--where location like '%India%'
order by DeathPercentageWorld desc


-- Looking at Total Population vs Total Vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 -- where dea.location like '%India%'
  order by 2,3



  -- USE CTE

  with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
  (

  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 -- where dea.location like '%India%'
  --order by 2,3
  )

  select * , (RollingPeopleVaccinated/population)*100
  from  PopvsVac




  create table #PercentPopulationVaccinated
  (
  continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric,
  )

  insert into #PercentPopulationVaccinated
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 -- where dea.location like '%India%'
  --order by 2,3

  select * , (RollingPeopleVaccinated/population)*100
  from  #PercentPopulationVaccinated




  Create view PercentPopulationVaccinated as
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 -- where dea.location like '%India%'
 -- order by 2,3

 select *
 from PercentPopulationVaccinated