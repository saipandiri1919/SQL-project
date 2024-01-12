-- Select Data that we are going to using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2;

-- Looking at Total cases vs Total deaths
Select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
order by DeathPercentage;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid
Select location, date, total_cases, Population, (total_deaths/ Population)*100 as DeathPercentage
from coviddeaths
where continent is not null
order by DeathPercentage;

-- Looking at the countries with highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_deaths/ Population))*100 as PercentPopulationInfected
from coviddeaths
where continent is not null
group by location, population
order by PercentPopulationInfected;

-- Looking at countries showing highest death count
Select location, population, Max(cast(total_deaths as unsigned)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location, population
order by TotalDeathCount;

-- Looking at continents showing highest death count
Select continent, Max(cast(total_deaths as unsigned)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount;


-- Global numbers
Select date, sum(total_cases) as totalCases
from coviddeaths
where continent is not null
group by date
order by 1,2;


Select date, sum(new_cases) as totalCases, sum(cast(new_deaths as unsigned)) as totalDeaths, (sum(new_cases)/sum(cast(new_deaths as unsigned)))*100 as DeathPercentage
from coviddeaths
where continent is not null
group by date
order by 1,2;

-- Joining coviddeaths and covidvaccinations tables   
-- Looking at total population vs vaccination
-- use CTE
With PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,sum(convert(vac.new_vaccinations,unsigned)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	 from coviddeaths as dea
	 join covidvaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date
	 where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population)*100
 from PopvsVac;
 

-- Temp Table
Drop table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
);
Insert into PercentPopulationVaccinated 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,sum(convert(vac.new_vaccinations,unsigned)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	 from coviddeaths as dea
	 join covidvaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date;
	 -- where dea.continent is not null

select * , (RollingPeopleVaccinated/Population)*100
 from PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

select * from percentpopulationvaccinated2;
 

