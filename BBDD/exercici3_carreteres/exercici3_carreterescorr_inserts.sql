-- insert titularitat
INSERT INTO titularitat (pk_id_titularitat, titualritat) VALUES 
(1, "Estatal"),
(2, "Autonómica"),
(3, "Provincial"),
(4, "Municipal");
-- insert tipus_via
INSERT INTO tipus_via (pk_id_tipus_via, via) VALUES 
(1, "Autovia"),
(2, "Autopista"),
(3, "Multicarril"),
(4, "Convencional");
-- insert nivell
INSERT INTO nivell (pk_id_nivell, nivell, color) VALUES 
(1, "0", "0"),
(2, "1", "taronja"),
(3, "2", "verd"),
(4, "3", "groc");



-- insert carreteres
INSERT INTO carreteres (pk_id_carretera, codi_carretera, nom_carretera, fk_id_titularitat, fk_id_tipus_via, fk_id_nivell, acces_cont, doble_cal, prefix, senyal) VALUES 
(10, 2, "A-2", 1, 1, 1, 1, 1, "A", "Blau"),
(20, 7, "AP-7", 1, 2, 1, 1, 1, "AP", "Blau"),
(30, 2, "N-II", 1, 3, 1, 0, 0, "N", "Vermell"),
(40, 32, "C-32", 2, 1, 2, 1, 1, "C", "Blau");


-- insert tipus_tram
INSERT INTO tipus_tram (pk_id_tipus_tram, tipus_tram) VALUES 
(1, "Calçada única"),
(2, "Desdoblat");

-- insert tipus_terreny
INSERT INTO tipus_terreny (pk_id_tipus_terreny, tipus_terreny) VALUES 
(1, "pla"),
(2, "pujada"),
(3, "baixada");

-- insert entorns
INSERT INTO entorns (pk_id_entorn, entorn) VALUES 
(1, "urba"),
(2, "travessa"),
(3, "extraurba");

-- Insert provincies
INSERT INTO provincies (pk_id_provincia, nom_provincia, fk_id_ccaa) VALUES 
(1, "Barcelona", 1),
(2, "Girona", 1),
(3, "Lleida", 1),
(4, "Tarragona", 1)
(5, "Castelló", 2),
(6, "València", 2),
(7, "Alacant", 2);   

-- Insert CCAA
INSERT INTO comunitats_autonomes (pk_id_ccaa, comunitat_autonoma) VALUES (1, "Catalunya");
INSERT INTO comunitats_autonomes (pk_id_ccaa, comunitat_autonoma) VALUES (2, "Valencia");