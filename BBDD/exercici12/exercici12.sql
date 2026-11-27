-- Ejercicio 12. Operaciones de Conjunto
-- Usando la Base de Datos jardineria:
use jardineria;

-- 1. Crea la siguiente consulta de UNION con la tabla de cliente, empleado y oficina.
    -- La consulta deberá tener los siguientes campos: inicial, id, contacto, tipo, teléfono.
        -- El campo inicial será la inicial del apellido
        -- El campo id será el pk del cliente/empleado. Usa la función LPAD() para rellenar con ceros a la izquierda
        -- El campo contacto será la concatenación del nombre + el (los) apellidos
        -- El campo tipo será un valor literal que indique el tipo de contacto cliente” o “empleado”.
        -- El campo teléfono viene de la tabla cliente u oficina según el origen de datos.
        -- La consulta deberá ordenarse por el apellido.
            /*
            Ejemplo de salida:
            inicial id contacto tipo telefono
            B 030 Julian Bellinelli empleado +61 2 9264 2451
            B 007 Jose Bermejo cliente 654987321
            B 018 Michael Bolton empleado +1 650 219 4782
            C 009 Lucio Campoamor Martín empleado +34 91 7514487
            C 018 Victoria Cruz cliente 612343529
            */
    -- Guarda la consulta como una vista, con el nombre vista_contactos.

-- CREATE OR REPLACE VIEW vista_contactos AS
SELECT inicial,
        id,
        contacto,
        tipo,
        telefono
    FROM (
        SELECT UPPER(LEFT(TRIM(apellido_contacto), 1)) as inicial,
                LPAD(pk_cliente, 3, '0') as id,
                CONCAT(TRIM(nombre_contacto)," ",TRIM(apellido_contacto)) as contacto,
                'cliente' as tipo,
                telefono,
                TRIM(apellido_contacto) as apellido_orden
            FROM cliente

        UNION ALL

        SELECT UPPER(LEFT(TRIM(e.apellido1), 1)) as inicial,
                LPAD(e.pk_empleado, 3, '0') as id,
                CONCAT(TRIM(e.nombre)," ",TRIM(e.apellido1)," ",TRIM(e.apellido2)) as contacto,
                'empleado' as tipo,
                oficina.telefono,
                CONCAT(TRIM(e.apellido1),TRIM(e.apellido2)) as apellido_orden
            FROM empleado e
            INNER JOIN oficina ON e.fk_oficina = oficina.pk_oficina
    ) AS contactos_unificados
    ORDER BY apellido_orden ASC, contacto ASC;

-- CREATE OR REPLACE VIEW vista_contactos as
    SELECT UPPER(LEFT(TRIM(apellido_contacto), 1)) as inicial,
            LPAD(pk_cliente, 3, '0') as id,
            CONCAT_WS(' ', TRIM(nombre_contacto), TRIM(apellido_contacto)) AS contacto,
            'cliente' as tipo,
            telefono
    FROM cliente

    UNION ALL

    SELECT 
        UPPER(LEFT(TRIM(e.apellido1), 1)) as inicial,
        LPAD(e.pk_empleado, 3, '0') as id,
        CONCAT_WS(' ', TRIM(e.nombre), TRIM(e.apellido1), NULLIF(TRIM(e.apellido2), '')) as contacto,
        'empleado' as tipo,
        oficina.telefono
    FROM empleado e
    INNER JOIN oficina ON e.fk_oficina = oficina.pk_oficina
    ORDER BY inicial ASC, SUBSTRING(contacto, LOCATE(' ', contacto) + 1) ASC;

-- CREATE OR REPLACE VIEW vista_contactos as
    SELECT UPPER(LEFT(TRIM(apellido_contacto), 1)) as inicial,
            LPAD(pk_cliente, 3, '0') as id,
            CONCAT_WS(' ', TRIM(nombre_contacto), TRIM(apellido_contacto)) AS contacto,
            'cliente' as tipo,
            telefono
    FROM cliente

    UNION ALL

    SELECT 
        UPPER(LEFT(TRIM(e.apellido1), 1)) as inicial,
        LPAD(e.pk_empleado, 3, '0') as id,
        CONCAT_WS(' ', TRIM(e.nombre), TRIM(e.apellido1), NULLIF(TRIM(e.apellido2), '')) as contacto,
        'empleado' as tipo,
        oficina.telefono
    FROM empleado e
    INNER JOIN oficina ON e.fk_oficina = oficina.pk_oficina
    ORDER BY inicial ASC;

-- 2. Usando el campo fk_cliente y una de las consultas de operaciones de conjunto (UNION, INTERCEPT, EXCEPT), genera una lista de códigos de clientes que hayan hecho pedidos que estén entregados y no tengan pagos. 
    -- Guarda esta consulta como una vista con el nombre clientes_morosos.
CREATE OR REPLACE VIEW clientes_morosos AS
    SELECT fk_cliente
        FROM pedido
        WHERE estado = 'Entregado'

    EXCEPT
    SELECT 
            fk_cliente
            FROM pago;

-- 3. Usa la vista clientes_morosos junto con un INNER JOIN para mostrar los datos de los clientes sin pagos.
-- SELECT * FROM clientes_morosos;

SELECT c.*
    FROM clientes_morosos cm
    INNER JOIN cliente c ON cm.fk_cliente = c.pk_cliente;

-- 4. Repite los puntos 2 y 3 para tener la lista de clientes con pagos. Al generar la lista de clientes que hayan pagado (equivalente al punto 3) indica la fecha del pago y el importe.
CREATE OR REPLACE VIEW clientes_con_pagos AS
    SELECT fk_cliente
        FROM pedido
        WHERE estado = 'Entregado'

    INTERSECT
    SELECT 
            fk_cliente
            FROM pago;

-- SELECT * FROM clientes_con_pagos;

SELECT c.*,
        pa.fecha_pago as "fecha del pago",
        pa.total as "importe"
    FROM clientes_con_pagos cp
    INNER JOIN cliente c ON cp.fk_cliente = c.pk_cliente
    INNER JOIN pago pa ON cp.fk_cliente = pa.fk_cliente;