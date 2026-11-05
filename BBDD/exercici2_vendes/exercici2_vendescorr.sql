CREATE DATABASE vendes;

USE vendes;
-- create tables clients
CREATE TABLE clients(
    pk_cif_nif varchar(9) PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    carrer VARCHAR(30) NOT NULL,
    numero int NOT NULL,
    ciutat VARCHAR(30) NOT NULL,
    codi_postal varchar(5) NOT NULL
);
CREATE TABLE telefons(
    pk_telf int PRIMARY KEY,
    fk_cif_nif INT
);

-- proveidors
CREATE TABLE proveidors(
    pk_cif_nif_prov varchar(9) PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    carrer VARCHAR(30) NOT NULL,
    numero int NOT NULL,
    ciutat VARCHAR(30) NOT NULL,
    codi_postal varchar(5) NOT NULL,
    web VARCHAR(255),
    telefon int NOT NULL
);
CREATE TABLE categories(
    pk_id_categoria int PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    descrpicio VARCHAR(255)
);
CREATE TABLE productes(
    pk_id_producte int PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    stock int UNSIGNED,
    preu_actual decimal(10,2),
    fk_cif_nif_prov int,
    fk_id_categoria int,
    CONSTRAINT preu_actual_positiu CHECK (preu >= 0)
);

-- factures i intermitja
CREATE TABLE factures(
    pk_id_factura int PRIMARY KEY,
    data_emissio DATE NOT NULL,
    descompte decimal(10,2),
    import_final decimal(10,2),
    fk_cif_nif int,
    CONSTRAINT preu_actual_positiu CHECK (preu >= 0)
);
CREATE TABLE fact_prod(
    fk_id_factura int,
    fk_id_producte int,
    quantitat int NOT NULL,
    preu_venda int UNSIGNED CHECK (preu_venda > 0),
    iva decimal(10,2),
    CONSTRAINT fact_prod PRIMARY KEY (fk_id_factura, fk_id_producte)
);

--establishing FK
-- clients

ALTER TABLE telefons 
ADD CONSTRAINT telfs_clients 
FOREIGN KEY (fk_cif_nif) REFERENCES clients(pk_cif_nif)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- proveidors
ALTER TABLE productes 
ADD CONSTRAINT productes_proveidors 
FOREIGN KEY (fk_cif_nif_prov) REFERENCES proveidors(pk_cif_nif_prov)
ON UPDATE CASCADE
ON DELETE RESTRICT;
ALTER TABLE productes 
ADD CONSTRAINT productes_categoria 
FOREIGN KEY (fk_id_categoria) REFERENCES categories(pk_id_categoria)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- factures i intermitges
ALTER TABLE factures 
ADD CONSTRAINT facts_clients 
FOREIGN KEY (fk_cif_nif) REFERENCES clients(pk_cif_nif)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE fact_prod 
ADD CONSTRAINT factprod_factures 
FOREIGN KEY (fk_id_factura) REFERENCES factures(pk_id_factura)
ON UPDATE CASCADE 
ON DELETE RESTRICT;
ALTER TABLE fact_prod 
ADD CONSTRAINT factprod_productes2 
FOREIGN KEY (fk_id_producte) REFERENCES productes(pk_id_producte)
ON UPDATE CASCADE 
ON DELETE RESTRICT;





