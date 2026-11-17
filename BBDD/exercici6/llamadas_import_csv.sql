DROP DATABASE IF EXISTS trucades;

CREATE DATABASE trucades;

use trucades;

-- SHOW VARIABLES LIKE 'secure_file_priv';


CREATE TABLE IF NOT EXISTS trucades_table (
 tipus_trucada varchar(50),
 desti varchar(50),
 telefon INT,
 fecha VARCHAR(50),
 telefon_desti INT,
 import_minut decimal(10,2),
 minuts INT,
 segons int,
 minuts_totals decimal(10,3)
);

SET GLOBAL local_infile = 1;

LOAD DATA INFILE -- quitar LOCAL (ya lo pone la instrucción anterior en 8.4)
    'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/llamadas_corretgit.csv'
INTO TABLE trucades_table
CHARACTER SET latin1 -- cambiar el UTF8mb4 por latin1 que es el que usa Excel
FIELDS TERMINATED BY ',' -- Excel separa las columnas con ;
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

ALTER TABLE trucades_table
    ADD COLUMN cost_total DECIMAL(10,2) GENERATED ALWAYS AS (import_minut * minuts_totals) STORED;

-- veure tota la taula
SELECT * FROM trucades_table;

-- veure el que ha gastat més en total
SELECT 
    telefon, 
    SUM(cost_total) AS gasto_total
FROM trucades_table
GROUP BY telefon
ORDER BY gasto_total DESC
LIMIT 1;

-- veure el que ha gastat més en una sola trucada
SELECT 
    telefon, 
    cost_total,
    telefon_desti, 
    minuts_totals
FROM trucades_table
ORDER BY cost_total DESC
LIMIT 1;
    