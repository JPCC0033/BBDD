CREATE DATABASE catchgene;
use catchgene;

CREATE TABLE experiments(
    pk_id_exp int NOT NULL PRIMARY KEY,
    date_sequencing DATE NOT NULL,
    fk_id_biosample int,
    fk_id_platform int
);
CREATE TABLE histone_mark(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    histone_mark varchar(20) NOT NULL
);
CREATE TABLE transcription(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    trans_type varchar(20) NOT NULL
);
CREATE TABLE transcription_factor(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    TF varchar(20) NOT NULL
);
CREATE TABLE DNA_accessibility(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    DNAA_type varchar(20) NOT NULL
);
CREATE TABLE platforms(
    pk_id_platform int NOT NULL PRIMARY KEY,
    name_platform varchar(20) NOT NULL
);
ALTER TABLE histone_mark 
ADD CONSTRAINT exp_hm 
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE CASCADE; -- si un padre se intenta borrar se borra este hijo
ALTER TABLE transcription 
ADD CONSTRAINT exp_transcription 
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE CASCADE; -- si un padre se intenta borrar se borra este hijo
ALTER TABLE transcription_factor 
ADD CONSTRAINT exp_TF
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE CASCADE; -- si un padre se intenta borrar se borra este hijo
ALTER TABLE DNA_accessibility 
ADD CONSTRAINT exp_DNAA
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE CASCADE; -- si un padre se intenta borrar se borra este hijo
ALTER TABLE experiments 
ADD CONSTRAINT exp_plat 
FOREIGN KEY (fk_id_platform) REFERENCES platforms(pk_id_platform)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE biosamples(
    pk_id_biosample int NOT NULL PRIMARY KEY,
    purchase_lot int NOT NULL,
    age decimal(10,2) NOT NULL,
    sex ENUM("mascle","femella"),
    name_bios varchar(20) NOT NULL,
    fk_id_tissue int,
    fk_id_organism int
);
ALTER TABLE experiments 
ADD CONSTRAINT exp_bios 
FOREIGN KEY (fk_id_biosample) REFERENCES biosamples(pk_id_biosample)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación


CREATE TABLE tissues(
    pk_id_tissue int NOT NULL PRIMARY KEY,
    name_tissue varchar(20) NOT NULL
);
CREATE TABLE organisms(
    pk_id_organism int NOT NULL PRIMARY KEY,
    scientific_name varchar(20) UNIQUE NOT NULL,
    nom_cat varchar(20),
    taxid int UNIQUE NOT NULL
);
ALTER TABLE biosamples 
ADD CONSTRAINT bios_tis 
FOREIGN KEY (fk_id_tissue) REFERENCES tissues(pk_id_tissue)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE biosamples 
ADD CONSTRAINT bios_org 
FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE gene_ontologies(
    pk_id_GO int NOT NULL PRIMARY KEY,
    desc_GO varchar(255),
    GO_number int NOT NULL UNIQUE
);
CREATE TABLE genes(
    pk_id_gene int NOT NULL PRIMARY KEY,
    description_gene varchar(255),
    name_gene varchar(20),
    fk_id_GO int
);
ALTER TABLE genes 
ADD CONSTRAINT GO_genes 
FOREIGN KEY (fk_id_GO) REFERENCES gene_ontologies(pk_id_GO)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE assemblies(
    pk_id_ass int NOT NULL PRIMARY KEY,
    url_link varchar(255) NOT NULL,
    busco_score decimal(10,2),
    name_ass varchar(100),
    date_of_release DATE,
    version varchar(30) NOT NULL UNIQUE,
    fk_id_organism int
);
ALTER TABLE assemblies 
ADD CONSTRAINT ass_org 
FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE gene_ass(
    pk_fk_id_ass int NOT NULL,
    pk_fk_id_gene int NOT NULL,
    TSS int,
    TES int,
    gene_length decimal(10,2) GENERATED ALWAYS AS (TES - TSS) STORED,
    CONSTRAINT pk_id_gene_ass PRIMARY KEY (pk_fk_id_ass, pk_fk_id_gene)
);
ALTER TABLE gene_ass 
ADD CONSTRAINT GA_assembly 
FOREIGN KEY (pk_fk_id_ass) REFERENCES assemblies(pk_id_ass)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE gene_ass 
ADD CONSTRAINT GA_gene
FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación

CREATE TABLE expression(
    pk_fk_id_exp int NOT NULL,
    pk_fk_id_gene int NOT NULL,
    expression_value int
);
ALTER TABLE expression 
ADD CONSTRAINT expression_exp 
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
ALTER TABLE expression 
ADD CONSTRAINT expression_gene
FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
ON UPDATE CASCADE -- si un padre se cambia se cambian sus hijos en la tabla empleado
ON DELETE RESTRICT; -- si un padre se intenta borrar y tiene hijos, no se permite la operación
