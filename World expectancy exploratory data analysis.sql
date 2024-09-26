# The next step involves we performing exploratory data analysis on our cleanup sets of data
#Let analyse the maximun and minimun life expectancy per country

SELECT country, min(`life expectancy`), max(`life expectancy`),
round(max(`life expectancy`)-min(`life expectancy`),1) as life_increase 
from world_life_expectancy.world_life_expectancy
GROUP BY country
HAVING min(`life expectancy`) <> 0
AND max(`life expectancy`) <> 0
ORDER BY life_increase DESC
;

# let find the average life expectancy BY YEAR
SELECT country, 
round(avg(`Life expectancy`),1) as Avg_life_expectancy_rates
FROM world_life_expectancy.world_life_expectancy
GROUP BY country 
ORDER BY Avg_life_expectancy_rates desc
;

# We will also analyse the relationship between the life expectancy and the GDP of various countries. 

SELECT Country, `Life expectancy`, 
round(avg(GDP),1) AS Avg_GDP
FROM world_life_expectancy.world_life_expectancy
where GDP <> 0
GROUP BY Country, `Life expectancy`
ORDER BY Avg_GDP DESC
;

# next we want to analyse high and low GDP countries from the year 2007 t0 2022
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0  END) AS High_Gdp_Count,
AVG(CASE WHEN GDP >= 1500 THEN  `Life expectancy` ELSE NULL END) as High_Gdp_life_expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0  END) AS Low_Gdp_Count,
AVG(CASE WHEN GDP <= 1500 THEN  `Life expectancy` ELSE NULL END) as Low_Gdp_life_expectancy
FROM world_life_expectancy.world_life_expectancy
;


SELECT STatus, count(DISTINCT(country)),
round(avg(`Life expectancy`),1) as Avg_life_exp
FROM world_life_expectancy.world_life_expectancy
GROUP BY Status
;

# let ANALYZE the data in relation to Adult mortality per country

SELECT Country, year,
`Life expectancy`,
`Adult Mortality`,
# Next we want to sum the adult mortality and break it by countries and order them by year so we can add them up structurally
sum(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY year) AS Rolling_Total
FROM world_life_expectancy.world_life_expectancy
WHERE country LIKE '%united%'
;

# Finally let compare the countries life expectancy in relation to their Body Mass index(BMI)
SELECT Country, 
round(avg(`Life expectancy`),1) AS Life_exp,
round(AVG(BMI),1) AS BMI
FROM world_life_expectancy.world_life_expectancy
GROUP BY Country
HAVING Life_exp > 0
AND BMI > 0
ORDER BY Life_exp DESC
;
