-- Ejercicio 11. Consultas de Datos Agrupados
    -- Referencias:
        -- SQL COUNT(), AVG() y SUM()
        -- SQL MIN() y MAX()
        -- SQL GROUP BY
        -- SQL ORDER BY
        -- SQL HAVING
use nomina;

SELECT
    TABLE_NAME AS 'Tabla',
    COLUMN_NAME AS 'Campo',
    DATA_TYPE AS 'Tipo',
    CHARACTER_MAXIMUM_LENGTH AS 'Tamano',
    COLUMN_KEY AS 'Claves',
    COLUMN_COMMENT AS 'Comentarios del campo'
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'nomina';

-- 1. Calcula el número total de empleados que hay en la tabla empleado.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'nomina' 
      AND TABLE_NAME = 'empleados'
    ORDER BY ORDINAL_POSITION;

SELECT COUNT(pk_empleado) as "Número total de treballadors" FROM empleados;

-- 2. Calcula el número total de departamentos que hay en la tabla departamento.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'nomina' 
      AND TABLE_NAME = 'departamentos'
    ORDER BY ORDINAL_POSITION;

SELECT COUNT(pk_departamento) as "Número total de de departaments" FROM departamento;

-- 3. Calcula la media de sueldo de todos los empleados.
SELECT CONCAT(ROUND(AVG(sueldo),2),"€") as "Mitjana del sou dels treballadors" FROM empleados;

-- 4. Indica quién es el empleado más joven.
    -- amb una subtaula
    SELECT CONCAT(pk_empleado," - ",nombre," ",apellido) as "Treballador més jove" 
        FROM empleados
        WHERE fecha_nacimiento = (SELECT MAX(fecha_nacimiento) FROM empleados);

    -- Unint dues taules
    SELECT CONCAT(e1.pk_empleado, ' - ', e1.nombre, ' ', e1.apellido) AS "Treballador més jove"
        FROM empleados e1
        JOIN empleados e2
        GROUP BY e1.pk_empleado, e1.nombre, e1.apellido, e1.fecha_nacimiento
        HAVING e1.fecha_nacimiento = MAX(e2.fecha_nacimiento);

    -- creant una variable
    SELECT MAX(fecha_nacimiento) INTO @jove FROM empleados;
    SELECT CONCAT(pk_empleado," - ",nombre," ",apellido) as "Treballador més jove" 
        FROM empleados
        WHERE fecha_nacimiento = @jove;

-- 5. Indica quién es el empleado menos joven.
    -- amb una subconsulta
    SELECT CONCAT(pk_empleado," - ",nombre," ",apellido) as "Treballador menys jove" 
        FROM empleados
        WHERE fecha_nacimiento = (SELECT MIN(fecha_nacimiento) FROM empleados);

    -- Unint dues taules
    SELECT CONCAT(e1.pk_empleado, ' - ', e1.nombre, ' ', e1.apellido) AS "Treballador més jove"
        FROM empleados e1
        JOIN empleados e2
        GROUP BY e1.pk_empleado, e1.nombre, e1.apellido, e1.fecha_nacimiento
        HAVING e1.fecha_nacimiento = MIN(e2.fecha_nacimiento);

    -- creant una variable
    SELECT MIN(fecha_nacimiento) INTO @vell FROM empleados;
    SELECT CONCAT(pk_empleado," - ",nombre," ",apellido) as "Treballador més jove" 
        FROM empleados
        WHERE fecha_nacimiento = @vell;

-- 6. Calcula el número total de empleados por estado civil.
SELECT estado_civil as "Estat civil",
    COUNT(pk_empleado) as "Número de treballadors"
    FROM empleados
    GROUP BY estado_civil;

-- 7. Muestra el número de empleados que han ingresado cada año a la empresa
SELECT YEAR(fecha_contrato) as "Any d'ingrés a l'empresa",
    COUNT(pk_empleado) as "Número de treballadors"
    FROM empleados
    GROUP BY YEAR(fecha_contrato)
    ORDER BY YEAR(fecha_contrato) ASC;

-- 8. Lista el nombre y el precio del producto más caro.
use jardineria;

SELECT
    TABLE_NAME AS 'Tabla',
    COLUMN_NAME AS 'Campo',
    DATA_TYPE AS 'Tipo',
    CHARACTER_MAXIMUM_LENGTH AS 'Tamano',
    COLUMN_KEY AS 'Claves',
    COLUMN_COMMENT AS 'Comentarios del campo'
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'jardineria';

SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'producto'
    ORDER BY ORDINAL_POSITION;

SELECT nombre as "Nom del producte",
    precio_venta as "preu de venta"
    FROM producto
    WHERE precio_venta = (SELECT MAX(precio_venta) FROM producto);

SELECT p1.nombre as "nom del producte"
    FROM producto p1
    JOIN producto p2
    GROUP BY p1.pk_producto, p1.nombre, p1.precio_venta
    HAVING p1.precio_venta = MAX(p2.precio_venta);

SELECT MAX(precio_venta) INTO @caro FROM producto;
SELECT nombre as "Nom del producte",
    precio_venta as "preu de venta"
    FROM producto
    WHERE precio_venta = @caro; 

-- 9. Calcula la suma de los salarios de los empleados por departamento.
use nomina;

SELECT
    TABLE_NAME AS 'Tabla',
    COLUMN_NAME AS 'Campo',
    DATA_TYPE AS 'Tipo',
    CHARACTER_MAXIMUM_LENGTH AS 'Tamano',
    COLUMN_KEY AS 'Claves',
    COLUMN_COMMENT AS 'Comentarios del campo'
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'nomina';

SELECT departamentos.departamento as "Departament",
        SUM(pk_empleado) as "Total de treballadors"        
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento
    GROUP BY departamentos.departamento;

-- 10.Calcula la suma de los salarios de los empleados por sexo.
SELECT sexo as "Sexe del treballador",
    ROUND(SUM(sueldo),2) as "Suma dels salaris"        
    FROM empleados
    GROUP BY sexo;

-- 11. Calcula el número de empleados que son Asistentes.
SELECT cargos.cargo as "Càrrec",
        SUM(pk_empleado) as "Total de treballadors"        
    FROM empleados
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    WHERE cargos.cargo = "Asistente"
    GROUP BY cargos.cargo;

-- 12. Calcula la media de hijos de los empleados por sexo y estado civil
SELECT estado_civil as "Estat civil",
        sexo as "Sexe del treballador",
        ROUND(AVG(hijos),2) as "Mitjana de fills"
    FROM empleados
    GROUP BY estado_civil, sexo;

-- 13.Calcula el sueldo más bajo de los Analistas.
SELECT cargos.cargo as "Càrrec",
        MIN(sueldo) as "Sou mínim"        
    FROM empleados
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    WHERE cargos.cargo = "Analista"
    GROUP BY cargos.cargo;

-- 14.Calcula el sueldo más alto de los Analistas.
SELECT cargos.cargo as "Càrrec",
        MAX(sueldo) as "Sou màxim"        
    FROM empleados
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    WHERE cargos.cargo = "Analista"
    GROUP BY cargos.cargo;

-- 15. Muestra el sueldo máximo, sueldo mínimo, sueldo promedio y el número total de empleados por cargo.
SELECT cargos.cargo as "Càrrec",
        MAX(sueldo) as "Sou màxim",
        MIN(sueldo) as "Sou mínim",
        AVG(sueldo) as "Sou promig",
        COUNT(pk_empleado) as "Número de treballadors"
    FROM empleados
    INNER JOIN cargos ON empleados.fk_cargo = cargos.pk_cargo
    GROUP BY cargos.cargo;

-- 16. Muestra el sueldo máximo, sueldo mínimo, sueldo promedio y el número total de empleados por departamento, ordenando de forma descendente por el sueldo promedio.
SELECT departamentos.departamento as "Departament",
        MAX(sueldo) as "Sou màxim",
        MIN(sueldo) as "Sou mínim",
        AVG(sueldo) as "Sou promig",
        COUNT(pk_empleado) as "Número de treballadors"
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento
    GROUP BY departamentos.departamento
    ORDER BY AVG(sueldo) DESC;

-- 17. Muestra la edad máxima, edad mínima, edad promedio y el número total de empleados de los departamentos que tienen una edad promedio superior a los 45 años.
SELECT departamentos.departamento as "Departament",
        MAX(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())) as "Edat màxima",
        MIN(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())) as "Edat mínima",
        ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())),2) as "Edat promig",
        COUNT(pk_empleado) as "Número de treballadors"
    FROM empleados
    INNER JOIN departamentos ON empleados.fk_departamento = departamentos.pk_departamento
    GROUP BY departamentos.departamento
        HAVING ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())),2) > 45;

-- 18.Calcula el número de empleados que tienen un sueldo mayor o igual a 1800€.
SELECT COUNT(pk_empleado) as "Número de treballadors amb un sou major o igual a 1800€"
    FROM empleados
    WHERE sueldo >= 1800;

-- 19. Calcula el número de empleados que tienen una edad menor o igual a 28 años.
SELECT COUNT(pk_empleado) as "Número de treballadors amb una edat menor o igual a 28 anys"
    FROM empleados
    WHERE ROUND(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()),2) <= 28;

-- 20.Lista los nombres de los departamentos cuyos empleados tienen una edad promedio mayor o igual a 35 años.
SELECT departamentos.departamento as "Departament",
        ROUND(AVG(TIMESTAMPDIFF(YEAR, empleados.fecha_nacimiento, CURDATE())),2) as "Edat promig"
    FROM departamentos
    INNER JOIN empleados ON empleados.fk_departamento = departamentos.pk_departamento
    GROUP BY departamentos.departamento
        HAVING ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())),2) >= 35;

-- 21. Devuelve un listado con los nombres de los cargos que tienen 5 o más empleados.
SELECT departamentos.departamento as "Departament amb 5 o més treballadors",
        COUNT(empleados.pk_empleado) as "Número de treballadors"
    FROM departamentos
    INNER JOIN empleados ON empleados.fk_departamento = departamentos.pk_departamento
    GROUP BY departamentos.departamento
        HAVING  COUNT(empleados.pk_empleado) >= 5;

-- 22.Devuelve un listado con los nombres de los departamentos donde el promedio de edad sea superior 40 años.
SELECT departamentos.departamento as "Departament",
        ROUND(AVG(TIMESTAMPDIFF(YEAR, empleados.fecha_nacimiento, CURDATE())),2) as "Edat promig"
    FROM departamentos
    INNER JOIN empleados ON empleados.fk_departamento = departamentos.pk_departamento
    GROUP BY departamentos.departamento
        HAVING ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())),2) > 40;

-- 23.Muestra el número total de empleados que tiene cada departamento. El listado también debe incluir los departamentos que no tienen ningún empleado. 
    -- El resultado mostrará dos columnas, una con el nombre del departamento y otra con el número de empleados que tiene. 
    -- Ordena el resultado descendentemente por el número de empleados.
SELECT departamentos.departamento as "Departament amb 5 o més treballadors",
        COUNT(empleados.pk_empleado) as "Número de treballadors"
    FROM departamentos
    LEFT JOIN empleados ON empleados.fk_departamento = departamentos.pk_departamento
    GROUP BY departamentos.departamento
    ORDER BY COUNT(empleados.pk_empleado) DESC;

-- 24.Explica las diferencias entre las cláusulas WHERE y HAVING, y cuándo utilizar cada una de ellas.
    -- WHERE serveix per filtrar files individuals mentre que HAVING serveix per filtrar grups. Per tant WHERE es posarà abans del GROUP BY i HAVING es posarà després.
    -- Si volem restringir algunes dades que requereixen d'un càlcul en grup com l'AVG o el SUM hem d'utilitzar HAVING ja que correspondrà al valor agrupat.AVING.

