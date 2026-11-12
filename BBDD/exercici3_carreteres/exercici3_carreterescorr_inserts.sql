use carreteres;

-- insert titularitat
INSERT INTO titularitat (pk_id_titularitat, titularitat) VALUES 
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

-- insert entorns
INSERT INTO obs_carr (pk_id_obs, fk_id_carretera, observacio) VALUES
(1, 20, "Sense peatges"),
(2, 40, "Amb peatges cars"),
(3, 30, "Accident múltiple a l'altura de Mataró"),
(4, 10, "Senglar aixafat per a conductor novell");


-- Insert CCAA
INSERT INTO comunitats_autonomes (pk_id_ccaa, comunitat_autonoma) VALUES (1, "Catalunya");
INSERT INTO comunitats_autonomes (pk_id_ccaa, comunitat_autonoma) VALUES (2, "Valencia");

-- Insert provincies
INSERT INTO provincies (pk_id_provincia, nom_provincia, fk_id_ccaa) VALUES 
(1, "Barcelona", 1),
(2, "Girona", 1),
(3, "Lleida", 1),
(4, "Tarragona", 1),
(5, "Castelló", 2),
(6, "València", 2),
(7, "Alacant", 2);

-- insert per a trams
INSERT INTO trams (pk_id_tram, km_inicial, km_final, velocitat_limit, sentit, carrils_danada, carrils_tornada, observacions, fk_id_carretera, fk_id_tipus_tram, fk_id_prov_ini, fk_id_prov_fin, 
    fk_id_tipus_terreny, fk_id_entorn) VALUES
(101, 445.00, 520.50, 120, "Doble", 2, 2, "Perill boira", 10, 2, 3, 3, 1, 3),
(102, 520.50, 585.00, 100, "Doble", 2, 2, "Compte amb el timbaler", 10, 2, 3, 1, 2, 3),
(201, 140.00, 215.80, 120, "Doble", 3, 3, "Zona de baixes emissions", 20, 2, 1, 4, 1, 3),
(202, 215.80, 345.00, 120, "Doble", 2, 2, "Zona d'accidents", 20, 2, 4, 5, 1, 3),
(301, 630.00, 645.20, 50, "Doble", 1, 1, "Sense problemes destacables", 30, 1, 1, 1, 1, 2),
(302, 645.20, 710.00, 90, "Doble", 1, 1, "Zona d'accidents", 30, 1, 1, 2, 2, 3),
(401, 15.00, 56.40, 120, "Doble", 2, 2, "Bona visibilitat", 40, 2, 1, 4, 3, 3);

-- insert erroni per a comprovar trigger
INSERT INTO trams (pk_id_tram, km_inicial, km_final, velocitat_limit, sentit, carrils_danada, carrils_tornada, observacions, fk_id_carretera, fk_id_tipus_tram, fk_id_prov_ini, fk_id_prov_fin, 
    fk_id_tipus_terreny, fk_id_entorn) VALUES
(402, 15.00, 14.40, 30, "Únic", 1, 1, "No va", 10, 2, 1, 4, 3, 3);

-- insert per a confluencies
INSERT INTO confluencies (
    pk_id_confluencia, km_tram1, km_tram2, fk_id_tram1, fk_id_tram2, fk_id_provincia) VALUES
(1, 582.30, 165.40, 102, 201, 1),
(2, 215.80, 56.40, 201, 401, 4),
(3, 645.20, 140.00, 302, 201, 1);