/* 
The main goals of this Project are to create views that will be used later in Power BI and, 
to create queries to compare with the results obtained on the Power BI Report 
*/

-- Creating Views to be used for later Visualizations in Power BI

--( 1 ) This view shows the most important figures about Deaths from Covid all over the World

CREATE VIEW DeathFigures AS
SELECT iso_code,
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	new_deaths, 
	hosp_patients
FROM CovidProject.dbo.CovidDeaths

SELECT *
FROM DeathFigures
ORDER BY 1,2


--( 2 ) This view shows the most important figures about Covid Vaccinations all over the World

CREATE VIEW VaccinationsFigures AS
SELECT iso_code, 
	date, 
	total_tests, 
	new_tests, 
	positive_rate, 
	tests_units, 
	total_vaccinations, 
	people_vaccinated, 
	people_fully_vaccinated, 
	median_age, 
	aged_65_older, 
	aged_70_older
FROM CovidProject.dbo.CovidVaccinations

SELECT *
FROM VaccinationsFigures
ORDER BY 1,2


--( 3 ) This view shows information regarding the Locations in our Data

CREATE VIEW LocationInformation AS
SELECT iso_code, 
	continent, 
	location, 
	population
FROM CovidProject.dbo.CovidDeaths

SELECT *
FROM LocationInformation
ORDER BY 1,3


-- Queries to Compare Results with the Power BI Report

-- Global Numbers

-- Creating a Table to store the following Global figures for each country: 
-- Total Number of Cases, Total Number of Deaths and Total Number of Peolpe Fully Vaccinated

SELECT d.continent, 
	d.location, 
	MAX(d.population) AS Population, 
	MAX(d.total_cases) AS Total_Cases, 
	MAX(CAST(d.total_deaths AS INT)) AS Total_Deaths, 
	MAX(CAST(v.people_fully_vaccinated AS INT)) AS Total_People_Fully_Vaccinated
INTO GlobalTable  
FROM CovidProject.dbo.CovidDeaths d, 
	CovidProject.dbo.CovidVaccinations v
WHERE d.Continent IS NOT NULL
	AND d.location = v.location 
	AND d.date = v.date
GROUP BY d.Location, d.Continent, d.population


-- Visualizing this new table in Descending order of the Total Number of Deaths

SELECT *
FROM GlobalTable
ORDER BY 4 DESC


-- Calculating the Global Figures 

SELECT SUM(Total_Cases) AS Total_Cases_Global, 
	SUM(Total_Deaths) AS Total_Deaths_Global, 
	ROUND((SUM(Total_Deaths)/SUM(Total_Cases))*100, 2) AS DeathPercentage_Global,
	ROUND((SUM(CAST(Total_People_Fully_Vaccinated AS BIGINT))/SUM(Population))*100, 2) AS Fully_Vaccinated_Population_Rate
FROM GlobalTable


-- This query summarizes the Total Number of Covid Cases by Country in Descending order

SELECT Continent, 
	Location, 
	MAX(population) AS Population, 
	MAX(total_cases) AS TotalCasesCount
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, Continent
ORDER BY 4 DESC


-- This query summarizes the Total Number of Deaths due to Covid by Country in Descending order

SELECT Continent, 
	location, 
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, Continent
ORDER BY TotalDeathCount DESC


-- This query summarizes the Total Number of Deaths due to Covid by Continent in Descending order

SELECT Continent, 
	SUM(Total_Deaths) AS TotalDeathCount
FROM CovidProject.dbo.GlobalTable
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- This query summarizes the Total Number of People Fully Vaccinated in Descending order

SELECT Continent, 
	Location, 
	MAX(CAST(people_fully_vaccinated AS INT)) AS People_Fully_Vaccinated
FROM CovidProject.dbo.CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location, Continent
ORDER BY 3 DESC


-- Looking at the Total of Fully Vaccinated People vs Population
-- The following query shows what Percentage of the Population who were Fully Vaccinated in Descending order

SELECT Continent,
	Location, 
	MAX(population) AS Population, 
	ROUND((MAX(Total_People_Fully_Vaccinated)/MAX(Population))*100, 2) AS Percentage_PopulationFullyVaccinated
FROM CovidProject.dbo.GlobalTable
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY 4 DESC


-- Looking at the Total Cases vs Total Deaths
-- This query shows the likelihood of dying if you get Covid in each Country

SELECT Location, 
	MAX(total_cases) AS TotalCasesCount, 
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount, 
	ROUND((MAX(CAST(total_deaths AS INT))/MAX(total_cases))*100, 2) AS DeathPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC


-- Looking at the Total Cases vs Population
-- This query shows what Percentage of the Population got Covid in Descending order

SELECT Location, 
	MAX(population) AS Population, 
	MAX(total_cases) AS TotalCasesCount, 
	ROUND((MAX(total_cases)/MAX(population))*100, 2) AS Percentage_PopulationInfected
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC
