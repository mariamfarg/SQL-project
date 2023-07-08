select *
from [project new]..CovidDeaths
where continent is not null
order by 3,4


--select *
--from [project new]..CovidVaccinations
--order by 3,4
--select the data that we are going to be useing 
--show likelihood of dying if you contract covid in your country 
select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage 
from [project new]..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population 
--show what percentage of population got covid 
select location,date,total_cases,population,(total_cases/population)*100 as deathpercentage 
from [project new]..CovidDeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population 

select location ,max(total_cases) as highestinfectioncount ,population,max((total_cases/population))*100 as percentpopulationinfected
from [project new]..CovidDeaths
--where location like '%states%'
group by location ,population
order by percentpopulationinfected desc

--showing countries with highest death count per loction 

select location ,max(cast (total_deaths as int )) as totaldeathcount 
from [project new]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location 
order by totaldeathcount  desc

--lets break things down by continent 
select continent ,max(cast (total_deaths as int )) as totaldeathcount 
from [project new]..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount  desc

--showing continent eith the highest death count per poulation 
select continent ,max(cast (total_deaths as int )) as totaldeathcount 
from [project new]..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount  desc


--global numbers
select date,sum(new_cases),sum(CAST(new_deaths as int)),sum(CAST(new_deaths as int)) / SUM(new_cases)*100 as deathpercentage 
from [project new]..CovidDeaths
-- location like '%states%' and
 where continent is not null 
 group by date
order by 1,2


------------------------------------------------------table 2 
select *
from [project new]..CovidVaccinations
--looking at total population and vaccination 
select *
from [project new]..CovidDeaths dea
join [project new]..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date

with popvsvacc (continent,location,date ,population ,new_vaccinations, rollingpeoplvaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date ) as rollingpeoplvaccinated 
from [project new]..CovidDeaths dea
join [project new]..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3 
)

--use cte 

select * ,(rollingpeoplvaccinated/population)*100
from popvsvacc

--temp table
drop table if exists #percentpopulatinvaccinated 
create table #percentpopulatinvaccinated 
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime ,
population numeric ,
new_vaccinations numeric ,
rollingpeoplvaccinated numeric 
)
insert into #percentpopulatinvaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date ) as rollingpeoplvaccinated 
from [project new]..CovidDeaths dea
join [project new]..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3 

select * ,(rollingpeoplvaccinated/population)*100
from #percentpopulatinvaccinated 


--creating view to store data for later visualization 
create view percentpopulatinvaccinated as 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date ) as rollingpeoplvaccinated 
from [project new]..CovidDeaths dea
join [project new]..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3 

select *
from percentpopulatinvaccinated