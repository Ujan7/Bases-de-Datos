-- 1. Listar el nombre de la ciudad y el nombre del país de todas las ciudades que pertenezcan a países con una población menor a 10000 habitantes.

WITH
	little_countries AS (
		SELECT Name, Code, Population
		FROM country
		WHERE country.Population < 10000
	)
SELECT city.Name, little_countries.Name, little_countries.Population
FROM city
JOIN little_countries
ON city.CountryCode = little_countries.Code;

-- 2.Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.

WITH
	avg_population AS (
		SELECT AVG(Population) AS avg
		FROM city
	)
SELECT Name
FROM city
WHERE Population > (SELECT avg FROM avg_population);

-- 3. Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.

WITH 
	pop_target AS (
		SELECT Population as asian_pop
		FROM country
		WHERE country.Continent = "Asia"
		ORDER BY RAND()
		LIMIT 1
	)
SELECT Name
FROM city
WHERE city.Population >= (SELECT asian_pop from pop_target);

-- 4.Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes a cada uno de los idiomas oficiales del país.

SELECT cl.Language, cl.Percentage, cl.IsOfficial, c.Name 
FROM countrylanguage cl
JOIN country c 
ON c.Code = cl.CountryCode 
WHERE cl.IsOfficial = 'F'
  AND cl.Percentage > (
      SELECT MAX(sub_cl.Percentage)
      FROM countrylanguage sub_cl
      WHERE sub_cl.CountryCode = cl.CountryCode
        AND sub_cl.IsOfficial = 'T'
  );

-- 5. Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 y exista (en el país) al menos una ciudad con más de 100000 habitantes. (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).
 
 	-- Sin subquery
 SELECT DISTINCT c.Region, c.SurfaceArea, ci.Population 
 FROM country as c
 JOIN city as ci
 ON c.Code = ci.CountryCode
 WHERE c.SurfaceArea <= 1000 and ci.Population >= 100000;

	-- Con subquery
WITH 
	regions_target as (
		SELECT c.Region, c.Code, c.SurfaceArea
		FROM country as c
		WHERE c.SurfaceArea <= 1000
	)
SELECT DISTINCT regions_target.Region, regions_target.SurfaceArea, ci.Population 
FROM city AS ci
JOIN regions_target
ON regions_target.Code = ci.CountryCode
WHERE ci.Population > 100000;

-- 6. Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada. (Hint: Hay dos maneras de llegar al mismo resultado. Usando consultas escalares o usando agrupaciones, encontrar ambas).

	-- Con consulta escalar
SELECT c.Name, (
	SELECT MAX(ci.Population)
	FROM city ci
	WHERE c.Code = ci.CountryCode
)
FROM country c;

	-- Con agrupaciones
SELECT c.Name, MAX(ci.Population)
FROM country c
JOIN city ci 
ON c.Code = ci.CountryCode
GROUP BY c.Name;

-- 7. Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.
WITH 
	avg_speakers AS (
		SELECT AVG(cl.Percentage) AS avg
		FROM countrylanguage cl
		WHERE cl.IsOfficial LIKE "T"
	)
SELECT c.Name, cl.Language, cl.Percentage 
FROM country c
JOIN countrylanguage cl
ON c.Code = cl.CountryCode
WHERE cl.Percentage > (SELECT avg FROM avg_speakers) and cl.IsOfficial LIKE "F"

 
 
 
 
 
 
 
 
 
 
 
