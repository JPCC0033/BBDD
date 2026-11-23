use jardineria;

-- Composición interna (INNER JOIN)
-- 1. Obtén un listado con el nombre de cada cliente y el nombre y apellido de su representante de ventas.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'cliente'
    ORDER BY ORDINAL_POSITION;
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'empleado'
    ORDER BY ORDINAL_POSITION;
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'puestos'
    ORDER BY ORDINAL_POSITION;
SELECT DISTINCT puesto 
FROM puestos;

SELECT cliente.nombre_cliente AS nom_client,
       puestos.puesto AS posicio,
       empleado.nombre AS nom_RV,
       empleado.apellido1 AS cognom1_RV,
       empleado.apellido2 AS cognom2_RV
    FROM cliente
    INNER JOIN empleado ON cliente.fk_representante_ventas = empleado.pk_empleado
    INNER JOIN puestos ON empleado.fk_puesto = puestos.pk_puesto;

-- 2. Muestra el nombre de los clientes que hayan realizado pagos junto con el nombre de sus representantes de ventas.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'pago'
    ORDER BY ORDINAL_POSITION;

SELECT DISTINCT cliente.nombre_cliente AS nom_client,
               puestos.puesto AS posicio,
               empleado.nombre AS nom_RV
    FROM cliente
    INNER JOIN empleado ON cliente.fk_representante_ventas = empleado.pk_empleado
    INNER JOIN puestos ON empleado.fk_puesto = puestos.pk_puesto
    INNER JOIN pago ON pago.fk_cliente = cliente.pk_cliente;

-- 3. Muestra el nombre de los clientes que no hayan realizado pagos junto con el nombre de sus representantes de ventas.
SELECT cliente.nombre_cliente AS nom_client,
       puestos.puesto AS posicio,
       empleado.nombre AS nom_RV
    FROM cliente
    INNER JOIN empleado ON cliente.fk_representante_ventas = empleado.pk_empleado
    INNER JOIN puestos ON empleado.fk_puesto = puestos.pk_puesto
    WHERE cliente.pk_cliente NOT IN (
        SELECT DISTINCT fk_cliente 
        FROM pago
    );

-- 4. Devuelve el nombre de los clientes que han hecho pagos y el nombre de sus representantes junto con la ciudad de la oficina a la que pertenece el representante.
SELECT DISTINCT cliente.nombre_cliente AS nom_client,
               empleado.nombre AS nom_RV,
               ciudades.ciudad AS ciutat
    FROM cliente
    INNER JOIN empleado ON cliente.fk_representante_ventas = empleado.pk_empleado
    INNER JOIN pago ON pago.fk_cliente = cliente.pk_cliente
    INNER JOIN oficina ON empleado.fk_oficina = oficina.pk_oficina
    INNER JOIN ciudades ON oficina.fk_ciudad = ciudades.pk_ciudad;

-- 5. Devuelve el nombre de los clientes que no hayan hecho pagos y el nombre de sus representantes junto con la ciudad de la oficina a la que pertenece el representante.
SELECT DISTINCT cliente.nombre_cliente AS nom_client,
               empleado.nombre AS nom_RV,
               ciudades.ciudad AS ciutat
    FROM cliente
    INNER JOIN empleado ON cliente.fk_representante_ventas = empleado.pk_empleado
    INNER JOIN oficina ON empleado.fk_oficina = oficina.pk_oficina
    INNER JOIN ciudades ON oficina.fk_ciudad = ciudades.pk_ciudad
    WHERE cliente.pk_cliente NOT IN (
        SELECT DISTINCT fk_cliente 
        FROM pago
    );

-- 6. Lista la dirección de las oficinas que tengan clientes en Fuenlabrada.
SELECT DISTINCT oficina.direccion AS adreça
    FROM oficina
    INNER JOIN empleado ON empleado.fk_oficina = oficina.pk_oficina
    INNER JOIN cliente ON cliente.fk_representante_ventas = empleado.pk_empleado
    INNER JOIN ciudades ON cliente.fk_ciudad = ciudades.pk_ciudad
    WHERE ciudades.ciudad = 'Fuenlabrada'; 

SELECT direccion from cliente;

-- 7. Devuelve el nombre de los clientes y el nombre de sus representantes junto con la ciudad de la oficina a la que pertenece el representante.
SELECT DISTINCT cliente.nombre_cliente AS nom_client,
               empleado.nombre AS nom_RV,
               ciudades.ciudad AS ciutat
    FROM cliente
    INNER JOIN empleado ON cliente.fk_representante_ventas = empleado.pk_empleado
    INNER JOIN oficina ON empleado.fk_oficina = oficina.pk_oficina
    INNER JOIN ciudades ON oficina.fk_ciudad = ciudades.pk_ciudad;

-- El ejercicio 8, permite comparar filas dentro de la misma tabla generalmente para extraer relaciones jerárquicas, por ejemplo, emparejar empleados con sus respectivos gerentes. 
    -- Para que funcione, es obligatorio usar alias de tabla (por ejemplo, t1 y t2) para que el sistema distinga entre las dos instancias virtuales de la misma tabla.
        -- La siguiente consulta muestra, para cada empleado (de una tabla hipotética), el nombre de su gerente.
            /* SELECT
             e.nombre AS empleado,
             g.nombre AS gerente
            FROM
             empleado e
            LEFT JOIN
             empleado g;
            ON
             e.id_gerente = g.id;
            */

-- Intenta realizar el siguiente ejercicio usando como base el ejemplo anterior.
-- 8. Devuelve un listado con el nombre de los empleados junto con el nombre de sus jefes.
SELECT e.nombre AS treballador,
       e.apellido1 AS cognom_treballador,
       j.nombre AS cap,
       j.apellido1 AS cognom_cap
    FROM empleado e
    INNER JOIN empleado j ON e.fk_jefe = j.pk_empleado;

-- 9. Devuelve el nombre de los clientes a los que no se les ha entregado a tiempo un pedido.
SELECT DISTINCT c.nombre_cliente AS "Client"
    FROM cliente c
    INNER JOIN pedido p ON p.fk_cliente = c.pk_cliente
    WHERE p.fecha_entrega > p.fecha_esperada;

-- 10.Devuelve un listado de las diferentes gamas de producto que ha comprado cada cliente.
SELECT DISTINCT c.nombre_cliente AS "Client",
            gp.gama AS Gamma
    FROM cliente c
    INNER JOIN pedido p ON c.pk_cliente = p.fk_cliente
    INNER JOIN detalle_pedido dp ON p.pk_pedido = dp.fk_pedido
    INNER JOIN producto pr ON dp.fk_producto = pr.pk_producto
    INNER JOIN gama_producto gp ON pr.fk_gama = gp.pk_gama;

-- Composición externa ( LEFT JOIN, RIGHT JOIN )
-- 11. Devuelve un listado que muestre solamente los clientes que no han realizado ningún pago.
SELECT c.*
    FROM cliente c
    LEFT JOIN pago p ON c.pk_cliente = p.fk_cliente
    WHERE p.fk_cliente IS NULL;

-- 12. Devuelve un listado que muestre solamente los clientes que no han realizado ningún pedido.
SELECT c.*
    FROM cliente c
    LEFT JOIN pedido p ON c.pk_cliente = p.fk_cliente
    WHERE p.fk_cliente IS NULL;

-- 13. Devuelve un listado que muestre los clientes que no han realizado ningún pago y los que no han realizado ningún pedido.
SELECT c.*
    FROM cliente c
    LEFT JOIN pedido p ON c.pk_cliente = p.fk_cliente
    LEFT JOIN pago pa ON c.pk_cliente = pa.fk_cliente
    WHERE p.fk_cliente IS NULL 
        AND pa.fk_cliente IS NULL;

-- 14.Devuelve un listado que muestre solamente los empleados que no tienen una oficina asociada.
SELECT e.*
    FROM empleado e
    LEFT JOIN oficina o ON e.fk_oficina = o.pk_oficina
    WHERE o.pk_oficina IS NULL;

    -- no retorna res as fk_oficina es not null

-- 15.Devuelve un listado que muestre solamente los empleados que no tienen un cliente asociado.
SELECT e.*
    FROM empleado e
    LEFT JOIN cliente c ON e.pk_empleado = c.fk_representante_ventas
    WHERE c.fk_representante_ventas IS NULL;

-- 16. Devuelve un listado que muestre solamente los empleados que no tienen un cliente asociado junto con los datos de la oficina donde trabajan.
SELECT e.*,
        o.*
    FROM empleado e
    LEFT JOIN cliente c ON e.pk_empleado = c.fk_representante_ventas
    LEFT JOIN oficina o ON e.fk_oficina = o.pk_oficina
    WHERE c.fk_representante_ventas IS NULL;

-- 17. Devuelve un listado que muestre los empleados que no tienen una oficina asociada y los que no tienen un cliente asociado.
SELECT DISTINCT e.*
    FROM empleado e
    LEFT JOIN cliente c ON e.pk_empleado = c.fk_representante_ventas
    LEFT JOIN oficina o ON e.fk_oficina = o.pk_oficina
    WHERE c.fk_representante_ventas IS NULL 
       OR o.pk_oficina IS NULL;

-- 18.Devuelve un listado de los productos que nunca han aparecido en un pedido.
SELECT p.*
    FROM producto p
    LEFT JOIN detalle_pedido dp ON p.pk_producto = dp.fk_producto
    WHERE dp.fk_producto IS NULL;
    
-- 19. Devuelve un listado de los productos que nunca han aparecido en un pedido.
    -- El resultado debe mostrar el nombre, la descripción y la imagen del producto.
SELECT p.nombre AS Nom,
       p.descripcion AS Descripcio
    FROM producto p
    LEFT JOIN detalle_pedido dp ON p.pk_producto = dp.fk_producto
    WHERE dp.fk_producto IS NULL;
-- 20.Devuelve las oficinas donde no trabajan ninguno de los empleados que hayan sido los representantes de ventas de algún cliente que haya realizado la compra de algún producto de la gama Frutales.
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
-- 21. Devuelve un listado con los clientes que han realizado algún pedido pero no han realizado ningún pago.
SELECT DISTINCT c.*
    FROM cliente c
    INNER JOIN pedido pe ON c.pk_cliente = pe.fk_cliente
    LEFT JOIN pago pa ON c.pk_cliente = pa.fk_cliente
    WHERE pa.fk_cliente IS NULL;
-- 22.Devuelve un listado con los datos de los empleados que no tienen clientes asociados y el nombre de su jefe asociado.
SELECT e.*,
       j.nombre AS nom_cap,
       j.apellido1 AS cognom_cap
    FROM empleado e
    LEFT JOIN cliente c ON e.pk_empleado = c.fk_representante_ventas
    LEFT JOIN empleado j ON e.fk_jefe = j.pk_empleado
    WHERE c.fk_representante_ventas IS NULL;
