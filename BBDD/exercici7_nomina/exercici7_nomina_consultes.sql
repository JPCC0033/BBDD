USE nomina;

-- 1. Lista los nombres de todos los empleados que hay en la tabla empleado.
SELECT nombre FROM empleados;
-- 2. Lista los nombres y los sueldos de todos los empleados de la tabla empleado.
SELECT nombre as NOM,sueldo as SOU FROM empleados;
-- 3. Lista todas las columnas (*) de la tabla empleado.
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'nomina' 
  AND TABLE_NAME = 'empleados';
-- 4. Lista el nombre + apellido de todos los empleados, su fecha de nacimiento y su fecha de contrato.
SELECT CONCAT(nombre," ",apellido) as 'nombre + apellido', fecha_nacimiento, fecha_contrato FROM empleados;
-- 5. Lista el nombre de los empleados, su apellido, el sexo e hijos.
SELECT nombre, apellido, sexo, hijos FROM empleados;
-- 6. Utiliza los siguientes alias para las columnas: nombre del empleado, apellido del empleado, sexo, número de hijos.
SELECT nombre as 'nombe del empleado',
        apellido as 'apellido del empleado',
        sexo as 'sexo',
        hijos as 'número de hijos'
    FROM empleados;
-- 7. Lista los nombres + apellidos y el sueldo de todos los empleados de la tabla empleado, mostrando los apellidos en mayúsculas (función UPPER).
SELECT CONCAT(nombre," ",UPPER(apellido)) as 'nom + COGNOM', 
        sueldo 
    FROM empleados;
-- 8. Lista los nombres + apellidos y estado civil de todos los empleados de la tabla empleado, mostrando el estado civil en minúscula (función LOWER).
SELECT CONCAT(nombre," ",apellido) as 'nom + cognom', 
        LOWER(estado_civil) as 'estat civil' 
    FROM empleados;

-- 9. Lista los nombres + apellidos de todos los empleados y calcula las iniciales de los mismos (primera letra del nombre y primera letra del apellido seguidas de punto.
    -- Ejemplo: Marcos Rodríguez sería M.R.). (función LEFT)
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        CONCAT(LEFT(nombre, 1), ".", LEFT(apellido, 1), ".") as 'inicials' 
    FROM empleados;

-- 10. Lista los nombres + apellidos de todos los empleados y calcula su edad a partir de la fecha de nacimiento.
    -- SELECT  FROM tabla;
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) AS edat
    FROM empleados;

-- 11. Lista los nombres + apellidos de todos los empleados y calcula su antigüedad a partir de la fecha del contrato.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        TIMESTAMPDIFF(YEAR, fecha_contrato, CURDATE()) AS antiguitat
    FROM empleados;

-- 12. Lista sin repetir el código de los cargos (fk_cargo) de la tabla empleado.
SELECT DISTINCT fk_cargo as cargos FROM empleados;

-- 13. Lista la tabla empleado ordenada de forma ascendente (ASC) por apellido y nombre.
SELECT * FROM empleados
    ORDER BY apellido ASC,
            nombre ASC;

-- 14. Lista la tabla empleado ordenada de forma descendente (DESC) por sueldos.
SELECT * FROM empleados
    ORDER BY sueldo DESC;

-- 15. Lista los empleados ordenados en primer lugar por el estado civil de forma ascendente y en segundo lugar el sueldo de forma descendente.
SELECT * FROM empleados
    ORDER BY estado_civil ASC,
            sueldo DESC;

-- 16. Devuelve una lista con las 3 primeras filas de la tabla cargo.
SELECT * FROM cargos
    LIMIT 3;

-- 17. Devuelve una lista con 2 filas a partir de la cuarta fila de la tabla departamento. La cuarta fila también se debe incluir en la respuesta
SELECT * FROM cargos
    LIMIT 2
    OFFSET 3;
    
-- Utilizando las cláusulas ORDER BY y LIMIT...
-- 18. Lista el nombre + apellido y el sueldo del empleado que gane menos sueldo.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        sueldo AS sou
    FROM empleados
    ORDER BY sueldo ASC
    LIMIT 1;

-- 19. Lista el nombre + apellido y la fecha de nacimiento del empleado de mayor edad.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        fecha_nacimiento AS 'data de naixement'
    FROM empleados
    ORDER BY fecha_nacimiento ASC
    LIMIT 1;

-- Cláusula WHERE y Operadores
-- 20.Lista el nombre de todos los empleados cuyo fk_departamento es igual a 2.
SELECT nombre as Nom 
    FROM empleados
    WHERE fk_departamento = 2;

-- 21. Lista nombre + apellido de los empleados que tienen un sueldo menor o igual a 15.000€.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        sueldo as sou
    FROM empleados
    WHERE sueldo <= 15000;

-- 22.Lista nombre + apellido de los empleados que tienen un sueldo mayor o igual a 40.000€.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        sueldo as sou
    FROM empleados
    WHERE sueldo >= 40000;

-- 23.Lista nombre + apellido de los empleados que no tienen un sueldo mayor o igual a 14.000€.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        sueldo as sou
    FROM empleados
    WHERE sueldo < 14000;

-- 24.Lista todos los empleados que tengan un sueldo entre 18.000€ y 25.000€. 
    -- Sin utilizar el operador BETWEEN.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        sueldo as sou
    FROM empleados
    WHERE sueldo > 18000 AND sueldo < 25000;
 
-- 25.Lista todos los empleados que tengan un sueldo entre 16.000€ y 20.000€. 
    -- Utilizando el operador BETWEEN.
SELECT CONCAT(nombre," ",apellido) as 'nom + cognom', 
        sueldo as sou
    FROM empleados
    WHERE sueldo BETWEEN 16000 AND 20000;

-- 26.Lista los empleados que tengan un sueldo mayor que 15.000€ y que el fk_departamento sea igual a 6.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        sueldo as sou
    FROM empleados
    WHERE sueldo > 15000 AND fk_departamento = 6;

-- 27. Lista los empleados donde el fk_cargo sea 1,3 o 5. 
    --  Sin utilizar el operador IN.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        fk_cargo as cargo,
        sueldo as sou
    FROM empleados
    WHERE fk_cargo = 1 
        OR  fk_cargo = 3 
        OR fk_cargo = 5;

-- 28.Lista todos los empleados donde el fk_cargo sea 1, 3 o 5. 
    -- Utilizando el operador IN.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        fk_cargo as cargo,
        sueldo as sou
    FROM empleados
    WHERE fk_cargo IN (1,3,5);

-- 29.Lista el nombre + apellido de los empleados y su mes de nacimiento.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        MONTH(fecha_nacimiento) as 'mes de naixement'
    FROM empleados;

-- Comodines (Wildcards)
-- 30.Lista los empleados cuyo nombre empiece por la letra S.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom' 
    FROM empleados
    WHERE nombre LIKE 'S%';

-- 31. Lista los empleados cuyo nombre termine por la vocal e.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom' 
    FROM empleados
    WHERE nombre LIKE '%e';

-- 32.Lista los cargos que contengan el carácter r.
SELECT cargo as càrrec 
    FROM cargos
    WHERE cargo LIKE '%r%';
    
-- 33.Devuelve una lista de todos los empleados que contienen la cadena ana en el nombre.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom' 
    FROM empleados
    WHERE nombre LIKE '%ana%';

-- 34.Haz una lista de todos los empleados que contienen la cadena ez en el apellido y tienen un sueldo inferior a 21.500€.
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom',
        sueldo as sou
    FROM empleados
    WHERE apellido LIKE '%ez%'
        AND sueldo < 215000;

-- 35.Lista los apellidos cuya longitud sea igual a 4 caracteres.
SELECT apellido as cognom
    FROM empleados
    WHERE CHAR_LENGTH(apellido) = 4;

-- 36.Lista el nombre y el sueldo de todos los empleados que tengan un sueldo mayor o igual a 18.000€. 
    -- Ordena el resultado en primer lugar por el sueldo (en orden descendente) 
    -- y en segundo lugar por el apellido (en orden ascendente).
SELECT CONCAT_WS(" ",nombre,apellido) as 'nom + cognom', 
        sueldo as sou
    FROM empleados
    WHERE sueldo >= 18000
    ORDER BY sueldo DESC,
            apellido ASC;
