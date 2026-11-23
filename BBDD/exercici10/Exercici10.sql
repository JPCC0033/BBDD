-- Ejercicio 10. Vistas, creación de tablas y variables de sesión o Create New Table From Existing Table
-- Usando la Base de Datos jardineria:
use jardineria;

-- 1. Crea una vista llamada pedidos_no_entregados que muestre para cada uno de los pedidos de la Base de Datos de jardinería:
    -- el código del pedido, la fecha del pedido, el nombre completo del cliente que lo realizó y su estado para aquellos pedidos que no hayan sido entregados. 
    -- Ordenala por estado.
CREATE OR REPLACE VIEW pedidos_no_entregados AS
    SELECT p.pk_pedido AS codigo_pedido,
           p.fecha_pedido,
           c.nombre_cliente AS nombre_completo_cliente,
           p.estado
    FROM pedido p
    INNER JOIN cliente c ON p.fk_cliente = c.pk_cliente
    WHERE p.estado != 'Entregado'
    ORDER BY p.estado ASC;
-- 2. Crea una vista que se llame listado_pagos_clientes que muestre un listado donde aparezcan todos los clientes y los pagos que ha realizado cada uno de ellos. 
    -- La vista deberá tener las siguientes columnas: nombre y apellidos del cliente concatenados, teléfono, ciudad, pais, fecha_pago, total del pago e id de la transacción.
CREATE OR REPLACE VIEW listado_pagos_clientes AS
    SELECT CONCAT_WS(' ', c.nombre_contacto, c.apellido_contacto) AS "nom complet del client",
           c.telefono AS "Telèfon client",
           ciudades.ciudad,
           paises.pais,
           p.fecha_pago AS data_pagament,
           p.total AS "Total del pagament",
           p.id_transaccion AS "ID de la transaccio"
        FROM cliente c
        INNER JOIN ciudades ON c.fk_ciudad = ciudades.pk_ciudad
        INNER JOIN regiones ON ciudades.fk_region = regiones.pk_region
        INNER JOIN paises ON regiones.fk_pais = paises.pk_pais
        LEFT JOIN pago p ON c.pk_cliente = p.fk_cliente;

-- 3. Crea una vista que se llame listado_pedidos_clientes que muestre un listado donde aparezcan todos los clientes y los pedidos que ha realizado cada uno de ellos.
    -- La vista deberá tener las siguientes columnas: código del cliente, nombre y apellidos del cliente concatendados, teléfono, ciudad, pais, código del pedido, fecha del pedido, fecha esperada y fecha de entrega.
CREATE OR REPLACE VIEW listado_pedidos_clientes AS
    SELECT c.pk_cliente AS "Codi client",
           CONCAT_WS(' ', c.nombre_contacto, c.apellido_contacto) AS "nom complet del client",
           c.telefono AS "Telèfon client",
           ciudades.ciudad AS Ciutat,
           paises.pais AS "País",
           p.pk_pedido AS "Codi comanda",
           p.fecha_pedido AS "data de comanda",
           p.fecha_esperada AS "data esperada",
           p.fecha_entrega AS "data d'entrega"
        FROM cliente c
        INNER JOIN ciudades ON c.fk_ciudad = ciudades.pk_ciudad
        INNER JOIN regiones ON ciudades.fk_region = regiones.pk_region
        INNER JOIN paises ON regiones.fk_pais = paises.pk_pais
        LEFT JOIN pedido p ON c.pk_cliente = p.fk_cliente;


-- 4. Crea una variable de sesión denominada @ciudad. Utiliza la vista que ha creado en el punto 2, para crear una consulta que:
    --  muestre el listado de los clientes de la ciudad de Madrid que han realizado pagos.
SET @ciudad = 'Madrid';

SELECT *
    FROM listado_pagos_clientes
    WHERE ciudad = @ciudad
      AND data_pagament IS NOT NULL;
-- 5. Cambia el valor de la variable @ciudad a Miami y repite la operación anterior.
SET @ciudad = 'Miami';

SELECT *
    FROM listado_pagos_clientes
    WHERE ciudad = @ciudad
      AND data_pagament IS NOT NULL;
-- 6. Crea ocho vistas basadas en las consultas realizadas en el Ejercicio 9 (Consultas Multitabla), 
    -- cuatro de ellas con los ejercicios que hayas considerado más difíciles de la Base de Datos de nómina y 
use nomina;
/*
-- 4. Lista el código del empleado, su nombre y apellido, el código del departameto y el nombre del departamento de los empleados que ganen más de 2000€.
-- 8. Lista el nombre y apellido del empleado, el nombre del cargo y el del departamento de los empleados solteros sin hijos
-- 11. Lista el nombre y apellido del empleado, el nombre del cargo y del departamento de aquellas personas que tienen más de 20 años en la empresa.
    -- Ordena el resultado en primer lugar por el departamento (en orden ascendente) y en segundo lugar por el tiempo trabajado (en orden descendente)
-- 12. Lista nombre y apellido, edad, nombre del cargo, nombre del departamento de los empleados Solteros, Divorciados o Viudos que tengan más de un hijo.
*/
CREATE OR REPLACE VIEW listado_empleados_masde2000 AS
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
CREATE OR REPLACE VIEW listado_empleados_solterossinhijos AS
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
CREATE OR REPLACE VIEW listado_empleados_masde20anyos AS
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
CREATE OR REPLACE VIEW listado_empleados_masdeunhijoynocasados AS
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

    -- cuatro con los ejercicios que hayas considerado más difíciles de la Base de Datos de jardinería.
use jardineria;

/*
-- 8. Devuelve un listado con el nombre de los empleados junto con el nombre de sus jefes.
-- 10.Devuelve un listado de las diferentes gamas de producto que ha comprado cada cliente.
-- 15.Devuelve un listado que muestre solamente los empleados que no tienen un cliente asociado.
-- 20.Devuelve las oficinas donde no trabajan ninguno de los empleados que hayan sido los representantes de ventas de algún cliente que haya realizado la compra de algún producto de la gama Frutales.
*/
CREATE OR REPLACE VIEW listado_empleadojefe AS
SELECT e.nombre AS treballador,
       e.apellido1 AS cognom_treballador,
       j.nombre AS cap,
       j.apellido1 AS cognom_cap
    FROM empleado e
    INNER JOIN empleado j ON e.fk_jefe = j.pk_empleado;
CREATE OR REPLACE VIEW listado_diferentesgamascompradas AS
SELECT DISTINCT c.nombre_cliente AS "Client",
            gp.gama AS Gamma
    FROM cliente c
    INNER JOIN pedido p ON c.pk_cliente = p.fk_cliente
    INNER JOIN detalle_pedido dp ON p.pk_pedido = dp.fk_pedido
    INNER JOIN producto pr ON dp.fk_producto = pr.pk_producto
    INNER JOIN gama_producto gp ON pr.fk_gama = gp.pk_gama;
CREATE OR REPLACE VIEW listado_empleadossincliente AS
SELECT e.*
    FROM empleado e
    LEFT JOIN cliente c ON e.pk_empleado = c.fk_representante_ventas
    WHERE c.fk_representante_ventas IS NULL;
CREATE OR REPLACE VIEW listado_oficinassintrabajadores AS
SELECT o.*
    FROM oficina o
    LEFT JOIN (
        SELECT DISTINCT e.fk_oficina
        FROM empleado e
        INNER JOIN cliente c ON e.pk_empleado = c.fk_representante_ventas
        INNER JOIN pedido p ON c.pk_cliente = p.fk_cliente
        INNER JOIN detalle_pedido dp ON p.pk_pedido = dp.fk_pedido
        INNER JOIN producto pr ON dp.fk_producto = pr.pk_producto
        INNER JOIN gama_producto gp ON pr.fk_gama = gp.pk_gama
        WHERE gp.gama = 'Frutales'
    ) AS oficinas_frutales ON o.pk_oficina = oficinas_frutales.fk_oficina
    WHERE oficinas_frutales.fk_oficina IS NULL;


-- 7. Elimina la vista listado_pedidos_clientes de la Base de Datos jardineria.
DROP VIEW IF EXISTS listado_pedidos_clientes;

-- 8. Crea una nueva tabla con el resultado de la vista que te haya resultado más sencilla del Ejercicio 9 (Consultas Multitabla)
    -- 7. Lista todos los datos de los empleados de Contabilidad
use nomina;

CREATE OR REPLACE VIEW vista_contabilitat AS
SELECT e.*
FROM empleados e
INNER JOIN departamentos d ON e.fk_departamento = d.pk_departamento
WHERE d.departamento LIKE '%Contabilidad%';

CREATE TABLE IF NOT EXISTS contabilitat AS
SELECT * FROM vista_contabilitat;