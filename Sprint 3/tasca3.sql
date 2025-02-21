/* NIVEL 1 - EJERCICIO 1: Creamos la tabla credit_card*/
  CREATE TABLE IF NOT EXISTS credit_card (
		id VARCHAR(20) PRIMARY KEY,
        iban VARCHAR(50) UNIQUE,
        pan VARCHAR(30) UNIQUE,
        pin VARCHAR(4),
        cvv VARCHAR(3),
        expiring_date VARCHAR(20)
    );

-- NIVEL 1 - EJERCICIO 1: Agregamos foreign key a tabla 'transaction'
-- referenciando a primary key de la tabla 'credit_card'
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);
  
/* Formato para agregar una foreign key, con nombre. Child table es la tabla de hechos
ADD CONSTRAINT fk_name
FOREIGN KEY (child_column)
REFERENCES parent_table (parent_column);*/
/* Forma alternativa de creat la foreign key, utilizando el formato anterior
ALTER TABLE transaction
ADD CONSTRAINT fk_creditcard_transaction
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);*/
/* Codigo utilizado para las pruebas. Borrar tablas y foreign keys:  
DROP TABLE credit_card

ALTER TABLE transaction
DROP CONSTRAINT transaction_ibfk_2;*/

/* NIVEL 1 - EJERCICIO 2: Cambio de un registro - IBAN*/
-- Revisamos valor antes del cambio
SELECT * FROM credit_card 
WHERE id = 'CcU-2938'; 

/* NIVEL 1 - EJERCICIO 2: Cambio de un registro - IBAN*/
-- realizamos el cambio 
UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938'; 

 -- Revisamos valor después del cambio
 SELECT * FROM credit_card 
 WHERE id = 'CcU-2938'; 

/* NIVEL 1 - EJERCICIO 3: Insertar datos nuevos a tabla ya creada - transaction*/
-- Insertamos datos de transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');
-- NO FUNCIONA, primero hay que poblar las tablas de dimensiones con los datos que los valores de las fk referencian.
/*
INSERT INTO company (id) 
VALUES ('b-9999');
SELECT * 
FROM company
WHERE id = 'b-9999';

INSERT INTO company (id) 
VALUES ('b-9999');
SELECT * 
FROM company
WHERE id = 'b-9999';
*/

/* NIVEL 1 - EJERCICIO 4: Eliminar columna de tabla*/
-- Eliminamos columna 'pan' de tabla 'credit_card'
ALTER TABLE credit_card
DROP COLUMN pan;
-- Revisamos si la columna fue eliminada
SELECT *
FROM credit_card;

#--------------------------------------------------------------------------#
/* NIVEL 2 - EJERCICIO 1: Eliminar registro (fila) de una tabla*/
-- DELETE FROM table_name WHERE condition;
-- Eliminamos registro
DELETE FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';
-- Revisamos si el registro fue eliminado
SELECT *
FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

/* NIVEL 2 - EJERCICIO 2: Creación de una VIEW*/
/*Sintaxis Creacion VIEW
CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;*/
CREATE VIEW VistaMarketing AS
SELECT company_name, phone, country, ROUND(AVG(t.amount),2) AS Media_Compras
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
GROUP BY company_name, phone, country
ORDER BY Media_Compras DESC;

/* NIVEL 2 - EJERCICIO 3: Selección de datos de una VIEW*/
SELECT *
FROM VistaMarketing
WHERE country = 'Germany'
ORDER BY Media_Compras DESC;

#--------------------------------------------------------------------------#
/* NIVEL 3 - EJERCICIO 1: Creacion de una Foreign Key transaction->user*/
ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES user(id);

/*Cambiamos el nombre de la tabla 'user' a 'data_user'*/
ALTER TABLE user
RENAME TO data_user;

/* NIVEL 3 - EJERCICIO 2: Seleccion de datos con de diversas tablas*/
/*Syntaxis multiples JOINS. 3 tablas de Dimensiones y 1 tabla de Hechos
SELECT 
    f.sale_id,
    c.customer_name,
    p.product_name,
    d.sale_date,
    f.sales_amount
FROM fact_sales f
INNER JOIN dim_customer c ON f.customer_id = c.customer_id
INNER JOIN dim_product p ON f.product_id = p.product_id
INNER JOIN dim_date d ON f.date_id = d.date_id;
*/
SELECT 
    t.id AS id_transaccion,
    data_user.name AS nombre,
	data_user.surname AS apellido,
	credit_card.id AS IBAN,
	company.company_name AS nombre_compañia
FROM transaction AS t
INNER JOIN company ON t.company_id = company.id
INNER JOIN credit_card ON t.credit_card_id = credit_card.id
INNER JOIN data_user ON t.user_id = data_user.id
ORDER BY id_transaccion DESC;