use catchgene;
-- consulta documentacio
CREATE OR REPLACE VIEW info_tablas AS
    SELECT
        TABLE_NAME AS 'Tabla',
        COLUMN_NAME AS 'Campo',
        DATA_TYPE AS 'Tipo',
        CHARACTER_MAXIMUM_LENGTH AS 'Tamano',
        COLUMN_KEY AS 'Claves',
        COLUMN_COMMENT AS 'Comentarios del campo'
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'catchgene';

-- consulta registres de la base de dades
CREATE OR REPLACE VIEW registros_tablas AS
    SELECT 'tissues' AS Tabla, COUNT(*) AS Registros FROM tissues
    UNION ALL
    SELECT 'organisms', COUNT(*) FROM organisms
    UNION ALL
    SELECT 'biosamples', COUNT(*) FROM biosamples
    UNION ALL
    SELECT 'platforms', COUNT(*) FROM platforms
    UNION ALL
    SELECT 'histone_catalog', COUNT(*) FROM histone_catalog
    UNION ALL
    SELECT 'tf_catalog', COUNT(*) FROM tf_catalog
    UNION ALL
    SELECT 'accessibility_catalog', COUNT(*) FROM accessibility_catalog
    UNION ALL
    SELECT 'transcription_catalog', COUNT(*) FROM transcription_catalog
    UNION ALL
    SELECT 'laboratories', COUNT(*) FROM laboratories
    UNION ALL
    SELECT 'users', COUNT(*) FROM users
    UNION ALL
    SELECT 'users_creators', COUNT(*) FROM users_creators
    UNION ALL
    SELECT 'users_readers', COUNT(*) FROM users_readers
    UNION ALL
    SELECT 'queries', COUNT(*) FROM queries
    UNION ALL
    SELECT 'experiments', COUNT(*) FROM experiments
    UNION ALL
    SELECT 'exp_hm', COUNT(*) FROM exp_hm
    UNION ALL
    SELECT 'exp_tf', COUNT(*) FROM exp_tf
    UNION ALL
    SELECT 'exp_da', COUNT(*) FROM exp_da
    UNION ALL
    SELECT 'exp_tr', COUNT(*) FROM exp_tr
    UNION ALL
    SELECT 'assemblies', COUNT(*) FROM assemblies
    UNION ALL
    SELECT 'gene_ontologies', COUNT(*) FROM gene_ontologies
    UNION ALL
    SELECT 'genes', COUNT(*) FROM genes
    UNION ALL
    SELECT 'gene_ass', COUNT(*) FROM gene_ass
    UNION ALL
    SELECT 'expression', COUNT(*) FROM expression;

-- consulta estructura base de datos

CREATE OR REPLACE VIEW estructura_bbdd AS
    SELECT TABLE_NAME AS 'Objeto', TABLE_TYPE AS 'Tipo'
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = 'catchgene'
    UNION
    SELECT EVENT_OBJECT_TABLE AS 'Tabla', TRIGGER_NAME AS 'Trigger'
        FROM information_schema.TRIGGERS
        WHERE TRIGGER_SCHEMA = 'catchgene'
    UNION
    SELECT ROUTINE_NAME AS 'Objeto', ROUTINE_TYPE AS 'Tipo'
        FROM information_schema.ROUTINES
        WHERE ROUTINE_SCHEMA = 'catchgene';


-- consultes
-- quin 5 teixits tenen més gens en els nostres experiments
SELECT 
    tissues.name_tissue AS teixit,
    COUNT(DISTINCT expression.pk_fk_id_gene) AS total_gens_diferents
FROM tissues
JOIN biosamples ON tissues.pk_id_tissue = biosamples.fk_id_tissue
JOIN experiments ON biosamples.pk_id_biosample = experiments.fk_id_biosample
JOIN expression ON experiments.pk_id_exp = expression.pk_fk_id_exp
-- Opcional: descomenta la línia següent si només vols comptar gens expressats ('YES')
-- WHERE ex.gene_expressed = 'YES'
GROUP BY tissues.pk_id_tissue, tissues.name_tissue
ORDER BY total_gens_diferents DESC
LIMIT 5;

-- Quines espècies tenen l'assembly més recentment o durant el 2020. Enganxa el seu nom i el taxid entre parèntesis
SELECT DISTINCT CONCAT(o.scientific_name, ' (', o.taxid, ')') AS especie_taxid, 
                a.name_ass AS 'Nom de la versio',
                a.date_of_release AS 'Release date'
    FROM organisms o
    INNER JOIN assemblies a ON o.pk_id_organism = a.fk_id_organism
    WHERE YEAR(a.date_of_release) >= 2020;


-- Quins son tots els teixits de la database
SELECT name_tissue FROM tissues;

-- Hi ha el gen BRCA1 a la database?
SELECT * FROM genes WHERE name_gene = "BRCA1";

-- Quins son els cientifics names i taxids dels organismes de la database
SELECT scientific_name, taxid FROM organisms;

-- Quants experiments es van sequenciar el primer dia de gener del 2025?
SELECT COUNT(*) FROM experiments WHERE date_sequencing = "2025-01-01";

-- Llista tots els teixits de la BBDD i el nombre d'experiments associats (fins i tot si en tenen 0)
SELECT t.name_tissue AS teixit,
       COUNT(e.pk_id_exp) AS total_experiments
    FROM tissues t
    LEFT JOIN biosamples b ON t.pk_id_tissue = b.fk_id_tissue
    LEFT JOIN experiments e ON b.pk_id_biosample = e.fk_id_biosample
    GROUP BY t.pk_id_tissue, t.name_tissue
    ORDER BY total_experiments ASC;

-- Quants gens per teixit tinc en tots els experiments de la database
SELECT tissues.name_tissue, 
    COUNT(DISTINCT expression.pk_fk_id_gene) as number_of_genes
    FROM tissues 
        JOIN biosamples ON tissues.pk_id_tissue = biosamples.fk_id_tissue 
        JOIN experiments ON biosamples.pk_id_biosample = experiments.fk_id_biosample 
        JOIN expression ON experiments.pk_id_exp = expression.pk_fk_id_exp 
    GROUP BY tissues.name_tissue;

-- Quins gens es descriuen com a kinase a la database?
SELECT name_gene FROM genes WHERE description_gene LIKE "%kinase%";

-- All the genes expressed in liver
SELECT DISTINCT 
    genes.name_gene
    FROM genes
        JOIN expression ON genes.pk_id_gene = expression.pk_fk_id_gene
        JOIN experiments ON expression.pk_fk_id_exp = experiments.pk_id_exp
        JOIN biosamples ON experiments.fk_id_biosample = biosamples.pk_id_biosample
        JOIN tissues ON biosamples.fk_id_tissue = tissues.pk_id_tissue
    WHERE LOWER(tissues.name_tissue) = 'liver'
      AND expression.gene_expressed = 'YES';
 
-- How many genes are expressed in the brain of gorillas after adolescence and not in human
SELECT COUNT(DISTINCT expression.pk_fk_id_gene) AS total_gens_exclusius_gorila
    FROM expression
        JOIN experiments ON expression.pk_fk_id_exp = experiments.pk_id_exp
        JOIN biosamples ON experiments.fk_id_biosample = biosamples.pk_id_biosample
        JOIN tissues ON biosamples.fk_id_tissue = tissues.pk_id_tissue
        JOIN organisms ON biosamples.fk_id_organism = organisms.pk_id_organism
    WHERE LOWER(tissues.name_tissue) = 'brain'
  AND expression.gene_expressed = 'YES'
  AND biosamples.age > 10
  AND LOWER(organisms.scientific_name) LIKE 'gorilla%'
  AND expression.pk_fk_id_gene NOT IN (
      SELECT DISTINCT expression.pk_fk_id_gene
          FROM expression
              JOIN experiments ON expression.pk_fk_id_exp = experiments.pk_id_exp
              JOIN biosamples ON experiments.fk_id_biosample = biosamples.pk_id_biosample
              JOIN tissues ON biosamples.fk_id_tissue = tissues.pk_id_tissue
              JOIN organisms ON biosamples.fk_id_organism = organisms.pk_id_organism
          WHERE LOWER(tissues.name_tissue) = 'brain'
            AND expression.gene_expressed = 'YES'
            AND LOWER(organisms.scientific_name) = 'homo sapiens'
 );

 -- How many genes are accessible in human liver that are not accessible in small intestine
SELECT COUNT(DISTINCT expression.pk_fk_id_gene) AS accessible_genes_only_in_human_liver
    FROM expression
        JOIN experiments ON expression.pk_fk_id_exp = experiments.pk_id_exp
        JOIN exp_da ON experiments.pk_id_exp = exp_da.pk_fk_id_exp
        JOIN biosamples ON experiments.fk_id_biosample = biosamples.pk_id_biosample
        JOIN tissues ON biosamples.fk_id_tissue = tissues.pk_id_tissue
        JOIN organisms ON biosamples.fk_id_organism = organisms.pk_id_organism
    WHERE LOWER(tissues.name_tissue) = 'liver'
      AND LOWER(organisms.scientific_name) = 'homo sapiens'
      AND expression.pk_fk_id_gene NOT IN (
          SELECT DISTINCT expression.pk_fk_id_gene
          FROM expression
          JOIN experiments ON expression.pk_fk_id_exp = experiments.pk_id_exp
          JOIN exp_da ON experiments.pk_id_exp = exp_da.pk_fk_id_exp
          JOIN biosamples ON experiments.fk_id_biosample = biosamples.pk_id_biosample
          JOIN tissues ON biosamples.fk_id_tissue = tissues.pk_id_tissue
          JOIN organisms ON biosamples.fk_id_organism = organisms.pk_id_organism
          WHERE LOWER(tissues.name_tissue) = 'small intestine'
            AND LOWER(organisms.scientific_name) = 'homo sapiens'
);

-- In which tisses does LOXL2 have maxim expression for each species? Is it always the same tissue?
WITH max_expression_per_species AS (
    SELECT 
        organisms.pk_id_organism,
        organisms.scientific_name,
        tissues.name_tissue,
        MAX(expression.expression_value) AS max_expression,
        RANK() OVER (
            PARTITION BY organisms.pk_id_organism 
            ORDER BY MAX(expression.expression_value) DESC
        ) AS ranking
    FROM expression
        JOIN genes ON expression.pk_fk_id_gene = genes.pk_id_gene
        JOIN experiments ON expression.pk_fk_id_exp = experiments.pk_id_exp
        JOIN biosamples ON experiments.fk_id_biosample = biosamples.pk_id_biosample
        JOIN organisms ON biosamples.fk_id_organism = organisms.pk_id_organism
        JOIN tissues ON biosamples.fk_id_tissue = tissues.pk_id_tissue
    WHERE UPPER(genes.name_gene) = 'LOXL2'
    GROUP BY organisms.pk_id_organism, organisms.scientific_name, tissues.name_tissue
)
SELECT 
    scientific_name,
    name_tissue AS tissue_with_max_expression,
    max_expression
FROM max_expression_per_species
WHERE ranking = 1
ORDER BY scientific_name;

-- From all available DNA accessibility experiments in human, which tissue has the most?
SELECT 
    tissues.name_tissue,
    COUNT(experiments.pk_id_exp) AS total_accessibility_experiments
FROM experiments
    JOIN exp_da ON experiments.pk_id_exp = exp_da.pk_fk_id_exp
    JOIN biosamples ON experiments.fk_id_biosample = biosamples.pk_id_biosample
    JOIN tissues ON biosamples.fk_id_tissue = tissues.pk_id_tissue
    JOIN organisms ON biosamples.fk_id_organism = organisms.pk_id_organism
WHERE LOWER(organisms.scientific_name) = 'homo sapiens'
GROUP BY tissues.pk_id_tissue, tissues.name_tissue
ORDER BY total_accessibility_experiments DESC
LIMIT 1;

-- Which is the location of the highest expressed gene in human?
SELECT 
    genes.name_gene,
    assemblies.version_ass AS assembly_version,
    gene_ass.TSS,
    gene_ass.TES,
    gene_ass.gene_length,
    expression.expression_value
    FROM expression
        JOIN experiments ON expression.pk_fk_id_exp = experiments.pk_id_exp
        JOIN biosamples ON experiments.fk_id_biosample = biosamples.pk_id_biosample
        JOIN organisms ON biosamples.fk_id_organism = organisms.pk_id_organism
        JOIN genes ON expression.pk_fk_id_gene = genes.pk_id_gene
        JOIN gene_ass ON genes.pk_id_gene = gene_ass.pk_fk_id_gene
        JOIN assemblies ON gene_ass.pk_fk_id_ass = assemblies.pk_id_ass
    WHERE LOWER(organisms.scientific_name) = 'homo sapiens'
      AND assemblies.fk_id_organism = organisms.pk_id_organism
    ORDER BY expression.expression_value DESC
    LIMIT 1;


-- quins gens tenen una llargada més gran que la mitjana
WITH mitjana_longitud AS (
    SELECT AVG(gene_length) AS avg_len
        FROM gene_ass
)
SELECT 
    genes.pk_id_gene,
    genes.name_gene,
    ROUND(AVG(gene_ass.gene_length), 2) AS gene_length
    FROM genes
    JOIN gene_ass ON genes.pk_id_gene = gene_ass.pk_fk_id_gene
    CROSS JOIN mitjana_longitud m
    GROUP BY genes.pk_id_gene, genes.name_gene, m.avg_len
    HAVING AVG(gene_ass.gene_length) > m.avg_len;




-- UDF 1: Classificació qualitativa del valor d'expressió gènica
DROP FUNCTION IF EXISTS fn_nivell_expressio;

SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER $$

CREATE FUNCTION fn_nivell_expressio(p_valor DECIMAL(10,2))
RETURNS VARCHAR(25)
DETERMINISTIC
BEGIN
    DECLARE resultat VARCHAR(25);
    
    IF p_valor IS NULL OR p_valor < 5 THEN
        SET resultat = 'Baix / No expressat';
    ELSEIF p_valor >= 5 AND p_valor < 50 THEN
        SET resultat = 'Moderat';
    ELSE
        SET resultat = 'Alt';
    END IF;
    
    RETURN resultat;
END
DELIMITER ;

-- UDF 2: Total d'experiments pujats per un investigador (user_creator)
DROP FUNCTION IF EXISTS fn_total_experiments_usuari;

DELIMITER $$

CREATE FUNCTION fn_total_experiments_usuari(p_id_user INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total INT;
    
    SELECT COUNT(*) INTO total
    FROM experiments
    WHERE fk_fk_id_user = p_id_user;
    
    RETURN IFNULL(total, 0);
END

DELIMITER ;


-- Taula auxiliar per al manteniment històric
CREATE TABLE IF NOT EXISTS queries_historic (
    fk_fk_id_user INT NOT NULL,
    query_number INT NOT NULL,
    target_topic ENUM('genes', 'tissues', 'organisms', 'experiments', 'general'),
    query_text TEXT NOT NULL,
    date_query TIMESTAMP,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fk_fk_id_user, query_number)
);

DELIMITER $$

CREATE PROCEDURE sp_manteniment_queries(IN p_dies_antiguitat INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error crític durant el manteniment de queries. Transacció revertida (ROLLBACK).';
    END;

    START TRANSACTION;

        INSERT IGNORE INTO queries_historic (fk_fk_id_user, query_number, target_topic, query_text, date_query)
        SELECT fk_fk_id_user, query_number, target_topic, query_text, date_query
        FROM queries
        WHERE date_query < DATE_SUB(NOW(), INTERVAL p_dies_antiguitat DAY);

        DELETE FROM queries
        WHERE date_query < DATE_SUB(NOW(), INTERVAL p_dies_antiguitat DAY);

    COMMIT;
END

DELIMITER ;

-- Activate el planificador d'esdeveniments
SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS ev_manteniment_mensual_queries
    ON SCHEDULE EVERY 30 DAY
    STARTS CURRENT_TIMESTAMP
    DO
        CALL sp_manteniment_queries(30);

-- Crear un rol (administrador) y otro (usuario) con sus permisos pertinentes.
    -- Explicar y justificar.

CREATE ROLE IF NOT EXISTS 'rol_administrador', 'rol_usuario';

GRANT ALL PRIVILEGES ON catchgene.* TO 'rol_administrador' WITH GRANT OPTION;

GRANT SELECT ON catchgene.* TO 'rol_usuario';
GRANT INSERT ON catchgene.queries TO 'rol_usuario';
GRANT EXECUTE ON FUNCTION catchgene.fn_nivell_expressio TO 'rol_usuario';
GRANT EXECUTE ON FUNCTION catchgene.fn_total_experiments_usuari TO 'rol_usuario';

CREATE USER IF NOT EXISTS 'admin_catchgene'@'localhost' IDENTIFIED BY 'AdminBio2026!';
CREATE USER IF NOT EXISTS 'investigador_01'@'localhost' IDENTIFIED BY 'BioRead2026!';

GRANT 'rol_administrador' TO 'admin_catchgene'@'localhost';
GRANT 'rol_usuario' TO 'investigador_01'@'localhost';

SET DEFAULT ROLE 'rol_administrador' TO 'admin_catchgene'@'localhost';
SET DEFAULT ROLE 'rol_usuario' TO 'investigador_01'@'localhost';

FLUSH PRIVILEGES;
/*
rol_administrador: Pensat per als bioinformàtics responsables del manteniment del sistema; requereix ALL PRIVILEGES per gestionar esquemes, 
    importar nous assemblies, executar manteniments manuals i administrar permisos.
rol_usuario: Aplica el principi de mínim privilegi per a investigadors externs o lectors (users_readers). 
    Només tenen permís de lectura (SELECT) sobre els catàlegs i resultats experimentals per evitar modificacions o esborrats accidentals, i permís d'inserció (INSERT) exclusivament a la taula queries
    perquè quedi registrada la seva activitat i s'apliqui el límit diari (max_QxD).
*/