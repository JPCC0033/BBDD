DROP DATABASE IF EXISTS botiga_db;

CREATE DATABASE botiga_db;

use botiga_db;

-- taula fabricants
CREATE TABLE fabricants(
    pk_id_fabricant int NOT NULL PRIMARY KEY,
    nom_fabricant varchar(50) NOT NULL
);

-- taula productes
CREATE TABLE productes(
    pk_id_producte int NOT NULL PRIMARY KEY,
    nom_producte varchar(50) NOT NULL,
    preu DECIMAL(10,2),
    fk_id_fabricant int
);
-- foreign keys
ALTER TABLE productes 
    ADD CONSTRAINT prod_fabr 
    FOREIGN KEY (fk_id_fabricant) REFERENCES fabricants(pk_id_fabricant)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- trigger per posarho en majuscules
DELIMITER $$
CREATE TRIGGER majuscules
BEFORE INSERT ON fabricants
    FOR EACH ROW
    BEGIN
        SET NEW.nom_fabricant = UPPER(NEW.nom_fabricant);
    END;

DELIMITER ;


-- Inserts de fabricants
INSERT INTO fabricants (pk_id_fabricant, nom_fabricant) VALUES
(1, 'Asus'),
(2, 'Lenovo'),
(3, 'Hewlett-Packard'),
(4, 'Samsung'),
(5, 'Seagate'),
(6, 'Crucial'),
(7, 'Gigabyte'),
(8, 'Huawei'),
(9, 'Xiaomi');

-- Inserts de productes
INSERT INTO productes (pk_id_producte, nom_producte, preu, fk_id_fabricant) VALUES
(1, 'Disco duro SATA3 1TB', 86.99, 5),
(2, 'Memoria RAM DDR4 8GB', 120.00, 6),
(3, 'Disco SSD 1 TB', 150.99, 4),
(4, 'GeForce GTX 1050Ti', 185.00, 7),
(5, 'GeForce GTX 1080 Xtreme', 755.00, 6),
(6, 'Monitor 24 LED Full HD', 202.00, 1),
(7, 'Monitor 27 LED Full HD', 245.91, 1),
(8, 'Portátil Yoga 520', 559.00, 2),
(9, 'Portátil Ideapad 320', 444.00, 2),
(10, 'Impresora HP Deskjet 3720', 59.99, 3),
(11, 'Impresora HP Laserjet Pro M26nw', 180.00, 3);

-- Pujada del 15%

UPDATE productes
SET preu = preu * 1.15
WHERE fk_id_fabricant IN (
    SELECT pk_id_fabricant 
    FROM fabricants 
    WHERE nom_fabricant IN ('ASUS', 'LENOVO', 'SAMSUNG')
);

-- Pujada del 20% per a la resta
UPDATE productes
SET preu = preu * 1.20
WHERE fk_id_fabricant NOT IN (
    SELECT pk_id_fabricant 
    FROM fabricants 
    WHERE nom_fabricant IN ('ASUS', 'LENOVO', 'SAMSUNG')
);
