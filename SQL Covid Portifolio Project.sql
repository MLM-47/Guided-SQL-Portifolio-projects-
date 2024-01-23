SELECT *
FROM CovidDeaths
WHERE continent is not null 
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date,total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2 

--Looking at Total Cases vs Total Deaths 
--Shows likelyhood of dying if you contract covid in your country 
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%kenya%'
ORDER BY 1,2 

--Looking at total cases vs population 
--Shows what percentage of population got covid 
SELECT location, date,total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE location like '%kenya%'
ORDER BY 1,2 

--Looking at what countries had the highest infections 
SELECT Location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeaths
--WHERE location like '%kenya%'
GROUP BY  Location, population
ORDER BY PercentagePopulationInfected DESC 

--Countries with the Highest Death Count per population 
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%kenya%'
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCount DESC 

--LETS BREAK IT DOWN BY CONTINENT 
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%kenya%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC 

--GLOBAL NUMBERS 
SELECT date,SUM(new_cases)AS SumNewCases,SUM(cast(new_deaths as int))AS SumNewDeathCases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage--total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%kenya%'
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2 

--Looking at Total Population vs Vaccinations 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
order by 2,3 

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3 


--CTE
WITH PopvsVac(continent, location, date,population,new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table 
DROP TABLE IF EXISTS #PercentVaccinated
CREATE TABLe #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric 
)

INSERT INTO #PercentVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
order by 2,3 

SELECT *,(RollingPeopleVaccinated/population)*100 
FROM #PercentVaccinated

--Creating view to store data for later visualizations 
CREATE VIEW  PercentVaccinated as 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3 

SELECT *
FROM PercentVaccinated