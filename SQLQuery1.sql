--SELECT * 
--From PortfolioProject..CovidDeaths

--SELECT * 
--From PortfolioProject..CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths

-- Look at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercente
From PortfolioProject..CovidDeaths

SELECT location, Max(total_cases) all_cases, Max(total_deaths) all_deaths, Max((total_deaths/total_cases)*100) as DeathPercente
From PortfolioProject..CovidDeaths
Group By location
Order By all_cases desc

-- Looking at tolal cases vs population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths

SELECT location, Max(population) as population, Max(total_cases) as cases, Max((total_cases/population)*100) as PopulationPercentageInfected
From PortfolioProject..CovidDeaths
Group By location
Order by PopulationPercentageInfected desc

-- Compare percentage of population with covid and percentage of death

SELECT location, Max(population) as population, Max(total_cases) as cases, Max((total_cases/population)*100) as PopulationPercentageInfected,  
		Max((total_deaths/total_cases)*100) as DeathPercent
From PortfolioProject..CovidDeaths
Group By location
Order by PopulationPercentageInfected desc

-- Compare by continent 

SELECT location, Max(population) as population, Max(total_cases) as cases, Max((total_cases/population)*100) as PopulationPercentageInfected,  
		Max((total_deaths/total_cases)*100) as DeathPercent
From PortfolioProject..CovidDeaths
Where continent is null
Group By location
Order by PopulationPercentageInfected desc

-- Showing the continents with the highes deat count per population

SELECT continent, Max(population) as population, Max(cast(total_deaths as int)) As TotalDeaths
From PortfolioProject..CovidDeaths
group by continent
Order By TotalDeaths

-- GLOBAL NUMBERS

SELECT Sum(new_cases) as newCases, Sum(cast(new_deaths as int)) as NewDeaths, 
	(Sum(cast(new_deaths as int))/Sum(new_cases))*100 As TotalDeaths
From PortfolioProject..CovidDeaths 
where continent is not null 

-- By date

SELECT Date, Sum(new_cases) as newCases, Sum(cast(new_deaths as int)) as NewDeaths, 
	(Sum(cast(new_deaths as int))/Sum(new_cases))*100 As TotalDeaths
From PortfolioProject..CovidDeaths 
where continent is not null 
Group by date
Order By date

-- Joining tables
-- looking at total population vs vacinations
--CTE

With PopVsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
	Sum(Cast(CV.new_vaccinations as int)) Over (Partition By CV.location Order By CV.location,  CV.date) as RollinPeopleVaccinated
From PortfolioProject..CovidDeaths CD
	join PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopVsVac

-- Temp table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
	Sum(Cast(CV.new_vaccinations as int)) Over (Partition By CV.location Order By CV.location,  CV.date) as RollinPeopleVaccinated
From PortfolioProject..CovidDeaths CD
	join PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated

-- Create view for later visiliation 

create view GlobalNumbers as
SELECT Sum(new_cases) as newCases, Sum(cast(new_deaths as int)) as NewDeaths, 
	(Sum(cast(new_deaths as int))/Sum(new_cases))*100 As TotalDeaths
From PortfolioProject..CovidDeaths 
where continent is not null
