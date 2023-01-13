select * from [dbo].[CovidDeaths$]

--- query to find total number of rows
select count(*) from CovidDeaths$

--- Query to find total # of countries
--- total there are 219 countries in this spread sheet
select count( distinct (location)) from [dbo].[CovidDeaths$]

--- query to find max of total cases by each country
select location, max(total_cases) from [dbo].[CovidDeaths$]
--where location like '%states%' 
group by location
order by  max(total_cases) desc;

--From the data, it is found Europe has highest no.of cases recorded 



select max(total_cases) from CovidDeaths$
select sum(total_cases) from CovidDeaths$

--- highest number of cases were recorded on 2021-04-30
select total_cases, date from CovidDeaths$
order by total_cases desc
   

-- qurying for total cases between dates
select total_cases,date from CovidDeaths$
where date between '2021-04-28' and '2021-04-29'
order by date 

--- querying for specific location and date when total cases are 4
select location,date from CovidDeaths$
where total_cases = '4'
---group by location



--- querying for # of distinct locations when cases are 4
select distinct (location) from CovidDeaths$
where total_cases = '4' and date = '2021-03-27'

select count (distinct (location))
from CovidDeaths$

select count(location)
from CovidDeaths$


select * from [dbo].CovidDeaths$
order by 3,4


select * from [dbo].[CovidVaccinations$]
order by 3,4

select location,date,total_cases,new_cases,population
from [dbo].CovidDeaths$
order by 1,2


--Looking for total cases vs total deaths
--chances of dying when infected covid

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentageof_Deaths
from [dbo].CovidDeaths$
where location like '%states%'
order by 1,2

--From the result, percentage of deaths peaked to 10% in March 2020 in United states and slowed down 1.8% later of the month.
--Again Death percentage spiked from the end of 1st week of April and continued to peak Till end of June. From then there is a slight
--drop in deaths. By the end of the Year 2020, Death percentage has lowered to 1.75%




--Looking at countries with highest infection rate compared to population

select location, population,max(total_cases) as Highest_number_ofcases, max((total_cases/population))*100 as percentage_population_infected
from [dbo].CovidDeaths$
where population >= 100000000
group by location,population
order by percentage_population_infected desc
--Of  all the countries  has highest infection rate. how ever, it has very low population. when further analysed in 
--countries with higher population, United states has the highest infection rate of 10%



---showing countries with Highest death count per population
select location, population,max(cast(total_deaths as int)) as total_deathcount, max((total_deaths/population))*100 as percentage_population_died
from [dbo].CovidDeaths$
group by location,population
order by percentage_population_died desc
--from the data, Hungary has highest percentage of population died that is 0.2% .



--- looking for death count in countries with higher population 
select location, population,max(cast(total_deaths as int)) as total_deathcount, max((total_deaths/population))*100 as percentage_population_died
from [dbo].CovidDeaths$
where population >= 100000000
and continent is not null
group by location,population
order by 4 desc
 -- from the Countries with higher population , Brazil and united states has the highest death count of 0.18% 


 
 --- looking total deaths by continent
 select continent,max(cast(total_deaths as int)) 
 from [dbo].CovidDeaths$
 where continent is not null
 group by continent
  order by max(cast(total_deaths as int)) desc;
  

  select location,max(convert(int,total_deaths)) over(partition by location)
   from [dbo].CovidDeaths$
   --where continent is not null
   group by location ,total_deaths
   order by location
  

  --looking at total population vaccinated 
 select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
  from [dbo].CovidDeaths$ dea join [dbo].[CovidVaccinations$] vac 
  on dea.location=vac.location 
  and dea.date=vac.date
   where dea.continent is not null
   order by 2,3
  
  
  --looking at total number of vaccinations per each location 
 
 select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert (int,vac.new_vaccinations))over (partition by dea.location) as total_vacinations
  from [dbo].CovidDeaths$ dea join [dbo].[CovidVaccinations$] vac 
  on dea.location=vac.location 
  and dea.date=vac.date
   where dea.continent is not null --and dea.location like'india'
   order by 2,3
--- Total vaccinations for 2020/2021 for each country is listed in the last column




-- looking at total vaccinations done per each day in all locations (using partion by)
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert (int,vac.new_vaccinations))over (partition by dea.location order by dea.date) as total_vacinations_perday,
 sum(convert (int,vac.new_vaccinations))over (partition by dea.location) as total_vacinations
  from [dbo].CovidDeaths$ dea join [dbo].[CovidVaccinations$] vac 
  on dea.location=vac.location 
  and dea.date=vac.date
   where dea.continent is not null --and dea.location like'india'
   order by 2,3
-- total_vacinations_rollingsum gives the sum of total accinations per day for each llocation.



-- looking for percentage population vaccinated. usecase 1
--- using CTE as derived collumn can be used further computations.
 with percentage_populationvaccinated(continent,location,date,population,new_vaccinations,
 total_vacinations_perday,total_vacinations)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert (int,vac.new_vaccinations))over (partition by dea.location order by dea.date) as total_vacinations_perday,
 sum(convert (int,vac.new_vaccinations))over (partition by dea.location) as total_vacinations
  from [dbo].CovidDeaths$ dea join [dbo].[CovidVaccinations$] vac 
  on dea.location=vac.location 
  and dea.date=vac.date
   where dea.continent is not null --and dea.location like'india'
   ---order by 2,3
   )
   select *,(total_vacinations_perday/population)*100 as percentvac_perday
   from percentage_populationvaccinated
--- Totaall vaccinations per day has increases each day. so percentage vaccinations also increased. percentvac_perday 
--column shows the % of population vaccinated on each day.
---for example, For Romania and Turkey 26% of its total population got vaccinated , UK 67% got vaccinated,
   




   ------looking for percentage population vaccinated. usecase2
   -- using Temp tables

   drop table if exists #vaccinated_percent
   create table #vaccinated_percent
   (
   continent nvarchar(255),
   location nvarchar(255),
   date datetime,
   population numeric,
   new_vaccinations numeric,
   total_vacinations_perday numeric,
   total_vacinations numeric
   )

    insert into #vaccinated_percent
   select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert (int,vac.new_vaccinations))over (partition by dea.location order by dea.location,dea.date) as total_vacinations_perday
 ,sum(convert (int,vac.new_vaccinations))over (partition by dea.location) as total_vacinations
  from [dbo].CovidDeaths$ dea join [dbo].[CovidVaccinations$] vac 
  on dea.location=vac.location 
  and dea.date=vac.date
   where dea.continent is not null --and dea.location like'india'
   ---order by 2,3
   
   select *,(total_vacinations_perday/population)*100 
   from #vaccinated_percent


---- creating views to store data for later visualizations

create view vaccinated_percent1 as
 select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(convert (int,vac.new_vaccinations))over (partition by dea.location order by dea.location,dea.date) as total_vacinations_perday
 ,sum(convert (int,vac.new_vaccinations))over (partition by dea.location) as total_vacinations
  from [dbo].CovidDeaths$ dea join [dbo].[CovidVaccinations$] vac 
  on dea.location=vac.location 
  and dea.date=vac.date
   where dea.continent is not null --and dea.location like'india'
   ---order by 2,3

  