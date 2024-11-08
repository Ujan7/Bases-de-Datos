-- 1. Devuelva la oficina con mayor número de empleados.

USE classicmodels;


SELECT o.officeCode, COUNT(e.employeeNumber) as total_employee
FROM offices o
JOIN employees e 
ON o.officeCode = e.officeCode
GROUP BY o.officeCode
ORDER BY total_employee DESC
LIMIT 1;

-- 2. ¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la mayor cantidad de productos?

CREATE VIEW total_orders_per_office AS (
    SELECT o.officeCode, COUNT(o2.orderNumber) AS total_orders
    FROM offices o 
    JOIN employees e 
        ON o.officeCode = e.officeCode 
    JOIN customers c 
        ON c.salesRepEmployeeNumber = e.employeeNumber 
    JOIN orders o2
        ON o2.customerNumber = c.customerNumber 
    GROUP BY o.officeCode
);
SELECT AVG(t.total_orders) AS average_orders
FROM total_orders_per_office t;

SELECT t.officeCode, t.total_orders
FROM total_orders_per_office t
ORDER BY t.officeCode DESC 
LIMIT 1;
 
-- 3. Devolver el valor promedio, máximo y mínimo de pagos que se hacen por mes.

SELECT MONTH(p.paymentDate) AS month,
	AVG(p.amount) AS amount, 
	MAX(p.amount) AS max_payment, 
	MIN(p.amount) AS min_payment
FROM payments p
GROUP BY month
ORDER BY month ASC;

-- 4. Crear un procedimiento "Update Credit" en donde se modifique el límite de crédito de un cliente con un valor pasado por parámetro.

DROP PROCEDURE IF EXISTS update_credit;

CREATE PROCEDURE update_credit(IN customer_name VARCHAR(50), customer_last_name VARCHAR(50) , new_credit_limit DECIMAL(10, 2))
BEGIN
	UPDATE customers c
	SET c.creditLimit = new_credit_limit
	WHERE c.contactFirstName = customer_name AND c.contactLastName = customer_last_name;
END;

CALL update_credit("Carine ", "Schmitt", 29000.00);

-- 5. Cree una vista "Premium Customers" que devuelva el top 10 de clientes que más dinero han gastado en la plataforma. La vista deberá devolver el nombre del cliente, la ciudad y el total gastado por ese cliente en la plataforma.

DROP VIEW IF EXISTS premium_customers;

CREATE VIEW premium_customers AS 
	SELECT c.customerName, c.city, SUM(p.amount) as total_payments
	FROM customers c
	JOIN payments p
	ON c.customerNumber = p.customerNumber
	GROUP BY c.customerName, c.city
	ORDER BY total_payments DESC 
	LIMIT 10;

SELECT * FROM premium_customers;

-- 6. Cree una función "employee of the month" que tome un mes y un año y devuelve el empleado (nombre y apellido) cuyos clientes hayan efectuado la mayor cantidad de órdenes en ese mes.

DROP FUNCTION IF EXISTS employee_of_the_month;

CREATE FUNCTION employee_of_the_month(by_month INT, by_year INT)
RETURNS VARCHAR(200)
DETERMINISTIC 
BEGIN
	DECLARE employee VARCHAR(200);
	
	SELECT CONCAT(e.firstName, "", e.lastName) INTO employee
	FROM employees e
	JOIN customers c
	ON e.employeeNumber = c.salesRepEmployeeNumber
	JOIN orders o
	ON c.customerNumber = o.customerNumber
	WHERE MONTH(o.orderDate) = by_month AND YEAR(o.orderDate) = by_year
	GROUP BY e.firstName, e.lastName
	ORDER BY COUNT(o.orderNumber) DESC 
	LIMIT 1;
	
	RETURN employee;
END;

SELECT employee_of_the_month(2, 2005);

-- 7. Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno con "products" y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`.

DROP TABLE IF EXISTS productRefillment;

CREATE TABLE productRefillment(
	refillmentID INT,
	productCode VARCHAR(15),
	orderDate DATE,
	quantity INT,
	
	PRIMARY KEY (refillmentID),
	FOREIGN KEY (productCode) REFERENCES products(productCode)
);

-- 8.Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados en `orderdetails` y cada vez que se agregue una nueva orden revise la cantidad de productos pedidos (`quantityOrdered`) y compare con la cantidad en stock (`quantityInStock`) y si es menor a 10 genere un pedido en la tabla "Product Refillment" por 10 nuevos productos.

CREATE TRIGGER restockProduct AFTER INSERT ON orderdetails
FOR EACH ROW 
BEGIN 
	DECLARE actualStock INT;

	SELECT (quantityInStock - NEW.quantityOrdered) INTO actualStock
	FROM products
	WHERE productCode = NEW.productCode;
	
	IF (10 > actualStock)
	THEN
		INSERT INTO productRefillment (productCode, quantity, orderDate)
        VALUES (NEW.productCode, 10, curdate());
	END IF;
END;

-- 9. Crear un rol "Empleado" en la BD que establezca accesos de lectura a todas las tablas y accesos de creación de vistas.

CREATE ROLE Empleado;
GRANT SELECT ON classicmodels.* TO Empleado;
GRANT CREATE VIEW ON classicmodels.* TO Empleado;







	


