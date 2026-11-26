DROP DATABASE IF EXISTS catchgene;

CREATE DATABASE IF NOT EXISTS catchgene;
-- CREATE SCHEMA IF NOT EXISTS catchgene;
use catchgene;

-- creació taules
CREATE TABLE IF NOT EXISTS tissues (
    pk_id_tissue INT NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador únic del teixit anatòmic',
    name_tissue VARCHAR(100) NOT NULL COMMENT 'Nom del teixit o òrgan biològic'
) COMMENT = 'Catàleg de teixits anatòmics i òrgans estudiats';

CREATE TABLE IF NOT EXISTS organisms(
    pk_id_organism int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Identificador únic de l'organisme",
    scientific_name varchar(50) UNIQUE NOT NULL COMMENT "Nom científic de l'organisme i clau candidata",
    nom_cat varchar(50) COMMENT "Nom vulgar de l'organisme",
    taxid int UNIQUE NOT NULL COMMENT "Identificador internacional de l'organisme i clau candidata"
) COMMENT = 'Catàleg dels organismes estudiats';

CREATE TABLE IF NOT EXISTS biosamples(
    pk_id_biosample int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador únic de la mostra',
    purchase_lot int COMMENT "Valor que pot quedar NULL sobretot en mostres provinents de repositoris públics",
    age decimal(10,2) COMMENT "Admet NULL perquè alguns experiments públics no publiquen l'edat del donant. Dades reals en anys.",
    sex varchar(20) COMMENT "Admet NULL quan el sexe no consta o és una barreja de mostres. Dada real d'ENCODE / EMBL-EBI.'",
    name_bios varchar(50) UNIQUE NOT NULL COMMENT "Nom únic de cada mostra",
    fk_id_tissue int COMMENT "FK del teixit específic per a cada mostra",
    fk_id_organism int "FK de l'organisme específic per a cada mostra",
    CONSTRAINT age_unsigned CHECK (age >= 0) COMMENT "Check que no permet valors negatius a l'edat"
) COMMENT = "Catàleg de mostres biològiques provinents d'un únic organisme i un únic teixit. D'una mostra es poden fer varis experiments";
    -- foreign keys biosamples
ALTER TABLE biosamples 
    ADD CONSTRAINT bios_tis 
        FOREIGN KEY (fk_id_tissue) REFERENCES tissues(pk_id_tissue)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT bios_org 
        FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
        ON UPDATE CASCADE ON DELETE RESTRICT;


CREATE TABLE IF NOT EXISTS platforms(
    pk_id_platform int NOT NULL AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identificador únic de la plataforma de seqüenciació',
    name_platform varchar(100) NOT NULL COMMENT "Nom de la plataforma de seqüenciació amb què s'ha fet l'experiment"
) COMMENT = "Catàleg de plataformes de seqüenciació amb què s'han fet els experiments";

CREATE TABLE IF NOT EXISTS histone_catalog (
    pk_id_hm int NOT NULL PRIMARY KEY COMMENT "Identificador únic del catàleg de marques d'histona que s'han utilitzat en els experiments",
    name_hm varchar(20) NOT NULL UNIQUE COMMENT "Nom de la marca d'histona"
) COMMENT = "Catàleg de les marques d'histona que s'han utilitzat en els experiments";

CREATE TABLE IF NOT EXISTS tf_catalog (
    pk_id_tf int NOT NULL PRIMARY KEY COMMENT "Identificador únic del catàleg de factors de transcripció que s'han utilitzat en els experiments",
    name_tf varchar(20) NOT NULL UNIQUE COMMENT "Nom del factor de transcripció"
) COMMENT = "Catàleg dels factors de transcripció dels quals s'han fet ChIP-Seq i obtingut dades de seqüenciació";

CREATE TABLE IF NOT EXISTS accessibility_catalog (
    pk_id_da int NOT NULL PRIMARY KEY COMMENT "Identificador únic de la tècnica d'accessibilitat utilitzada",
    name_da varchar(20) NOT NULL UNIQUE COMMENT "Nom de la tècnica d'accessibilitat utilitzada"
) COMMENT = "Catàleg de les tècniques d'accessibilitat al ADN amb les que s'ha obtingut dades de seqüenciació";
CREATE TABLE IF NOT EXISTS transcription_catalog(
    pk_id_tr int NOT NULL PRIMARY KEY COMMENT "Identificador únic de la tècnica de transcripció utilitzada",
    name_tr varchar(20) NOT NULL COMMENT "Nom de la tècnica de transcripció utilitzada"
) COMMENT = "Catàleg de les tècniques d'obtenció de l'RNA amb les que s'ha obtingut dades de seqüenciació";


-- bloc users
CREATE TABLE IF NOT EXISTS laboratories (
    pk_id_lab int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Identificador únic del laboratori que ha fet un experiment",
    institucio varchar(50) NOT NULL UNIQUE COMMENT "Nom del laboratori",
    url_lab varchar(100) COMMENT "Link web del laboratori"
) COMMENT = "Catàleg dels laboratoris que han realitzat els experiments que tenim a la BBDD";

CREATE TABLE IF NOT EXISTS users (
    pk_id_user int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Identificador únic dels usuaris de la BBDD",
    username varchar(50) NOT NULL UNIQUE COMMENT "Nom d'usuari de la persona que pot utilitzar la BBDD",
    email varchar(100) NOT NULL UNIQUE COMMENT "Email de la persona que pot utilitzar la BBDD",
    fk_id_lab int COMMENT "FK del laboratori d'on prové la persona que pot utilitzar la BBDD"
) COMMENT = "Catàleg dels usuaris de la BBDD. Tots venen d'un laboratori concret i es distingeixen entre creadors i lectors";
-- foreign keys
ALTER TABLE users
    ADD CONSTRAINT user_lab
        FOREIGN KEY (fk_id_lab) REFERENCES laboratories(pk_id_lab)
        ON UPDATE CASCADE ON DELETE RESTRICT;

-- tables ISA
CREATE TABLE IF NOT EXISTS users_creators (
    pk_fk_id_user int NOT NULL PRIMARY KEY COMMENT "Identificador únic dels usuaris que fan experiments i els podran entrar a la BBDD",
    orcid varchar(19) UNIQUE COMMENT "Número únic de cada científic que treballa en un laboratori del consorci"
) COMMENT = "Catàleg dels usuaris creadors";
CREATE TABLE IF NOT EXISTS users_readers (
    pk_fk_id_user int NOT NULL PRIMARY KEY COMMENT "Identificador únic dels usuaris que només poden fer consultes a la BBDD",
    max_QxD int DEFAULT 100 COMMENT "Número màxim de consultes per dia per evitar automatitzacions absurdes"
) COMMENT = "Catàleg dels usuaris lectors";

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
    fk_fk_id_user int NOT NULL COMMENT "FK de l'usuari lector que fa la consulta",
    query_number int NOT NULL COMMENT "Número de la consulta feta per un lector. Cada lector té el seu recompte",
    target_topic ENUM('genes', 'tissues', 'organisms', 'experiments', 'calcul', 'general') DEFAULT 'general' COMMENT "Camp per a estructurar les consultes basat en 4 taules principals, un càlcul específic o general per la resta",
    query_text TEXT NOT NULL COMMENT "On queda registrada la consulta feta",
    date_query TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT "Establiment automàtic de la data on s'ha fet la consulta",
    CONSTRAINT pk_user_queries PRIMARY KEY (fk_fk_id_user, query_number) COMMENT "Establiment de l'identificador únic com una combinació de l'usuari lector i el número de consulta"
) COMMENT = "Catàleg de les consultes fetes pels usuaris lectors";
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

CREATE TABLE IF NOT EXISTS queries (
    fk_fk_id_user int NOT NULL COMMENT "FK de l'usuari lector que fa la consulta",
    query_number int NOT NULL COMMENT "Número de la consulta feta per un lector. Cada lector té el seu recompte",
    target_topic ENUM('genes', 'tissues', 'organisms', 'experiments', 'calcul', 'general') DEFAULT 'general' COMMENT "Camp per a estructurar les consultes basat en 4 taules principals, un càlcul específic o general per la resta",
    query_text TEXT NOT NULL COMMENT "On queda registrada la consulta feta",
    date_query TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT "Establiment automàtic de la data on s'ha fet la consulta",
    CONSTRAINT pk_user_queries PRIMARY KEY (fk_fk_id_user, query_number) COMMENT "Establiment de l'identificador únic com una combinació de l'usuari lector i el número de consulta"
) COMMENT = "Catàleg de les consultes fetes pels usuaris lectors";

-- bloc experiments
CREATE TABLE IF NOT EXISTS experiments(
    pk_id_exp int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Identificador únic de cada experiment",
    date_sequencing DATE NOT NULL DEFAULT '2001-01-01' COMMENT "Data on es va seqüenciar l'experiment en cas de no haver-n'hi establert 2001-01-01 per default",
    fk_id_biosample int COMMENT "FK de la mostra d'on s'ha fet l'experiment de seqüenciació",
    fk_id_platform int COMMENT "FK de la plataforma amb què s'ha fet la seqüenciació",
    fk_fk_id_user int COMMENT "FK de l'usuari que ha fet l'experiment"
) COMMENT = "Catàleg dels experiments de seqüenciació de la BBDD. Conté la informació de seqüenciació per a cada gen";
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
    pk_fk_id_exp int NOT NULL PRIMARY KEY COMMENT "Identificador únic de cada experiment de marques d'histona que prové de l'identificador únic de l'experiment",
    fk_id_hm int NOT NULL COMMENT "FK del catàleg de marques d'histona específic per cada experiment",
    antibody varchar(50) COMMENT "Anticòs utilitzat en l'experiment contra una de les marques d'histona"
) COMMENT = "Relació de cada experiment fet amb anticossos contra les marques d'histona";
CREATE TABLE IF NOT EXISTS exp_tf(
    pk_fk_id_exp int NOT NULL PRIMARY KEY  COMMENT "Identificador únic de cada experiment de ChIP-seq amb factors de transcripció que prové de l'identificador únic de l'experiment",
    fk_id_tf int NOT NULL COMMENT "FK del catàleg de factors de transcripció específic per cada experiment",
    antibody varchar(50) COMMENT "Anticòs utilitzat en l'experiment contra un dels factors de transcripció"
) COMMENT = "Relació de cada experiment fet amb anticossos contra factors de transcripció";
CREATE TABLE IF NOT EXISTS exp_da(
    pk_fk_id_exp int NOT NULL PRIMARY KEY COMMENT "Identificador únic de cada experiment d'accessibilitat al DNA que prové de l'identificador únic de l'experiment",
    fk_id_da int NOT NULL COMMENT "FK del catàleg de tècniques d'accessibilitat al DNA específic per cada experiment",
    technique_used varchar(100) NOT NULL COMMENT "Especificacions de la tècnica d'accessibilitat al DNA especifica de cada tècnica"
) COMMENT = "Relació de cada experiment fet amb tècniques d'accessibilitat al DNA";
CREATE TABLE IF NOT EXISTS exp_tr(
    pk_fk_id_exp int NOT NULL PRIMARY KEY COMMENT "Identificador únic de cada experiment de transcripció que prové de l'identificador únic de l'experiment",
    fk_id_tr int NOT NULL COMMENT "FK del catàleg de tècniques de transcripció específic per cada experiment",
    rna_extraction_kit varchar(100) NOT NULL COMMENT "Especificacions de la tècnica de transcripció especifica de cada tècnica"
) COMMENT = "Relació de cada experiment fet directament de transcriptòmica";

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
    pk_id_ass int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Identificador únic de cada assembly",
    url_link varchar(255) NOT NULL UNIQUE COMMENT "Obligatori (NOT NULL) i únic. URL construïda dinàmicament cap a la fitxa real de l'assemblatge a Ensembl/NCBI.",
    busco_score decimal(10,2) COMMENT "Puntuació de completesa genòmica BUSCO (%) simulada/estimada per a l'assembly.",
    name_ass varchar(100) COMMENT "Nom oficial de l'assembly extret de l'Ensembl",
    date_of_release DATE COMMENT "Data de publicació de l'assembly extreta de l'Ensembl",
    version_ass varchar(50) NOT NULL UNIQUE COMMENT "Codi d'accés de l'assembly extreta de l'Ensembl",
    fk_id_organism int COMMENT "FK que vincula l'assembly a l'organisme al qual pertany"
) COMMENT = "Catàleg d'assemblies on hi ha la posició genòmica de cada gen. Cada organisme pot tenir varis assemblies";

    -- foreign keys
ALTER TABLE assemblies 
    ADD CONSTRAINT ass_org 
        FOREIGN KEY (fk_id_organism) REFERENCES organisms(pk_id_organism)
        ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TABLE IF NOT EXISTS gene_ontologies(
    pk_id_GO int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Identificador únic de cada GO per a la BBDD",
    desc_GO TEXT COMMENT "Descripció funcional real extreta d'UniProt / Gene Ontology",
    GO_number varchar(15) NOT NULL UNIQUE COMMENT "Identificador oficial real (ex. GO:0003677) extret d'UniProt / Gene Ontology"
) COMMENT = "Catàleg dels GO que poden tenir els gens presents a la BBDD";

CREATE TABLE IF NOT EXISTS genes(
    pk_id_gene int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Identificador únic de cada gen per a la BBDD",
    name_gene varchar(50) UNIQUE COMMENT "Símbol oficial real del gen extret d'UniProt / EMBL-EBI.",
    description_gene TEXT COMMENT "Nom complet i funció biològica real de la proteïna extreta d'UniProt."
) COMMENT = "Catàleg dels gens dels quals es té informació en la BBDD";


-- taules intermitges n:m
CREATE TABLE IF NOT EXISTS gene_go(
    pk_fk_id_GO int NOT NULL COMMENT "FK que vincula cada gen amb els diferents GO",
    pk_fk_id_gene int NOT NULL COMMENT "FK que vincula cada GO amb els diferents gens",
    CONSTRAINT pk_id_gene_go PRIMARY KEY (pk_fk_id_GO, pk_fk_id_gene) COMMENT "Constraint que fa que les dues FKs siguin la PK"
) COMMENT = "Relació entre els gens i els GO";

-- foreign keys
ALTER TABLE gene_go 
    ADD CONSTRAINT GGO_go 
        FOREIGN KEY (pk_fk_id_GO) REFERENCES gene_ontologies(pk_id_GO)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT GGO_gene 
        FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
        ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TABLE IF NOT EXISTS gene_ass(
    pk_fk_id_ass int NOT NULL COMMENT "FK que vincula cada assembly amb els diferents gens",
    pk_fk_id_gene int NOT NULL COMMENT "FK que vincula cada gen amb els diferents assemblies",
    TSS int COMMENT "Transcription Start Site simulat a la longitud proteica d'UniProt.",
    TES int COMMENT "Transcription End Site simulat a la longitud proteica d'UniProt",
    gene_length decimal(10,2) GENERATED ALWAYS AS (TES - TSS) STORED COMMENT "Columna calculada automàticament (TES - TSS) en parells de bases",
    CONSTRAINT pk_id_gene_ass PRIMARY KEY (pk_fk_id_ass, pk_fk_id_gene) COMMENT "Constraint que fa que les dues FKs siguin la PK"
) COMMENT = "Relació entre els gens i els assemblies. On cada gen té una posicio inicial i final diferent i àdhuc una llargada diferent";
-- foreign keys
ALTER TABLE gene_ass 
    ADD CONSTRAINT GA_assembly 
        FOREIGN KEY (pk_fk_id_ass) REFERENCES assemblies(pk_id_ass)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT GA_gene 
        FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
        ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TABLE IF NOT EXISTS expression (
    pk_fk_id_exp INT NOT NULL COMMENT "FK que vincula cada experiment amb els diferents gens",
    pk_fk_id_gene INT NOT NULL COMMENT "FK que vincula cada gen amb els diferents experiments",
    expression_value DECIMAL(10, 2) NOT NULL COMMENT "Valor real en TPM (EMBL-EBI RNA-seq) o senyal simulada (HM/TF/DA d'ENCODE)",
    gene_expressed ENUM('YES', 'NO') COMMENT "Assignat dinàmicament per trigger segons el llindar de la tècnica (TR>=5, DA>=2, TF/HM>=1)",
    CONSTRAINT pk_id_expression PRIMARY KEY (pk_fk_id_exp, pk_fk_id_gene) COMMENT "Constraint que fa que les dues FKs siguin la PK",
    CONSTRAINT chk_expression_positive CHECK (expression_value >= 0) COMMENT "Constraint perquè el valor sigui sempre positiu o 0"
) COMMENT = "Relació entre els gens i els experiments. Cada gen té un valor diferent en cada experiment";

ALTER TABLE expression 
    ADD CONSTRAINT exp_expression 
        FOREIGN KEY (pk_fk_id_exp) REFERENCES experiments(pk_id_exp)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT gen_expression 
        FOREIGN KEY (pk_fk_id_gene) REFERENCES genes(pk_id_gene)
        ON UPDATE CASCADE ON DELETE RESTRICT;

DELIMITER $$

CREATE TRIGGER trg_threshold_signal_type
BEFORE INSERT ON expression
FOR EACH ROW
BEGIN
    DECLARE llindar DECIMAL(10, 2) DEFAULT 5.00;

    IF EXISTS (SELECT 1 FROM exp_tr WHERE pk_fk_id_exp = NEW.pk_fk_id_exp) THEN
        SET llindar = 5.00;
        
    ELSEIF EXISTS (SELECT 1 FROM exp_da WHERE pk_fk_id_exp = NEW.pk_fk_id_exp) THEN
        SET llindar = 2.00;
        
    ELSEIF EXISTS (SELECT 1 FROM exp_tf WHERE pk_fk_id_exp = NEW.pk_fk_id_exp) 
        OR EXISTS (SELECT 1 FROM exp_hm WHERE pk_fk_id_exp = NEW.pk_fk_id_exp) THEN
        SET llindar = 1.00;
    END IF;

    IF NEW.expression_value >= llindar THEN
        SET NEW.gene_expressed = 'YES';
    ELSE
        SET NEW.gene_expressed = 'NO';
    END IF;
END

DELIMITER ;























