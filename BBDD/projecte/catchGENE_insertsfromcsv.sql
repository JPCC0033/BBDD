USE catchgene;

-- 1. Taules catàleg i usuaris
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/01_organisms.csv'
INTO TABLE organisms
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/02_platforms.csv'
INTO TABLE platforms
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/03_laboratories.csv'
INTO TABLE laboratories
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/04_users.csv'
INTO TABLE users
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/05_users_creators.csv'
INTO TABLE users_creators
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/06_transcription_catalog.csv'
INTO TABLE transcription_catalog
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. Teixits, mostres i experiments
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/07_tissues.csv'
INTO TABLE tissues
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/08_biosamples.csv'
INTO TABLE biosamples
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/09_experiments.csv'
INTO TABLE experiments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/10_exp_tr.csv'
INTO TABLE exp_tr
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. Gens (tractem el camp buit de fk_id_GO com a NULL)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/11_genes.csv'
INTO TABLE genes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_id_gene, name_gene, description_gene, @v_go)
SET fk_id_GO = NULLIF(TRIM(REPLACE(@v_go, '\r', '')), '');

-- 4. Taules d'expressió (Substitueix NOM_EXACTE pels noms dels 7 fitxers de la carpeta)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp1_10_week_reproductive_organ.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp2_7_to_7_5_week_urinary_bladder.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp3_7_week_reproductive_organ.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp4_7_week_urinary_bladder.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp5_7_5_week_urinary_bladder.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp6_8_week_reproductive_organ.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp7_8_week_urinary_bladder.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp8_9_week_reproductive_organ.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/csv_catchgene/12_expression_exp9_9_week_urinary_bladder.csv'
INTO TABLE expression
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pk_fk_id_exp, pk_fk_id_gene, expression_value);


