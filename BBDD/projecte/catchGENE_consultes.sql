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


-- Quins son tots els teixits de la database
SELECT name_tissue FROM tissues;

-- Hi ha el gen BRCA1 a la database?
SELECT * FROM genes WHERE name_gene = "BRCA1";

-- Quins son els cientifics names i taxids dels organismes de la database
SELECT scientific_name, taxid FROM organisms;

-- Quants experiments es van sequenciar el primer dia de gener del 2025?
SELECT COUNT(*) FROM experiments WHERE date_sequencing > "2025-01-01";

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
