USE transports_db;

-- taula marques
INSERT INTO marques (pk_id_marca, marca) VALUES
(1, 'Volvo'),
(2, 'Mercedes-Benz'),
(3, 'Ford'),
(4, 'Iveco');

-- taula models
INSERT INTO models (pk_id_model, model, fk_id_marca) VALUES
(1, 'FH16', 1),
(2, 'Actros', 2),
(3, 'Transit', 3),
(4, 'Daily', 4);

-- taula matricules
INSERT INTO vehicles (pk_matricula, anys, fk_id_model) VALUES
('4568DLM', 2021, 1),
('1234KKM', 2022, 2),
('7890KPT', 2023, 3),
('2456HJL', 2020, 4);

-- taula camions i furgonetes
INSERT INTO camions (fk_matricula, tonelatge_max) VALUES
('4568DLM', 24000),
('1234KKM', 18000);

INSERT INTO furgonetes (fk_matricula, capacitat_max) VALUES
('7890KPT', 1500),
('2456HJL', 1200);

-- taula departaments
INSERT INTO departaments (pk_id_departament, departament) VALUES
(1, 'Logística'),
(2, 'Recursos Humans'),
(3, 'Facturació');

-- taula treballadors
INSERT INTO treballadors (pk_dni, nom, cognom1, cognom2, telefon) VALUES
(11111111, 'Marc', 'Puig', 'Soler', 600111222),
(22222222, 'Laura', 'Vila', 'Roca', 600333444),
(33333333, 'Jordi', 'Ferrer', NULL, 600555666),
(44444444, 'Anna', 'Serra', 'Martí', 600777888),
(55555555, 'Pau', 'Gómez', 'Costa', 600999000);

-- taula conductors i administratius
INSERT INTO conductors (fk_dni, carnet, categoria) VALUES
(11111111, 987654, 'C+E'),
(22222222, 456789, 'C'), 
(33333333, 123456, 'B');

INSERT INTO administratius (fk_dni, fk_id_departament) VALUES
(44444444, 1),
(55555555, 3);

-- taula viatges
INSERT INTO viatges (pk_id_viatge, origen, desti, fk_dni, fk_matricula) VALUES
(1, 'Barcelona', 'Madrid', 11111111, '4568DLM'),
(2, 'Girona', 'València', 22222222, '1234KKM'),
(3, 'Tarragona', 'Lleida', 33333333, '7890KPT');

-- taula admin_viatge
INSERT INTO admin_viatge (fk_id_viatge, fk_dni) VALUES
(1, 44444444),
(1, 55555555),
(2, 44444444),
(3, 55555555);

-- taula trams_viatge
INSERT INTO trams_viatge (pk_fk_id_viatge, pk_id_numtram, distancia_km, data_dinici, data_final) VALUES
(1, 1, 305, '2026-11-10', '2026-11-10'),
(1, 2, 315, '2026-11-11', '2026-11-11'),
(2, 1, 450, '2026-11-12', '2026-11-12'),
(3, 1, 100, '2026-11-13', '2026-11-13');


-- inserts per a fer saltar els triggers
INSERT INTO viatges (pk_id_viatge, origen, desti, fk_dni, fk_matricula) VALUES
(4, 'Barcelona', 'Bilbao', 33333333, '4568DLM');
INSERT INTO trams_viatge (pk_fk_id_viatge, pk_id_numtram, distancia_km, data_dinici, data_final) VALUES
(4, 1, 100, '2026-11-13', '2026-11-12');
