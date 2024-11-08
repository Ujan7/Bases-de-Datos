-- 1.Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de Películas.

CREATE TABLE directors (
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  quantity_of_movies INT NOT NULL
);

-- 2.El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia (i.e. el mayor número de películas filmadas) son también directores de las películas en las que participaron. Basados en esta información, inserten, utilizando una subquery los valores correspondientes en la tabla `directors`.

INSERT INTO directors (first_name, last_name, quantity_of_movies)
SELECT a.first_name, a.last_name, COUNT(fa.film_id) AS quantity_of_movies
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY quantity_of_movies DESC
LIMIT 5;


-- 3.Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de acuerdo a si el cliente es "premium" o no. Por defecto ningún cliente será premium.

ALTER TABLE customer
ADD COLUMN premium_customer CHAR(1) NOT NULL DEFAULT 'F';


-- 4.Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` de los 10 clientes con mayor dinero gastado en la plataforma.

WITH top_10 AS (
    SELECT p.customer_id
    FROM payment p
    JOIN customer c 
    ON p.customer_id = c.customer_id 
    GROUP BY p.customer_id
    ORDER BY SUM(p.amount) DESC
    LIMIT 10
)
UPDATE customer cus
SET cus.premium_customer = 'T'
WHERE cus.customer_id IN (SELECT customer_id FROM top_10);

-- 5.Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings de las películas existentes (Hint: rating se refiere en este caso a la clasificación según edad: G, PG, R, etc).

SELECT f.rating, COUNT(f.film_id) as number_of_films
FROM film f
GROUP BY f.rating 
ORDER BY COUNT(f.film_id) DESC;

-- 6.¿Cuáles fueron la primera y última fecha donde hubo pagos?

	-- Ultimo pago
SELECT p.payment_date 
FROM payment p 
ORDER BY p.payment_date DESC 
LIMIT 1;

	-- Primer pago
SELECT p.payment_date 
FROM payment p 
ORDER BY p.payment_date ASC 
LIMIT 1;

	-- Usando MIN/MAX
SELECT MIN(payment_date), MAX(payment_date) FROM payment

-- 7.Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el nombre del mes de una fecha).

SELECT
	MONTH(p.payment_date) AS month,
	AVG(p.amount) AS avg_payment
FROM payment p 
GROUP BY MONTH(p.payment_date);

-- 8.Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total de alquileres).

WITH 
	payments AS (
		SELECT COUNT(p.rental_id) AS total_rental, c.first_name, c.address_id
		FROM payment p 
		JOIN customer c 
		ON c.customer_id = p.customer_id
		GROUP BY c.first_name, c.address_id
		ORDER BY total_rental DESC 
	)
SELECT addr.district, payments.total_rental
FROM address addr
JOIN payments 
ON addr.address_id = payments.address_id
LIMIT 10;

 -- Mas facil sin subquery
SELECT addr.district, COUNT(r.rental_id)
FROM address addr
JOIN customer c ON c.address_id = addr.address_id 
JOIN rental r ON r.customer_id = c.customer_id 
GROUP BY addr.district 

-- 9. Modifique la table `inventory_id` agregando una columna `stock` que sea un número entero y representa la cantidad de copias de una misma película que tiene determinada tienda. El número por defecto debería ser 5 copias.

ALTER TABLE inventory 
ADD COLUMN stock INT DEFAULT 5;

-- 10. Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla rental, haga un update en la tabla `inventory` restando una copia al stock de la película rentada (Hint: revisar que el rental no tiene información directa sobre la tienda, sino sobre el cliente, que está asociado a una tienda en particular).

CREATE TRIGGER update_stock 
AFTER INSERT ON rental 
FOR EACH ROW
BEGIN 
	UPDATE inventory
	SET
	stock = stock -1
	WHERE inventory.inventory_id = NEW.inventory.id
END



-- 11. Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es una clave foránea a la tabla rental y el segundo es un valor numérico con dos decimales.

CREATE TABLE fines (
	rental_id INT NOT NULL,
	amount DECIMAL (10, 2),
	
	FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 12. Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un registro en la tabla `fines` por cada `rental` cuya devolución (return_date) haya tardado más de 3 días (comparación con rental_date). El valor de la multa será el número de días de retraso multiplicado por 1.5.

CREATE PROCEDURE check_date_and_fine()
BEGIN
    INSERT INTO fines (rental_id, amount)
    SELECT r.rental_id, (DATEDIFF(r.return_date, r.rental_date) - 3) * 1.5 AS fine_amount
    FROM rental r
    WHERE r.return_date IS NOT NULL AND DATEDIFF(r.return_date, r.rental_date) > 3;
END;

CALL check_date_and_fine();

-- 13. Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a la tabla `rental`.

CREATE ROLE employee;

GRANT UPDATE, INSERT, DELETE on sakila.rental
TO employee;

-- 14. Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que tenga todos los privilegios sobre la BD `sakila`.

REVOKE DELETE on sakila.rental
FROM employee;

CREATE ROLE admin;
GRANT ALL PRIVILEGES ON sekila.* TO admin;

-- 15. Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al otro de `administrator`.

CREATE ROLE junior_dev;
GRANT employee TO junior_dev;

CREATE ROLE senior_dev;
GRANT admin TO senior_dev;


