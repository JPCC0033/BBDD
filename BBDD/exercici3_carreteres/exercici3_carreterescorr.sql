CREATE DATABASE carreteres;

use carreteres;
-- create tables
-- carreteres
CREATE TABLE IF NOT EXISTS carreteres(
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
-- foreign keys
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

-- insert into the TABLE
INSERT INTO carreteres (pk_id_carretera, codi_carretera, nom_carretera, fk_id_titularitat, fk_id_tipus_via, fk_id_nivell, acces_cont, doble_cal, prefix, senyal) VALUES 
(10, 2, "A-2", 1, 1, 1, 1, 1, "A", "Blau"),
(20, 7, "AP-7", 1, 2, 1, 1, 1, "AP", "Blau"),
(30, 2, "N-II", 1, 3, 1, 0, 0, "N", "Vermell"),
(40, 32, "C-32", 2, 1, 2, 1, 1, "C", "Blau");

CREATE TABLE titularitat(
    pk_id_titularitat int NOT NULL PRIMARY KEY,
    titualritat varchar(30) NOT NULL UNIQUE
);

-- insert into the table
INSERT INTO titularitat (pk_id_titularitat, titualritat) VALUES 
(1, "Estatal"),
(2, "Autonómica"),
(3, "Provincial"),
(4, "Municipal");

CREATE TABLE tipus_via(
    pk_id_tipus_via int NOT NULL PRIMARY KEY,
    via varchar(30) NOT NULL UNIQUE
);

-- insert into the table
INSERT INTO tipus_via (pk_id_tipus_via, via) VALUES 
(1, "Autovia"),
(2, "Autopista"),
(3, "Multicarril"),
(4, "Convencional");

CREATE TABLE nivell(
    pk_id_nivell int PRIMARY KEY,
    nivell ENUM("0","1","2","3") NOT NULL,
    color ENUM("groc","verd","taronja","0") NOT NULL
);

-- insert into the table
INSERT INTO nivell (pk_id_nivell, nivell, color) VALUES 
(1, "0", "0"),
(2, "1", "taronja"),
(3, "2", "verd"),
(4, "3", "groc");

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

-- insert into the table
INSERT INTO tipus_tram (pk_id_tipus_tram, tipus_tram) VALUES 
(1, "Calçada única"),
(2, "Desdoblat");

CREATE TABLE tipus_terreny(
    pk_id_tipus_terreny int PRIMARY KEY,
    tipus_terreny ENUM("pla","pujada","baixada")
);
-- insert into the table
INSERT INTO tipus_terreny (pk_id_tipus_terreny, tipus_terreny) VALUES 
(1, "pla"),
(2, "pujada"),
(3, "baixada");

CREATE TABLE entorns(
    pk_id_entorn int PRIMARY KEY,
    entorn ENUM("urba","travessa","extraurba")
);
-- insert into the table
INSERT INTO entorns (pk_id_entorn, entorn) VALUES 
(1, "urba"),
(2, "travessa"),
(3, "extraurba");

--provincia
CREATE TABLE provincies(
    pk_id_provincia int PRIMARY KEY,
    nom_provincia VARCHAR(20),
    fk_id_ccaa int
);
-- foreign keys
ALTER TABLE provincies
ADD CONSTRAINT prov_ccaa
FOREIGN KEY (fk_id_ccaa) REFERENCES comunitats_autonomes(pk_id_ccaa)
ON UPDATE CASCADE ON DELETE RESTRICT;
-- Insert into the table
INSERT INTO provincies (pk_id_provincia, nom_provincia, fk_id_ccaa) VALUES 
(1, "Barcelona", 1),
(2, "Girona", 1),
(3, "Lleida", 1),
(4, "Tarragona", 1)
(5, "Castelló", 2),
(6, "València", 2),
(7, "Alacant", 2);   

CREATE TABLE comunitats_autonomes(
    pk_id_ccaa int PRIMARY KEY,
    comunitat_autonoma VARCHAR(20)
);
-- Insert into the table
INSERT INTO comunitats_autonomes (pk_id_ccaa, comunitat_autonoma) VALUES (1, "Catalunya");
INSERT INTO comunitats_autonomes (pk_id_ccaa, comunitat_autonoma) VALUES (2, "Valencia");











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




