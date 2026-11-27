-- Ejercicio 12. Subconsultas
    -- Usando la Base de Datos jardineria:
use jardineria;

-- Subconsultas con operadores básicos de comparación
-- 1. Devuelve el nombre del cliente con mayor límite de crédito.
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
      AND TABLE_NAME = 'cliente'
    ORDER BY ORDINAL_POSITION;

SELECT c.nombre_cliente as "Nom del client amb el màxim de límit de crèdit"
    FROM cliente c 
    WHERE limite_credito = (
        SELECT MAX(limite_credito) 
        FROM cliente
    );
    
-- 2. Devuelve el nombre del producto que tenga el precio de venta más caro.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'producto'
    ORDER BY ORDINAL_POSITION;

SELECT p.nombre as "Nom del producte amb el preu de venda més alt"
    FROM producto p 
    WHERE precio_venta = (
        SELECT MAX(precio_venta) 
        FROM producto
    );
-- 3. Devuelve el nombre del producto del que se han vendido más unidades.
    -- (Tenga en cuenta que tendrá que calcular cuál es el número total de unidades que se han vendido de cada producto a partir de los datos de la tabla detalle_pedido)
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'detalle_pedido'
    ORDER BY ORDINAL_POSITION;

SELECT p.nombre as "Nom del producte del qual s'han venut més unitats"
    FROM producto p
    JOIN detalle_pedido dp ON dp.fk_producto = p.pk_producto
    GROUP BY p.pk_producto, p.nombre
        HAVING SUM(dp.cantidad) >= ALL (
            SELECT SUM(cantidad)
            FROM detalle_pedido
            GROUP BY fk_producto
        );

-- 4. Los clientes cuyo límite de crédito sea mayor que los pagos que haya realizado. (Sin utilizar INNER JOIN).
SELECT c.nombre_cliente as "Nom del clients on el límit de crèdit és més gran que els pagaments realitzats"
    FROM cliente c
    WHERE c.limite_credito > (
        SELECT SUM(p.total)
        FROM pago p
        WHERE p.fk_cliente = c.pk_cliente
    );

-- 5. Devuelve el producto que más unidades tiene en stock.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'producto'
    ORDER BY ORDINAL_POSITION;

SELECT p.nombre as "Nom del producte que té més unitats en stock",
        p.cantidad_en_stock as "Stock"
    FROM producto p
    WHERE cantidad_en_stock = (
        SELECT MAX(cantidad_en_stock) 
        FROM producto
    );

-- 6. Devuelve el producto que menos unidades tiene en stock.
SELECT p.nombre as "Nom del producte que té més unitats en stock",
        p.cantidad_en_stock as "Stock"
    FROM producto p
    WHERE cantidad_en_stock = (
        SELECT MIN(cantidad_en_stock) 
        FROM producto
    );

-- 7. Devuelve el nombre, los apellidos y el email de los empleados que están a cargo de Alberto Soria.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'empleado'
    ORDER BY ORDINAL_POSITION;


SELECT e.nombre as "Nom dels treballadors amb n'Alberto Soria de cap",
        CONCAT(e.apellido1," ",e.apellido2) as "Cognoms"
    FROM empleado e
    WHERE fk_jefe = (
        SELECT fk_puesto 
        FROM empleado
        WHERE nombre = "Alberto" AND apellido1 = "Soria"
    ); 

-- Subconsultas con ALL y ANY
-- 8. Devuelve el nombre del cliente con mayor límite de crédito.
SELECT c.nombre_cliente AS "Nom del client amb màxim límit de crèdit"
    FROM cliente c
    WHERE c.limite_credito >= ALL (
        SELECT limite_credito
        FROM cliente
    );

-- 9. Devuelve el nombre del producto que tenga el precio de venta más caro.
SELECT p.nombre AS "Nom del producte amb el preu de venda més alt"
    FROM producto p
    WHERE p.precio_venta >= ALL (
        SELECT precio_venta
        FROM producto
    );

-- 10.Devuelve el producto que menos unidades tiene en stock.
SELECT p.nombre AS "Nom del producte amb menys unitats en stock"
    FROM producto p
    WHERE p.cantidad_en_stock <= ALL (
        SELECT cantidad_en_stock
        FROM producto
    );

-- Subconsultas con IN y NOT IN
-- 11. Devuelve el nombre, apellido1 y cargo de los empleados que no representen a ningún cliente.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'empleado' OR TABLE_NAME = 'puestos' OR TABLE_NAME = 'cliente'
    ORDER BY ORDINAL_POSITION;

SELECT e.nombre AS "Nom dels treballadors que no representen cap client",
       e.apellido1 AS "Primer cognom",
       puestos.puesto AS "Posició"
    FROM empleado e
    JOIN puestos ON e.fk_puesto = puestos.pk_puesto
    WHERE e.pk_empleado NOT IN (
        SELECT fk_representante_ventas 
            FROM cliente 
    );

-- 12. Devuelve un listado que muestre solamente los clientes que no han realizado ningún pago.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'cliente' OR TABLE_NAME = 'pago'
    ORDER BY ORDINAL_POSITION;

SELECT * 
    FROM cliente
    WHERE pk_cliente NOT IN (
        SELECT fk_cliente
            FROM pago
    );

-- 13. Devuelve un listado que muestre solamente los clientes que sí han realizado algún pago.
SELECT * 
    FROM cliente
    WHERE pk_cliente IN (
        SELECT fk_cliente
            FROM pago
    );

-- 14.Devuelve un listado de los productos que nunca han aparecido en un pedido.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'producto' OR TABLE_NAME = 'detalle_pedido'
    ORDER BY ORDINAL_POSITION;

SELECT * 
    FROM producto
    WHERE pk_producto NOT IN (
        SELECT fk_producto 
            FROM detalle_pedido
    );

-- 15.Devuelve el nombre, apellidos, puesto y teléfono de la oficina de aquellos empleados que no sean representante de ventas de ningún cliente.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'empleado' OR TABLE_NAME = 'oficina'
    ORDER BY ORDINAL_POSITION;

SELECT e.nombre as "Nom del treballador que no es RRVV de cap client",
        CONCAT(e.apellido1," ",e.apellido2) as "Cognoms",
        puestos.puesto as "Posició",
        oficina.telefono as "Telèfon de la oficina"
    FROM empleado e
    JOIN puestos ON puestos.pk_puesto = e.fk_puesto
    JOIN oficina ON oficina.pk_oficina = e.fk_oficina
    WHERE e.pk_empleado NOT IN (
        SELECT fk_representante_ventas 
            FROM cliente 
    );
    
-- 16. Devuelve las oficinas donde no trabajan ninguno de los empleados que hayan sido los representantes de ventas de algún cliente que haya realizado la compra de algún producto de la gama Frutales.
SELECT o.codigo_oficina AS "Oficines on no treballa cap RRVV de clients que han comprat Frutales"
    FROM oficina o
    WHERE o.pk_oficina NOT IN (
        SELECT DISTINCT e.fk_oficina
        FROM empleado e
        JOIN cliente c ON c.fk_representante_ventas = e.pk_empleado
        JOIN pedido pe ON pe.fk_cliente = c.pk_cliente
        JOIN detalle_pedido dp ON dp.fk_pedido = pe.pk_pedido
        JOIN producto pr ON pr.pk_producto = dp.fk_producto
        JOIN gama_producto gp ON gp.pk_gama = pr.fk_gama
        WHERE gp.gama = 'Frutales'
    );
-- 17. Devuelve un listado con los clientes que han realizado algún pedido pero no han realizado ningún pago.
SELECT * 
    FROM cliente
    WHERE pk_cliente NOT IN (
        SELECT fk_cliente
            FROM pago
    ) AND pk_cliente IN (
        SELECT fk_cliente
            FROM pedido  
    );

-- Subconsultas con EXISTS y NOT EXISTS
-- 18.Devuelve un listado que muestre solamente los clientes que no han realizado ningún pago.
SELECT * 
    FROM cliente
    WHERE NOT EXISTS (
    SELECT 1
    FROM pago as p
    WHERE p.fk_cliente = cliente.pk_cliente
    );

-- 19. Devuelve un listado que muestre solamente los clientes que sí han realizado algún pago.
SELECT * 
    FROM cliente
    WHERE EXISTS (
    SELECT 1
    FROM pago p
    WHERE p.fk_cliente = cliente.pk_cliente
    );

-- 20.Devuelve un listado de los productos que nunca han aparecido en un pedido.
SELECT *
    FROM producto p 
    WHERE NOT EXISTS (
        SELECT 1
        FROM detalle_pedido dp
        WHERE dp.fk_producto = p.pk_producto
    );

-- 21. Devuelve un listado de los productos que han aparecido en un pedido alguna vez.
SELECT *
    FROM producto p 
    WHERE EXISTS (
        SELECT 1
        FROM detalle_pedido dp
        WHERE dp.fk_producto = p.pk_producto
    );
    
-- Common Table Expressions (WITH)
-- 22.Elige dos subconsultas que se encuentren en la cláusula FROM y reescribelas utilizando la sintaxis moderna (con una CTE).
    -- del 3 
WITH total_vendido AS (
    SELECT fk_producto, SUM(cantidad) AS total_unitats
        FROM detalle_pedido
        GROUP BY fk_producto
)
    SELECT p.nombre AS "Nom del producte del qual s'han venut més unitats"
        FROM producto p
        JOIN total_vendido tv ON p.pk_producto = tv.fk_producto
        WHERE tv.total_unitats >= ALL (
            SELECT total_unitats 
            FROM total_vendido
        );


    -- de la 16
WITH oficinas_con_frutales AS (
    SELECT DISTINCT e.fk_oficina
        FROM empleado e
        JOIN cliente c ON c.fk_representante_ventas = e.pk_empleado
        JOIN pedido pe ON pe.fk_cliente = c.pk_cliente
        JOIN detalle_pedido dp ON dp.fk_pedido = pe.pk_pedido
        JOIN producto pr ON pr.pk_producto = dp.fk_producto
        JOIN gama_producto gp ON gp.pk_gama = pr.fk_gama
        WHERE gp.gama = 'Frutales'
          AND e.fk_oficina IS NOT NULL
    )

SELECT o.codigo_oficina AS "Oficines on no treballa cap RRVV de clients que han comprat Frutales"
    FROM oficina o
    WHERE o.pk_oficina NOT IN (
        SELECT fk_oficina 
        FROM oficinas_con_frutales
);
