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
ALTER TABLE models 
ADD CONSTRAINT mod_mar 
FOREIGN KEY (fk_id_marca) REFERENCES marques(pk_id_marca)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE vehicles(
    pk_matricula int NOT NULL PRIMARY KEY,
    anys YEAR,
    fk_id_model int
);
ALTER TABLE vehicles 
ADD CONSTRAINT veh_mod 
FOREIGN KEY (fk_id_model) REFERENCES models(pk_id_model)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE camions(
    fk_matricula int NOT NULL PRIMARY KEY,
    tonelatge_max int
);
CREATE TABLE furgonetes(
    fk_matricula int NOT NULL PRIMARY KEY,
    capacitat_max int
);
ALTER TABLE furgonetes 
ADD CONSTRAINT fur_veh 
FOREIGN KEY (fk_matricula) REFERENCES vehicles(pk_matricula)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE camions 
ADD CONSTRAINT cam_veh 
FOREIGN KEY (fk_matricula) REFERENCES vehicles(pk_matricula)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

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
ALTER TABLE conductors 
ADD CONSTRAINT treball_conductors 
FOREIGN KEY (fk_dni) REFERENCES treballadors(pk_dni)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE administratius 
ADD CONSTRAINT treball_administratius 
FOREIGN KEY (fk_dni) REFERENCES treballadors(pk_dni)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE departaments(
    pk_id_departament int NOT NULL PRIMARY KEY,
    departament varchar(20) NOT NULL
);
ALTER TABLE administratius 
ADD CONSTRAINT admin_dep 
FOREIGN KEY (fk_id_departament) REFERENCES departaments(pk_id_departament)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE viatges(
    pk_id_viatge int NOT NULL PRIMARY KEY,
    origen varchar(20) NOT NULL,
    desti varchar(20) NOT NULL,
    fk_dni int, 
    fk_matricula int
);
ALTER TABLE viatges 
ADD CONSTRAINT viatge_conductor 
FOREIGN KEY (fk_dni) REFERENCES conductors(fk_dni)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE viatges 
ADD CONSTRAINT viatge_vehicle 
FOREIGN KEY (fk_matricula) REFERENCES vehicles(pk_matricula)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE admin_viatge(
    fk_id_viatge int NOT NULL,
    fk_dni int NOT NULL
);
ALTER TABLE admin_viatge 
ADD CONSTRAINT adminviat_viatge 
FOREIGN KEY (fk_id_viatge) REFERENCES viatges(pk_id_viatge)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE admin_viatge 
ADD CONSTRAINT adminviat_admin
FOREIGN KEY (fk_dni) REFERENCES administratius(fk_dni)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE trams_viatge(
    pk_fk_id_viatge int NOT NULL,
    pk_id_numtram int NOT NULL,
    distancia_km int,
    data_dinici DATE,
    data_final DATE,
    CONSTRAINT pk_schedule_prog_vols PRIMARY KEY (pk_fk_id_viatge, pk_id_numtram)
);
ALTER TABLE trams_viatge 
ADD CONSTRAINT tramsviatge_viatge
FOREIGN KEY (pk_fk_id_viatge) REFERENCES viatges(pk_id_viatge)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

-- DROP TABLE trams_viatge;
-- DROP DATABASE transports_db;

