-- Creamos la base de datos
CREATE DATABASE IF NOT EXISTS tasca4;
USE tasca4;

/*CREACION E INGRESO DE DATOS TABLA USERS*/
-- Creación tabla 'users'
CREATE TABLE IF NOT EXISTS users (
		id INT AUTO_INCREMENT PRIMARY KEY,
		name VARCHAR(20),
		surname VARCHAR(20),
		phone VARCHAR(20),
		email VARCHAR(100),
		birth_date DATE,
		country VARCHAR(20),
		city VARCHAR(40),
		postal_code VARCHAR(12),
		address VARCHAR(60)
);

SHOW VARIABLES LIKE 'local_infile';

-- Luego de revisar la consistencia de los 3 archivos csv de users, importamos los registros de las 3 tablas en una sola
-- IMPORTACION DE DATOS TABLAS USERS A UNA MISMA TABLA
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_usa.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_uk.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_ca.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

-- Revisamos la creacion de la tabla 'users'
SELECT *
FROM users;


/*CREACION E INGRESO DE DATOS TABLA CREDIT_CARDS*/
-- Creación tabla 'credit_cards'
CREATE TABLE IF NOT EXISTS credit_cards (
        id VARCHAR(10) PRIMARY KEY,
        user_id	INT,
        iban VARCHAR(40) UNIQUE,
        pan	VARCHAR(30) UNIQUE,
        pin	VARCHAR(12),
        cvv	VARCHAR(4),
        track1 VARCHAR(60),
        track2 VARCHAR(60),
        expiring_date DATE
);
        
-- IMPORTACION DE DATOS A TABLA CREDIT_CARDS
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
-- LINES TERMINATED BY '\r\n' (ESTO FALLA)
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date)
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

-- Revisamos la creacion de la tabla 'credit cards'
SELECT *
FROM credit_cards;


/*CREACION E INGRESO DE DATOS TABLA COMPANIES*/
-- Creación tabla 'companies'
CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(10) PRIMARY KEY,
        company_name VARCHAR(60),
        phone	VARCHAR(30) UNIQUE,
		email	VARCHAR(50) UNIQUE,
        country	VARCHAR(30),
        website VARCHAR(60)
);
					
-- IMPORTACION DE DATOS A TABLA COMPANIES
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Revisamos la creacion de la tabla 'companies'
SELECT *
FROM companies;


/*CREACION E INGRESO DE DATOS TABLA PRODUCTS*/
-- Creación tabla 'products'
CREATE TABLE IF NOT EXISTS products (
        id INT AUTO_INCREMENT PRIMARY KEY,
        product_name VARCHAR(60),
		price	DECIMAL(7,2),
		colour	VARCHAR(50),
        weight	DECIMAL(5,1),
        warehouse_id VARCHAR(10)
);
            
-- IMPORTACION DE DATOS A TABLA PRODUCTS
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv"
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id)
SET price = REPLACE(@price, '$', ''); -- cambiamos el simbolo '$' por nada para eliminarlo.

-- Revisamos la creacion de la tabla 'products'
SELECT *
FROM products;


/*CREACION E INGRESO DE DATOS TABLA TRANSACTIONS*/
-- Creación tabla 'transactions'
CREATE TABLE IF NOT EXISTS transactions (
		id VARCHAR(40) PRIMARY KEY,
		card_id VARCHAR(10),
		business_id VARCHAR(10),
		timestamp TIMESTAMP,
		amount DECIMAL(10, 2),
		declined BOOLEAN,
		product_ids VARCHAR(50),
		user_id INT,
		lat FLOAT,
		longitude FLOAT,
        FOREIGN KEY (card_id) REFERENCES credit_cards(id),
        FOREIGN KEY (business_id) REFERENCES companies(company_id),
		FOREIGN KEY (user_id) REFERENCES users(id)
);

-- IMPORTACION DE DATOS A TABLA TRANSACTIONS
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
-- Este archivo csv separa los datos por ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;							

-- Revisamos la creacion de la tabla 'transactions'
SELECT *
FROM transactions;

-- CREACION DE LA TABLA PUENTE ‘transactions_products’
CREATE TABLE transactions_products (
    id_transaction VARCHAR(40),
    id_product INT,
    -- quantity INT NOT NULL,  -- No lo incorporamos por ahora
    PRIMARY KEY (id_transaction, id_product),
    FOREIGN KEY (id_transaction) REFERENCES transactions(id),
    FOREIGN KEY (id_product) REFERENCES products(id)
);

DESCRIBE transactions_products;

-- IMPORTACION DE DATOS A TABLA TRANSACTIONS_PRODUCTS
INSERT INTO transactions_products (id_transaction, id_product)
SELECT 
    t.id AS id_transaction, -- lo podemos obtener directamente de la tabla 'transactions'
    CAST(j.id_product2 AS UNSIGNED) AS id_product -- hacemos un cambio de tipo de datos con CAST, de lo obtenido en JSON_TABLE a un numero positivo
FROM transactions AS t
JOIN JSON_TABLE(
    CONCAT('[', REPLACE(t.product_ids, ', ', ','),']'), -- agrego parentesis cuadrados, y elimino espacios entre productos
	'$[*]' -- todos los elementos dentro del array
    COLUMNS (id_product2 VARCHAR(255) PATH '$') -- los elementos seleccionados los quiero como registros separados
) AS j;

SELECT *
FROM transactions_products;

/* NIVEL 1 - EJERCICIO 1: Subconsulta*/
/*Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.*/
SELECT DISTINCT *
FROM users AS u
WHERE u.id IN
(
    SELECT user_id
    FROM transactions
    GROUP BY user_id
    HAVING COUNT(id) > 30
);


/* NIVEL 1 - EJERCICIO 2 Consulta*/
/*Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.*/
SELECT iban, ROUND(AVG(t.amount),2) AS media_compras -- agregar nombre compañia cuando esté todo conectado.
FROM credit_cards AS cc
INNER JOIN transactions AS t
ON cc.id = t.card_id 
AND business_id IN
(
    SELECT company_id
    FROM companies
    WHERE company_name = 'Donec Ltd'

)
GROUP BY iban
ORDER BY media_compras DESC;

/* NIVEL 2 - EJERCICIO 1 Creación tabla de transacciones declinadas*/
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si 
-- les últimes tres transaccions van ser declinades i genera la següent consulta:

CREATE TABLE card_status (
    card_id VARCHAR(10) PRIMARY KEY,
    status VARCHAR(10),
    FOREIGN KEY (card_id) REFERENCES credit_cards(id)
);

-- Subconsulta para ranking de transacciones por tarjeta, desde más nueva a más antigua.
SELECT  card_id,
        declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS orden,
        timestamp
FROM transactions;


-- Obtenemos un listado de todas las tarjetas, y de cuantas de las tres ultimas 3 transacciones han sido declinadas
WITH tarjetas_ordenadas AS
(
	SELECT 
	card_id,
	declined,
	ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS orden
	FROM transactions
)
SELECT card_id,
SUM(CASE WHEN declined = TRUE THEN 1 ELSE 0 END) AS suma_ultimas_tres_declinadas
FROM tarjetas_ordenadas
WHERE orden <= 3
GROUP BY card_id
ORDER BY suma_ultimas_tres_declinadas DESC;

-- Ingreso de datos a tabla 'card_status'
INSERT INTO card_status (card_id, status)
WITH tarjetas_ordenadas AS (
	SELECT 
	card_id,
	declined,
	ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS orden
    FROM transactions
    ),
ultimas_tres AS (
	SELECT 
	card_id,
	SUM(CASE WHEN declined = TRUE THEN 1 ELSE 0 END) AS suma_ultimas_tres_declinadas
    FROM tarjetas_ordenadas
    WHERE orden <= 3
    GROUP BY card_id)    
SELECT card_id,
CASE WHEN suma_ultimas_tres_declinadas = 3 THEN 'inactiva' ELSE 'activa' END AS status
FROM ultimas_tres;
---

SELECT *
FROM card_status;

-- Consulta: Quantes targetes estan actives?
SELECT COUNT(*) AS numero_tarjetas_activas
FROM card_status
WHERE status = 'activa';

/* NIVEL 3 - EJERCICIO 1: Creación y consulta en tabla puente*/
/*Necessitem conèixer el nombre de vegades que s'ha venut cada producte*/

SELECT *
FROM transactions_products
ORDER BY id_product;

SELECT p.*, COUNT(id_transaction) AS cantidad_ventas_producto
FROM transactions_products AS tp
INNER JOIN products AS p
ON tp.id_product = p.id
GROUP BY id_product;