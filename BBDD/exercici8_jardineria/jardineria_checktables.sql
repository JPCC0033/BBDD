USE jardineria;
SET SESSION group_concat_max_len = 100000;
-- Vaciar las tablas
-- Ordenar esta lista para que no salten las restricciones de Foreign key)
/*
TRUNCATE TABLE oficina;
TRUNCATE TABLE empleado;
TRUNCATE TABLE gama_producto;
TRUNCATE TABLE cliente;
TRUNCATE TABLE detalle_pedido;
TRUNCATE TABLE pedido;
TRUNCATE TABLE producto;
TRUNCATE TABLE pago;


SET FOREIGN_KEY_CHECKS = 0; 
TRUNCATE TABLE detalle_pedido;
TRUNCATE TABLE pago;
TRUNCATE TABLE pedido;
TRUNCATE TABLE producto;
TRUNCATE TABLE cliente;
TRUNCATE TABLE empleado;
TRUNCATE TABLE gama_producto;
TRUNCATE TABLE oficina;

SET FOREIGN_KEY_CHECKS = 1;
*/




-- veure què passa amb les columnes i si hi hauria coses que es podrien normalitzar
SELECT CONCAT(
    GROUP_CONCAT(
        CONCAT(
            'SELECT ', ORDINAL_POSITION, ' AS pos, ''', COLUMN_NAME, ''' AS columna, ',
            'COUNT(DISTINCT ', COLUMN_NAME, ') AS valors_unics, ',
            'COUNT(*) AS total_files ',
            'FROM ', TABLE_NAME
        )
        ORDER BY ORDINAL_POSITION SEPARATOR '\nUNION ALL\n'
    ),
    ';'
) AS consulta_a_executar
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
  AND TABLE_NAME = 'oficina';

SELECT 1 AS pos, 'pk_oficina' AS columna, COUNT(DISTINCT pk_oficina) AS valors_unics, COUNT(*) AS total_files FROM oficina
    UNION ALL
    SELECT 2 AS pos, 'ciudad' AS columna, COUNT(DISTINCT ciudad) AS valors_unics, COUNT(*) AS total_files FROM oficina
    UNION ALL
    SELECT 3 AS pos, 'pais' AS columna, COUNT(DISTINCT pais) AS valors_unics, COUNT(*) AS total_files FROM oficina
    UNION ALL
    SELECT 4 AS pos, 'region' AS columna, COUNT(DISTINCT region) AS valors_unics, COUNT(*) AS total_files FROM oficina
    UNION ALL
    SELECT 5 AS pos, 'codigo_postal' AS columna, COUNT(DISTINCT codigo_postal) AS valors_unics, COUNT(*) AS total_files FROM oficina
    UNION ALL
    SELECT 6 AS pos, 'telefono' AS columna, COUNT(DISTINCT telefono) AS valors_unics, COUNT(*) AS total_files FROM oficina
    UNION ALL
    SELECT 7 AS pos, 'linea_direccion1' AS columna, COUNT(DISTINCT linea_direccion1) AS valors_unics, COUNT(*) AS total_files FROM oficina
    UNION ALL
    SELECT 8 AS pos, 'linea_direccion2' AS columna, COUNT(DISTINCT linea_direccion2) AS valors_unics, COUNT(*) AS total_files FROM oficina;

SELECT CONCAT(
    GROUP_CONCAT(
        CONCAT(
            'SELECT ', ORDINAL_POSITION, ' AS pos, ''', COLUMN_NAME, ''' AS columna, ',
            'COUNT(DISTINCT ', COLUMN_NAME, ') AS valors_unics, ',
            'COUNT(*) AS total_files ',
            'FROM ', TABLE_NAME
        )
        ORDER BY ORDINAL_POSITION SEPARATOR '\nUNION ALL\n'
    ),
    ';'
) AS consulta_a_executar
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
  AND TABLE_NAME = 'empleado';

SELECT 1 AS pos, 'pk_empleado' AS columna, COUNT(DISTINCT pk_empleado) AS valors_unics, COUNT(*) AS total_files FROM empleado
UNION ALL
SELECT 2 AS pos, 'nombre' AS columna, COUNT(DISTINCT nombre) AS valors_unics, COUNT(*) AS total_files FROM empleado
UNION ALL
SELECT 3 AS pos, 'apellido1' AS columna, COUNT(DISTINCT apellido1) AS valors_unics, COUNT(*) AS total_files FROM empleado
UNION ALL
SELECT 4 AS pos, 'apellido2' AS columna, COUNT(DISTINCT apellido2) AS valors_unics, COUNT(*) AS total_files FROM empleado
UNION ALL
SELECT 5 AS pos, 'extension' AS columna, COUNT(DISTINCT extension) AS valors_unics, COUNT(*) AS total_files FROM empleado
UNION ALL
SELECT 6 AS pos, 'email' AS columna, COUNT(DISTINCT email) AS valors_unics, COUNT(*) AS total_files FROM empleado
UNION ALL
SELECT 7 AS pos, 'fk_oficina' AS columna, COUNT(DISTINCT fk_oficina) AS valors_unics, COUNT(*) AS total_files FROM empleado
UNION ALL
SELECT 8 AS pos, 'fk_jefe' AS columna, COUNT(DISTINCT fk_jefe) AS valors_unics, COUNT(*) AS total_files FROM empleado;

SELECT CONCAT(
    GROUP_CONCAT(
        CONCAT(
            'SELECT ', ORDINAL_POSITION, ' AS pos, ''', COLUMN_NAME, ''' AS columna, ',
            'COUNT(DISTINCT ', COLUMN_NAME, ') AS valors_unics, ',
            'COUNT(*) AS total_files ',
            'FROM ', TABLE_NAME
        )
        ORDER BY ORDINAL_POSITION SEPARATOR '\nUNION ALL\n'
    ),
    ';'
) AS consulta_a_executar
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
  AND TABLE_NAME = 'gama_producto';

SELECT 1 AS pos, 'pk_gama' AS columna, COUNT(DISTINCT pk_gama) AS valors_unics, COUNT(*) AS total_files FROM gama_producto
UNION ALL
SELECT 2 AS pos, 'gama' AS columna, COUNT(DISTINCT gama) AS valors_unics, COUNT(*) AS total_files FROM gama_producto
UNION ALL
SELECT 3 AS pos, 'descripcion_texto' AS columna, COUNT(DISTINCT descripcion_texto) AS valors_unics, COUNT(*) AS total_files FROM gama_producto;

SELECT CONCAT(
    GROUP_CONCAT(
        CONCAT(
            'SELECT ', ORDINAL_POSITION, ' AS pos, ''', COLUMN_NAME, ''' AS columna, ',
            'COUNT(DISTINCT ', COLUMN_NAME, ') AS valors_unics, ',
            'COUNT(*) AS total_files ',
            'FROM ', TABLE_NAME
        )
        ORDER BY ORDINAL_POSITION SEPARATOR '\nUNION ALL\n'
    ),
    ';'
) AS consulta_a_executar
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
  AND TABLE_NAME = 'cliente';

SELECT 1 AS pos, 'pk_cliente' AS columna, COUNT(DISTINCT pk_cliente) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 2 AS pos, 'nombre_cliente' AS columna, COUNT(DISTINCT nombre_cliente) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 3 AS pos, 'nombre_contacto' AS columna, COUNT(DISTINCT nombre_contacto) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 4 AS pos, 'apellido_contacto' AS columna, COUNT(DISTINCT apellido_contacto) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 5 AS pos, 'telefono' AS columna, COUNT(DISTINCT telefono) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 6 AS pos, 'fax' AS columna, COUNT(DISTINCT fax) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 7 AS pos, 'linea_direccion1' AS columna, COUNT(DISTINCT linea_direccion1) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 8 AS pos, 'linea_direccion2' AS columna, COUNT(DISTINCT linea_direccion2) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 9 AS pos, 'ciudad' AS columna, COUNT(DISTINCT ciudad) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 10 AS pos, 'region' AS columna, COUNT(DISTINCT region) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 11 AS pos, 'pais' AS columna, COUNT(DISTINCT pais) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 12 AS pos, 'codigo_postal' AS columna, COUNT(DISTINCT codigo_postal) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 13 AS pos, 'fk_representante_ventas' AS columna, COUNT(DISTINCT fk_representante_ventas) AS valors_unics, COUNT(*) AS total_files FROM cliente
UNION ALL
SELECT 14 AS pos, 'limite_credito' AS columna, COUNT(DISTINCT limite_credito) AS valors_unics, COUNT(*) AS total_files FROM cliente;

SELECT CONCAT(
    GROUP_CONCAT(
        CONCAT(
            'SELECT ', ORDINAL_POSITION, ' AS pos, ''', COLUMN_NAME, ''' AS columna, ',
            'COUNT(DISTINCT ', COLUMN_NAME, ') AS valors_unics, ',
            'COUNT(*) AS total_files ',
            'FROM ', TABLE_NAME
        )
        ORDER BY ORDINAL_POSITION SEPARATOR '\nUNION ALL\n'
    ),
    ';'
) AS consulta_a_executar
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
  AND TABLE_NAME = 'pedido';

SELECT 1 AS pos, 'pk_pedido' AS columna, COUNT(DISTINCT pk_pedido) AS valors_unics, COUNT(*) AS total_files FROM pedido
UNION ALL
SELECT 2 AS pos, 'fecha_pedido' AS columna, COUNT(DISTINCT fecha_pedido) AS valors_unics, COUNT(*) AS total_files FROM pedido
UNION ALL
SELECT 3 AS pos, 'fecha_esperada' AS columna, COUNT(DISTINCT fecha_esperada) AS valors_unics, COUNT(*) AS total_files FROM pedido
UNION ALL
SELECT 4 AS pos, 'fecha_entrega' AS columna, COUNT(DISTINCT fecha_entrega) AS valors_unics, COUNT(*) AS total_files FROM pedido
UNION ALL
SELECT 5 AS pos, 'estado' AS columna, COUNT(DISTINCT estado) AS valors_unics, COUNT(*) AS total_files FROM pedido
UNION ALL
SELECT 6 AS pos, 'comentarios' AS columna, COUNT(DISTINCT comentarios) AS valors_unics, COUNT(*) AS total_files FROM pedido
UNION ALL
SELECT 7 AS pos, 'fk_cliente' AS columna, COUNT(DISTINCT fk_cliente) AS valors_unics, COUNT(*) AS total_files FROM pedido;

SELECT CONCAT(
    GROUP_CONCAT(
        CONCAT(
            'SELECT ', ORDINAL_POSITION, ' AS pos, ''', COLUMN_NAME, ''' AS columna, ',
            'COUNT(DISTINCT ', COLUMN_NAME, ') AS valors_unics, ',
            'COUNT(*) AS total_files ',
            'FROM ', TABLE_NAME
        )
        ORDER BY ORDINAL_POSITION SEPARATOR '\nUNION ALL\n'
    ),
    ';'
) AS consulta_a_executar
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
  AND TABLE_NAME = 'producto';

SELECT 1 AS pos, 'pk_producto' AS columna, COUNT(DISTINCT pk_producto) AS valors_unics, COUNT(*) AS total_files FROM producto
UNION ALL
SELECT 2 AS pos, 'nombre' AS columna, COUNT(DISTINCT nombre) AS valors_unics, COUNT(*) AS total_files FROM producto
UNION ALL
SELECT 3 AS pos, 'fk_gama' AS columna, COUNT(DISTINCT fk_gama) AS valors_unics, COUNT(*) AS total_files FROM producto
UNION ALL
SELECT 4 AS pos, 'dimensiones' AS columna, COUNT(DISTINCT dimensiones) AS valors_unics, COUNT(*) AS total_files FROM producto
UNION ALL
SELECT 5 AS pos, 'proveedor' AS columna, COUNT(DISTINCT proveedor) AS valors_unics, COUNT(*) AS total_files FROM producto
UNION ALL
SELECT 6 AS pos, 'descripcion' AS columna, COUNT(DISTINCT descripcion) AS valors_unics, COUNT(*) AS total_files FROM producto
UNION ALL
SELECT 7 AS pos, 'cantidad_en_stock' AS columna, COUNT(DISTINCT cantidad_en_stock) AS valors_unics, COUNT(*) AS total_files FROM producto
UNION ALL
SELECT 8 AS pos, 'precio_venta' AS columna, COUNT(DISTINCT precio_venta) AS valors_unics, COUNT(*) AS total_files FROM producto
UNION ALL
SELECT 9 AS pos, 'precio_proveedor' AS columna, COUNT(DISTINCT precio_proveedor) AS valors_unics, COUNT(*) AS total_files FROM producto;

SELECT CONCAT(
    GROUP_CONCAT(
        CONCAT(
            'SELECT ', ORDINAL_POSITION, ' AS pos, ''', COLUMN_NAME, ''' AS columna, ',
            'COUNT(DISTINCT ', COLUMN_NAME, ') AS valors_unics, ',
            'COUNT(*) AS total_files ',
            'FROM ', TABLE_NAME
        )
        ORDER BY ORDINAL_POSITION SEPARATOR '\nUNION ALL\n'
    ),
    ';'
) AS consulta_a_executar
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
  AND TABLE_NAME = 'detalle_pedido';

SELECT 1 AS pos, 'fk_pedido' AS columna, COUNT(DISTINCT fk_pedido) AS valors_unics, COUNT(*) AS total_files FROM detalle_pedido
UNION ALL
SELECT 2 AS pos, 'fk_producto' AS columna, COUNT(DISTINCT fk_producto) AS valors_unics, COUNT(*) AS total_files FROM detalle_pedido
UNION ALL
SELECT 3 AS pos, 'cantidad' AS columna, COUNT(DISTINCT cantidad) AS valors_unics, COUNT(*) AS total_files FROM detalle_pedido
UNION ALL
SELECT 4 AS pos, 'precio_unidad' AS columna, COUNT(DISTINCT precio_unidad) AS valors_unics, COUNT(*) AS total_files FROM detalle_pedido
UNION ALL
SELECT 5 AS pos, 'numero_linea' AS columna, COUNT(DISTINCT numero_linea) AS valors_unics, COUNT(*) AS total_files FROM detalle_pedido;

SELECT CONCAT(
    GROUP_CONCAT(
        CONCAT(
            'SELECT ', ORDINAL_POSITION, ' AS pos, ''', COLUMN_NAME, ''' AS columna, ',
            'COUNT(DISTINCT ', COLUMN_NAME, ') AS valors_unics, ',
            'COUNT(*) AS total_files ',
            'FROM ', TABLE_NAME
        )
        ORDER BY ORDINAL_POSITION SEPARATOR '\nUNION ALL\n'
    ),
    ';'
) AS consulta_a_executar
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
  AND TABLE_NAME = 'pago';

SELECT 1 AS pos, 'fk_cliente' AS columna, COUNT(DISTINCT fk_cliente) AS valors_unics, COUNT(*) AS total_files FROM pago
UNION ALL
SELECT 2 AS pos, 'forma_pago' AS columna, COUNT(DISTINCT forma_pago) AS valors_unics, COUNT(*) AS total_files FROM pago
UNION ALL
SELECT 3 AS pos, 'id_transaccion' AS columna, COUNT(DISTINCT id_transaccion) AS valors_unics, COUNT(*) AS total_files FROM pago
UNION ALL
SELECT 4 AS pos, 'fecha_pago' AS columna, COUNT(DISTINCT fecha_pago) AS valors_unics, COUNT(*) AS total_files FROM pago
UNION ALL
SELECT 5 AS pos, 'total' AS columna, COUNT(DISTINCT total) AS valors_unics, COUNT(*) AS total_files FROM pago;