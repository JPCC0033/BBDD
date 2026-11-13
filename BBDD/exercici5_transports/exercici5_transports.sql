DROP DATABASE IF EXISTS transports_db;

CREATE DATABASE transports_db;

use transports_db;

CREATE TABLE marques(
    pk_id_marca int NOT NULL PRIMARY KEY,
    marca varchar(20) NOT NULL
);
CREATE TABLE models(
    pk_id_model int NOT NULL PRIMARY KEY,
    model varchar(20) NOT NULL,
    fk_id_marca int

);
-- foreign keys
ALTER TABLE models 
    ADD CONSTRAINT mod_mar 
        FOREIGN KEY (fk_id_marca) REFERENCES marques(pk_id_marca)
        ON UPDATE CASCADE ON DELETE RESTRICT; 


CREATE TABLE vehicles(
    pk_matricula varchar(7) NOT NULL PRIMARY KEY,
    anys YEAR,
    fk_id_model int
);
-- foreign keys
ALTER TABLE vehicles 
    ADD CONSTRAINT veh_mod 
        FOREIGN KEY (fk_id_model) REFERENCES models(pk_id_model)
        ON UPDATE CASCADE ON DELETE RESTRICT; 


CREATE TABLE camions(
    fk_matricula varchar(7) NOT NULL PRIMARY KEY,
    tonelatge_max int
);
CREATE TABLE furgonetes(
    fk_matricula varchar(7) NOT NULL PRIMARY KEY,
    capacitat_max int
);
-- foreign keys
ALTER TABLE furgonetes 
    ADD CONSTRAINT fur_veh 
        FOREIGN KEY (fk_matricula) REFERENCES vehicles(pk_matricula)
        ON UPDATE CASCADE ON DELETE RESTRICT; 
ALTER TABLE camions 
    ADD CONSTRAINT cam_veh 
        FOREIGN KEY (fk_matricula) REFERENCES vehicles(pk_matricula)
        ON UPDATE CASCADE ON DELETE RESTRICT; 


CREATE TABLE treballadors(
    pk_dni int NOT NULL PRIMARY KEY,
    nom varchar(20) NOT NULL,
    cognom1 varchar(20) NOT NULL,
    cognom2 varchar(20),
    telefon int
);
CREATE TABLE conductors(
    fk_dni int NOT NULL PRIMARY KEY,
    carnet int NOT NULL,
    categoria varchar(20) NOT NULL
);
CREATE TABLE administratius(
    fk_dni int NOT NULL PRIMARY KEY,
    fk_id_departament int
);
-- foreign keys
ALTER TABLE conductors 
    ADD CONSTRAINT treball_conductors 
        FOREIGN KEY (fk_dni) REFERENCES treballadors(pk_dni)
        ON UPDATE CASCADE ON DELETE RESTRICT; 

ALTER TABLE administratius 
    ADD CONSTRAINT treball_administratius 
        FOREIGN KEY (fk_dni) REFERENCES treballadors(pk_dni)
        ON UPDATE CASCADE ON DELETE RESTRICT; 


CREATE TABLE departaments(
    pk_id_departament int NOT NULL PRIMARY KEY,
    departament varchar(20) NOT NULL
);
-- foreign keys
ALTER TABLE administratius 
    ADD CONSTRAINT admin_dep 
        FOREIGN KEY (fk_id_departament) REFERENCES departaments(pk_id_departament)
        ON UPDATE CASCADE ON DELETE RESTRICT; 


CREATE TABLE viatges(
    pk_id_viatge int NOT NULL PRIMARY KEY,
    origen varchar(20) NOT NULL,
    desti varchar(20) NOT NULL,
    fk_dni int, 
    fk_matricula varchar(7)
);
-- foreign keys
ALTER TABLE viatges 
    ADD CONSTRAINT viatge_conductor 
        FOREIGN KEY (fk_dni) REFERENCES conductors(fk_dni)
        ON UPDATE CASCADE ON DELETE RESTRICT, 
    ADD CONSTRAINT viatge_vehicle 
        FOREIGN KEY (fk_matricula) REFERENCES vehicles(pk_matricula)
        ON UPDATE CASCADE ON DELETE RESTRICT;

-- trigger per detectar si un conductor te el carnet correcte
DELIMITER $$

CREATE TRIGGER validar_carnet_conductor
BEFORE INSERT ON viatges
FOR EACH ROW
BEGIN
    DECLARE v_categoria VARCHAR(20);
    DECLARE v_es_camio INT;

    SELECT COUNT(*) INTO v_es_camio 
    FROM camions 
    WHERE fk_matricula = NEW.fk_matricula;

    IF v_es_camio > 0 THEN
        SELECT categoria INTO v_categoria 
        FROM conductors 
        WHERE fk_dni = NEW.fk_dni;

        IF v_categoria NOT IN ('C', 'C+E') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El conductor no té carnet de camió per a aquest vehicle.';
        END IF;
    END IF;
END

DELIMITER ;




CREATE TABLE admin_viatge(
    fk_id_viatge int NOT NULL,
    fk_dni int NOT NULL
);
-- foreign keys
ALTER TABLE admin_viatge 
    ADD CONSTRAINT adminviat_viatge 
        FOREIGN KEY (fk_id_viatge) REFERENCES viatges(pk_id_viatge)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT adminviat_admin
        FOREIGN KEY (fk_dni) REFERENCES administratius(fk_dni)
        ON UPDATE CASCADE ON DELETE RESTRICT; 

CREATE TABLE trams_viatge(
    pk_fk_id_viatge int NOT NULL,
    pk_id_numtram int NOT NULL,
    distancia_km int,
    data_dinici DATE,
    data_final DATE,
    CONSTRAINT pk_schedule_prog_vols PRIMARY KEY (pk_fk_id_viatge, pk_id_numtram)
);
-- foreign keys
ALTER TABLE trams_viatge 
    ADD CONSTRAINT tramsviatge_viatge
        FOREIGN KEY (pk_fk_id_viatge) REFERENCES viatges(pk_id_viatge)
        ON UPDATE CASCADE ON DELETE RESTRICT;

-- trigger perque data final no sigui anterior que data dinici
DELIMITER $$

CREATE TRIGGER validar_dates_tram
BEFORE INSERT ON trams_viatge
FOR EACH ROW
BEGIN
    IF NEW.data_final IS NOT NULL AND NEW.data_final < NEW.data_dinici THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La data final del tram no pot ser anterior a la data d inici.';
    END IF;
END

DELIMITER ;


