USE jardineria;

-- 1. Devuelve un listado con el código de oficina y la ciudad donde hay oficinas.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'oficina'
    ORDER BY ORDINAL_POSITION;

SELECT pk_oficina as 'Codi oficina', 
        ciudad as 'Ciutat' 
    FROM oficina;

-- 2. Devuelve un listado con la ciudad y el teléfono de las oficinas de España.
SELECT pk_oficina as 'Codi oficina', 
        ciudad as 'Ciutat',
        telefono as 'Telèfon' 
    FROM oficina;

-- 3. Devuelve un listado con el nombre, apellidos y email de los empleados cuyo jefe tiene un código de jefe igual a 7.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'empleado'
    ORDER BY ORDINAL_POSITION;

SELECT nombre as 'nom',
        apellido1 as 'Primer cognom',
        apellido2 as 'Segon cognom',
        email as 'e-mail',
        fk_jefe as 'codi de cap'
    FROM empleado
    WHERE fk_jefe = 7;

-- 4. Devuelve el nombre del puesto, nombre, apellidos y email del jefe de la empresa.
SELECT puesto as 'nom de la posició',
        nombre as 'nom',
        apellido1 as 'Primer cognom',
        apellido2 as 'Segon cognom',
        email as 'e-mail',
        fk_jefe as 'codi de cap'
    FROM empleado
    WHERE fk_jefe IS NULL;

-- 5. Devuelve un listado con el nombre, apellidos y puesto de aquellos empleados que no sean representantes de ventas.
SELECT DISTINCT puesto FROM empleado;
SELECT nombre as 'nom',
        apellido1 as 'Primer cognom',
        apellido2 as 'Segon cognom',
        email as 'e-mail',
        puesto as 'nom de la posició'
    FROM empleado
    WHERE puesto != 'Representante Ventas';

-- 6. Devuelve un listado con el nombre de los todos los clientes españoles.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'cliente'
    ORDER BY ORDINAL_POSITION;

SELECT DISTINCT pais FROM cliente;

SELECT nombre_cliente as 'nom'
    FROM cliente
    WHERE pais = 'Spain';

-- 7. Devuelve un listado con los distintos estados por los que puede pasar un pedido.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'pedido'
    ORDER BY ORDINAL_POSITION;

  
SELECT DISTINCT estado FROM pedido;

-- 8. Devuelve un listado con el código de cliente de aquellos clientes que realizaron algún pago en 2008. Ten en cuenta que no deberás mostrar aquellos códigos de cliente que aparezcan repetidos. 
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'pago'
    ORDER BY ORDINAL_POSITION;

SELECT DISTINCT fecha_pago FROM pago;

    -- Resuelve la consulta:
    -- o Utilizando la función YEAR de MySQL.
SELECT DISTINCT fk_cliente as 'Codi de client'
    FROM pago
    WHERE YEAR(fecha_pago) = 2008;

    -- o Utilizando la función DATE_FORMAT de MySQL.
SELECT DISTINCT fk_cliente as 'Codi de client'
    FROM pago
    WHERE DATE_FORMAT(fecha_pago, '%Y') = 2008;
   
    -- o Sin utilizar ninguna de las funciones anteriores.
SELECT DISTINCT fk_cliente AS 'Codi de client'
    FROM pago
    WHERE fecha_pago BETWEEN '2008-01-01' AND '2008-12-31';

-- 9. Devuelve un listado con el código de pedido, código de cliente, fecha esperada y fecha de entrega de los pedidos que no han sido entregados a tiempo.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'pedido'
    ORDER BY ORDINAL_POSITION;

SELECT pk_pedido AS 'Codi de comanda',
        fk_cliente AS 'Codi de client',
        fecha_esperada AS 'Data esperada',
        fecha_entrega AS "Data d'entrega"
    FROM pedido
    WHERE fecha_esperada < fecha_entrega;

-- 10. Devuelve un listado con el código de pedido, código de cliente, fecha esperada y fecha de entrega de los pedidos cuya fecha de entrega ha sido al menos dos días antes de la fecha esperada.
    -- o Utilizando la función ADDDATE de MySQL.
SELECT pk_pedido AS 'Codi de comanda',
        fk_cliente AS 'Codi de client',
        fecha_esperada AS 'Data esperada',
        fecha_entrega AS "Data d'entrega"
    FROM pedido
    WHERE ADDDATE(fecha_entrega, 2) <= fecha_esperada;

    -- o Utilizando la función DATEDIFF de MySQL.
SELECT pk_pedido AS 'Codi de comanda',
        fk_cliente AS 'Codi de client',
        fecha_esperada AS 'Data esperada',
        fecha_entrega AS "Data d'entrega"
    FROM pedido
    WHERE DATEDIFF(fecha_esperada, fecha_entrega) >= 2;

    -- o ¿Sería posible resolver esta consulta utilizando el operador de suma + o resta -?
SELECT pk_pedido AS 'Codi de comanda',
        fk_cliente AS 'Codi de client',
        fecha_esperada AS 'Data esperada',
        fecha_entrega AS "Data d'entrega"
    FROM pedido
    WHERE fecha_esperada - fecha_entrega >= 2;

-- 11. Devuelve un listado de todos los pedidos que fueron rechazados en 2009.
SELECT DISTINCT estado FROM pedido;

SELECT pk_pedido AS 'Codi de comanda',
        fk_cliente AS 'Codi de client',
        fecha_esperada AS 'Data esperada',
        fecha_entrega AS "Data d'entrega",
        estado AS "Estat de la comanda"
    FROM pedido
    WHERE estado = "Rechazado" 
        AND (YEAR(fecha_entrega) = 2009 
                OR YEAR(fecha_esperada) = 2009);

-- 12. Devuelve un listado de todos los pedidos que han sido entregados en el mes de enero de cualquier año.
SELECT pk_pedido AS 'Codi de comanda',
        fk_cliente AS 'Codi de client',
        fecha_esperada AS 'Data esperada',
        fecha_entrega AS "Data d'entrega",
        estado AS "Estat de la comanda"
    FROM pedido
    WHERE MONTH(fecha_entrega) = 1; 

-- 13. Devuelve un listado con todos los pagos que se realizaron en el año 2008 mediante Paypal. Ordena el resultado de mayor a menor.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'pago'
    ORDER BY ORDINAL_POSITION;

SELECT id_transaccion AS 'Codi del pagament',
    forma_pago AS 'Forma de pagament',
    fecha_pago AS 'Data de pagament',
    total AS 'Preu total'
    FROM pago
    WHERE YEAR(fecha_pago) = 2008
        AND forma_pago = "Paypal"
    ORDER BY  total DESC;

-- 14. Devuelve un listado con todas las formas de pago que aparecen en la tabla pago. Tenga en cuenta que no deben aparecer formas de pago repetidas.
SELECT DISTINCT forma_pago AS 'Forma de pagament'
    FROM pago;

-- 15. Devuelve un listado con todos los productos que pertenecen a la gama Ornamentales y que tienen más de 100 unidades en stock. 
    -- El listado deberá estar ordenado por su precio de venta, mostrando en primer lugar los de mayor precio.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'producto'
    ORDER BY ORDINAL_POSITION;

SELECT * FROM gama_producto;

SELECT pk_producto AS 'Codi del producte',
        fk_gama AS 'Gamma del producte',
        cantidad_en_stock AS 'Stock del producte',
        precio_venta AS 'Preu de la venda'
    FROM producto
    WHERE cantidad_en_stock > 100
      AND fk_gama IN (
          SELECT pk_gama 
          FROM gama_producto 
          WHERE gama LIKE '%Ornamental%'
      )
    ORDER BY precio_venta DESC;

-- 16. Devuelve un listado con todos los clientes que sean de la ciudad de Madrid y cuyo representante de ventas tenga el código de empleado 11 o 30.
SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'jardineria' 
      AND TABLE_NAME = 'cliente'
    ORDER BY ORDINAL_POSITION;

SELECT pk_cliente AS 'Codi del client',
        fk_representante_ventas AS 'Representant de vendes',
        ciudad AS 'Ciutat'
    FROM cliente
    WHERE (fk_representante_ventas = 11
            OR fk_representante_ventas = 30)
        AND ciudad = "Madrid";
        
/*    
SELECT pk_cliente AS 'Codi del client',
        fk_representante_ventas AS 'Representant de vendes',
        ciudad AS 'Ciutat'
    FROM cliente
    WHERE (fk_representante_ventas = 11
            OR fk_representante_ventas = 30)
        AND ciudad IN ( 
            SELECT pk_ciudad
                FROM ciudades
                WHERE ciudad = "Madrid"
        );
*/