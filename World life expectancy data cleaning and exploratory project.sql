#Firstly we need to write a query in order to identify the duplicate
SELECT country, year, concat(country, year), count(concat(country, year))
FROM world_life_expectancy.world_life_expectancy
GROUP BY country, year, concat(country, year)
# We need to filter on the aggregate function count(concat(country, year)
HAVING count(concat(country, year)) > 1
;
# Now that we have identifly the duplicate from HAVING count(concat(country, year)) > 1 we need to remove the duplicate

#In order for us to filter we need to use the statement as a subquery
SELECT *
from (
	SELECT row_id, 
	concat(country, year),
	#Partitioning on the concatination
	ROW_NUMBER() OVER(PARTITION BY concat(country, year) 
	ORDER BY concat(country, year)) as Row_num
	from world_life_expectancy.world_life_expectancy
    ) as row_table
    where row_num > 1
    ;
# we want to delete the duplicates
DELETE from world_life_expectancy.world_life_expectancy
WHERE
Row_ID IN (
SELECT Row_ID
from (
	SELECT row_id, 
	concat(country, year),
	#Partitioning on the concatination
	ROW_NUMBER() OVER(PARTITION BY concat(country, year) 
	ORDER BY concat(country, year)) as Row_num
	from world_life_expectancy.world_life_expectancy
    ) as row_table
    where row_num > 1
    )
;
# Duplicate deleted
SELECT *
from world_life_expectancy.world_life_expectancy
WHERE status = ''
;

SELECT DISTINCT Status
from world_life_expectancy.world_life_expectancy
WHERE status <> ''
;

# we can use the status as developing and populate the blank spaces for status
SELECT DISTINCT Country
from world_life_expectancy.world_life_expectancy
WHERE status ='Developing'
;

# we are going to joined the table to itself
UPDATE world_life_expectancy.world_life_expectancy t1
JOIN world_life_expectancy.world_life_expectancy t2
ON t1.country = t2.country 
SET t1.status = "developing"
WHERE t1. status = ''
And t2.status <> ''
And t2. status = 'developing'
;

# The duplicate has been removed, we need to populate that of united state

SELECT *
from world_life_expectancy.world_life_expectancy
WHERE country ='United States of America'
;
UPDATE world_life_expectancy.world_life_expectancy t1
JOIN world_life_expectancy.world_life_expectancy t2
ON t1.country = t2.country 
SET t1.status = "Developed"
WHERE t1. status = ''
And t2.status <> ''
And t2. status = 'Developed'
;

# the status for the US has been updated
SELECT *
from world_life_expectancy.world_life_expectancy
WHERE Status = NULL
;
# We dont have a NULL VALUE

# let drive and clean up the life expectancy column
SELECT *
from world_life_expectancy.world_life_expectancy
WHERE `Life expectancy` = ''
;

SELECT t1.country, t1.year, t1.`life expectancy`,
t2.country, t2.year, t2.`life expectancy`,
t3.country, t3.year, t3.`life expectancy`
from world_life_expectancy.world_life_expectancy t1
JOIN world_life_expectancy.world_life_expectancy t2
	ON t1.country = t2.country
    And t1.year = t2.year-1
JOIN world_life_expectancy.world_life_expectancy t3
ON t1.country = t3.country
    And t1.year = t3.year+1
WHERE t1.`life expectancy` = ''
;
# Next step is to take the average from table 2 and 3 and populate it to table 1

SELECT t1.country, t1.year, t1.`life expectancy`,
t2.country, t2.year, t2.`life expectancy`,
t3.country, t3.year, t3.`life expectancy`,
#rounding to one decimal spaces ROUND((t2.`life expectancy`+ t3.`life expectancy`)/2,1)
ROUND((t2.`life expectancy`+ t3.`life expectancy`)/2,1) 
from world_life_expectancy.world_life_expectancy t1
JOIN world_life_expectancy.world_life_expectancy t2
	ON t1.country = t2.country
    And t1.year = t2.year-1
JOIN world_life_expectancy.world_life_expectancy t3
ON t1.country = t3.country
    And t1.year = t3.year+1
WHERE t1.`life expectancy` = ''
;

# Next is to update table 1 with our calculation
UPDATE world_life_expectancy.world_life_expectancy t1
JOIN world_life_expectancy.world_life_expectancy t2
	ON t1.country = t2.country
    And t1.year = t2.year-1
    JOIN world_life_expectancy.world_life_expectancy t3
ON t1.country = t3.country
    And t1.year = t3.year+1
    SET t1.`life expectancy` = ROUND((t2.`life expectancy`+ t3.`life expectancy`)/2,1) 
;
SELECT *
from world_life_expectancy.world_life_expectancy
WHERE `Life expectancy` = ''
;
# Completely updated

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
