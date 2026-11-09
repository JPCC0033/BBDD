CREATE DATABASE IF NOT EXISTS catchgene;
-- CREATE SCHEMA IF NOT EXISTS catchgene;
use catchgene;

-- creació taules
-- EXPERIMENTS
CREATE TABLE IF NOT EXISTS experiments(
    pk_id_exp int NOT NULL PRIMARY KEY,
    date_sequencing DATE NOT NULL,
    fk_id_biosample int,
    fk_id_platform int
);

CREATE TABLE IF NOT EXISTS histone_mark(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    histone_mark varchar(20) NOT NULL
);
CREATE TABLE IF NOT EXISTS transcription(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    trans_type varchar(20) NOT NULL
);
CREATE TABLE IF NOT EXISTS transcription_factor(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    TF varchar(20) NOT NULL
);
CREATE TABLE IF NOT EXISTS DNA_accessibility(
    pk_fk_id_exp int NOT NULL PRIMARY KEY,
    DNAA_type varchar(20) NOT NULL
);
CREATE TABLE IF NOT EXISTS platforms(
    pk_id_platform int NOT NULL PRIMARY KEY,
    name_platform varchar(20) NOT NULL
);

-- BIOSAMPLES i ASSEMBLIES
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
CREATE TABLE IF NOT EXISTS tissues(
    pk_id_tissue int NOT NULL PRIMARY KEY,
    name_tissue varchar(20) NOT NULL
);

INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (1, 'Cerebral cortex');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (2, 'Prefrontal cortex');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (3, 'Cerebellum');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (4, 'Brainstem');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (5, 'Thalamus');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (6, 'Hippocampus');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (7, 'Amygdala');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (8, 'Heart');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (9, 'Lung');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (10, 'Stomach');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (11, 'Small intestine');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (12, 'Large intestine');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (13, 'Liver');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (14, 'Pancreas');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (15, 'Kidney');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (16, 'Bladder');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (17, 'Skin');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (18, 'Spleen');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (19, 'Bone');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (20, 'Bone marrow');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (21, 'Testis');
INSERT INTO tissues (pk_id_tissue, name_tissue) VALUES (22, 'Ovaries');

CREATE TABLE IF NOT EXISTS organisms(
    pk_id_organism int NOT NULL PRIMARY KEY,
    scientific_name varchar(20) UNIQUE NOT NULL,
    nom_cat varchar(20),
    taxid int UNIQUE NOT NULL
);
CREATE TABLE IF NOT EXISTS assemblies(
    pk_id_ass int NOT NULL PRIMARY KEY,
    url_link varchar(255) NOT NULL,
    busco_score decimal(10,2),
    name_ass varchar(100),
    date_of_release DATE,
    version varchar(30) NOT NULL UNIQUE,
    fk_id_organism int
);
-- genes
CREATE TABLE IF NOT EXISTS gene_ontologies(
    pk_id_GO int NOT NULL PRIMARY KEY,
    desc_GO varchar(255),
    GO_number int NOT NULL UNIQUE
);

INSERT INTO gene_ontologies (pk_id_GO, desc_GO, GO_number) VALUES (1, 'Apoptotic process', 0006915);
INSERT INTO gene_ontologies (pk_id_GO, desc_GO, GO_number) VALUES (2, 'Signal transduction', 0007165);
INSERT INTO gene_ontologies (pk_id_GO, desc_GO, GO_number) VALUES (3, 'DNA repair', 0006281);
INSERT INTO gene_ontologies (pk_id_GO, desc_GO, GO_number) VALUES (4, 'Metabolic process', 0008152);
INSERT INTO gene_ontologies (pk_id_GO, desc_GO, GO_number) VALUES (5, 'Transmembrane transporter activity', 0005215);
INSERT INTO gene_ontologies (pk_id_GO, desc_GO, GO_number) VALUES (6, 'Structural molecule activity receptor protein tyrosine kinase activity', 0005198);

CREATE TABLE IF NOT EXISTS genes(
    name_gene varchar(20),
    description_gene varchar(255),    
    fk_id_GO int
    pk_id_gene int NOT NULL PRIMARY KEY,
);

INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("TP53", "Tumor suppressor transcription factor that activates cell cycle arrest (p21) or apoptosis (BAX/PUMA)", 1, 1);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("MYC", "Proto-oncogene bHLH transcription factor that promotes global cell growth, translation, and proliferation", 1, 2);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("SRY", "Master-switch HMG-box transcription factor on the Y chromosome that initiates male sex determination", 1, 3);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("FOXP2", "Forkhead-box transcription factor crucial for synaptic plasticity and speech motor-sequence learning", 1, 4);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("HOXA1", "A specific homeobox gene from the HOXA cluster encoding a transcription factor essential for anterior-posterior patterning and hindbrain development", 1, 5);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("BRCA1", "Nuclear phosphoprotein essential for double-strand DNA break repair via homologous recombination", 2, 6);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("BRCA2", "Works with BRCA1; binds single-stranded DNA and recruits RAD51 to double-strand breaks for error-free repair", 2, 7);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("KRAS", "Small membrane-associated GTPases that act as molecular on/off switches for cell growth", 3, 8);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("EGFR", "Transmembrane receptor tyrosine kinase that activates upstream mitogenic pathways upon ligand binding", 3, 9);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("ERBB2", "Orphan receptor tyrosine kinase locked in an active conformation to amplify cell proliferation cascades", 3, 10);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("APC", "Scaffold protein in the beta-catenin destruction complex; acts as a negative regulator of the Wnt pathway", 3, 11);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("SHH", "Secreted morphogen establishing developmental gradients through the Patched-Smoothened pathway", 3, 12);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("MC1R", "Gs-coupled GPCR on melanocytes that controls the intracellular shift between eumelanin and pheomelanin", 3, 13);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("DRD4", "D4 subtype Gi/o-coupled dopamine receptor that inhibits adenylyl cyclase to reduce cAMP levels", 3, 14);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("PTEN", "Dual-specificity phosphatase that counteracts the PI3K/Akt pro-survival pathway by converting PIP3 to PIP2", 4, 15);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("VHL", "Component of an E3 ubiquitin ligase that marks HIF-1a for proteasomal degradation under normal oxygen levels", 4, 16);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("COMT", "Enzyme causing O-methylation and inactivation of dopamine and norepinephrine in the prefrontal cortex", 4, 17);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("MAOA", "Mitochondrial enzyme driving the oxidative deamination of serotonin, norepinephrine, and dopamine", 4, 18);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("MTHFR", "Rate-limiting cytosolic enzyme converting 5,10-methylenetetrahydrofolate to 5-methyltetrahydrofolate", 4, 19);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("PCSK9", "Secreted protease that targets hepatic LDL receptors for lysosomal degradation instead of recycling", 4, 20);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("FTO", "Alpha-ketoglutarate-dependent dioxygenase acting as an mRNA m6A demethylase to modulate appetite pathways", 4, 21);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("LCT", "Brush-border enzyme in the small intestine that hydrolyzes lactose disaccharides into glucose and galactose", 4, 22);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("APOE", "Apolipoprotein lipid transporter in the CNS involved in the clearance and handling of amyloid-beta", 5, 23);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("LDLR", "Cell-surface receptor mediating the endocytosis and clearing of cholesterol-rich LDL particles from the blood", 5, 24);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("CFTR", "ATP-gated ABC transporter chloride channel that regulates fluid viscosity across mucosal surfaces", 5, 25);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("ACE2", "Zinc metalloprotease that regulates blood pressure and acts as the entry receptor for the SARS-CoV-2 virus", 5, 26);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("HTT", "Huntingtin, a massive scaffolding protein required for vesicle transport and cytoskeletal motor anchoring", 6, 27);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("ACTN3", "Structural protein in skeletal muscle fast-twitch Z-discs anchoring internal actin filaments", 6, 28);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("DMD", "Dystrophin, a major structural link anchoring the intracellular F-actin cytoskeleton to the muscle extracellular matrix", 6, 29);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("HBB", "Beta-globin subunit of adult hemoglobin, structurally required for stable oxygen transport in red blood cells", 6, 30);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("SMN1", "Core structural scaffold protein regulating the assembly of snRNPs required for functional pre-mRNA splicing", 6, 31);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("HLA-B", "Polymorphic MHC class I heavy chain glycoprotein that physically holds and displays antigens to CD8+ T cells", 6, 32);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("SNAIL", "Zinc-finger transcription factor; represses E-cadherin to drive epithelial-mesenchymal transition (EMT) during development and fibrosis", 1, 33);
INSERT INTO genes (name_gene, description_gene, fk_id_GO, pk_id_gene) VALUES ("LOXL2", "Copper-dependent amine oxidase; catalyzes oxidative deamination of lysyl residues to crosslink extracellular matrix collagen", 4, 34);

-- taules intermitges n:m
CREATE TABLE IF NOT EXISTS gene_ass(
    pk_fk_id_ass int NOT NULL,
    pk_fk_id_gene int NOT NULL,
    TSS int,
    TES int,
    gene_length decimal(10,2) GENERATED ALWAYS AS (TES - TSS) STORED,
    CONSTRAINT pk_id_gene_ass PRIMARY KEY (pk_fk_id_ass, pk_fk_id_gene)
);
CREATE TABLE IF NOT EXISTS expression(
    pk_fk_id_exp int NOT NULL,
    pk_fk_id_gene int NOT NULL,
    expression_value int,
    gene_length ENUM("YES","NO") GENERATED ALWAYS AS (expression_value>=5) STORED,
    CONSTRAINT pk_id_expression PRIMARY KEY (pk_fk_id_exp, pk_fk_id_gene)
);

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
ALTER TABLE histone_mark 
ADD CONSTRAINT exp_hm 
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE transcription 
ADD CONSTRAINT exp_transcription 
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE transcription_factor 
ADD CONSTRAINT exp_TF
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE ON DELETE CASCADE;
 
ALTER TABLE DNA_accessibility 
ADD CONSTRAINT exp_DNAA
FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE experiments 
ADD CONSTRAINT exp_plat 
FOREIGN KEY (fk_id_platform) REFERENCES platforms(pk_id_platform)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE experiments 
ADD CONSTRAINT exp_bios 
FOREIGN KEY (fk_id_biosample) REFERENCES biosamples(pk_id_biosample)
ON UPDATE CASCADE ON DELETE RESTRICT;


-- BIOSAMPLES i ASSEMBLIES
ALTER TABLE biosamples 
ADD CONSTRAINT bios_tis 
FOREIGN KEY (fk_id_tissue) REFERENCES tissues(pk_id_tissue)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE biosamples 
ADD CONSTRAINT bios_org 
FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE assemblies 
ADD CONSTRAINT ass_org 
FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
ON UPDATE CASCADE ON DELETE RESTRICT;


--genes
ALTER TABLE genes 
ADD CONSTRAINT GO_genes 
FOREIGN KEY (fk_id_GO) REFERENCES gene_ontologies(pk_id_GO)
ON UPDATE CASCADE ON DELETE RESTRICT;

--taules intermitges
ALTER TABLE gene_ass 
ADD CONSTRAINT GA_assembly 
FOREIGN KEY (pk_fk_id_ass) REFERENCES assemblies(pk_id_ass)
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