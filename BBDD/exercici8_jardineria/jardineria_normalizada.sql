 -- ERROR contra la 3FN. ciutat, pais i regio son dependències transitives.
 -- país hauria de ser una altra taula
CREATE TABLE IF NOT EXISTS paises AS
    SELECT DISTINCT TRIM(pais) AS pais FROM cliente WHERE pais IS NOT NULL AND TRIM(pais) != ''
    UNION
    SELECT DISTINCT TRIM(pais) AS pais FROM oficina WHERE pais IS NOT NULL AND TRIM(pais) != '';

ALTER TABLE paises
    ADD COLUMN pk_pais INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
    MODIFY COLUMN pais VARCHAR(50) NOT NULL,
    ADD UNIQUE (pais);

-- Regio hauria de ser una altra taula: Creem la taula creuant amb paises per obtenir directament el fk_pais
CREATE TABLE IF NOT EXISTS regiones AS
    SELECT DISTINCT 
        COALESCE(NULLIF(TRIM(cliente.region), ''), 'Sin región') AS region,
        paises.pk_pais AS fk_pais
    FROM cliente
    JOIN paises ON TRIM(cliente.pais) = paises.pais
    UNION
    SELECT DISTINCT 
        COALESCE(NULLIF(TRIM(oficina.region), ''), 'Sin región') AS region,
        paises.pk_pais AS fk_pais
    FROM oficina
    JOIN paises ON TRIM(oficina.pais) = paises.pais;

-- Afegim la PK, la FK cap a pais i evitem regions duplicades dins el mateix país
ALTER TABLE regiones
    ADD COLUMN pk_region INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
    MODIFY COLUMN region VARCHAR(50) NOT NULL,
    MODIFY COLUMN fk_pais INT NOT NULL,
    ADD UNIQUE (region, fk_pais),
    ADD CONSTRAINT fk_region_pais FOREIGN KEY (fk_pais) REFERENCES paises(pk_pais)
        ON UPDATE CASCADE ON DELETE RESTRICT;

-- ciutats hauria de ser una altra taula i la creem creuant amb paises i regiones per obtenir el fk_region exacte
CREATE TABLE IF NOT EXISTS ciudades AS
    SELECT DISTINCT 
        TRIM(cliente.ciudad) AS ciudad,
        regiones.pk_region AS fk_region
    FROM cliente
    JOIN paises ON TRIM(cliente.pais) = paises.pais
    JOIN regiones ON COALESCE(NULLIF(TRIM(cliente.region), ''), 'Sin región') = regiones.region 
               AND regiones.fk_pais = paises.pk_pais
    WHERE cliente.ciudad IS NOT NULL AND TRIM(cliente.ciudad) != ''
    UNION
    SELECT DISTINCT 
        TRIM(oficina.ciudad) AS ciudad,
        regiones.pk_region AS fk_region
    FROM oficina
    JOIN paises ON TRIM(oficina.pais) = paises.pais
    JOIN regiones ON COALESCE(NULLIF(TRIM(oficina.region), ''), 'Sin región') = regiones.region 
               AND regiones.fk_pais = paises.pk_pais
    WHERE oficina.ciudad IS NOT NULL AND TRIM(oficina.ciudad) != '';

ALTER TABLE ciudades
    ADD COLUMN pk_ciudad INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
    MODIFY COLUMN ciudad VARCHAR(50) NOT NULL,
    MODIFY COLUMN fk_region INT NOT NULL,
    ADD UNIQUE (ciudad, fk_region),
    ADD CONSTRAINT fk_ciudad_region FOREIGN KEY (fk_region) REFERENCES regiones (pk_region)
        ON UPDATE CASCADE ON DELETE RESTRICT;

-- Substituir les columnes erronies en les taules de clients i oficines:
ALTER TABLE oficina ADD COLUMN fk_ciudad INT;
UPDATE oficina
    JOIN paises ON TRIM(oficina.pais) = paises.pais
    JOIN regiones ON COALESCE(NULLIF(TRIM(oficina.region), ''), 'Sin región') = regiones.region AND regiones.fk_pais = paises.pk_pais
    JOIN ciudades ON TRIM(oficina.ciudad) = ciudades.ciudad AND ciudades.fk_region = regiones.pk_region
    SET oficina.fk_ciudad = ciudades.pk_ciudad;

ALTER TABLE oficina
    MODIFY COLUMN fk_ciudad INT NOT NULL,
    ADD CONSTRAINT fk_oficina_ciudad FOREIGN KEY (fk_ciudad) REFERENCES ciudades (pk_ciudad),
    DROP COLUMN ciudad,
    DROP COLUMN region,
    DROP COLUMN pais;

ALTER TABLE cliente ADD COLUMN fk_ciudad INT;
UPDATE cliente
    JOIN paises ON TRIM(cliente.pais) = paises.pais
    JOIN regiones ON COALESCE(NULLIF(TRIM(cliente.region), ''), 'Sin región') = regiones.region AND regiones.fk_pais = paises.pk_pais
    JOIN ciudades ON TRIM(cliente.ciudad) = ciudades.ciudad AND ciudades.fk_region = regiones.pk_region
    SET cliente.fk_ciudad = ciudades.pk_ciudad;

ALTER TABLE cliente
    MODIFY COLUMN fk_ciudad INT NOT NULL,
    ADD CONSTRAINT fk_cliente_ciudad FOREIGN KEY (fk_ciudad) REFERENCES ciudades (pk_ciudad)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    DROP COLUMN ciudad,
    DROP COLUMN region,
    DROP COLUMN pais;

-- ERROR contra la 3FN. Càrrec de treballadors depèn de l'empleat però ha de ser el mateix per a tots així s'eviten errors
-- càrrec de treballador necessita també una nova taula
CREATE TABLE IF NOT EXISTS puestos AS
    SELECT DISTINCT COALESCE(NULLIF(TRIM(puesto), ''), 'Sin asignar') AS puesto
    FROM empleado;

ALTER TABLE puestos
    ADD COLUMN pk_puesto INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
    MODIFY COLUMN puesto VARCHAR(50) NOT NULL,
    ADD UNIQUE (puesto);

-- substitució a empleado 
ALTER TABLE empleado ADD COLUMN fk_puesto INT;

UPDATE empleado
    JOIN puestos ON COALESCE(NULLIF(TRIM(empleado.puesto), ''), 'Sin asignar') = puestos.puesto
    SET empleado.fk_puesto = puestos.pk_puesto;

ALTER TABLE empleado
    MODIFY COLUMN fk_puesto INT NOT NULL,
    ADD CONSTRAINT fk_empleado_puesto FOREIGN KEY (fk_puesto) REFERENCES puestos (pk_puesto)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    DROP COLUMN puesto;

 -- ERROR contra la 3FN. Dependències transitives en cas que afegeixis dades al proveidor així que molt millor en una nova taula.
-- els proveidors no haurien de ser text de la taula producte sino una taula apart
CREATE TABLE IF NOT EXISTS proveedores AS
    SELECT DISTINCT COALESCE(NULLIF(TRIM(proveedor), ''), 'Sin proveedor') AS proveedor
    FROM producto;

ALTER TABLE proveedores
    ADD COLUMN pk_proveedor INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
    MODIFY COLUMN proveedor VARCHAR(50) NOT NULL,
    ADD UNIQUE (proveedor);

-- substitució a proveedor 
ALTER TABLE producto ADD COLUMN fk_proveedor INT;

UPDATE producto
    JOIN proveedores ON COALESCE(NULLIF(TRIM(producto.proveedor), ''), 'Sin proveedor') = proveedores.proveedor
    SET producto.fk_proveedor = proveedores.pk_proveedor;

ALTER TABLE producto
    MODIFY COLUMN fk_proveedor INT NOT NULL,
    ADD CONSTRAINT fk_producto_proveedor FOREIGN KEY (fk_proveedor) REFERENCES proveedores (pk_proveedor)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    DROP COLUMN proveedor;


-- a pagos i a pedidos hi ha dues columnes que haurien de ser enums o noves taules ja que contenen pocs valors i que es repeteixen molt:
ALTER TABLE pedido
    MODIFY COLUMN estado ENUM('Entregado', 'Rechazado', 'Pendiente') NOT NULL DEFAULT 'Pendiente';

ALTER TABLE pago
    MODIFY COLUMN forma_pago ENUM('PayPal', 'Transferencia', 'Cheque') NOT NULL;


-- ERROR contrari a la 1FN. Grup repetitiu. cliente i oficina tenen dues columnes anomanades direccion1 direccion2 està malament el que farem es ajuntarho tot en una de sola ja que la segona es complementaria de la primera i el CP i la ciutat ja son adjudicades al client il'oficina
ALTER TABLE oficina ADD COLUMN direccion VARCHAR(100) AFTER pk_oficina;
ALTER TABLE cliente ADD COLUMN direccion VARCHAR(100) AFTER fax;

UPDATE oficina
    SET direccion = CONCAT_WS(', ', NULLIF(TRIM(linea_direccion1), ''), NULLIF(TRIM(linea_direccion2), ''));
UPDATE cliente
    SET direccion = CONCAT_WS(', ', NULLIF(TRIM(linea_direccion1), ''), NULLIF(TRIM(linea_direccion2), ''));

ALTER TABLE oficina
    MODIFY COLUMN direccion VARCHAR(100) NOT NULL,
    DROP COLUMN linea_direccion1,
    DROP COLUMN linea_direccion2;
ALTER TABLE cliente
    MODIFY COLUMN direccion VARCHAR(100) NOT NULL,
    DROP COLUMN linea_direccion1,
    DROP COLUMN linea_direccion2;


-- ERROR contrari a la XFN. Algunes PK son noms i no numeros que facilita molt més el treball i evita errors.
-- oficina
ALTER TABLE empleado DROP FOREIGN KEY empleado_ibfk_1;


ALTER TABLE oficina
    DROP PRIMARY KEY,
    CHANGE COLUMN pk_oficina codigo_oficina VARCHAR(10) NOT NULL,
    ADD UNIQUE (codigo_oficina);

ALTER TABLE oficina
    ADD COLUMN pk_oficina INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE empleado ADD COLUMN fk_oficina_nueva INT;

UPDATE empleado
    JOIN oficina ON empleado.fk_oficina = oficina.codigo_oficina
    SET empleado.fk_oficina_nueva = oficina.pk_oficina;

ALTER TABLE empleado
    DROP COLUMN fk_oficina,
    CHANGE COLUMN fk_oficina_nueva fk_oficina INT NOT NULL,
    ADD CONSTRAINT fk_empleado_oficina FOREIGN KEY (fk_oficina) REFERENCES oficina (pk_oficina)
        ON UPDATE CASCADE ON DELETE RESTRICT;



-- producto
ALTER TABLE detalle_pedido DROP FOREIGN KEY detalle_pedido_ibfk_2;

ALTER TABLE producto
    DROP PRIMARY KEY,
    CHANGE COLUMN pk_producto codigo_producto VARCHAR(15) NOT NULL,
    ADD UNIQUE (codigo_producto);

ALTER TABLE producto
    ADD COLUMN pk_producto INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE detalle_pedido ADD COLUMN fk_producto_nuevo INT;

UPDATE detalle_pedido
    JOIN producto ON detalle_pedido.fk_producto = producto.codigo_producto
    SET detalle_pedido.fk_producto_nuevo = producto.pk_producto;

ALTER TABLE detalle_pedido
        DROP PRIMARY KEY,
        DROP COLUMN fk_producto,
        CHANGE COLUMN fk_producto_nuevo fk_producto INT NOT NULL,
        ADD PRIMARY KEY (fk_pedido, fk_producto),
        ADD CONSTRAINT fk_detalle_producto FOREIGN KEY (fk_producto) REFERENCES producto (pk_producto)
            ON UPDATE CASCADE ON DELETE RESTRICT;

-- ERROR contra la 1FN. producto.dimensiones gens atomatitzat..
ALTER TABLE producto
    ADD COLUMN altura_min_cm DECIMAL(6,2) UNSIGNED DEFAULT NULL AFTER fk_gama,
    ADD COLUMN altura_max_cm DECIMAL(6,2) UNSIGNED DEFAULT NULL AFTER altura_min_cm,
    ADD COLUMN ancho_cm DECIMAL(6,2) UNSIGNED DEFAULT NULL AFTER altura_max_cm,
    ADD COLUMN largo_cm DECIMAL(6,2) UNSIGNED DEFAULT NULL AFTER ancho_cm;

UPDATE producto
    SET 
        altura_min_cm = CAST(SUBSTRING_INDEX(TRIM(dimensiones), '-', 1) AS DECIMAL(6,2)),
        altura_max_cm = CAST(SUBSTRING_INDEX(TRIM(dimensiones), '-', -1) AS DECIMAL(6,2))
    WHERE dimensiones REGEXP '^[0-9]+(\\.[0-9]+)?-[0-9]+(\\.[0-9]+)?$';

UPDATE producto
    SET 
        ancho_cm = CAST(SUBSTRING_INDEX(TRIM(dimensiones), 'x', 1) AS DECIMAL(6,2)),
        largo_cm = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(dimensiones), 'x', 2), 'x', -1) AS DECIMAL(6,2)),
        altura_max_cm = CAST(SUBSTRING_INDEX(TRIM(dimensiones), 'x', -1) AS DECIMAL(6,2))
    WHERE LOWER(dimensiones) REGEXP '^[0-9]+(\\.[0-9]+)?x[0-9]+(\\.[0-9]+)?x[0-9]+(\\.[0-9]+)?$';

ALTER TABLE producto DROP COLUMN dimensiones;

-- Manca de check per stocks negatius:
ALTER TABLE producto
    MODIFY COLUMN cantidad_en_stock SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    ADD CONSTRAINT chk_producto_stock CHECK (cantidad_en_stock >= 0);

-- check per preus majors a zero a producto, detalle_pedido, pago i cliente
ALTER TABLE producto
    ADD CONSTRAINT chk_producto_precio_venta CHECK (precio_venta >= 0),
    ADD CONSTRAINT chk_producto_precio_proveedor CHECK (precio_proveedor IS NULL OR precio_proveedor >= 0);

ALTER TABLE detalle_pedido
    MODIFY COLUMN cantidad INT UNSIGNED NOT NULL,
    MODIFY COLUMN numero_linea SMALLINT UNSIGNED NOT NULL,
    ADD CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    ADD CONSTRAINT chk_detalle_precio CHECK (precio_unidad >= 0);

ALTER TABLE pago
    ADD CONSTRAINT chk_pago_total CHECK (total > 0);

ALTER TABLE cliente
    ADD CONSTRAINT chk_cliente_limite_credito CHECK (limite_credito IS NULL OR limite_credito >= 0);


-- check per a dates esperades i entregades mes enllà de la demanda
ALTER TABLE pedido
    ADD CONSTRAINT chk_pedido_fecha_esperada CHECK (fecha_esperada >= fecha_pedido),
    ADD CONSTRAINT chk_pedido_fecha_entrega CHECK (fecha_entrega IS NULL OR fecha_entrega >= fecha_pedido);


SELECT pk_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado
    FROM pedido
    WHERE fecha_esperada < fecha_pedido
       OR (fecha_entrega IS NOT NULL AND fecha_entrega < fecha_pedido);