DROP DATABASE IF EXISTS catchgene;

CREATE DATABASE IF NOT EXISTS catchgene;
-- CREATE SCHEMA IF NOT EXISTS catchgene;
use catchgene;

-- creació taules
CREATE TABLE IF NOT EXISTS tissues(
    pk_id_tissue int NOT NULL PRIMARY KEY,
    name_tissue varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS organisms(
    pk_id_organism int NOT NULL PRIMARY KEY,
    scientific_name varchar(50) UNIQUE NOT NULL,
    nom_cat varchar(50),
    taxid int UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS biosamples(
    pk_id_biosample int NOT NULL PRIMARY KEY,
    purchase_lot int NOT NULL,
    age decimal(10,2) NOT NULL,
    sex ENUM("mascle","femella"),
    name_bios varchar(20) NOT NULL,
    fk_id_tissue int,
    fk_id_organism int,
    CONSTRAINT age_unsigned CHECK (age >= 0)
);
    -- foreign keys biosamples
ALTER TABLE biosamples 
    ADD CONSTRAINT bios_tis 
        FOREIGN KEY (fk_id_tissue) REFERENCES tissues(pk_id_tissue)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT bios_org 
        FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
        ON UPDATE CASCADE ON DELETE RESTRICT;


CREATE TABLE IF NOT EXISTS platforms(
    pk_id_platform int NOT NULL PRIMARY KEY,
    name_platform varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS histone_catalog (
    pk_id_hm int NOT NULL PRIMARY KEY,
    name_hm varchar(20) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS tf_catalog (
    pk_id_tf int NOT NULL PRIMARY KEY,
    name_tf varchar(20) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS accessibility_catalog (
    pk_id_da int NOT NULL PRIMARY KEY,
    name_da varchar(20) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS transcription_catalog(
    pk_id_tr int NOT NULL PRIMARY KEY,
    name_tr varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS experiments(
    pk_id_exp int NOT NULL PRIMARY KEY,
    date_sequencing DATE NOT NULL,
    fk_id_biosample int,
    fk_id_platform int
);
-- foreign keys
    ALTER TABLE experiments 
        ADD CONSTRAINT exp_plat 
            FOREIGN KEY (fk_id_platform) REFERENCES platforms(pk_id_platform)
            ON UPDATE CASCADE ON DELETE RESTRICT,
        ADD CONSTRAINT exp_bios 
            FOREIGN KEY (fk_id_biosample) REFERENCES biosamples(pk_id_biosample)
            ON UPDATE CASCADE ON DELETE RESTRICT;



-- tables ISA
CREATE TABLE IF NOT EXISTS exp_hm(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    fk_id_hm int NOT NULL,
    antibody varchar(50)
);
CREATE TABLE IF NOT EXISTS exp_tf(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    fk_id_tf int NOT NULL,
    antibody varchar(50)
);
CREATE TABLE IF NOT EXISTS exp_da(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    fk_id_da int NOT NULL,
    technique_used varchar(100) NOT NULL
);
CREATE TABLE IF NOT EXISTS exp_tr(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    fk_id_tr int NOT NULL,
    rna_extraction_kit varchar(100) NOT NULL
);

-- foreign keys
ALTER TABLE exp_hm 
    ADD CONSTRAINT exp_exphm 
        FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
        ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT hm_exphm 
        FOREIGN KEY (fk_id_hm) REFERENCES histone_catalog(pk_id_hm)
        ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE exp_tr 
    ADD CONSTRAINT exp_exptr 
        FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
        ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT tr_exptr 
        FOREIGN KEY (fk_id_tr) REFERENCES transcription_catalog(pk_id_tr)
        ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE exp_tf 
    ADD CONSTRAINT exp_exptf
        FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
        ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT tf_exptf
        FOREIGN KEY (fk_id_tf) REFERENCES tf_catalog(pk_id_tf)
        ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE exp_da 
    ADD CONSTRAINT exp_expda
        FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
        ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT da_expda
        FOREIGN KEY (fk_id_da) REFERENCES accessibility_catalog(pk_id_da)
        ON UPDATE CASCADE ON DELETE RESTRICT;



CREATE TABLE IF NOT EXISTS assemblies(
    pk_id_ass int NOT NULL PRIMARY KEY,
    url_link varchar(255) NOT NULL UNIQUE,
    busco_score decimal(10,2),
    name_ass varchar(100),
    date_of_release DATE,
    version_ass varchar(50) NOT NULL UNIQUE,
    fk_id_organism int
);
    -- foreign keys
ALTER TABLE assemblies 
    ADD CONSTRAINT ass_org 
        FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
        ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TABLE IF NOT EXISTS gene_ontologies(
    pk_id_GO int NOT NULL PRIMARY KEY,
    desc_GO varchar(255),
    GO_number int NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS genes(
    pk_id_gene int NOT NULL PRIMARY KEY,
    name_gene varchar(20) UNIQUE,
    description_gene varchar(255),    
    fk_id_GO int

);
    -- foreign keys
ALTER TABLE genes 
    ADD CONSTRAINT GO_genes 
        FOREIGN KEY (fk_id_GO) REFERENCES gene_ontologies(pk_id_GO)
        ON UPDATE CASCADE ON DELETE RESTRICT;


-- taules intermitges n:m
CREATE TABLE IF NOT EXISTS gene_ass(
    pk_fk_id_ass int NOT NULL,
    pk_fk_id_gene int NOT NULL,
    TSS int,
    TES int,
    gene_length decimal(10,2) GENERATED ALWAYS AS (TES - TSS) STORED,
    CONSTRAINT pk_id_gene_ass PRIMARY KEY (pk_fk_id_ass, pk_fk_id_gene)
);
-- foreign keys
ALTER TABLE gene_ass 
    ADD CONSTRAINT GA_assembly 
        FOREIGN KEY (pk_fk_id_ass) REFERENCES assemblies(pk_id_ass)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT GA_gene 
        FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
        ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TABLE IF NOT EXISTS expression(
    pk_fk_id_exp int NOT NULL,
    pk_fk_id_gene int NOT NULL,
    expression_value int,
    gene_expressed ENUM("YES","NO") GENERATED ALWAYS AS (
        CASE WHEN expression_value >= 5 THEN 'YES' ELSE 'NO' END
    ) STORED,
    CONSTRAINT pk_id_expression PRIMARY KEY (pk_fk_id_exp, pk_fk_id_gene)
);
ALTER TABLE expression 
    ADD CONSTRAINT exp_expression 
        FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT gen_expression 
        FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
        ON UPDATE CASCADE ON DELETE RESTRICT;
































