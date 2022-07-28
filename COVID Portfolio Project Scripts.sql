--COVID Death Count and Death Rate by Continent

SELECT continent, SUM(total_deaths) AS death_count, (total_deaths/population) * 100 AS death_rate
FROM covid_deaths
WHERE continent is NOT NULL
GROUP BY continent,total_deaths,population
ORDER BY death_count desc NULLS LAST;

--Global Daily COVID Statistics
SELECT date,SUM(new_cases) AS total_global_cases,SUM(new_deaths) AS total_global_deaths, SUM(new_deaths)/ SUM(new_cases) * 100 as death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date asc NULLS LAST

--Global COVID Totals
SELECT SUM(new_cases) AS total_global_cases,SUM(new_deaths) AS total_global_deaths, SUM(new_deaths)/ SUM(new_cases) * 100 as death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL

--Total Population vs Vaccinations

SELECT covid_deaths.continent, covid_deaths.location, covid_deaths.date, covid_deaths.population, covid_vaccinations.new_vaccinations,SUM(covid_vaccinations.new_vaccinations) OVER (PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date) AS Rolling_Vaccination_Total
FROM covid_deaths
INNER JOIN covid_vaccinations
ON covid_deaths.location = covid_vaccinations.location AND covid_deaths.date = covid_vaccinations.date
WHERE covid_deaths.continent IS NOT NULL
ORDER BY 2,3

--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccination_Total)
as
(SELECT covid_deaths.continent, covid_deaths.location, covid_deaths.date, covid_deaths.population, covid_vaccinations.new_vaccinations,SUM(covid_vaccinations.new_vaccinations) OVER (PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date) AS Rolling_Vaccination_Total
FROM covid_deaths
INNER JOIN covid_vaccinations
ON covid_deaths.location = covid_vaccinations.location AND covid_deaths.date = covid_vaccinations.date
WHERE covid_deaths.continent IS NOT NULL)

SELECT *, (Rolling_Vaccination_Total/Population) * 100
FROM PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255)
Location nvarchar(255)
Date datetime
Population numeric
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT covid_deaths.continent, covid_deaths.location, covid_deaths.date, covid_deaths.population, covid_vaccinations.new_vaccinations,SUM(covid_vaccinations.new_vaccinations) OVER (PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date) AS Rolling_Vaccination_Total
FROM covid_deaths
INNER JOIN covid_vaccinations
ON covid_deaths.location = covid_vaccinations.location AND covid_deaths.date = covid_vaccinations.date

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPeopleVaccinated

--Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT covid_deaths.continent, covid_deaths.location, covid_deaths.date, covid_deaths.population, covid_vaccinations.new_vaccinations,SUM(covid_vaccinations.new_vaccinations) OVER (PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date) AS Rolling_Vaccination_Total
FROM covid_deaths
INNER JOIN covid_vaccinations
ON covid_deaths.location = covid_vaccinations.location AND covid_deaths.date = covid_vaccinations.date
WHERE covid_deaths.continent IS NOT NULL



