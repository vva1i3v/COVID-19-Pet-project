/*
    Исследование данных о Covid-19
*/

SELECT 
    *
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 
    3, 4;

-- Выборка данных, с которых начнём работу
SELECT 
    Location AS Страна,
    date AS Дата,
    total_cases AS ВсегоСлучаев,
    new_cases AS НовыеСлучаи,
    total_deaths AS ВсегоСмертей,
    population AS Население
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 
    1, 2;

-- Всего случаев против общего числа смертей
-- Показывает вероятность смерти при заражении Covid в вашей стране
SELECT 
    Location AS Страна,
    date AS Дата,
    total_cases AS ВсегоСлучаев,
    total_deaths AS ВсегоСмертей,
    (total_deaths / total_cases) * 100 AS ПроцентСмертности
FROM
    coviddeaths
WHERE
    location LIKE 'Russia%'
    AND continent IS NOT NULL
ORDER BY 
    1, 2;

-- Всего случаев против населения
-- Показывает процент населения, инфицированного Covid
SELECT 
    Location AS Страна,
    date AS Дата,
    Population AS Население,
    total_cases AS ВсегоСлучаев,
    (total_cases / population) * 100 AS ПроцентНаселенияИнфицировано
FROM
    coviddeaths
ORDER BY 
    1, 2;

-- Страны с наивысшим уровнем заражения относительно населения
SELECT 
    Location AS Страна,
    Population AS Население,
    MAX(total_cases) AS МаксимумСлучаев,
    MAX((total_cases / population)) * 100 AS ПроцентНаселенияИнфицировано
FROM
    coviddeaths
GROUP BY 
    Location, Population
ORDER BY 
    ПроцентНаселенияИнфицировано DESC;

-- Страны с наивысшим числом смертей по отношению к населению
SELECT 
    Location AS Страна,
    MAX(CAST(total_deaths AS SIGNED)) AS ВсегоСмертей
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY 
    Location
ORDER BY 
    ВсегоСмертей DESC;

-- Континенты с наивысшим числом смертей на душу населения
SELECT 
    continent AS Континент,
    MAX(CAST(total_deaths AS SIGNED)) AS ВсегоСмертей
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    ВсегоСмертей DESC;

-- Глобальная статистика
SELECT 
    SUM(new_cases) AS ВсегоСлучаев,
    SUM(CAST(new_deaths AS SIGNED)) AS ВсегоСмертей,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS ПроцентСмертности
FROM
    coviddeaths
WHERE
    continent IS NOT NULL;

-- Общее население против числа вакцинаций
-- Показывает процент населения, получившего хотя бы одну дозу вакцины
SELECT 
    dea.continent AS Континент,
    dea.location AS Страна,
    dea.date AS Дата,
    dea.population AS Население,
    vac.new_vaccinations AS НовыеВакцинации,
    SUM(CONVERT(vac.new_vaccinations, SIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS НакопленныеВакцинированные
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL 
    AND vac.new_vaccinations IS NOT NULL
ORDER BY 
    2, 3;

-- Использование CTE для расчёта с использованием Partition By
WITH PopvsVac AS (
    SELECT 
        dea.continent AS Континент,
        dea.location AS Страна,
        dea.date AS Дата,
        dea.population AS Население,
        vac.new_vaccinations AS НовыеВакцинации,
        SUM(CONVERT(vac.new_vaccinations, SIGNED)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS НакопленныеВакцинированные
    FROM
        coviddeaths dea
    JOIN
        covidvaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT 
    *, 
    (НакопленныеВакцинированные / Население) * 100 AS ПроцентВакцинации
FROM 
    PopvsVac;

-- Использование временной таблицы для расчёта с Partition By
DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Континент VARCHAR(255),
    Страна VARCHAR(255),
    Дата DATETIME,
    Население NUMERIC,
    НовыеВакцинации NUMERIC,
    НакопленныеВакцинированные NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(vac.new_vaccinations, SIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS НакопленныеВакцинированные
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

-- Вывод данных из временной таблицы
SELECT 
    *, 
    (НакопленныеВакцинированные / Население) * 100 AS ПроцентВакцинации
FROM
    PercentPopulationVaccinated;

-- Создание представления для дальнейших визуализаций
CREATE VIEW PercentPopulationVaccinated1 AS
SELECT 
    dea.continent AS Континент,
    dea.location AS Страна,
    dea.date AS Дата,
    dea.population AS Население,
    vac.new_vaccinations AS НовыеВакцинации,
    SUM(CONVERT(vac.new_vaccinations, SIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS НакопленныеВакцинированные
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;


