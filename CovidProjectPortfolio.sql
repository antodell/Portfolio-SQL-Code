SELECT * FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null

--Select data 

SELECT Location, Date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths
Order by 1,2

-- Looking at the total cases vs total deaths 

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'Argentina'
Order by 1,2

-- Death Percentage by Covid infection --

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location LIKE '%states'
Order by 1,2

-- Looking at Total Cases vs Population -- 
--shows what percentage of population got covid-- 
SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
Order by 1,2

--Sweden--

SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location LIKE '%Sweden%'
Order by 1,2

--Returns the full amount of deaths in Sweden

SELECT SUM (total_cases) AS TotalSweden
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location LIKE '%Sweden%' 

--What countries have the highest infection rate compared to Population-- 

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, 
Max((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, population
Order by InfectedPercentage desc

-- Showing countries with the Highest Death Count per Population-- 

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
Order by TotalDeathCount desc

-- Checking BY CONTINENT // Removing extras -- 
-- Visualization for Global Numbers-- 

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent NOT LIKE '%income%' 
AND continent NOT LIKE '%international'
AND continent NOT LIKE '%union%'
AND continent is not null 
GROUP BY continent
Order by TotalDeathCount desc

--

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%states%' 
WHERE continent is not null
GROUP BY continent
Order by TotalDeathCount desc

--- GLOBAL NUMBERS PER DAY -----

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(New_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Argentina'
where continent is not null 
group by date 
Order by 1,2

--Total cases--- 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(New_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Argentina'
where continent is not null 
--group by date 
Order by 1,2

--Next Table--

SELECT * 
FROM PortfolioProject..CovidVaccinations

--Looking at Total Population vs Vaccinations--

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3 

--Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3 

--How many people in that country is vaccinated-- 

--USE CTE--

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE 

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations--

CREATE VIEW TotalDeathCountPerContinent AS 
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent NOT LIKE '%income%' 
AND continent NOT LIKE '%international'
AND continent NOT LIKE '%union%'
AND continent is not null 
GROUP BY continent
--Order by TotalDeathCount desc

SELECT * 
FROM TotalDeathCountPerContinent 