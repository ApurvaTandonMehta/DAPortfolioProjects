select*
from covid_deaths
where continent is not null


select location, date, total_cases, new_cases, total_deaths, new_deaths, population
from covid_deaths

--total cases to the total deaths  per country
--deaths to the total cases in the country

select location, date, total_cases,  total_deaths , Round (((total_deaths::decimal / total_cases) * 100),2) as percent_deaths
from covid_deaths
where location = 'India'
order by 1,2


-- looking at total cases vs the population

select location, date, total_cases, population, round(((total_cases/cast(population as decimal)) * 100),3) as percent_pop
from covid_deaths
where location = 'India'
order by 1,2


-- find the countries that have the highest infection rates


select location, Max(total_cases) as highestInfectionCount, population, Max(round(((total_cases/cast(population as decimal)) * 100),2)) 
as percentPopulationInfected
from covid_deaths
--where location = 'India'
where continent is not null
group by location, population
order by percentPopulationInfected desc


-- find the countries with the highest number of deaths

select location, Max(total_deaths) as highestDeathCount, population, Max(round(((total_deaths/cast(population as decimal)) * 100),2)) 
as percentPopulationDeath
from covid_deaths
--where location = 'India'
where continent is not null
group by location, population
order by percentPopulationDeath desc


select location , max(total_deaths) as totalDeathCount
from covid_deaths
where continent is not null
group by location
order by totalDeathCount desc

-- breaking things down by continent

select continent , max(total_deaths) as totalDeathCount
from covid_deaths
where continent is not null
group by continent
order by totalDeathCount desc

-- select location , max(total_deaths) as totalDeathCount
-- from covid_deaths
-- where continent is null
-- group by location
-- order by totalDeathCount desc

--Global Number where we will not group by any location, we will only use the date and then get all the numbers globally


select date, sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, round((sum(new_deaths::decimal)/sum(new_cases) * 100),2) as globalDeathPercentage
from covid_deaths
where continent is not null
Group by date
order by 1,2


-- global death percentage 

select sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, round((sum(new_deaths::decimal)/sum(new_cases) * 100),2) as globalDeathPercentage
from covid_deaths
where continent is not null
--Group by date
order by 1,2





-- creating CTE
with total_vaccinations_by_population(continent, location,date, population, new_vaccinations,running_total_new_vaccinations)
as 
(
   select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		sum(cast (cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as 
		running_total_new_vaccinations
		from covid_deaths cd
		join covid_vaccinations cv
		   on cv.location = cd.location
		   and cv.date = cd.date
		where cd.continent is not null
		--order by 2,3
)

select *
from total_vaccinations_by_population

--- creating Temp Table

Drop table if exists percentPopulationVaccinated
create table percentPopulationVaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 running_total_new_vaccinations numeric

)

insert into percentPopulationVaccinated

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		sum(cast (cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as running_total_new_vaccinations
		from covid_deaths cd
		join covid_vaccinations cv
		   on cv.location = cd.location
		   and cv.date = cd.date
		where cd.continent is not null
		--order by 2,3


select  continent, location, date, population, new_vaccinations, running_total_new_vaccinations,
 round(((running_total_new_vaccinations::decimal )/cast(population as decimal)) * 100, 2 )as vaccination_percentage
from percentPopulationVaccinated


--creating views for later visualizations

create view percentPopulationVaccinatedGlobally as 

 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		sum(cast (cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as running_total_new_vaccinations
		from covid_deaths cd
		join covid_vaccinations cv
		   on cv.location = cd.location
		   and cv.date = cd.date
		where cd.continent is not null
		order by 2,3
