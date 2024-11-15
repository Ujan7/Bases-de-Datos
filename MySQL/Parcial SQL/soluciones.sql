-- 1. Listar las 7 propiedades con la mayor cantidad de reviews en el año 2024.

SELECT p.*, COUNT(r.id) as total_reviews
FROM properties p
JOIN reviews r
ON p.id = r.property_id
WHERE YEAR(r.created_at) = 2024
GROUP BY p.id
ORDER BY total_reviews DESC
LIMIT 7;

-- 2. Obtener los ingresos por reservas de cada propiedad. 

	-- Agrupo por reservas porque asumo que existen varias reservas por una misma propiedad.
SELECT p.*, SUM(DATEDIFF(b.check_out, b.check_in) * p.price_per_night) AS total_booking_income
FROM properties p
JOIN bookings b 
ON p.id = b.property_id
GROUP BY b.id;

-- 3. Listar los principales usuarios según los pagos totales. Esta consulta calcula los pagos totales realizados por cada usuario y enumera los principales 10 usuarios según la suma de sus pagos.

SELECT u.*, SUM(p.amount) AS total_amount_spent
FROM users u
JOIN bookings b
ON u.id = b.user_id
JOIN payments p
ON b.id = p.booking_id
GROUP BY u.id
ORDER BY total_amount_spent DESC 
LIMIT 10;

-- 4. Crear un trigger notify_host_after_booking que notifica al anfitrión sobre una nueva reserva. Es decir, cuando se realiza una reserva, notifique al anfitrión de la propiedad mediante un mensaje.

DROP TRIGGER IF EXISTS notify_host_after_booking;

CREATE TRIGGER notify_host_after_booking AFTER INSERT ON bookings
FOR EACH ROW 
BEGIN 
	DECLARE id_owner INT;
	DECLARE id_sender INT;
	DECLARE id_property INT;

	SELECT b.user_id INTO id_sender
	FROM bookings b
	WHERE b.user_id = NEW.user_id;

	SELECT p.owner_id INTO id_owner
	FROM properties
	WHERE p.id = NEW.property_id;

	SELECT p.id INTO id_property
	FROM properties p
	WHERE p.id = NEW.property_id;

	INSERT INTO messages (sender_id, receiver_id, property_id, content, sent_at)
	VALUES (id_sender, id_owner, id_property, "You have a new Booking!", NEW.created_at);
END;


-- 5. Crear un procedimiento add_new_booking  para agregar una nueva reserva. Este procedimiento agrega una nueva reserva para un usuario, según el ID de la propiedad, el ID del usuario y las fechas de entrada y salida. Verifica si la propiedad está disponible durante las fechas especificadas antes de insertar la reserva.

DROP PROCEDURE IF EXISTS add_new_booking;

CREATE PROCEDURE add_new_booking (IN idProperty INT, IN idUser INT, IN checkIn DATE, IN checkOut DATE)
BEGIN
	DECLARE available_f DATE;
	DECLARE available_t DATE;
	DECLARE status_s VARCHAR(50);

	SELECT pa.available_from INTO available_f
	FROM property_availability pa
	WHERE pa.property_id = idProperty;
	
	SELECT pa.available_to INTO available_t
	FROM property_availability pa
	WHERE pa.property_id = idProperty;

	SELECT pa.status INTO status_s
	FROM property_availability pa
	WHERE pa.property_id = idProperty;

	IF (checkIN >= available_f AND checkOut <= available_t AND status_s = "available") THEN 
		INSERT INTO bookings (property_id, user_id, check_in, check_out, total_price, status, created_at)
		VALUES (idProperty, idUser, checkIn, checkOut, 0, "confirmed", CURRENT_DATE());
		
		UPDATE property_availability pa
		SET pa.status = "blocked"
		WHERE pa.property_id = idProperty;
	END IF;
END;

-- 6. Crear el rol `admin` y asignarle permisos de creación sobre la tabla `properties` y permiso de actualización sobre la columna `status`  de la tabla `property_availability` .

CREATE ROLE admin;
GRANT CREATE ON properties to admin;
GRANT UPDATE (status) ON property_availability TO admin;

-- 7. Porque los datos no fueron cargados previamente por otra transaccion. Una vez que se ejecuta la transaccion, sus efectos no pueden modificarse sin ejecutar otra transaccion. 








