CREATE DATABASE carreteres;

use carreteres;
-- create tables
-- carreteres
CREATE TABLE carreteres(
    pk_id_carretera int NOT NULL PRIMARY KEY,
    codi_carretera int NOT NULL,
    nom_carretera varchar(20) NOT NULL,
    fk_id_titularitat int,
    fk_id_tipus_via int,
    fk_id_nivell int,
    acces_cont int,
    doble_cal int,
    prefix varchar(10),
    senyal varchar(10)
);
CREATE TABLE titularitat(
    pk_id_titularitat int NOT NULL PRIMARY KEY,
    titualritat varchar(30) NOT NULL UNIQUE
);
CREATE TABLE tipus_via(
    pk_id_tipus_via int NOT NULL PRIMARY KEY,
    via varchar(30) NOT NULL UNIQUE
);
CREATE TABLE nivell(
    pk_id_nivell int PRIMARY KEY,
    nivell ENUM("0","1","2","3") NOT NULL,
    color ENUM("groc","verd","taronja","0") NOT NULL
);
CREATE TABLE obs_carr(
    pk_id_obs int PRIMARY KEY,
    fk_id_carretera int,
    observacio VARCHAR(100)
);
-- trams
CREATE TABLE trams(
    pk_id_tram int PRIMARY KEY,
    km_inicial int NOT NULL,
    km_final int NOT NULL,
    velocitat_limit int,
    sentit varchar(10),
    carrils_danada int,
    carrils_tornada int,
    observacions varchar(100),
    longitud decimal(10,2) GENERATED ALWAYS AS (km_final - km_inicial) STORED,
    fk_id_carretera int,
    fk_id_tipus_tram int,
    fk_id_prov_ini int,
    fk_id_prov_fin int,
    fk_id_tipus_terreny int,
    fk_id_entorn int
);
CREATE TABLE tipus_tram(
    pk_id_tipus_tram int PRIMARY KEY,
    tipus_tram VARCHAR(20)
);
CREATE TABLE tipus_terreny(
    pk_id_tipus_terreny int PRIMARY KEY,
    tipus_terreny ENUM("pla","pujada","baixada")
);
CREATE TABLE entorns(
    pk_id_entorn int PRIMARY KEY,
    entorn ENUM("urba","travessa","extraurba")
);

--provincia
CREATE TABLE provincies(
    pk_id_provincia int PRIMARY KEY,
    nom_provincia VARCHAR(20),
    fk_id_ccaa int
);
CREATE TABLE comunitats_autonomes(
    pk_id_ccaa int PRIMARY KEY,
    comunitat_autonoma VARCHAR(20)
);

--confluencia
CREATE TABLE confluencies(
    pk_id_confluencia int PRIMARY KEY,
    km_tram1 int,
    km_tram2 int,
    fk_id_tram1 int,
    fk_id_tram2 int,
    fk_id_provincia int
);

-- establishing FK
-- carreteres
ALTER TABLE carreteres 
ADD CONSTRAINT carr_titul 
FOREIGN KEY (fk_id_titularitat) REFERENCES titularitat(pk_id_titularitat)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE carreteres 
ADD CONSTRAINT carr_tipusvia
FOREIGN KEY (fk_id_tipus_via) REFERENCES tipus_via(pk_id_tipus_via)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE carreteres 
ADD CONSTRAINT carr_nivell 
FOREIGN KEY (fk_id_nivell) REFERENCES nivell(pk_id_nivell)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE obs_carr
ADD CONSTRAINT obs_car_carre
FOREIGN KEY (fk_id_carretera) REFERENCES carreteres(pk_id_carretera)
ON UPDATE CASCADE 
ON DELETE RESTRICT;

--trams
ALTER TABLE trams
ADD CONSTRAINT tram_carre
FOREIGN KEY (fk_id_carretera) REFERENCES carreteres(pk_id_carretera)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE trams
ADD CONSTRAINT tram_tipus
FOREIGN KEY (fk_id_tipus_tram) REFERENCES tipus_tram(pk_id_tipus_tram)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE trams
ADD CONSTRAINT tram_tipuster
FOREIGN KEY (fk_id_tipus_terreny) REFERENCES tipus_terreny(pk_id_tipus_terreny)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE trams
ADD CONSTRAINT tram_entorn
FOREIGN KEY (fk_id_entorn) REFERENCES entorns(pk_id_entorn)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE trams
ADD CONSTRAINT tram_prov_ini
FOREIGN KEY (fk_id_prov_ini) REFERENCES provincies(pk_id_provincia)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE trams
ADD CONSTRAINT tram_prov_fin
FOREIGN KEY (fk_id_prov_fin) REFERENCES provincies(pk_id_provincia)
ON UPDATE CASCADE 
ON DELETE RESTRICT;

-- provincies i ccaa
ALTER TABLE provincies
ADD CONSTRAINT prov_ccaa
FOREIGN KEY (fk_id_ccaa) REFERENCES comunitats_autonomes(pk_id_ccaa)
ON UPDATE CASCADE 
ON DELETE RESTRICT;

-- confluencies
ALTER TABLE confluencies
ADD CONSTRAINT confl_tram1
FOREIGN KEY (fk_id_tram1) REFERENCES trams(pk_id_tram)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE confluencies
ADD CONSTRAINT confl_tram2
FOREIGN KEY (fk_id_tram2) REFERENCES trams(pk_id_tram)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE confluencies
ADD CONSTRAINT confl_prov
FOREIGN KEY (fk_id_provincia) REFERENCES provincies(pk_id_provincia)
ON UPDATE CASCADE 
ON DELETE RESTRICT;




