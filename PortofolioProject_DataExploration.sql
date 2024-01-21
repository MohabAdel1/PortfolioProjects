
--Exploring the data 
SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is null



--Select  the data we are working from 
SELECT location, date ,continent, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths in Canada

SELECT location, date ,continent , total_cases, total_deaths, (total_deaths /total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location = 'Canada' and continent is not NUll
ORDER BY 1,2


--Looking at total cases vs population

SELECT location, date ,continent,population, total_cases, (total_cases /population)*100 as CasesPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NUll
ORDER BY 1,2

--Looking at highest infection rate compared to population

SELECT location,population ,continent, MAX(total_cases) as HighestInfectionCount, MAX((total_cases /population))*100 as InfectionRate
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NUll
GROUP BY location,population,continent
ORDER BY InfectionRate DESC

--Showing Countries with Highest Death Count per Population 
SELECT location ,continent, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NUll
GROUP BY location,continent
ORDER BY HighestDeathCount DESC


----- Let's Break things into continent
--Highest Death Count Per Continent
 SELECT continent, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NUll
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Highest Death Cases per Continent
 SELECT continent, MAX(CAST(total_cases as int)) as HighestCasesCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NUll
GROUP BY continent
ORDER BY HighestCasesCount DESC

--Looking at total cases vs population

SELECT continent ,Sum(new_cases)
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NUll
GROUP BY continent


---Breaking Everything into Global 

SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
order by 1,2



--Lets jump into some data about vaccinations
--Looking at Total Population vs Vaccination
SELECT dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(PARTITION BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidVaccinations vac
JOIN PortfolioProject1..CovidDeaths dea
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE to know the RollingPeopleVaccinated per country
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(PARTITION BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidVaccinations vac
JOIN PortfolioProject1..CovidDeaths dea
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From PopvsVac


--Looking into  Max Cases and Max vaccinations in one day
with VacPerCases (continent,location,date,population,new_vaccinations,new_cases,RollingPeopleVaccinated,RollingNewCasesCount) 
as 
(
SELECT dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,dea.new_cases,
SUM(convert(int,vac.new_vaccinations)) OVER(PARTITION BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated,
SUM(dea.new_cases) OVER(PARTITION BY dea.location Order by dea.location,dea.date) as RollingNewCasesCount
FROM PortfolioProject1..CovidVaccinations vac
JOIN PortfolioProject1..CovidDeaths dea
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)
select location,
MAX(RollingNewCasesCount) as MaxNewCases,
MAX(RollingPeopleVaccinated) as MaxNewVaccinations,
(MAX(RollingNewCasesCount)/MAX(RollingPeopleVaccinated))*100 as MaxNewCases_vs_MaxVacc
From VacPerCases
Where new_vaccinations is not null
and new_cases is not null
Group By Location


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
--Looking into PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT*
FROM PercentPopulationVaccinated
