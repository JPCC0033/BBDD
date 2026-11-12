DROP DATABASE IF EXISTS vols_db;

CREATE DATABASE vols_db;

use vols_db;

-- taula països
CREATE TABLE paisos(
    pk_id_pais int NOT NULL PRIMARY KEY,
    pais varchar(50) NOT NULL
);

-- taula ciutats
CREATE TABLE ciutats(
    pk_id_ciutat int NOT NULL PRIMARY KEY,
    ciutat varchar(50) NOT NULL,
    fk_id_pais int
);
-- foreign keys
ALTER TABLE ciutats 
    ADD CONSTRAINT ciutat_pais 
    FOREIGN KEY (fk_id_pais) REFERENCES paisos(pk_id_pais)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- taula aeroports
CREATE TABLE aeroports(
    pk_codi_aeroport int NOT NULL PRIMARY KEY,
    aeroport varchar(50) NOT NULL,
    fk_id_ciutat int
);
-- foreign keys
ALTER TABLE aeroports 
    ADD CONSTRAINT aeroports_ciutat 
    FOREIGN KEY (fk_id_ciutat) REFERENCES ciutats(pk_id_ciutat)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- taula models
CREATE TABLE models(
    pk_id_model int NOT NULL PRIMARY KEY,
    model_avio varchar(50) NOT NULL,
    capacitat int NOT NULL
);

-- taula linies aeres
CREATE TABLE linies_aerees(
    pk_id_linia_aerea int NOT NULL PRIMARY KEY,
    linia_aerea varchar(50) NOT NULL
);


-- taula programa de vols
CREATE TABLE IF NOT EXISTS prog_vols(
    pk_id_progvol int NOT NULL PRIMARY KEY,
    num_vol varchar(15) NOT NULL UNIQUE,
    fk_id_aeroport_sortida int NOT NULL,
    fk_id_aeroport_arribada int NOT NULL,
    fk_id_linia_aerea int
);
-- foreign keys
ALTER TABLE prog_vols 
    ADD CONSTRAINT pv_llaa 
    FOREIGN KEY (fk_id_linia_aerea) REFERENCES linies_aerees(pk_id_linia_aerea)
    ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE prog_vols 
    ADD CONSTRAINT pv_aeroport_sortida 
    FOREIGN KEY (fk_id_aeroport_sortida) REFERENCES aeroports(pk_codi_aeroport)
    ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE prog_vols 
    ADD CONSTRAINT pv_aeroport_arribada 
    FOREIGN KEY (fk_id_aeroport_arribada) REFERENCES aeroports(pk_codi_aeroport)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- trigger per a comprovar que no arribem d'on sortim
DELIMITER $$
CREATE TRIGGER Take_of_far_away
BEFORE INSERT ON prog_vols
    FOR EACH ROW
    BEGIN
        IF NEW.fk_id_aeroport_sortida = NEW.fk_id_aeroport_arribada THEN
            SIGNAL SQLSTATE "45000"
            SET MESSAGE_TEXT = "Error al introduir les dades: Aquest programa de vol s'enlaira i aterra al mateix aeroport";
        END IF;
    END;

DELIMITER ;

-- taula vols
CREATE TABLE vols(
    pk_id_vols int NOT NULL PRIMARY KEY,
    num_vol varchar(15) NOT NULL,
    data_vol DATE NOT NULL,
    hora_vol TIME NOT NULL,
    places_buides int NOT NULL,
    fk_id_model int,
    CONSTRAINT placesbuides_positiu CHECK (places_buides >= 0)
);
-- foreign keys
ALTER TABLE vols 
    ADD CONSTRAINT vol_modelavio 
    FOREIGN KEY (fk_id_model) REFERENCES models(pk_id_model)
    ON UPDATE CASCADE ON DELETE RESTRICT;


-- taula aeroport_model
CREATE TABLE aeroport_model(
    fk_codi_aeroport int NOT NULL,
    fk_id_model int NOT NULL,
    CONSTRAINT pk_id_aeroport_model PRIMARY KEY (fk_codi_aeroport, fk_id_model)
);
-- foreign keys 
ALTER TABLE aeroport_model 
    ADD CONSTRAINT aeroportmodel_aeroport 
    FOREIGN KEY (fk_codi_aeroport) REFERENCES aeroports(pk_codi_aeroport)
    ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE aeroport_model 
    ADD CONSTRAINT aeroportmodel_model
    FOREIGN KEY (fk_id_model) REFERENCES models(pk_id_model)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- taula schedules
CREATE TABLE schedule_prog_vols(
    fk_id_progvol int,
    dia ENUM('Dilluns','Dimarts','Dimecres','Dijous','Divendres','Dissabte','Diumenge'),
    hora_sortida TIME,    
    CONSTRAINT pk_schedule_prog_vols PRIMARY KEY (fk_id_progvol, dia, hora_sortida)
);

-- foreign keys 
ALTER TABLE  schedule_prog_vols
    ADD CONSTRAINT spv_programa_vol 
    FOREIGN KEY (fk_id_progvol) REFERENCES prog_vols(pk_id_progvol)
    ON UPDATE CASCADE ON DELETE RESTRICT;





