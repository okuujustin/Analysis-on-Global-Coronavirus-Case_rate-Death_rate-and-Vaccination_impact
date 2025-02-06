/*
EXPLORATORY DATA ANALYSIS OF CORONOVIRUS DEATHS RATE AND VACCINATION IMPACT. 

DATA FROM COVID19 DATASET

*/

--1. GETTING THE DATA
--We take a look at the content of the data we have.
SELECT *
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL;

SELECT *
FROM portfolioproject.dbo.covidvaccinations
WHERE continent IS NOT NULL;

-------------------------------------------------------------------------------------------------------

--2. EXPLORING THE DATA FOR A BETTER GRASP OF INFORMATION

--A. We selected the data we will be making use of in the analysis
SELECT location, date,population, total_cases, new_cases, total_deaths
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

--B. Looking at Total cases vs Total deaths
--This shows likelihood of a covid infected patient dying in all countries
SELECT  location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM portfolioproject.dbo.coviddeaths
where total_cases <> 0 AND continent IS NOT NULL
ORDER BY location, date;

--C. Showing the likelihood of a covid infected patient dying in Nigeira 
SELECT  location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM portfolioproject.dbo.coviddeaths
where total_cases <> 0 AND location LIKE '%nigeria%' AND continent IS NOT NULL
ORDER BY location, date;


--D. LOOKING AT TOTAL CASES VS POPULATION
--Showing what percentage of population got covid in Nigeria
SELECT  location, date, population, total_cases, 
(total_cases/population)*100 as percentage_population_infected
FROM portfolioproject.dbo.coviddeaths
WHERE location like '%nigeria%' AND continent IS NOT NULL
ORDER BY location, date;


--Showing what percentage of population got covid Globally
SELECT  location, date, population, total_cases, 
(total_cases/population)*100 as percentage_population_infected
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

--Looking at countries with highest infection rate compared to population
SELECT  location, population, date, MAX(total_cases) highest_infection_count, 
MAX((total_cases/population))*100 as percentage_population_infected
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY percentage_population_infected DESC;

--Showing the countries with highest death count by population
SELECT  location, population, date, MAX(total_deaths) as total_death_count, 
MAX((total_deaths/population))*100 as percentage_population_deaths
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY  percentage_population_deaths DESC;


--E. Showing the continent with the highest death count
SELECT continent, MAX(total_deaths) as total_death_count, 
MAX((total_deaths/population))*100 as max_percentage_population_deaths
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC, max_percentage_population_deaths DESC;


--F. GLOBAL NUMBERS
--Showing the increment cases globally
SELECT SUM(new_deaths) as total_newdeaths, SUM(new_cases) as total_newcases, 
(SUM(new_deaths)/ SUM(new_cases))*100 as death_percentageincrement
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY total_newdeaths;

SELECT SUM(total_deaths) as total_deaths, SUM(total_cases) as total_cases, 
(SUM(new_deaths)/ SUM(new_cases))*100 as death_percentageincrement
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY total_deaths;

--G. LOOKING AT VACCINATION INCREASE BY POPULATION
WITH popvsvas (continent, location, date, population, new_vaccination, Rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rollingpeoplevaccinated
FROM portfolioproject.dbo.coviddeaths dea
	JOIN portfolioproject.dbo.covidvaccinations vac
		ON dea.location=vac.location
			AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (Rollingpeoplevaccinated/population)*100 percentagevaccinated
FROM popvsvas
;


------------------------------------------------------------------------------------------------------------

--3. CREATING DATA VIEW TO HELP IN VISUALIZING ON TABLEAU

-- A. VIEW FOR VACCINATION INCREASE BY POPULATION
CREATE VIEW 
Rollingpercentagevaccinated AS

WITH popvsvas (continent, location, date, population, new_vaccination, Rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rollingpeoplevaccinated
FROM portfolioproject.dbo.coviddeaths dea
	JOIN portfolioproject.dbo.covidvaccinations vac
		ON dea.location=vac.location
			AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (Rollingpeoplevaccinated/population)*100 percentagevaccinated
FROM popvsvas;

select *
from Rollingpercentagevaccinated


--B. VIEW FOR THE LIKELIHOOD INFECTED PEOPLE MAY DIE
CREATE VIEW infecteddeathcount AS
SELECT  location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM portfolioproject.dbo.coviddeaths
where total_cases <> 0 AND continent IS NOT NULL
--ORDER BY location, date;


--C. VIEW FOR THE TOTAL CASES GLOBALLY
CREATE VIEW globaltotalcases AS
SELECT  location, date, population, total_cases, 
(total_cases/population)*100 as percentage_population_infected
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
--ORDER BY location, date;

--D. VIEW FOR COUNTRIES WITH HIGHEST INFECTION RATE BY POPULATION.
CREATE VIEW countrieshighestinfectedcount AS
SELECT  location, population, date, MAX(total_cases) highest_infection_count, 
MAX((total_cases/population))*100 as percentage_population_infected
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
--ORDER BY percentage_population_infected DESC;


--E. VIEW FOR COUNTRIES WITH HIGHEST DEATH COUNT BY POPULATION
CREATE VIEW countrieshighestdeathcount AS
SELECT  location, population, date, MAX(total_deaths) as total_death_count, 
MAX((total_deaths/population))*100 as percentage_population_deaths
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
--ORDER BY  percentage_population_deaths DESC;


--F. VIEW FOR CONTINENT WITH HIGHEST DEATH COUNT 
CREATE VIEW
continenthighestdeathcount AS
SELECT continent, MAX(total_deaths) as total_death_count, 
MAX((total_deaths/population))*100 as max_percentage_population_deaths
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY total_death_count DESC, max_percentage_population_deaths DESC;


--G. VIEW FOR GLOBAL COVID CASE INCREMENT 

CREATE VIEW globalcovidcaseincrement AS
SELECT SUM(new_deaths) as total_newdeaths, SUM(new_cases) as total_newcases, 
(SUM(new_deaths)/ SUM(new_cases))*100 as death_percentageincrement
FROM portfolioproject.dbo.coviddeaths
WHERE continent IS NOT NULL;
--GROUP BY date
--ORDER BY total_newdeaths;



------------------------------------------------------------------------------------------------------------------

/*SOME QUERIES TO LOOK AT*/ 

DROP TABLE IF EXISTS  portfolioproject.dbo.percentagepopulationvaccinated
CREATE TABLE  portfolioproject.dbo.percentagepopulationvaccinated
(
continent nvarchar(250),
location nvarchar(250),
date datetime, 
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

INSERT INTO  portfolioproject.dbo.percentagepopulationvaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rollingpeoplevaccinated
FROM portfolioproject.dbo.coviddeaths dea
	JOIN portfolioproject.dbo.covidvaccinations vac
		ON dea.location=vac.location
			AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;


SELECT *, (Rollingpeoplevaccinated/population)*100 percentagerollingpeoplevaccinatedpopulation
FROM  portfolioproject.dbo.percentagepopulationvaccinated ;


CREATE VIEW dbo.percentagepopulationvaccinatedview as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) Rollingpeoplevaccinated
FROM portfolioproject.dbo.coviddeaths dea
	JOIN portfolioproject.dbo.covidvaccinations vac
		ON dea.location=vac.location
			AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;



