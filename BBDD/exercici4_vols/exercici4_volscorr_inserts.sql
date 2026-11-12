use vols_db;

-- insert paisos
INSERT INTO paisos (pk_id_pais, pais) VALUES
(1, 'Catalunya'),
(2, 'França'),
(3, 'Regne Unit'),
(4, 'Itàlia');
-- insert ciutats
INSERT INTO ciutats (pk_id_ciutat, ciutat, fk_id_pais) VALUES
(1, 'Barcelona', 1),
(2, 'La Seu d''Urgell', 1),
(3, 'París', 2),
(4, 'Londres', 3),
(5, 'Roma', 4);
-- insert aeroports
INSERT INTO aeroports (pk_codi_aeroport, aeroport, fk_id_ciutat) VALUES
(101, 'Josep Tarradellas Barcelona-El Prat', 1),
(102, 'Andorra-La Seu d''Urgell', 2),
(201, 'Paris Charles de Gaulle', 3),
(301, 'London Heathrow', 4),
(401, 'Roma Fiumicino', 5);

-- insert models
INSERT INTO models (pk_id_model, model_avio, capacitat) VALUES
(1, 'Airbus A320', 180),
(2, 'Boeing 737-800', 189),
(3, 'Airbus A350-900', 348),
(4, 'Boeing 787 Dreamliner', 290);

-- insert vols
INSERT INTO vols (pk_id_vols, num_vol, data_vol, hora_vol, places_buides, fk_id_model) VALUES
(1, '1001', '2026-11-16', '08:00:00', 25, 1),
(2, '1001', '2026-11-18', '08:00:00', 12, 1),
(3, '2045', '2026-11-17', '10:15:00', 40, 3),
(4, '3080', '2026-11-21', '12:00:00', 5, 4),
(5, '4012', '2026-11-22', '15:45:00', 60, 2);

-- insert llaa
INSERT INTO linies_aerees (pk_id_linia_aerea, linia_aerea) VALUES
(1, 'Vueling'),
(2, 'Iberia'),
(3, 'Air France'),
(4, 'British Airways');

-- insert aeroport_model
INSERT INTO aeroport_model (fk_codi_aeroport, fk_id_model) VALUES
(101, 1), (101, 2), (101, 3),
(102, 1), (102, 2), (102, 3), (102, 4),
(201, 1), (201, 3), (201, 4),
(301, 3), (301, 4),
(401, 1), (401, 2);

-- Insert programes de vol
INSERT INTO prog_vols (pk_id_progvol, num_vol, fk_id_aeroport_sortida, fk_id_aeroport_arribada, fk_id_linia_aerea) VALUES
(1, '1001', 101, 102, 1),
(2, '2045', 101, 201, 3),
(3, '3080', 102, 301, 4),
(4, '4012', 101, 401, 2);

-- insert erroni
INSERT INTO prog_vols (pk_id_progvol, num_vol, fk_id_aeroport_sortida, fk_id_aeroport_arribada, fk_id_linia_aerea) VALUES
(5, '9999', 102, 102, 1);

-- insert schedules
INSERT INTO schedule_prog_vols (fk_id_progvol, dia, hora_sortida) VALUES
(1, 'Dilluns', '08:00:00'),
(1, 'Dimecres', '08:00:00'),
(1, 'Divendres', '18:30:00'),
(2, 'Dimarts', '10:15:00'),
(2, 'Dijous', '10:15:00'),
(3, 'Dissabte', '12:00:00'),
(4, 'Diumenge', '15:45:00');
