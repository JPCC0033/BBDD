CREATE DATABASE vols_db;

use vols_db;
-- create tables
-- programa de vols
CREATE TABLE prog_vols(
    pk_id_progvol int NOT NULL PRIMARY KEY,
    num_vol int NOT NULL UNIQUE,
    fk_id_aeroport_sortida int NOT NULL,
    fk_id_aeroport_arribada int NOT NULL,
    fk_id_linia_aerea int
);
CREATE TABLE vols(
    pk_id_vols int NOT NULL PRIMARY KEY,
    num_vol int NOT NULL,
    data_vol DATE NOT NULL,
    hora_vol TIME NOT NULL,
    places_buides int NOT NULL,
    fk_id_model int
);
CREATE TABLE linies_aerees(
    pk_id_linia_aerea int NOT NULL PRIMARY KEY,
    linia_aerea varchar(20) NOT NULL
);

-- aeroports
CREATE TABLE aeroports(
    pk_codi_aeroport int NOT NULL PRIMARY KEY,
    aeroport varchar(50) NOT NULL,
    fk_id_ciutat int
);
CREATE TABLE ciutats(
    pk_id_ciutat int NOT NULL PRIMARY KEY,
    ciutat varchar(50) NOT NULL,
    fk_id_pais int
);
CREATE TABLE paisos(
    pk_id_pais int NOT NULL PRIMARY KEY,
    pais varchar(50) NOT NULL
);
CREATE TABLE models(
    pk_id_model int NOT NULL PRIMARY KEY,
    model_avio varchar(50) NOT NULL,
    capacitat int NOT NULL
);

-- intermitges
CREATE TABLE aeroport_model(
    fk_codi_aeroport int NOT NULL,
    fk_id_model int NOT NULL,
    CONSTRAINT pk_id_aeroport_model PRIMARY KEY (fk_codi_aeroport, fk_id_model)
);
CREATE TABLE schedule_prog_vols(
    fk_id_progvol int,
    dia varchar(50),
    hora_sortida TIME,    
    CONSTRAINT pk_schedule_prog_vols PRIMARY KEY (fk_id_progvol, dia, hora_sortida)
);

-- establishing FK
-- programa de vols
ALTER TABLE prog_vols 
ADD CONSTRAINT pv_llaa 
FOREIGN KEY (fk_id_linia_aerea) REFERENCES linies_aerees(pk_id_linia_aerea)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE prog_vols 
ADD CONSTRAINT pv_aeroport_sortida 
FOREIGN KEY (fk_id_aeroport_sortida) REFERENCES aeroports(pk_codi_aeroport)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE prog_vols 
ADD CONSTRAINT pv_aeroport_arribada 
FOREIGN KEY (fk_id_aeroport_arribada) REFERENCES aeroports(pk_codi_aeroport)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE vols 
ADD CONSTRAINT vol_modelavio 
FOREIGN KEY (fk_id_model) REFERENCES models(pk_id_model)
ON UPDATE CASCADE 
ON DELETE RESTRICT;

-- aeroports
ALTER TABLE aeroports 
ADD CONSTRAINT aeroports_ciutat 
FOREIGN KEY (fk_id_ciutat) REFERENCES ciutats(pk_id_ciutat)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE ciutats 
ADD CONSTRAINT ciutat_pais 
FOREIGN KEY (fk_id_pais) REFERENCES paisos(pk_id_pais)
ON UPDATE CASCADE 
ON DELETE RESTRICT;

-- imntermitges
ALTER TABLE aeroport_model 
ADD CONSTRAINT aeroportmodel_aeroport 
FOREIGN KEY (fk_codi_aeroport) REFERENCES aeroports(pk_codi_aeroport)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE aeroport_model 
ADD CONSTRAINT aeroportmodel_model
FOREIGN KEY (fk_id_model) REFERENCES models(pk_id_model)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE schedule_prog_vols 
ADD CONSTRAINT spv_programa_vol 
FOREIGN KEY (fk_id_progvol) REFERENCES prog_vols(pk_id_progvol)
ON UPDATE CASCADE 
ON DELETE RESTRICT;




