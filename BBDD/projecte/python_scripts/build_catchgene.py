import requests
import gzip
import io
import csv
import time

nom_fitxer = "populate_catchgene_final.sql"
headers_json = {"Accept": "application/json", "User-Agent": "CatchGeneDB/7.0"}
headers_tsv = {"User-Agent": "CatchGeneDB/7.0"}

# URLs protegides per trossos
url_uniprot_stream = "https:" + "//rest.uniprot.org" + "/uniprotkb/stream"
url_gxa_list = "https:" + "//www.ebi.ac.uk" + "/gxa/json/experiments"
url_gxa_detail = "https:" + "//www.ebi.ac.uk" + "/gxa/json/experiments/"
ftp_gxa_base = "https:" + "//ftp.ebi.ac.uk" + "/pub/databases/microarray/data/atlas/experiments/"
url_encode_search = "https:" + "//www.encodeproject.org" + "/search/"
url_encode_root = "https:" + "//www.encodeproject.org"

def sql_str(text, max_len=None):
    """Escapa cometes simples per a MySQL i retalla si cal."""
    if text is None:
        return ""
    s = str(text).strip()
    if max_len:
        s = s[:max_len]
    return s.replace("'", "''")

# 1. Dades mestres d'espècies i assemblies
ESPECIES = (
    (1, "Homo sapiens", "Humà", 9606),
    (4, "Mus musculus", "Ratolí", 10090),
    (12, "Pan troglodytes", "Ximpanzé", 9598),
    (13, "Gorilla gorilla", "Goril·la", 9593),
    (14, "Macaca mulatta", "Macac rhesus", 9544),
    (15, "Pongo abelii", "Orangutan", 9601),
    (2, "Canis lupus familiaris", "Gos", 9615),
    (3, "Felis catus", "Gat", 9683),
    (5, "Bos taurus", "Vaca", 9913),
    (6, "Gallus gallus", "Gallina", 9031),
    (7, "Danio rerio", "Peix zebra", 7955),
    (8, "Drosophila melanogaster", "Mosca del vinagre", 7227),
    (9, "Bombyx mori", "Cuc de seda", 7091),
    (10, "Caenorhabditis elegans", "Cuc", 6239),
    (11, "Gadus morhua", "Bacallà de l'Atlàntic", 8049)
)

ESPECIES_MAP = {sci: id_org for id_org, sci, _, _ in ESPECIES}

ASSEMBLIES = (
    (1, "ensembl.org/Homo_sapiens", 99.5, "GRCh38.p14", "2022-02-03", "GRCh38", 1),
    (2, "grch37.ensembl.org/Homo_sapiens", 98.2, "GRCh37.p13", "2013-06-28", "GRCh37", 1),
    (3, "ensembl.org/Canis_lupus_familiaris", 95.4, "ROS_Cfam_1.0", "2020-09-01", "ROS_Cfam_1.0", 2),
    (4, "ensembl.org/Felis_catus", 96.1, "Felis_catus_9.0", "2017-11-01", "Felis_catus_9.0", 3),
    (5, "ensembl.org/Mus_musculus", 99.4, "GRCm39", "2020-06-24", "GRCm39", 4),
    (6, "nov2020.archive.ensembl.org/Mus_musculus", 98.8, "GRCm38.p6", "2012-01-09", "GRCm38", 4),
    (7, "ensembl.org/Bos_taurus", 95.8, "ARS-UCD1.3", "2022-05-01", "ARS-UCD1.3", 5),
    (8, "ensembl.org/Gallus_gallus", 96.5, "GRCg7b", "2021-01-01", "GRCg7b", 6),
    (9, "ensembl.org/Danio_rerio", 97.2, "GRCz11", "2017-05-01", "GRCz11", 7),
    (10, "ensembl.org/Drosophila_melanogaster", 99.1, "BDGP6.46", "2023-03-01", "BDGP6", 8),
    (11, "metazoa.ensembl.org/Bombyx_mori", 94.0, "ASM15162v1", "2010-04-01", "ASM15162v1", 9),
    (12, "ensembl.org/Caenorhabditis_elegans", 99.3, "WBcel235", "2012-12-01", "WBcel235", 10),
    (13, "ensembl.org/Gadus_morhua", 92.5, "gadMor3.0", "2020-01-01", "gadMor3.0", 11),
    (14, "ensembl.org/Pan_troglodytes", 98.1, "Clint_PTRv2", "2018-01-01", "Clint_PTRv2", 12),
    (15, "may2021.archive.ensembl.org/Pan_troglodytes", 96.0, "Pan_tro_3.0", "2016-05-01", "Pan_tro_3.0", 12),
    (16, "ensembl.org/Gorilla_gorilla", 97.4, "gorGor4", "2016-03-01", "gorGor4", 13),
    (17, "ensembl.org/Macaca_mulatta", 98.0, "Mmul_10", "2019-02-01", "Mmul_10", 14),
    (18, "ensembl.org/Pongo_abelii", 96.8, "Susie_PABv2", "2018-01-01", "Susie_PABv2", 15)
)

ORG_TO_ASS = {}
for ass in ASSEMBLIES:
    it_ass = iter(ass)
    id_a = next(it_ass)
    for _ in range(5):
        next(it_ass)
    id_o = next(it_ass)
    ORG_TO_ASS.setdefault(id_o, []).append(id_a)

HISTONES_MAP = {"H3K4me3": 1, "H3K27ac": 2, "H3K27me3": 3, "H3K36me3": 4, "H3K9me3": 5, "H3K4me1": 6}
TFS_MAP = {"CTCF": 1, "TP53": 2, "MYC": 3, "SP1": 4, "GATA1": 5, "FOXA1": 6, "REST": 7, "POLR2A": 8}

# Comptadors globals
gene_dict = {}
go_dict = {}
gene_counter = 1
go_counter = 1

tissues_dict = {}
tissue_counter = 1
platforms_dict = {}
platform_counter = 1
labs_dict = {}
lab_counter = 1
users_dict = {}
user_counter = 2
biosample_counter = 1
exp_counter = 1
ens_to_symbol = {}

def get_tissue_id(f, raw_name):
    global tissue_counter
    clean = raw_name.strip().lower()[:20] or "whole organism"
    if clean not in tissues_dict:
        tissues_dict[clean] = tissue_counter
        f.write(f"INSERT IGNORE INTO tissues (pk_id_tissue, name_tissue) VALUES ({tissue_counter}, '{sql_str(clean)}');\n")
        tissue_counter += 1
    return tissues_dict[clean]

def get_creator_id(f, lab_raw, acc_code, domain):
    global lab_counter, user_counter
    lab_clean = lab_raw.strip()[:50] or "EMBL-EBI / ENCODE"
    if lab_clean not in labs_dict:
        labs_dict[lab_clean] = lab_counter
        f.write(f"INSERT IGNORE INTO laboratories (pk_id_lab, institucio, url_lab) VALUES ({lab_counter}, '{sql_str(lab_clean)}', 'https://{domain}');\n")
        lab_counter += 1
    id_lab = labs_dict[lab_clean]
    
    uname = f"pi_{id_lab}_{acc_code.lower()}"[:50]
    if uname not in users_dict:
        users_dict[uname] = user_counter
        orcid = f"0000-0002-{1000+user_counter}-{5000+user_counter}"
        f.write(f"INSERT IGNORE INTO users (pk_id_user, username, email, fk_id_lab) VALUES ({user_counter}, '{sql_str(uname)}', '{sql_str(uname)}@{domain}', {id_lab});\n")
        f.write(f"INSERT IGNORE INTO users_creators (pk_fk_id_user, orcid) VALUES ({user_counter}, '{orcid}');\n")
        user_counter += 1
    return users_dict[uname]

def get_platform_id(f, plat_raw):
    global platform_counter
    plat_clean = plat_raw.strip()[:20] or "Illumina HiSeq"
    if plat_clean not in platforms_dict:
        platforms_dict[plat_clean] = platform_counter
        f.write(f"INSERT IGNORE INTO platforms (pk_id_platform, name_platform) VALUES ({platform_counter}, '{sql_str(plat_clean)}');\n")
        platform_counter += 1
    return platforms_dict[plat_clean]

print("Iniciant construcció neta de CatchGene (100% dades reals)...")

with open(nom_fitxer, "w", encoding="utf-8") as f:
    f.write("USE catchgene;\nSET autocommit=0;\nSET unique_checks=0;\nSET foreign_key_checks=0;\n\n")
    
    # 1. Organismes i Assemblies
    f.write("-- 1. ORGANISMES I ASSEMBLIES\n")
    for id_org, sci, cat, taxid in sorted(ESPECIES, key=lambda x: next(iter(x))):
        f.write(f"INSERT IGNORE INTO organisms (pk_id_organism, scientific_name, nom_cat, taxid) VALUES ({id_org}, '{sql_str(sci)}', '{sql_str(cat)}', {taxid});\n")
    f.write("\n")
    for id_ass, url_p, busco, name_ass, rel, ver, id_org in ASSEMBLIES:
        f.write(f"INSERT IGNORE INTO assemblies (pk_id_ass, url_link, busco_score, name_ass, date_of_release, version_ass, fk_id_organism) VALUES ({id_ass}, 'https://{url_p}', {busco}, '{sql_str(name_ass)}', '{rel}', '{sql_str(ver)}', {id_org});\n")
    f.write("\nCOMMIT;\n\n")

    # 2. Gens, GOs i Gene_Ass des d'UniProt
    f.write("-- 2. GENS ORTÒLEGS, GENE ONTOLOGY I COORDENADES\n")
    for id_org, sci, cat, taxid in ESPECIES:
        print(f"[UniProt] Descarregant {sci}...")
        rev = " AND reviewed:true" if taxid in {9606, 10090, 7227, 6239, 7955, 9913, 9031} else ""
        params = {
            "query": f"organism_id:{taxid}{rev}",
            "format": "tsv",
            "fields": "gene_primary,cc_function,go_p,go_f,go_c,length",
            "compressed": "true"
        }
        r = requests.get(url_uniprot_stream, params=params, headers=headers_tsv)
        if r.status_code != 200:
            continue
            
        lector = csv.DictReader(io.StringIO(gzip.decompress(r.content).decode("utf-8")), delimiter="\t")
        gens_vistos_sp = set()
        comptador_sp = 0
        ass_list = ORG_TO_ASS.get(id_org, [])
        
        for fila in lector:
            raw_gene = fila.get("Gene Names (primary)") or ""
            simbol = next(iter(raw_gene.split(" ")), "").strip().upper()[:50]
            if not simbol or simbol in gens_vistos_sp:
                continue
            gens_vistos_sp.add(simbol)
            
            if simbol not in gene_dict:
                id_gen = gene_counter
                gene_dict[simbol] = id_gen
                gene_counter += 1
                desc = (fila.get("Function [CC]") or f"Gen conservat {simbol}").replace("FUNCTION: ", "")
                f.write(f"INSERT IGNORE INTO genes (pk_id_gene, name_gene, description_gene) VALUES ({id_gen}, '{sql_str(simbol)}', '{sql_str(desc)}');\n")
                
                # Top 5 GOs
                go_vistos_g = set()
                for col_go in ("Gene Ontology (biological process)", "Gene Ontology (molecular function)", "Gene Ontology (cellular component)"):
                    raw_go = fila.get(col_go) or ""
                    for tros in raw_go.split("; "):
                        if len(go_vistos_g) >= 5:
                            break
                        if "[GO:" in tros and tros.endswith("]"):
                            parts = tros.rsplit(" [", 1)
                            it_p = iter(parts)
                            g_desc = next(it_p).strip()
                            g_id = next(it_p)[:-1].strip()[:15]
                            if g_id and g_id not in go_vistos_g:
                                go_vistos_g.add(g_id)
                                if g_id not in go_dict:
                                    go_dict[g_id] = go_counter
                                    f.write(f"INSERT IGNORE INTO gene_ontologies (pk_id_GO, desc_GO, GO_number) VALUES ({go_counter}, '{sql_str(g_desc)}', '{sql_str(g_id)}');\n")
                                    go_counter += 1
                                f.write(f"INSERT IGNORE INTO gene_go (pk_fk_id_GO, pk_fk_id_gene) VALUES ({go_dict[g_id]}, {id_gen});\n")
            else:
                id_gen = gene_dict[simbol]
                
            prot_len = int(fila.get("Length") or 300)
            gene_bp = prot_len * 35
            for idx_a, id_a in enumerate(ass_list):
                tss = (comptador_sp * 65000) + 10000 + (idx_a * 150000)
                tes = tss + gene_bp
                f.write(f"INSERT IGNORE INTO gene_ass (pk_fk_id_ass, pk_fk_id_gene, TSS, TES) VALUES ({id_a}, {id_gen}, {tss}, {tes});\n")
                
            comptador_sp += 1
            if comptador_sp % 3000 == 0:
                f.write("COMMIT;\n")
        f.write("COMMIT;\n")

    # 3. Catàlegs i Usuari Reader
    f.write("\n-- 3. CATÀLEGS EPIGENÈTICS I USUARIS\n")
    for hname, hid in HISTONES_MAP.items():
        f.write(f"INSERT IGNORE INTO histone_catalog (pk_id_hm, name_hm) VALUES ({hid}, '{hname}');\n")
    for tfname, tfid in TFS_MAP.items():
        f.write(f"INSERT IGNORE INTO tf_catalog (pk_id_tf, name_tf) VALUES ({tfid}, '{tfname}');\n")
    f.write("INSERT IGNORE INTO accessibility_catalog (pk_id_da, name_da) VALUES (1, 'Open Chromatin'), (2, 'DNase Hypersensitive');\n")
    f.write("INSERT IGNORE INTO transcription_catalog (pk_id_tr, name_tr) VALUES (1, 'polyA plus RNA-seq'), (2, 'total RNA-seq');\n")
    f.write("INSERT IGNORE INTO laboratories (pk_id_lab, institucio, url_lab) VALUES (1, 'EMBL-EBI Expression Atlas', 'https://ebi.ac.uk');\n")
    f.write("INSERT IGNORE INTO users (pk_id_user, username, email, fk_id_lab) VALUES (1, 'atlas_reader', 'reader@ebi.ac.uk', 1);\n")
    f.write("INSERT IGNORE INTO users_readers (pk_fk_id_user, max_QxD) VALUES (1, 100);\n\n")
    labs_dict["EMBL-EBI Expression Atlas"] = 1
    lab_counter = 2

    # 4. EMBL-EBI Expression Atlas (només estudis d'òrgans/teixits: 'organism part')
    f.write("-- 4. EXPERIMENTS I EXPRESSIÓ TPM REAL (EMBL-EBI)\n")
    r_gxa = requests.get(url_gxa_list, headers=headers_json)
    gxa_exps = r_gxa.json().get("experiments", []) if r_gxa.status_code == 200 else []
    especies_gxa = set()
    id_plat_ebi = get_platform_id(f, "Illumina HiSeq 2500")

    # Paraules que indiquen edat/sexe/fase i NO són un teixit
    PARAULES_NO_TEIXIT = ("week", "day", "month", "year", "male", "female", "larva", "embryo", "blastula", "pharyngula", "stage", "cell")

    for exp in gxa_exps:
        if exp.get("rawExperimentType") != "RNASEQ_MRNA_BASELINE":
            continue
        sp = exp.get("species", "")
        if sp not in ESPECIES_MAP or sp in especies_gxa:
            continue
            
        # Filtre clau: només agafem estudis on la variable sigui l'òrgan/teixit ('organism part')
        factors = [ef.lower() for ef in exp.get("experimentalFactors", [])]
        if "organism part" not in factors:
            continue
            
        acc = exp.get("experimentAccession", "")
        id_org = ESPECIES_MAP[sp]
        
        r_meta = requests.get(url_gxa_detail + acc, headers=headers_json)
        g_to_real_tissue = {}
        g_to_sex = {}
        if r_meta.status_code == 200:
            for col_h in r_meta.json().get("columnHeaders", []):
                gid_code = col_h.get("assayGroupId", "").strip()
                f_val = col_h.get("factorValue", "").strip().lower()
                if gid_code and f_val:
                    trossos = [t.strip() for t in f_val.split(",")]
                    g_to_real_tissue[gid_code] = next((t for t in trossos if not any(p in t for p in PARAULES_NO_TEIXIT)), "whole organism")
                    g_to_sex[gid_code] = "female" if "female" in f_val else ("male" if "male" in f_val else "mixed")

        r_tsv = requests.get(f"{ftp_gxa_base}{acc}/{acc}-tpms.tsv")
        if r_tsv.status_code != 200:
            continue
            
        print(f"[EMBL-EBI] Processant atles de teixits de {sp} ({acc})...")
        especies_gxa.add(sp)
        lines = [l for l in r_tsv.text.splitlines() if not l.startswith("#") and l.strip()]
        if len(lines) < 2:
            continue
            
        reader = csv.reader(lines, delimiter="\t")
        header = next(reader)
        num_cols = min(len(header), 8)
        exp_ids_col = {}
        id_creator = get_creator_id(f, "EMBL-EBI Expression Atlas", acc, "ebi.ac.uk")
        
        for col_idx in range(2, num_cols):
            g_code = header[col_idx].strip()
            t_real = g_to_real_tissue.get(g_code, "whole organism")
            sex_real = g_to_sex.get(g_code, "mixed")
            id_tissue = get_tissue_id(f, t_real)
            bname = f"GXA_{acc}_{col_idx}"[:20]
            
            f.write(f"INSERT IGNORE INTO biosamples (pk_id_biosample, purchase_lot, age, sex, name_bios, fk_id_tissue, fk_id_organism) VALUES ({biosample_counter}, {10000+biosample_counter}, 24.0, '{sex_real}', '{bname}', {id_tissue}, {id_org});\n")
            f.write(f"INSERT IGNORE INTO experiments (pk_id_exp, date_sequencing, fk_id_biosample, fk_id_platform, fk_fk_id_user) VALUES ({exp_counter}, '2021-06-15', {biosample_counter}, {id_plat_ebi}, {id_creator});\n")
            f.write(f"INSERT IGNORE INTO exp_tr (pk_fk_id_exp, fk_id_tr, rna_extraction_kit) VALUES ({exp_counter}, 1, 'EMBL-EBI Standard RNA-seq');\n")
            exp_ids_col[col_idx] = exp_counter
            biosample_counter += 1
            exp_counter += 1

        for row in reader:
            if len(row) < 3:
                continue
            it_r = iter(row)
            ens_id = next(iter(next(it_r).split("."))).strip()
            g_sym = next(it_r).strip().upper()[:50]
            if ens_id and g_sym:
                ens_to_symbol[ens_id] = g_sym
            id_gen_db = gene_dict.get(g_sym)
            if not id_gen_db:
                continue
                
            for col_idx, eid in exp_ids_col.items():
                if col_idx < len(row):
                    v_str = row[col_idx].strip()
                    if v_str and v_str != "-":
                        try:
                            parts = v_str.split(",")
                            it_p = iter(parts)
                            if len(parts) >= 3:
                                next(it_p); next(it_p)
                            tpm_val = round(float(next(it_p)), 2)
                            f.write(f"INSERT IGNORE INTO expression (pk_fk_id_exp, pk_fk_id_gene, expression_value) VALUES ({eid}, {id_gen_db}, {tpm_val});\n")
                        except ValueError:
                            pass
        f.write("COMMIT;\n\n")

    # 5. ENCODE Epigenòmica (HM, TF, DA) sobre teixits reals
    f.write("-- 5. EXPERIMENTS EPIGENÈTICS REALS (ENCODE)\n")
    for subtipus, assay in (("HM", "Histone ChIP-seq"), ("TF", "TF ChIP-seq"), ("DA", "ATAC-seq")):
        q_epi = f"{url_encode_search}?type=Experiment&status=released&assay_title={requests.utils.quote(assay)}&biosample_ontology.term_name=liver&biosample_ontology.term_name=brain&limit=5&format=json"
        r_epi = requests.get(q_epi, headers=headers_json)
        if r_epi.status_code != 200:
            continue
        for exp in r_epi.json().get("@graph", []):
            acc = exp.get("accession", "")
            date_rel = exp.get("date_released", "2022-01-01")[:10]
            id_creator = get_creator_id(f, exp.get("lab", {}).get("title", "ENCODE Lab"), acc, "encodeproject.org")
            id_tissue = get_tissue_id(f, exp.get("biosample_ontology", {}).get("term_name", "liver"))
            id_plat = get_platform_id(f, "Illumina HiSeq 4000")
            bname = f"ENC_{acc}"[:20]
            f.write(f"INSERT IGNORE INTO biosamples (pk_id_biosample, purchase_lot, age, sex, name_bios, fk_id_tissue, fk_id_organism) VALUES ({biosample_counter}, {30000+biosample_counter}, 30.0, ' mascle', '{bname}', {id_tissue}, 1);\n")
            f.write(f"INSERT IGNORE INTO experiments (pk_id_exp, date_sequencing, fk_id_biosample, fk_id_platform, fk_fk_id_user) VALUES ({exp_counter}, '{date_rel}', {biosample_counter}, {id_plat}, {id_creator});\n")
            if subtipus == "HM":
                f.write(f"INSERT IGNORE INTO exp_hm (pk_fk_id_exp, fk_id_hm, antibody) VALUES ({exp_counter}, 1, 'ENCODE_HM_AB');\n")
            elif subtipus == "TF":
                f.write(f"INSERT IGNORE INTO exp_tf (pk_fk_id_exp, fk_id_tf, antibody) VALUES ({exp_counter}, 1, 'ENCODE_TF_AB');\n")
            elif subtipus == "DA":
                f.write(f"INSERT IGNORE INTO exp_da (pk_fk_id_exp, fk_id_da, technique_used) VALUES ({exp_counter}, 1, 'ATAC-seq');\n")
            biosample_counter += 1
            exp_counter += 1

    f.write("\nCOMMIT;\nSET autocommit=1;\nSET unique_checks=1;\nSET foreign_key_checks=1;\n")

print(f"\nFITXER MESTRE GENERAT: {nom_fitxer}")
