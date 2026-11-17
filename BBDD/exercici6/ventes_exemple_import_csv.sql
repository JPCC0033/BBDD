DROP DATABASE IF EXISTS exemple_power_query;

CREATE DATABASE exemple_power_query;

use exemple_power_query;

-- SHOW VARIABLES LIKE 'secure_file_priv';


CREATE TABLE IF NOT EXISTS ventas (
 año INT,
 mes INT,
 id INT,
 Producto VARCHAR(100),
 Provincia VARCHAR(20),
 Ventas DECIMAL(10,2)
);

SET GLOBAL local_infile = 1;

LOAD DATA INFILE -- quitar LOCAL (ya lo pone la instrucción anterior en 8.4)
    'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/exemple_power_query_ventes.csv'
INTO TABLE ventas
CHARACTER SET latin1 -- cambiar el UTF8mb4 por latin1 que es el que usa Excel
FIELDS TERMINATED BY ',' -- Excel separa las columnas con ;
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT * FROM ventas;

    