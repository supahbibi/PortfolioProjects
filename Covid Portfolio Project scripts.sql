-- where continent is null helps me to identify the continents from the countries 
Select *
From PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4 

-- Looking at Total Cases vs Total Death
-- shows likelihood of dying if you contract covid in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/ NULLIF(total_cases, 0 ))*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
WHERE Location = 'belgium'
order by 1,2

-- Looking at Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/NULLIF(population, 0 ))*100 AS Infection_Percentage
From PortfolioProject..CovidDeaths
WHERE Location = 'china'
order by 1,2

-- Looking for the country who has the highest rate of infection  compared to Population 
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/NULLIF(population, 0 )))*100 AS PercentPopulationInfected 
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing country with Highest Death Count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location
Order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT 

-- Showing the continents with the highest death count per population
Select continent, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..Coviddeaths
where continent is not null
group by continent 
order by TotalDeathCount desc

-- GLOBAL NUMBERS /this gives me the sum of new cases everyday in every world because we grouped it by date and not only by location, so we see the sum of all the world 
Select date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(NULLIF(New_deaths, 0))/Sum(NULLIF(New_cases, 0)) as DeathPercentage
From PortfolioProject..CovidDeaths
-- WHERE Location = 'belgium' and 
WHERE continent is not null 
Group by date
order by 1,2

--Total Cases and Deaths 
Select  SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(NULLIF(New_deaths, 0))/Sum(NULLIF(New_cases, 0)) as DeathPercentage
From PortfolioProject..CovidDeaths
-- WHERE Location = 'belgium' and 
WHERE continent is not null 
order by 1,2

--Viewing the other table
Select *
FROM PortfolioProject..CovidVaccinations 

Select *
FROM PortfolioProject..CovidDeaths

--Joining two tables 
SELECT * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE or Create a new column 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)/100
From PopvsVac

-- Temp table 
Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated (
Contnent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)/100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations 
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 -- order by 2,3

 Create VIEW PPV as Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 -- order by 2,3

 Select *
 From PPV