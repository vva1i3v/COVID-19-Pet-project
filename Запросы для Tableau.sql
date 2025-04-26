/*
    Запросы для проекта в Tableau
*/

-- 1. Глобальные суммы случаев и смертей + процент смертности
SELECT 
    SUM(new_cases) AS ВсегоСлучаев,
    SUM(CAST(new_deaths AS SIGNED)) AS ВсегоСмертей,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS ПроцентСмертности
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 
    1, 2;

-- 2. Число смертей по странам, не входящим в континенты (например, страны без региона)
SELECT 
    location AS Страна,
    SUM(CAST(new_deaths AS SIGNED)) AS ВсегоСмертей
FROM 
    coviddeaths
WHERE 
    continent IS NULL 
    AND location NOT IN ('World', 'European Union', 'International')
GROUP BY 
    location
ORDER BY 
    ВсегоСмертей DESC;

-- 3. Страны с наивысшим уровнем заражения относительно населения
SELECT 
    location AS Страна,
    population AS Население,
    MAX(total_cases) AS МаксимумСлучаев,
    MAX((total_cases / population)) * 100 AS ПроцентНаселенияИнфицировано
FROM 
    coviddeaths
GROUP BY 
    location, population
ORDER BY 
    ПроцентНаселенияИнфицировано DESC;

-- 4. Аналогично, но с датами
SELECT 
    location AS Страна,
    population AS Население,
    date AS Дата,
    MAX(total_cases) AS МаксимумСлучаев,
    MAX((total_cases / population)) * 100 AS ПроцентНаселенияИнфицировано
FROM 
    coviddeaths
GROUP BY 
    location, population, date
ORDER BY 
    ПроцентНаселенияИнфицировано DESC;

-- 5. Общее количество вакцинированных по странам и датам
SELECT 
    dea.continent AS Континент,
    dea.location AS Страна,
    dea.date AS Дата,
    dea.population AS Население,
    MAX(vac.total_vaccinations) AS НакопленныеВакцинированные
FROM 
    coviddeaths dea
JOIN 
    covidvaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
GROUP BY 
    dea.continent, dea.location, dea.date, dea.population
ORDER BY 
    1, 2, 3;

-- 6. Глобальная сводка случаев и смертей
SELECT 
    SUM(new_cases) AS ВсегоСлучаев,
    SUM(CAST(new_deaths AS SIGNED)) AS ВсегоСмертей,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS ПроцентСмертности
FROM 
    coviddeaths
WHERE 
    continent IS NOT NULL
ORDER BY 
    1, 2;

-- 7. Смертность по странам без континентов
SELECT 
    location AS Страна,
    SUM(CAST(new_deaths AS SIGNED)) AS ВсегоСмертей
FROM 
    coviddeaths
WHERE 
    continent IS NULL
    AND location NOT IN ('World', 'European Union', 'International')
GROUP BY 
    location
ORDER BY 
    ВсегоСмертей DESC;

-- 8. Страны с наивысшим процентом инфицирования населения
SELECT 
    location AS Страна,
    population AS Население,
    MAX(total_cases) AS МаксимумСлучаев,
    MAX((total_cases / population)) * 100 AS ПроцентНаселенияИнфицировано
FROM 
    coviddeaths
GROUP BY 
    location, population
ORDER BY 
    ПроцентНаселенияИнфицировано DESC;

-- 9. Базовая таблица по странам, датам, населению и случаям
SELECT 
    location AS Страна,
    date AS Дата,
    population AS Население,
    total_cases AS ВсегоСлучаев,
    total_deaths AS ВсегоСмертей
FROM 
    coviddeaths
WHERE 
    continent IS NOT NULL
ORDER BY 
    1, 2;

-- 10. Использование CTE для расчёта процента вакцинированного населения
WITH PopvsVac (Континент, Страна, Дата, Население, НовыеВакцинации, НакопленныеВакцинированные) AS (
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
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    *, 
    (НакопленныеВакцинированные / Население) * 100 AS ПроцентВакцинированногоНаселения
FROM 
    PopvsVac;

-- 11. Страны с наивысшим уровнем заражения по датам
SELECT 
    location AS Страна,
    population AS Население,
    date AS Дата,
    MAX(total_cases) AS МаксимумСлучаев,
    MAX((total_cases / population)) * 100 AS ПроцентНаселенияИнфицировано
FROM 
    coviddeaths
GROUP BY 
    location, population, date
ORDER BY 
    ПроцентНаселенияИнфицировано DESC;
