DROP DATABASE catchgene;

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

CREATE TABLE IF NOT EXISTS usuaris (
    pk_id_usuari INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Per guardar la contrasenya encriptada
    rol ENUM('administrador', 'cientific', 'estudiant') DEFAULT 'cientific',
    data_registre TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS consultes (
    pk_id_consulta INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fk_id_usuari INT NOT NULL,
    data_consulta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    text_cercat VARCHAR(255)
);




























--establishing foreign keys
-- experiments





-- BIOSAMPLES i ASSEMBLIES
ALTER TABLE biosamples 
ADD CONSTRAINT bios_tis 
FOREIGN KEY (fk_id_tissue) REFERENCES tissues(pk_id_tissue)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE biosamples 
ADD CONSTRAINT bios_org 
FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
ON UPDATE CASCADE ON DELETE RESTRICT;






ALTER TABLE gene_ass 
ADD CONSTRAINT GA_gene
FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE expression 
ADD CONSTRAINT expression_exp 
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE expression 
ADD CONSTRAINT expression_gene
FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE consultes 
ADD CONSTRAINT user_consulta
FOREIGN KEY (fk_id_usuari) REFERENCES usuaris(pk_id_usuari)
ON UPDATE CASCADE ON DELETE CASCADE;


-- Triggers
DELIMITER $$
CREATE TRIGGER nova_mostra
BEFORE INSERT ON biosamples
FOR EACH ROW
BEGIN
-- Verificar que la cantidad vendida sea mayor que cero
IF NEW.age <= 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "L'edat de la mostra és negativa i hauria de ser positiva";
END IF
DELIMITER;




/* 10 consultas mínim

1. Is LOXL2 accessible in hippocampus in young macaques?
2. Obtain all the genes expressed in mouse liver.
3. Which (or whichs) genes are expressed in Brain after adolescence in Macaques that are not expressed in human?
4. How many genes are accessible in human kidneys that are not accessible in small intestine?
5. In which tissue does GeneB have more expression for each organism? Is always the same tissue?
6. Retrieve all available DNA accessibility experiments in Gorilla. Which tissue has the most?
7. What are the coordinates of the highest expressed gene in human brain? 
8. Which transcription experiments are done with any platform from the company Illumina?
9. 
10. Classify the genes of one assembly by their length, from the shorter to the largest using Window Function DENSE_RANK().
*/

SELECT g.name_gene, t.name_tissue, o.scientific_name, b.age, da.DNAA_type
FROM DNA_accessibility da
JOIN experiments e ON da.pk_fk_id_exp = e.pk_id_exp
JOIN biosamples b ON e.fk_id_biosample = b.pk_id_biosample
JOIN tissues t ON b.fk_id_tissue = t.pk_id_tissue
JOIN organisms o ON b.fk_id_organism = o.pk_id_organism
JOIN expression ex ON e.pk_id_exp = ex.pk_fk_id_exp
JOIN genes g ON ex.pk_fk_id_gene = g.pk_id_gene
WHERE g.name_gene = 'LOXL2' 
  AND t.name_tissue = 'hippocampus' 
  AND o.scientific_name LIKE '%Macaca%' 
  AND b.age < 3.00;

SELECT g.name_gene, t.name_tissue, o.scientific_name, b.age, da.DNAA_type