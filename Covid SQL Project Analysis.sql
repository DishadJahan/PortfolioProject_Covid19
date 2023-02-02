-- Table 1.
SELECT * FROM Covid_Vacs 
where continent is not null
order by 3, 4;

-- Table 2.
SELECT * FROM Covid_Death
where continent is not null
order by 3, 4;

-----------------------------------------------------------------------------------------------------------------------

-- Selecting Data that we are going to use.

select location, date, total_cases, new_cases, 
total_deaths, population
from Covid_Deaths
where continent is not null
order by 1,2;



-- Looking at Total Cases vs Total deaths.
-- Probability rate of dying of Covid-19 in your country.

Select location, date, total_cases, total_deaths, 
concat((total_deaths/total_cases)*100,' ','%') as Death_percentage
from Covid_Death
where continent is not null
order by 1,2;



-- Looking at Total Cases vs Population.
-- Shows the % of population that were Infected by Covid-19.

Select location, date, total_cases, population, total_deaths, 
concat(cast((total_cases/population)*100 as int),' ','%') as Infect_percentage
from Covid_Death
where continent is not null
order by 1,2;



-- Looking at the countries with the Highest Infection rate compared to population.

Select location, population, max(total_cases) as total_cases,
concat(cast(max((total_cases/population))*100 as int),' ','%') as Infect_percentage
from Covid_Death
where continent is not null
--where location not in ('World', 'High income', 'Europe','Asia', 'European Union', 'Upper middle income', 
--						'North America', 'Lower middle income', 'South America', 'International', 'Africa')
group by location, population
order by total_cases desc;



-- Looking at the countries with the Highest Infection rate compared to population.

Select location, population, max(total_cases) as total_cases, max(total_deaths) as total_deaths,
concat(cast(max((total_cases/population))*100 as int),' ','%') as Infect_percentage,
concat(max((total_deaths/population))*100,' ','%') as Death_percentage
from Covid_Death
where continent is not null
--where location not in ('World', 'High income', 'Europe','Asia', 'European Union', 'Upper middle income', 
--						'North America', 'Lower middle income', 'South America', 'International', 'Africa')
group by location, population
order by total_cases desc;

--------------------------------------------------------------------------------------------------------------------

-- LET'S ANALYSE THINGS DOWN BY CONTINENT.


-- Total Infection count according to continent

Select continent, max(total_cases) as total_infected_cases
from Covid_Death
where continent is not null
--where location not in ('World', 'High income', 'Europe','Asia', 'European Union', 'Upper middle income', 
--						'North America', 'Lower middle income', 'South America', 'International', 'Africa')
group by continent
order by total_infected_cases desc;

-- Total Death count according to continent

Select continent, max(total_deaths) as total_deaths
from Covid_Death
where continent is not null
--where location not in ('World', 'High income', 'Europe','Asia', 'European Union', 'Upper middle income', 
--						'North America', 'Lower middle income', 'South America', 'International', 'Africa')
group by continent
order by total_deaths desc;

--------------------------------------------------------------------------------------------------------------
-- ANOTHER WAY OF LOOKING AT THINGS DOWN BY CONTINENT. (Few changes in WHERE condition)

-- Total Death count according to continent.

Select location, max(total_deaths) as total_deaths
from Covid_Death
where continent is  null
and location not in ('World', 'High income', 'Upper middle income', 
					 'Lower middle income', 'International', 'Low income')
group by location
order by total_deaths desc;


-- Total Infection count according to continent.

Select location, max(total_cases) as total_cases
from Covid_Death
where continent is  null
and location not in ('World', 'High income', 'Upper middle income', 
					 'Lower middle income', 'International', 'Low income')
group by location
order by total_cases desc;

-------------------------------------------------------------------------------------------------------

--  GLOBAL NUMBERS PER DAY FROM (1st Jan, 2020) to (2nd Feb, 2023):

Select date, 
	   coalesce(sum(new_cases), 0) as total_new_cases, 
	   coalesce(sum(new_deaths), 0) as total_new_deaths, 
	   concat((sum(new_deaths)/sum(new_cases))*100,' ','%') as Death_percentage
from Covid_Death
where continent is not null
		and location not in ('World', 'High income', 'Upper middle income', 
					 'Lower middle income', 'International', 'Low income')
group by date
order by date;

------------------------------------------------------------------------------------------------------

-- OVERALL NUMBERS ACCORDING TO COUNTRIES FROM (1st Jan, 2020) to (2nd Feb, 2023):

Select location, population,
	   coalesce(sum(new_cases), 0) as total_cases, 
	   coalesce(sum(new_deaths), 0) as total_deaths, 
	   concat((sum(new_deaths)/sum(new_cases))*100,' ','%') as Death_percentage,
	   concat((sum(new_cases)/max(population))*100,' ','%') as Infected_percentage
from Covid_Death
where continent is not null
	and location not in ('World', 'High income', 'Upper middle income', 
						'Lower middle income', 'International', 'Low income')
group by location, population
order by location;

------------------------------------------------------------------------------------------------------

-- OVERALL GLOBAL NUMBERS FROM (1st Jan, 2020) to (2nd Feb, 2023): 

-- Total Population = 8.04 billion.
-- Total Cases = 670 million. 
-- Total Deaths = 6.8 million.
-- Infected percentage = 8.3%.
-- Death percentage = 1.02%.

-- Using CTE

With global_no as (
				Select location, population,
					   coalesce(sum(new_cases), 0) as total_cases, 
					   coalesce(sum(new_deaths), 0) as total_deaths, 
					   concat((sum(new_deaths)/sum(new_cases))*100,' ','%') as Death_percentage,
					   concat((sum(new_cases)/max(population))*100,' ','%') as Infected_percentage
				from Covid_Death
				where continent is not null
						and location not in ('World', 'High income', 'Upper middle income', 
									 'Lower middle income', 'International', 'Low income')
				group by location, population)

select sum(population) as total_population, sum(total_cases) as total_cases, sum(total_deaths) as total_deaths,
	   concat((sum(total_cases)/sum(population))*100,' ','%') as Overall_infected_percent,
	   concat((sum(total_deaths)/sum(total_cases))*100,' ','%') as Overall_death_percent
from global_no; 


======================================================================================================================

Select * 
From Covid_Vacs vax
join Covid_Death dth
	on vax.location = dth.location and vax.date = dth.date;
--where dth.continent is not null

=============================================================================================================================

-- Looking at Total population vs Vaccination.

-- Percentage of people vaccinated per Country.
-- Using multiple CTE and creating a View.

Create View Percent_Pop_Vac_Per_Country as
With popVsVac (continent, location, date, population, 
			   new_vaccinations, total_vaccination_count) 
as 
	(Select dth.continent, dth.location, dth.date, dth.population, vax.new_vaccinations,
		sum(vax.new_vaccinations) over (partition by dth.location order by dth.date, dth.location) as total_vaccination_count
	From Covid_Vacs vax
	join Covid_Death dth
		on vax.location = dth.location and vax.date = dth.date
	where dth.continent is not null),

  percent_vacs as (select *, (total_vaccination_count/population)*100 as total_percent_vaccinated
				   from popVsVac),

  row_no as (select *,
			row_number() over(partition by location order by total_percent_vaccinated desc) as row_num
			from percent_vacs
			where continent is not null)

select location, population, new_vaccinations, 
	   total_vaccination_count, total_percent_vaccinated
from row_no
where row_num = 1;

==============================================================================================================================
-- Creating View:

Create view PercentPopulationvaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vax.new_vaccinations,
		sum(vax.new_vaccinations) over (partition by dth.location order by dth.date, dth.location) as total_vaccination_count
	From Covid_Vacs vax
	join Covid_Death dth
		on vax.location = dth.location and vax.date = dth.date
	where dth.continent is not null;









































