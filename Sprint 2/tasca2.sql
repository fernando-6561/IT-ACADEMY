/* NIVEL 1 - EJERCICIO 2.1: Listado de paises que estan haciendo compras */
SELECT DISTINCT(c.country)
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id;

/* NIVEL 1 - EJERCICIO 2.2: Cantidad de paises que estan haciendo compras */
SELECT COUNT(DISTINCT(c.country))
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id;

/* NIVEL 1 - EJERCICIO 2.3: Compañia con el mayor promedio de ventas */
SELECT ROUND(AVG(t.amount),2) AS 'Media de Ventas', c.id, c.company_name
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
GROUP BY c.id
ORDER BY ROUND(AVG(t.amount),2) DESC
LIMIT 1;

/* NIVEL 1 - EJERCICIO 2.3(extra): Compañia con el mayor promedio de ventas con correción por transacciones declinadas */
SELECT ROUND(AVG(t.amount),2) AS 'Media de Ventas', c.id, c.company_name
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
WHERE t.declined = FALSE
GROUP BY c.id
ORDER BY ROUND(AVG(t.amount),2) DESC
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
		SELECT AVG(amount) FROM transaction
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
