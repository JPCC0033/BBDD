USE nomina;

SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'nomina' 
      AND TABLE_NAME = 'empleados'
    ORDER BY ORDINAL_POSITION;

SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'nomina' 
      AND TABLE_NAME = 'cargos'
    ORDER BY ORDINAL_POSITION;

SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'nomina' 
      AND TABLE_NAME = 'departamentos'
    ORDER BY ORDINAL_POSITION;
-- Composición interna (INNER JOIN)
-- 1. Lista el nombre y apellido de los empleados, su sueldo y el nombre del departamento donde trabaja.
SELECT nombre, 
       apellido, 
       sueldo, 
        departamentos.departamento
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento;

-- 2. Lista el nombre y apellido de los empleados, su fecha de contrato y el nombre del cargo.
SELECT nombre, 
        apellido, 
        fecha_contrato, 
        cargos.cargo
    FROM empleados
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo;

-- 3. Ordena el resultado por la fecha de contrato.
SELECT nombre, 
        apellido, 
        fecha_contrato, 
        cargos.cargo
    FROM empleados
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    ORDER BY fecha_contrato;

-- 4. Lista el código del empleado, su nombre y apellido, el código del departameto y el nombre del departamento de los empleados que ganen más de 2000€.
SELECT pk_empleado,
        nombre, 
        apellido, 
        sueldo,
        ROUND(sueldo / 12, 2) AS sueldo_mensual,
        departamentos.pk_departamento,
        departamentos.departamento
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento
    WHERE (sueldo/12) > 2000
    ORDER BY sueldo DESC;

-- 5. Indica el nombre, apellido y nombre del cargo del empleado más joven.
SELECT nombre, 
        apellido,
        fecha_nacimiento,
        cargos.cargo
    FROM empleados
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    ORDER BY fecha_nacimiento DESC
    LIMIT 1;

-- 6. Indica el nombre, apellido y nombre del departamento de los empleados que tengan hijos.
SELECT nombre, 
       apellido, 
       sueldo, 
       hijos,
       departamentos.departamento
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento
    WHERE hijos >=1;

-- 7. Lista todos los datos de los empleados de Contabilidad.
SELECT *
    FROM empleados
    WHERE fk_departamento IN (
          SELECT pk_departamento 
          FROM departamentos 
          WHERE departamento LIKE '%Contabilidad%'
    );

-- 8. Lista el nombre y apellido del empleado, el nombre del cargo y el del departamento de los empleados solteros sin hijos
SELECT nombre, 
       apellido, 
       sueldo, 
       hijos,
       estado_civil,
       departamentos.departamento,
       cargos.cargo
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    WHERE hijos = 0
        AND estado_civil = "Soltero";

-- 9. Lista los empleados de los departamentos de Compras y Ventas sin utilizar el operador IN.
SELECT *
FROM empleados
WHERE departamento = 'Compras' 
   OR departamento = 'Ventas';

-- 10.Lista los empleados de los departamentos de Compras y Ventas utilizando el operador IN.
SELECT *
FROM empleados
WHERE departamento IN ('Compras', 'Ventas');

-- 11. Lista el nombre y apellido del empleado, el nombre del cargo y del departamento de aquellas personas que tienen más de 20 años en la empresa.
    -- Ordena el resultado en primer lugar por el departamento (en orden ascendente) y en segundo lugar por el tiempo trabajado (en orden descendente)
SELECT nombre, 
       apellido, 
       sueldo, 
       fecha_nacimiento,
       fecha_contrato,
       departamentos.departamento,
       cargos.cargo
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    WHERE TIMESTAMPDIFF(YEAR, fecha_contrato, CURDATE()) > 20
    ORDER BY departamentos.departamento ASC,
             fecha_contrato ASC;

-- 12. Lista nombre y apellido, edad, nombre del cargo, nombre del departamento de los empleados Solteros, Divorciados o Viudos que tengan más de un hijo.
SELECT nombre, 
       apellido,
       TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) as edad,
       hijos,
       estado_civil,
       departamentos.departamento,
       cargos.cargo
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    WHERE hijos > 1
        AND estado_civil IN ("Soltero", "Divorciado", "Viudo");

-- 13. Lista todos departamentos registrados que existen en la base de datos, junto con el código, nombre y apellido del empleado que tiene cada uno de ellos.
    -- El listado deberá mostrar también aquellos departamentos que no tienen empleados asociados.
SELECT departamentos.departamento,
       empleados.pk_empleado,
       empleados.nombre,
       empleados.apellido
    FROM departamentos
        LEFT JOIN empleados ON departamentos.pk_departamento = empleados.fk_departamento;

-- 14. Lista todos cargos registrados que existen en la base de datos, junto con el nombre y apellido del empleado, la edad y estado civil que tiene cada empleado.
    -- El listado deberá mostrar también aquellos cargos que no tienen empleados asociados.
SELECT cargo,
       empleados.nombre,
       empleados.apellido,
       TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) as edad,
       empleados.estado_civil

    FROM cargos
        LEFT JOIN empleados ON cargos.pk_cargo = empleados.fk_cargo;

-- 15. Lista los departamentos sin empleados asociados.
SELECT departamento
    FROM departamentos
    LEFT JOIN empleados ON departamentos.pk_departamento = empleados.fk_departamento;
    WHERE empleados.fk_departamento IS NULL;

-- 16. ¿Se puede asignar a un empleado un cargo que no esté registrado en la tabla de cargos? Justifica tu respuesta.
/* No, un treballador no pot tenir un càrrec que no estigui registrat a la taula càrrecs. 
La restricció d'integritat referencial es trencaria ja que es necessita la FK de càrrecs a l'introduir aquesta dada.
*/