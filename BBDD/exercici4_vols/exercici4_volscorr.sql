CREATE DATABASE vols_db;

use vols_db;

CREATE TABLE prog_vols(
    pk_id_progvol int NOT NULL PRIMARY KEY,
    num_vol int NOT NULL,
    fk_id_aeroport_sortida int,
    fk_id_aeroport_arribada int,
    fk_id_linia_aerea int
);
CREATE TABLE vols(
    pk_id_vols int NOT NULL PRIMARY KEY,
    num_vol int NOT NULL,
    nom_carretera varchar(20) NOT NULL,
    data_vol int,
    hora_vol int,
    places_buides int,
    model int
);
CREATE TABLE linies_aerees(
    pk_id_linia_aerea int NOT NULL PRIMARY KEY,
    num_vol int NOT NULL,
    linia_aerea varchar(20) NOT NULL
);
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
    model varchar(50) NOT NULL,
    capacitat int
);
CREATE TABLE aeroport_model(
    fk_codi_aeroport int NOT NULL,
    fk_id_model int NOT NULL,
    CONSTRAINT pk_id_aeroport_model PRIMARY KEY (fk_codi_aeroport, fk_id_model)
);
CREATE TABLE schedule_prog_vols(
    fk_id_progvol int,
    dia varchar(50),
    hora_sortida varchar(10),    
    CONSTRAINT pk_schedule_prog_vols PRIMARY KEY (fk_id_progvol, dia, hora_sortida)
);

ALTER TABLE prog_vols 
ADD CONSTRAINT pv_llaa 
FOREIGN KEY (fk_id_linia_aerea) REFERENCES linies_aerees(pk_id_linia_aerea)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE prog_vols 
ADD CONSTRAINT pv_aeroport_sortida 
FOREIGN KEY (fk_id_aeroport_sortida) REFERENCES aeroports(pk_codi_aeroport)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE prog_vols 
ADD CONSTRAINT pv_aeroport_arribada 
FOREIGN KEY (fk_id_aeroport_arribada) REFERENCES aeroports(pk_codi_aeroport)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE aeroports 
ADD CONSTRAINT aeroports_ciutat 
FOREIGN KEY (fk_id_ciutat) REFERENCES ciutats(pk_id_ciutat)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE ciutats 
ADD CONSTRAINT ciutat_pais 
FOREIGN KEY (fk_id_pais) REFERENCES paisos(pk_id_pais)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE aeroport_model 
ADD CONSTRAINT aeroportmodel_aeroport 
FOREIGN KEY (fk_codi_aeroport) REFERENCES aeroports(pk_codi_aeroport)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE aeroport_model 
ADD CONSTRAINT aeroportmodel_model
FOREIGN KEY (fk_id_model) REFERENCES models(pk_id_model)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE schedule_prog_vols 
ADD CONSTRAINT spv_programa_vol 
FOREIGN KEY (fk_id_progvol) REFERENCES prog_vols(pk_id_progvol)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación






