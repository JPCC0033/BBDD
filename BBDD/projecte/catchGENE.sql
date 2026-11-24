DROP DATABASE IF EXISTS catchgene;

CREATE DATABASE IF NOT EXISTS catchgene;
-- CREATE SCHEMA IF NOT EXISTS catchgene;
use catchgene;

-- creació taules
CREATE TABLE IF NOT EXISTS tissues(
    pk_id_tissue int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name_tissue varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS organisms(
    pk_id_organism int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    scientific_name varchar(50) UNIQUE NOT NULL,
    nom_cat varchar(50),
    taxid int UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS biosamples(
    pk_id_biosample int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    purchase_lot int,
    age decimal(10,2),
    sex varchar(20),
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
    pk_id_platform int NOT NULL AUTO_INCREMENT PRIMARY KEY,
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


-- bloc users
CREATE TABLE IF NOT EXISTS laboratories (
    pk_id_lab int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    institucio varchar(50) NOT NULL UNIQUE,
    url_lab varchar(100)
);

CREATE TABLE IF NOT EXISTS users (
    pk_id_user int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username varchar(50) NOT NULL UNIQUE,
    email varchar(100) NOT NULL UNIQUE,
    fk_id_lab int
);
-- foreign keys
ALTER TABLE users
    ADD CONSTRAINT user_lab
        FOREIGN KEY (fk_id_lab) REFERENCES laboratories(pk_id_lab)
        ON UPDATE CASCADE ON DELETE RESTRICT;

-- tables ISA
CREATE TABLE IF NOT EXISTS users_creators (
    pk_fk_id_user int NOT NULL PRIMARY KEY,
    orcid varchar(19) UNIQUE
);
CREATE TABLE IF NOT EXISTS users_readers (
    pk_fk_id_user int NOT NULL PRIMARY KEY,
    max_QxD int DEFAULT 100
);
-- foreign keys
ALTER TABLE users_creators
    ADD CONSTRAINT fk_user_creator
        FOREIGN KEY (pk_fk_id_user) REFERENCES users(pk_id_user)
        ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE users_readers
    ADD CONSTRAINT fk_user_readers
        FOREIGN KEY (pk_fk_id_user) REFERENCES users(pk_id_user)
        ON UPDATE CASCADE ON DELETE CASCADE;


CREATE TABLE IF NOT EXISTS queries (
    fk_fk_id_user int NOT NULL,
    query_number int NOT NULL,
    target_topic ENUM('genes', 'tissues', 'organisms', 'experiments', 'general') DEFAULT 'general',
    query_text TEXT NOT NULL,
    date_query TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_user_queries PRIMARY KEY (fk_fk_id_user, query_number)
);
-- foreign keys
ALTER TABLE queries
    ADD CONSTRAINT uq_us_read
        FOREIGN KEY (fk_fk_id_user) REFERENCES users_readers(pk_fk_id_user)
        ON UPDATE CASCADE ON DELETE CASCADE;

-- trigger massa queries
DELIMITER $$

CREATE TRIGGER check_max_queries_per_day
BEFORE INSERT ON queries
FOR EACH ROW
BEGIN
    DECLARE consultes_avui INT;
    DECLARE limit_usuari INT;

    SELECT COUNT(*) INTO consultes_avui
    FROM queries
    WHERE fk_fk_id_user = NEW.fk_fk_id_user
      AND DATE(date_query) = CURDATE();

    SELECT max_QxD INTO limit_usuari
    FROM users_readers
    WHERE pk_fk_id_user = NEW.fk_fk_id_user;

    IF consultes_avui >= limit_usuari THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Has superat el límit màxim de consultes diàries (max_QxD).';
    END IF;
END

DELIMITER ;

-- bloc experiments
CREATE TABLE IF NOT EXISTS experiments(
    pk_id_exp int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    date_sequencing DATE NOT NULL,
    fk_id_biosample int,
    fk_id_platform int,
    fk_fk_id_user int
);
-- foreign keys
    ALTER TABLE experiments 
        ADD CONSTRAINT exp_plat 
            FOREIGN KEY (fk_id_platform) REFERENCES platforms(pk_id_platform)
            ON UPDATE CASCADE ON DELETE RESTRICT,
        ADD CONSTRAINT exp_bios 
            FOREIGN KEY (fk_id_biosample) REFERENCES biosamples(pk_id_biosample)
            ON UPDATE CASCADE ON DELETE RESTRICT,
        ADD CONSTRAINT exp_us_creat 
            FOREIGN KEY (fk_fk_id_user) REFERENCES users_creators(pk_fk_id_user)
            ON UPDATE CASCADE ON DELETE RESTRICT;

-- trigger dates futures per error
DELIMITER $$

CREATE TRIGGER check_sequencing_date
BEFORE INSERT ON experiments
FOR EACH ROW
BEGIN
    IF NEW.date_sequencing > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La data de seqüenciació no pot ser futura.';
    END IF;
END

DELIMITER ;

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

-- bloc genes
CREATE TABLE IF NOT EXISTS assemblies(
    pk_id_ass int NOT NULL AUTO_INCREMENT PRIMARY KEY,
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
    pk_id_GO int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    desc_GO TEXT,
    GO_number varchar(15) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS genes(
    pk_id_gene int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name_gene varchar(50) UNIQUE,
    description_gene TEXT
);


-- taules intermitges n:m
CREATE TABLE IF NOT EXISTS gene_go(
    pk_fk_id_GO int NOT NULL,
    pk_fk_id_gene int NOT NULL,
    CONSTRAINT pk_id_gene_go PRIMARY KEY (pk_fk_id_GO, pk_fk_id_gene)
);

-- foreign keys
ALTER TABLE gene_go 
    ADD CONSTRAINT GGO_go 
        FOREIGN KEY (pk_fk_id_GO) REFERENCES gene_ontologies(pk_id_GO)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT GGO_gene 
        FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
        ON UPDATE CASCADE ON DELETE RESTRICT;

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
    expression_value DECIMAL(10,2),
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

























