DROP DATABASE IF EXISTS nomina;


-- nomina.sql

CREATE DATABASE IF NOT EXISTS nomina;
USE nomina;

-- tabla departamento
CREATE TABLE departamento(
  pk_departamento int AUTO_INCREMENT,
  departamento varchar(50) unique,
  primary key (pk_departamento)
);

-- tabla cargo
CREATE TABLE cargo(
  pk_cargo int AUTO_INCREMENT primary key,
  cargo varchar(50) unique
);

 -- tabla empleado
 CREATE TABLE empleado (
  pk_empleado int AUTO_INCREMENT primary key,
  apellido varchar(25) not null,
  nombre varchar(25) not null,
  sexo enum('Hombre', 'Mujer') not null,
  fecha_nacimiento date not null comment 'con esto se calculará la edad',
  estado_civil enum('Soltero', 'Casado', 'Divorciado', 'Viudo', 'Otro') not null,
  hijos int UNSIGNED default 0 ,
  fk_cargo integer,
  fk_departamento integer,
  fecha_contrato date not null,
  sueldo decimal(10,2) not null CHECK (sueldo > 700*12),
  retencion_sso decimal(10,2) GENERATED ALWAYS AS (sueldo * 0.047) STORED
);

-- foreign keys

ALTER TABLE empleado 
    ADD CONSTRAINT cargos_empleados
    FOREIGN KEY (fk_cargo) REFERENCES cargo(pk_cargo)
    ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
    ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

ALTER TABLE empleado 
    ADD CONSTRAINT departamentos_empleados
    FOREIGN KEY (fk_departamento) REFERENCES departamento(pk_departamento)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE empleado ADD COLUMN num_sso varchar(15);

ALTER TABLE empleado
    ADD CONSTRAINT sso_empleado UNIQUE(num_sso);

-- 5. Ahora que ya has hecho un trigger, inventa dos triggers para las tablas de la Base de Datos NOMINA.
-- trigger per posar els cognoms en majuscula
DELIMITER $$
CREATE TRIGGER majuscules_cognoms
BEFORE INSERT ON empleado
    FOR EACH ROW
    BEGIN
        SET NEW.apellido = UPPER(NEW.apellido);
    END;

DELIMITER ;

-- trigger per donar 500 euros més per fill
DELIMITER $$
CREATE TRIGGER plus_fills
BEFORE UPDATE ON empleado
    FOR EACH ROW
    BEGIN
        IF NEW.hijos > OLD.hijos THEN
            SET NEW.sueldo = NEW.sueldo + ((NEW.hijos - OLD.hijos) * 500);
        END IF;
    END;

DELIMITER ;


USE nomina;

-- insert departaments
INSERT INTO departamento (departamento) VALUES 
('Informàtica'),
('Recursos Humans'),
('Vendes'),
('Comptabilitat');

-- insert cargo
INSERT INTO cargo (cargo) VALUES 
('Desenvolupador Backend'),
('Tècnic de Selecció'),
('Comercial'),
('Cap de Departament');

-- insert empleados
INSERT INTO empleado (
    apellido, nombre, sexo, fecha_nacimiento, estado_civil, 
    hijos, fk_cargo, fk_departamento, fecha_contrato, sueldo, num_sso
) VALUES 
('Garcia', 'Anna', 'Mujer', '1992-05-14', 'Soltero', 0, 1, 1, '2022-03-01', 28000.00, '08-12345678-90'),
('Martínez', 'Marc', 'Hombre', '1985-11-20', 'Casado', 1, 4, 1, '2018-09-15', 42000.00, '08-98765432-10'),
('López', 'Carla', 'Mujer', '1990-02-10', 'Casado', 2, 2, 2, '2020-01-10', 26500.00, '08-55544433-22'),
('Sánchez', 'Jordi', 'Hombre', '1998-07-30', 'Soltero', 0, 3, 3, '2024-06-01', 21000.00, '08-11122233-44');

-- comprovació cognoms majuscula
SELECT pk_empleado, apellido, nombre, hijos, sueldo, retencion_sso FROM empleado;

-- update numero de fills
UPDATE empleado 
    SET hijos = 1 
    WHERE pk_empleado = 1;

-- comprovació nou sou
SELECT pk_empleado, apellido, nombre, hijos, sueldo, retencion_sso FROM empleado WHERE pk_empleado = 1;

