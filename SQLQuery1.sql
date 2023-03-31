
SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccination$
--ORDER BY 3, 4


SELECT location,
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		population
FROM 
		PortfolioProject..CovidDeaths$
ORDER BY 1, 2


Select
	location,
	date,
	total_cases,
	population,
	(total_cases / population) * 100 as ActiveCasePercentage
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
Order by 1,2


--Showing countries with Highest Infection Count per Population
Select
	location,
	population,
	MAX (total_cases) as Highest_Infection_Count,
	MAX((total_cases / population)) * 100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
Group by location,
		population
Order by Percent_Population_Infected desc


--Showing countries with Highest Death Count per Population
Select
	location,
	MAX (cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
Where continent is not null
Group by location
Order by Total_Death_Count desc


--Break things down by Continent
Select
	continent,
	MAX (cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
Where continent is not null
Group by continent
Order by Total_Death_Count desc


--Global numbers
SELECT SUM(new_cases) as total_cases,
		SUM(Cast(new_deaths as int)) as total_deaths,
		SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM 
		PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
Where continent is not null
--Group by date
ORDER BY 1, 2

--Looking at Total Population vs Vaccinations
Select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccination$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE
With PopvsVac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated) as
(
Select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccination$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select 
	*,
	(rolling_people_vaccinated/population)*100
From PopvsVac


--Temp Table
Drop Table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #percent_population_vaccinated
Select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccination$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select 
	*,
	(rolling_people_vaccinated/population)*100
From #percent_population_vaccinated


--Creating View to store data for later visualizations
Create View percent_population_vaccinated as
Select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccination$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From percent_population_vaccinated