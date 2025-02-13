/* NIVEL 1 - EJERCICIO 2.1: Listado de paises que estan haciendo compras */
SELECT DISTINCT(c.country)
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id;

/* NIVEL 1 - EJERCICIO 2.2: Cantidad de paises que estan haciendo compras */
SELECT COUNT(DISTINCT(c.country)) AS Cantidad_Paises_Compras
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id;

/* NIVEL 1 - EJERCICIO 2.3: Compañia con el mayor promedio de ventas */
SELECT ROUND(AVG(t.amount),2) AS Promedio_Ventas, c.id, c.company_name
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
GROUP BY c.id
ORDER BY Promedio_Ventas DESC
LIMIT 1;

/* NIVEL 1 - EJERCICIO 2.3(extra): Compañia con el mayor promedio de ventas con correción por transacciones declinadas */
SELECT ROUND(AVG(t.amount),2) AS Promedio_Ventas, c.id, c.company_name
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
WHERE t.declined = FALSE
GROUP BY c.id
ORDER BY Promedio_Ventas DESC
LIMIT 1;

/* NIVEL 1 - EJERCICIO 3.1: Transacciones realizadas por empresas de Alemanania - Sin Usar JOINS */
SELECT *
FROM transaction AS t
WHERE t.company_id IN 
	(
	SELECT c.id
	FROM company AS c
	WHERE c.country = 'Germany'
	) ;

/*  NIVEL 1 - EJERCICIO 3.2: Lista de empresas que han realizado transacciones con un monto superior a al promedio de las transacciones - Sin Usar JOINS */
SELECT c.company_name
FROM company as c
WHERE c.id IN 
	(
	SELECT DISTINCT t.company_id
	FROM transaction AS t
	WHERE t.amount > 
		(
		SELECT AVG(amount) FROM transaction
		)
	);

/*  NIVEL 1 - EJERCICIO 3.2 (extra): Lista de empresas que han realizado transacciones con un monto superior a al promedio de las transacciones - Sin Usar JOINS */
SELECT c.company_name
FROM company as c
WHERE c.id IN 
	(
	SELECT DISTINCT t.company_id
	FROM transaction AS t
	WHERE t.amount > 
		(
		SELECT AVG(amount) FROM transaction AS t
        WHERE t.declined = FALSE
		)
	);

/*  NIVEL 1 - EJERCICIO 3.3: Identificación y eliminacion de empresas que no tienen transacciones registradas - Sin Usar JOINS */

SELECT c.company_name
FROM company AS c
WHERE c.id NOT IN 
	(
	SELECT DISTINCT t.company_id
	FROM transaction AS t
	) ;

DELETE FROM company AS c
WHERE c.id NOT IN 
	(
	SELECT DISTINCT t.company_id
	FROM transaction AS t
	) ;

#--------------------------------------------------------------------------#
/*  NIVEL 2 - EJERCICIO 1: Identificación de 5 dias con mayor transacciones. Datos de transacciones y monto de ventas */
SELECT SUM(t.amount) AS ingreso_diario, DATE(t.timestamp) AS fecha
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
WHERE t.declined = FALSE
GROUP BY fecha
ORDER BY ingreso_diario DESC
LIMIT 5;

/*  NIVEL 2 - EJERCICIO 2: Media de ventas por pais en orden descendente */
SELECT ROUND(AVG(t.amount),2) AS media_ventas_pais, country
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
WHERE t.declined = FALSE
GROUP BY country
ORDER BY media_ventas_pais DESC;

/*  NIVEL 2 - EJERCICIO 3: Análisis competitivo a empresa ¨Non Institute USANDO JOINS Y SUBCONSULTAS */
SELECT t.*
FROM transaction AS t
INNER JOIN company AS c
ON c.id = t.company_id
WHERE country =
	(
	SELECT c.country
	FROM company as c
	WHERE company_name = 'Non Institute'
	);

/*  NIVEL 2 - EJERCICIO 3: Análisis competitivo a empresa ¨Non Institute USANDO SUBCONSULTAS */
SELECT t.*
FROM transaction AS t
WHERE company_id IN 
	(
	SELECT c.id
	FROM company AS c
	WHERE c.country =
		(
		SELECT c.country
		FROM company as c
		WHERE company_name = 'Non Institute'
		)
	);

#--------------------------------------------------------------------------#
/*  NIVEL 3 - EJERCICIO 1: Extracción de datos con múltiples condiciones */
SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS fecha, t.amount
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
WHERE t.amount BETWEEN 100 AND 200
AND DATE(t.timestamp) IN ('2021-04-29' , '2021-07-20' , '2022-03-13')
AND t.declined = FALSE /*irrelevante en este caso */
ORDER BY t.amount DESC;

/*  NIVEL 3 - EJERCICIO 2: Conteo transacciones por empresa y creación de nueva variable calculada para categorizar */
SELECT c.company_name, COUNT(*) AS cantidad_transacciones, 
CASE
    WHEN COUNT(*) >= 4 THEN 'Más de 4 transacciones'
    WHEN COUNT(*) < 4 THEN 'Menos de 4 transacciones'
END AS Categoria_Cliente
FROM transaction AS t
INNER JOIN company AS c
ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY cantidad_transacciones DESC;

/*  NIVEL 3 - EJERCICIO 2: Conteo transacciones por empresa y creación de nueva variable calculada para categorizar */
/*SIN TRANSACCIONES DECLINADAS*/
SELECT c.company_name, COUNT(*) AS cantidad_transacciones, 
CASE
    WHEN COUNT(*) >= 4 THEN 'Más de 4 transacciones'
    WHEN COUNT(*) < 4 THEN 'Menos de 4 transacciones'
END AS Categoria_Cliente
FROM transaction AS t
INNER JOIN company AS c
ON c.id = t.company_id
WHERE t.declined = FALSE 
GROUP BY c.company_name
ORDER BY cantidad_transacciones DESC;