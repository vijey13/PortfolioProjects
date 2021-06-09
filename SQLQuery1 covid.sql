select *
from [portfolio project]..['owid_covid -data(1)$']
where continent is not null
order by 3,4 

--select *
--from [portfolio project]..['owid_covid -data vaccinations$']
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]..['owid_covid -data(1)$']
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [portfolio project]..['owid_covid -data(1)$']
where location like '%states%'
order by 1,2

--looking at the total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases,  (total_cases/population)*100 as presentpopulationinfected
from [portfolio project]..['owid_covid -data(1)$']
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highestinfectioncount,  MAX((total_cases/population))*100 as presentpopulationinfected
from [portfolio project]..['owid_covid -data(1)$']
group by location, population
order by presentpopulationinfected desc

 --showing countries with highest death count per population

 select location, MAX(cast(total_deaths as int)) as totaldeathcount
from [portfolio project]..['owid_covid -data(1)$']
where continent is not null
group by location
order by totaldeathcount desc

--lets break things ny continent


--showing the contnets with the highest death count per population 

select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from [portfolio project]..['owid_covid -data(1)$']
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100  as deathpercentage
from [portfolio project]..['owid_covid -data(1)$']
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations 

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,
	    dea.Date) as rollingpeoplevaccinated 
		--, (rollingpeoplevaccinated/population)*100

from [portfolio project]..['owid_covid -data(1)$'] dea
join [portfolio project]..['owid_covid -data vaccinations$'] vac
   on dea.location = vac.location
   and dea.date = vac.date 
   where dea.continent is not null

   -- use cte

   with popvsvac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated )
   as
   (
   select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,
	    dea.Date) as rollingpeoplevaccinated 
		--, (rollingpeoplevaccinated/population)*100

from [portfolio project]..['owid_covid -data(1)$'] dea
join [portfolio project]..['owid_covid -data vaccinations$'] vac
   on dea.location = vac.location
   and dea.date = vac.date 
   where dea.continent is not null

 --  order by 1,2,3
   )
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


--temp table
DROP table if exists #vaccinatedpeople
create table #vaccinatedpeople
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into  #vaccinatedpeople
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,
	    dea.Date) as rollingpeoplevaccinated 
		--, (rollingpeoplevaccinated/population)*100

from [portfolio project]..['owid_covid -data(1)$'] dea
join [portfolio project]..['owid_covid -data vaccinations$'] vac
   on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
--  order by 1,2,3

 select *, (rollingpeoplevaccinated/population)*100
from  #vaccinatedpeople

-- creating view to store data for later visulaizations

create view vaccinatedpeople as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,
	    dea.Date) as rollingpeoplevaccinated 
		--, (rollingpeoplevaccinated/population)*100

from [portfolio project]..['owid_covid -data(1)$'] dea
join [portfolio project]..['owid_covid -data vaccinations$'] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
 
 select *
 from vaccinatedpeople