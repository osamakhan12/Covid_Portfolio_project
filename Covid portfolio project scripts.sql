--select * from PortfolioProject..CovidDeaths order by 3,4

--select * from PortfolioProject..CovidVacinations order by 3,4


-- Select Data we are working on

select Location,date, Total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths order by 1,2

-- Looking for Total cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

select Location,date, Total_cases,total_deaths,(total_deaths/Total_cases)*100 as Deathpercent
from PortfolioProject..CovidDeaths order by 1,2

select Location,date, Total_cases,total_deaths,(total_deaths/Total_cases)*100 as Deathpercent
from PortfolioProject..CovidDeaths 
where location like '%states%'
order by 1,2

--Looking at Total cases vs population

select Location,date, Total_cases,population,(population/Total_cases)*100 as Deathpercent
from PortfolioProject..CovidDeaths 
order by 1,2

select Location,date, Total_cases,population,(Total_cases/population)*100 as Deathpercent
from PortfolioProject..CovidDeaths 
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate campared to population

select Location,population, MAX(Total_cases) as HighestInfection,MAX((Total_cases/population))*100 as populatedpercent
from PortfolioProject..CovidDeaths 
--where location like '%states%'
Group by Location,population 
order by 1,2

--Showing Countries with highest death count per population
select Location, MAX(cast(total_deaths as int)) as Totaldeathscount 
from PortfolioProject..CovidDeaths 
--where location like '%states%'
Group by Location
order by Totaldeathscount desc 

select Location, MAX(cast(total_deaths as int)) as Totaldeathscount 
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
Group by Location
order by Totaldeathscount desc 


--Breaking by continent 

--showing continent with highest deathcounts per population
select continent, MAX(cast(total_deaths as int)) as Totaldeathscount 
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
Group by continent
order by Totaldeathscount desc 


--GLOBAL NUMBERS

select date, SUM(new_cases)--Total_cases,total_deaths,(total_deaths/Total_cases)*100 as Deathpercent
from PortfolioProject..CovidDeaths 
where continent is not null
group by date
order by 1,2


select date, SUM(new_cases) as totalcases,SUM(CAST(new_deaths as int)) as newdeaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathpercent
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- overall world cases deaths and death percent
select  SUM(new_cases) as totalcases,SUM(CAST(new_deaths as int)) as newdeaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathpercent
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


select * from PortfolioProject..CovidVacinations

select * from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
on dea.location=vac.location
and dea.date=vac.date

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
order by 2,3

--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
order by 2,3


--cte

with popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac

--temp table
drop table if exists #percentpopulatationvaccinated
create table #percentpopulatationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulatationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulatationvaccinated


--creating view to store data for later visualization

create view percentpopulatationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulatationvaccinated