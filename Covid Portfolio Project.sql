Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4


--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likehood of dying if you get Covid in your County

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like 'Portugal'
where continent is not null
order by 1,2


--Looking at the Total Cases vs Population
--Shows what Percentage of the Population that got Covid

Select Location, date, population, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location like 'Portugal'
where continent is not null
order by 1,2


--Looking at Countries with Highest Infection rate compared to Population


Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like 'Portugal'
Group by location, population
order by PercentagePopulationInfected desc
where continent is not null


--Showing Countries with Highest Death Counts

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like 'Portugal'
where continent is not null
Group by location
order by TotalDeathCount desc


--Let's break things down by Continent
--Showing Continents with the Highest Death Count

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like 'Portugal'
where continent is not null
Group by Continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(New_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(New_cases))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like 'Portugal'
where continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations
--Use CTE (Common Table Expression)

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP Table

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated


--Creating View to Store Data for later Visualizations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentagePopulationVaccinated