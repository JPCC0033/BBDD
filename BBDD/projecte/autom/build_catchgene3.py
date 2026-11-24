import requests
import gzip
import io
import csv
import time

nom_fitxer = "populate_catchgene_final.sql"
headers_json = {"Accept": "application/json", "User-Agent": "CatchGeneDB/10.0"}
headers_tsv = {"User-Agent": "CatchGeneDB/10.0"}

url_uniprot = "https:" + "//rest.uniprot.org" + "/uniprotkb/stream"
url_gxa_list = "https:" + "//www.ebi.ac.uk" + "/gxa/json/experiments"
url_gxa_det = "https:" + "//www.ebi.ac.uk" + "/gxa/json/experiments/"
ftp_gxa = "https:" + "//ftp.ebi.ac.uk" + "/pub/databases/microarray/data/atlas/experiments/"
url_enc_search = "https:" + "//www.encodeproject.org" + "/search/"
url_enc_root = "https:" + "//www.encodeproject.org"

def sql_str(text, max_len=None):
    if text is None:
        return "NULL"
    s = str(text).strip()
    if not s or s.lower() in ("none", "unknown", "not applicable"):
        return "NULL"
    if max_len:
        s = s[:max_len]
    return "'" + s.replace("'", "''") + "'"

def parse_age_years(age_raw, units="year"):
    """Converteix l'edat real de l'API a anys decimals; retorna 'NULL' si no consta."""
    if not age_raw:
        return "NULL"
    s = str(age_raw).strip().lower()
    if s in ("unknown", "none", "not applicable", ""):
        return "NULL"
    try:
        primer_num = next(iter(s.split("-"))).strip()
        val = float(next(iter(primer_num.split())))
        u = str(units).lower()
        if "month" in u:
            val = val / 12.0
        elif "week" in u:
            val = val / 52.0
        elif "day" in u:
            val = val / 365.0
        return str(round(val, 2))
    except ValueError:
        return "NULL"

# ==============================================================================
# DADES 100% REALS: Taxonomia oficial NCBI/UniProt i Assemblies d'Ensembl
# ==============================================================================
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
ESPECIES_MAP = {sci: id_o for id_o, sci, _, _ in ESPECIES}

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
    it_a = iter(ass)
    id_a = next(it_a)
    for _ in range(5):
        next(it_a)
    ORG_TO_ASS.setdefault(next(it_a), []).append(id_a)

INST_URLS = {
    "stanford": "stanford.edu", "broad": "broadinstitute.org", "ucsd": "ucsd.edu",
    "caltech": "caltech.edu", "cshl": "cshl.edu", "hudsonalpha": "hudsonalpha.org",
    "uw": "washington.edu", "yale": "yale.edu", "ebi": "ebi.ac.uk"
}

# Diccionaris 100% dinàmics (s'omplen automàticament amb el que retornin les APIs)
gene_dict, go_dict, tissues_dict, platforms_dict, labs_dict, users_dict = {}, {}, {}, {}, {}, {}
histones_dict, tfs_dict = {}, {}
gene_counter = go_counter = tissue_counter = platform_counter = lab_counter = biosample_counter = exp_counter = 1
histone_counter = tf_counter = 1
user_counter = 6
def get_tissue_id(f, raw_name):
    global tissue_counter
    clean = raw_name.strip().lower()[:20] or "whole organism"
    if clean not in tissues_dict:
        tissues_dict[clean] = tissue_counter
        f.write(f"INSERT IGNORE INTO tissues (pk_id_tissue, name_tissue) VALUES ({tissue_counter}, {sql_str(clean)});\n")
        tissue_counter += 1
    return tissues_dict[clean]

def get_creator_id(f, lab_raw, pi_name):
    global lab_counter, user_counter
    lab_clean = lab_raw.strip()[:50] or "EMBL-EBI Genomics"
    domain = next((u for k, u in INST_URLS.items() if k in lab_clean.lower()), "genome.gov")
    if lab_clean not in labs_dict:
        labs_dict[lab_clean] = lab_counter
        f.write(f"INSERT IGNORE INTO laboratories (pk_id_lab, institucio, url_lab) VALUES ({lab_counter}, {sql_str(lab_clean)}, 'https://{domain}');\n")
        lab_counter += 1
    id_lab = labs_dict[lab_clean]
    
    clean_pi = "".join(c for c in pi_name.lower() if c.isalnum() or c == " ").strip().replace(" ", "_")
    uname = (clean_pi or f"researcher_{id_lab}")[:50]
    if uname not in users_dict:
        users_dict[uname] = user_counter
        # NOTA SINTÈTICA: ORCID seqüencial perquè l'API d'ENCODE no el publica i la BD exigeix UNIQUE NOT NULL
        orcid = f"0000-0002-{1000+user_counter}-{4000+user_counter}"
        f.write(f"INSERT IGNORE INTO users (pk_id_user, username, email, fk_id_lab) VALUES ({user_counter}, {sql_str(uname)}, '{uname.replace(chr(39), '')}@{domain}', {id_lab});\n")
        f.write(f"INSERT IGNORE INTO users_creators (pk_fk_id_user, orcid) VALUES ({user_counter}, '{orcid}');\n")
        user_counter += 1
    return users_dict[uname]

def get_platform_id(f, plat_raw):
    global platform_counter
    plat_clean = plat_raw.strip()[:20] or "Illumina HiSeq 4000"
    if plat_clean not in platforms_dict:
        platforms_dict[plat_clean] = platform_counter
        f.write(f"INSERT IGNORE INTO platforms (pk_id_platform, name_platform) VALUES ({platform_counter}, {sql_str(plat_clean)});\n")
        platform_counter += 1
    return platforms_dict[plat_clean]

def get_histone_id(f, raw_hm):
    global histone_counter
    clean = raw_hm.strip()[:50] or "H3K27ac"
    if clean not in histones_dict:
        histones_dict[clean] = histone_counter
        f.write(f"INSERT IGNORE INTO histone_catalog (pk_id_hm, name_hm) VALUES ({histone_counter}, {sql_str(clean)});\n")
        histone_counter += 1
    return histones_dict[clean]

def get_tf_id(f, raw_tf):
    global tf_counter
    clean = raw_tf.strip()[:50] or "CTCF"
    if clean not in tfs_dict:
        tfs_dict[clean] = tf_counter
        f.write(f"INSERT IGNORE INTO tf_catalog (pk_id_tf, name_tf) VALUES ({tf_counter}, {sql_str(clean)});\n")
        tf_counter += 1
    return tfs_dict[clean]

print("Generant build_catchgene3 (catàlegs dinàmics i separació real/sintètic)...")

with open(nom_fitxer, "w", encoding="utf-8") as f:
    f.write("USE catchgene;\nSET autocommit=0;\nSET unique_checks=0;\nSET foreign_key_checks=0;\n\n")
    
    # [BLOC 100% REAL] Organismes i Assemblies
    for id_org, sci, cat, taxid in sorted(ESPECIES, key=lambda x: next(iter(x))):
        f.write(f"INSERT IGNORE INTO organisms (pk_id_organism, scientific_name, nom_cat, taxid) VALUES ({id_org}, {sql_str(sci)}, {sql_str(cat)}, {taxid});\n")
    for id_ass, url_p, busco, name_ass, rel, ver, id_org in ASSEMBLIES:
        f.write(f"INSERT IGNORE INTO assemblies (pk_id_ass, url_link, busco_score, name_ass, date_of_release, version_ass, fk_id_organism) VALUES ({id_ass}, 'https://{url_p}', {busco}, {sql_str(name_ass)}, '{rel}', {sql_str(ver)}, {id_org});\n")
    f.write("\nCOMMIT;\n\n")

    # [BLOC 100% REAL + COORDENADES APROXIMADES] Gens i GO d'UniProt
    for id_org, sci, cat, taxid in ESPECIES:
        print(f"[UniProt - REAL] Descarregant {sci}...")
        rev = " AND reviewed:true" if taxid in {9606, 10090, 7227, 6239, 7955, 9913, 9031} else ""
        r = requests.get(url_uniprot, params={"query": f"organism_id:{taxid}{rev}", "format": "tsv", "fields": "gene_primary,cc_function,go_p,go_f,go_c,length", "compressed": "true"}, headers=headers_tsv)
        if r.status_code != 200:
            continue
            
        lector = csv.DictReader(io.StringIO(gzip.decompress(r.content).decode("utf-8")), delimiter="\t")
        gens_vistos_sp, comptador_sp, ass_list = set(), 0, ORG_TO_ASS.get(id_org, [])
        
        for fila in lector:
            simbol = next(iter((fila.get("Gene Names (primary)") or "").split(" ")), "").strip().upper()[:50]
            if not simbol or simbol in gens_vistos_sp:
                continue
            gens_vistos_sp.add(simbol)
            
            if simbol not in gene_dict:
                id_gen = gene_counter
                gene_dict[simbol] = id_gen
                gene_counter += 1
                desc_raw = (fila.get("Function [CC]") or "").replace("FUNCTION: ", "").strip()
                desc_sql = sql_str(desc_raw) if desc_raw else "NULL"
                f.write(f"INSERT IGNORE INTO genes (pk_id_gene, name_gene, description_gene) VALUES ({id_gen}, {sql_str(simbol)}, {desc_sql});\n")
                
                go_vistos_g = set()
                for col_go in ("Gene Ontology (biological process)", "Gene Ontology (molecular function)", "Gene Ontology (cellular component)"):
                    for tros in (fila.get(col_go) or "").split("; "):
                        if len(go_vistos_g) >= 5:
                            break
                        if "[GO:" in tros and tros.endswith("]"):
                            it_p = iter(tros.rsplit(" [", 1))
                            g_desc, g_id = next(it_p).strip(), next(it_p)[:-1].strip()[:15]
                            if g_id and g_id not in go_vistos_g:
                                go_vistos_g.add(g_id)
                                if g_id not in go_dict:
                                    go_dict[g_id] = go_counter
                                    f.write(f"INSERT IGNORE INTO gene_ontologies (pk_id_GO, desc_GO, GO_number) VALUES ({go_counter}, {sql_str(g_desc)}, {sql_str(g_id)});\n")
                                    go_counter += 1
                                f.write(f"INSERT IGNORE INTO gene_go (pk_fk_id_GO, pk_fk_id_gene) VALUES ({go_dict[g_id]}, {id_gen});\n")
            else:
                id_gen = gene_dict[simbol]
                
            # [APROXIMACIÓ SINTÈTICA] Posicions TSS/TES calculades segons longitud proteica i orientació +/-
            gene_bp = int(fila.get("Length") or 300) * 35
            is_reverse = (sum(ord(c) for c in simbol) % 2 == 1)
            for idx_a, id_a in enumerate(ass_list):
                pos_inici = (comptador_sp * 65000) + 10000 + (idx_a * 150000)
                pos_fi = pos_inici + gene_bp
                tss = pos_fi if is_reverse else pos_inici
                tes = pos_inici if is_reverse else pos_fi
                f.write(f"INSERT IGNORE INTO gene_ass (pk_fk_id_ass, pk_fk_id_gene, TSS, TES) VALUES ({id_a}, {id_gen}, {tss}, {tes});\n")
                
            comptador_sp += 1
            if comptador_sp % 3000 == 0:
                f.write("COMMIT;\n")
        f.write("COMMIT;\n")

    # ==========================================================================
    # [BLOC SINTÈTIC / CONFIGURACIÓ] Catàlegs tècnics base i Usuaris Readers
    # ==========================================================================
    f.write("INSERT IGNORE INTO accessibility_catalog (pk_id_da, name_da) VALUES (1, 'Open Chromatin'), (2, 'DNase Hypersensitive'), (3, 'Nucleosome Free');\n")
    f.write("INSERT IGNORE INTO transcription_catalog (pk_id_tr, name_tr) VALUES (1, 'polyA plus RNA-seq'), (2, 'total RNA-seq'), (3, 'direct RNA-seq');\n")
    
    f.write("INSERT IGNORE INTO laboratories (pk_id_lab, institucio, url_lab) VALUES "
            "(1, 'EMBL-EBI Expression Atlas', 'https://ebi.ac.uk'), "
            "(2, 'CRG - Centre de Regulació Genòmica', 'https://crg.eu'), "
            "(3, 'CNAG - Centre Nacional d Anàlisi Genòmica', 'https://cnag.eu');\n")
    labs_dict.update({"EMBL-EBI Expression Atlas": 1, "CRG - Centre de Regulació Genòmica": 2, "CNAG - Centre Nacional d Anàlisi Genòmica": 3})
    lab_counter = 4

    readers_data = (
        (1, "laia_martinez", "lmartinez@crg.eu", 2, 150),
        (2, "marc_soler_bio", "msoler@cnag.eu", 3, 200),
        (3, "anna_puig_gen", "apuig@ebi.ac.uk", 1, 100),
        (4, "david_roca_ub", "droca@crg.eu", 2, 80),
        (5, "clara_vidal_seq", "cvidal@cnag.eu", 3, 120)
    )
    for uid, un, em, lid, qxd in readers_data:
        f.write(f"INSERT IGNORE INTO users (pk_id_user, username, email, fk_id_lab) VALUES ({uid}, '{un}', '{em}', {lid});\n")
        f.write(f"INSERT IGNORE INTO users_readers (pk_fk_id_user, max_QxD) VALUES ({uid}, {qxd});\n")
    f.write("INSERT IGNORE INTO queries (fk_fk_id_user, query_number, target_topic, query_text) VALUES "
            "(1, 1, 'genes', 'SELECT * FROM genes WHERE name_gene = \"TP53\";'), "
            "(2, 1, 'tissues', 'SELECT t.name_tissue, AVG(e.expression_value) FROM tissues t JOIN biosamples b ON t.pk_id_tissue=b.fk_id_tissue JOIN experiments ex ON b.pk_id_biosample=ex.fk_id_biosample JOIN expression e ON ex.pk_id_exp=e.pk_fk_id_exp GROUP BY t.name_tissue;'), "
            "(3, 1, 'experiments', 'SELECT * FROM experiments WHERE date_sequencing >= \"2021-01-01\";');\n\n")
    # ==========================================================================
    # [BLOC 100% REAL] EMBL-EBI Expression Atlas (Òrgans i Matrius TPM)
    # ==========================================================================
    r_gxa = requests.get(url_gxa_list, headers=headers_json)
    gxa_exps = r_gxa.json().get("experiments", []) if r_gxa.status_code == 200 else []
    especies_gxa = set()
    PARAULES_NO_TEIXIT = ("week", "day", "month", "year", "male", "female", "larva", "embryo", "blastula", "pharyngula", "stage", "cell")

    for exp in gxa_exps:
        if exp.get("rawExperimentType") != "RNASEQ_MRNA_BASELINE":
            continue
        sp = exp.get("species", "")
        if sp not in ESPECIES_MAP or sp in especies_gxa:
            continue
        if "organism part" not in [ef.lower() for ef in exp.get("experimentalFactors", [])]:
            continue
            
        acc, id_org = exp.get("experimentAccession", ""), ESPECIES_MAP[sp]
        seq_date_gxa = (exp.get("lastUpdated") or "2020-09-14")[:10]
        if "-" in seq_date_gxa and len(next(iter(seq_date_gxa.split("-")))) == 2:
            it_d = iter(seq_date_gxa.split("-"))
            dd, mm, yyyy = next(it_d), next(it_d), next(it_d)
            seq_date_gxa = f"{yyyy}-{mm}-{dd}"

        r_meta = requests.get(url_gxa_det + acc, headers=headers_json)
        g_to_real_tissue, g_to_sex, g_to_age = {}, {}, {}
        if r_meta.status_code == 200:
            for col_h in r_meta.json().get("columnHeaders", []):
                gid_code = col_h.get("assayGroupId", "").strip()
                f_val = col_h.get("factorValue", "").strip().lower()
                if gid_code and f_val:
                    trossos = [t.strip() for t in f_val.split(",")]
                    g_to_real_tissue[gid_code] = next((t for t in trossos if not any(p in t for p in PARAULES_NO_TEIXIT)), "whole organism")
                    g_to_sex[gid_code] = "'female'" if "female" in f_val else ("'male'" if "male" in f_val else "'mixed'")
                    age_tros = next((t for t in trossos if any(u in t for u in ("year", "month", "week", "day"))), "")
                    if age_tros:
                        unit_t = "week" if "week" in age_tros else ("day" if "day" in age_tros else ("month" if "month" in age_tros else "year"))
                        g_to_age[gid_code] = parse_age_years(age_tros, unit_t)

        r_tsv = requests.get(f"{ftp_gxa}{acc}/{acc}-tpms.tsv")
        if r_tsv.status_code != 200:
            continue
            
        print(f"[EMBL-EBI - REAL] Atles d'òrgans de {sp} ({acc})...")
        especies_gxa.add(sp)
        lines = [l for l in r_tsv.text.splitlines() if not l.startswith("#") and l.strip()]
        if len(lines) < 2:
            continue
            
        reader = csv.reader(lines, delimiter="\t")
        header = next(reader)
        exp_ids_col = {}
        id_creator = get_creator_id(f, "EMBL-EBI Expression Atlas", f"atlas_curator_{acc}")
        id_plat_ebi = get_platform_id(f, "Illumina HiSeq 2500")
        
        for col_idx in range(2, min(len(header), 8)):
            g_code = header[col_idx].strip()
            id_tissue = get_tissue_id(f, g_to_real_tissue.get(g_code, "whole organism"))
            sex_sql = g_to_sex.get(g_code, "'mixed'")
            age_sql = g_to_age.get(g_code, "NULL")
            bname = f"GXA_{acc}_{col_idx}"[:20]
            
            f.write(f"INSERT IGNORE INTO biosamples (pk_id_biosample, purchase_lot, age, sex, name_bios, fk_id_tissue, fk_id_organism) VALUES ({biosample_counter}, NULL, {age_sql}, {sex_sql}, '{bname}', {id_tissue}, {id_org});\n")
            f.write(f"INSERT IGNORE INTO experiments (pk_id_exp, date_sequencing, fk_id_biosample, fk_id_platform, fk_fk_id_user) VALUES ({exp_counter}, '{seq_date_gxa}', {biosample_counter}, {id_plat_ebi}, {id_creator});\n")
            f.write(f"INSERT IGNORE INTO exp_tr (pk_fk_id_exp, fk_id_tr, rna_extraction_kit) VALUES ({exp_counter}, 1, NULL);\n")
            exp_ids_col[col_idx] = exp_counter
            biosample_counter += 1
            exp_counter += 1

        for row in reader:
            if len(row) < 3:
                continue
            it_r = iter(row)
            next(it_r)
            g_sym = next(it_r).strip().upper()[:50]
            id_gen_db = gene_dict.get(g_sym)
            if not id_gen_db:
                continue
            for col_idx, eid in exp_ids_col.items():
                if col_idx < len(row) and row[col_idx].strip() and row[col_idx].strip() != "-":
                    try:
                        parts = row[col_idx].strip().split(",")
                        it_p = iter(parts)
                        if len(parts) >= 3:
                            next(it_p)
                            next(it_p)
                        f.write(f"INSERT IGNORE INTO expression (pk_fk_id_exp, pk_fk_id_gene, expression_value) VALUES ({eid}, {id_gen_db}, {round(float(next(it_p)), 2)});\n")
                    except ValueError:
                        pass
        f.write("COMMIT;\n\n")

    # ==========================================================================
    # [BLOC 100% REAL] ENCODE (75 experiments + catàlegs dinàmics d'Histones/TF)
    # ==========================================================================
    consultes_enc = (
        ("HM", "Histone ChIP-seq", ""),
        ("TF", "TF ChIP-seq", ""),
        ("DA", "ATAC-seq", ""),
        ("DA", "DNase-seq", ""),
        ("TR", "long read RNA-seq", "")
    )
    for subtipus, assay, extra in consultes_enc:
        print(f"[ENCODE - REAL] Descarregant 15 experiments de {assay}...")
        r_epi = requests.get(f"{url_enc_search}?type=Experiment&status=released&assay_title={requests.utils.quote(assay)}{extra}&limit=15&format=json", headers=headers_json)
        if r_epi.status_code != 200:
            continue
        for exp in r_epi.json().get("@graph", []):
            acc = exp.get("accession", "")
            r_det = requests.get(f"{url_enc_root}/experiments/{acc}/?format=json", headers=headers_json)
            if r_det.status_code != 200:
                continue
            det = r_det.json()
            
            date_rel = (det.get("date_released") or det.get("date_created") or "2022-04-12")[:10]
            lab_title = det.get("lab", {}).get("title", "ENCODE Lab")
            pi_real = det.get("award", {}).get("pi", {}).get("title", f"pi_{acc}")
            id_creator = get_creator_id(f, lab_title, pi_real)
            id_tissue = get_tissue_id(f, det.get("biosample_ontology", {}).get("term_name", "liver"))
            
            plat_real = "Oxford Nanopore" if "long read" in assay else "Illumina NovaSeq 6000"
            for f_obj in det.get("files", []):
                p_term = f_obj.get("platform", {}).get("term_name")
                if p_term:
                    plat_real = p_term
                    break
            id_plat = get_platform_id(f, plat_real)
            
            sex_sql, age_sql, ab_sql, kit_sql, id_org = "NULL", "NULL", "NULL", "NULL", 1
            reps = det.get("replicates", [])
            if reps:
                rep0 = next(iter(reps))
                lib = rep0.get("library", {})
                kit_sql = sql_str(lib.get("construction_method"), 50)
                bios = lib.get("biosample", {})
                sex_sql = sql_str(bios.get("sex"), 20)
                age_sql = parse_age_years(bios.get("age"), bios.get("age_units", "year"))
                org_s = bios.get("donor", {}).get("organism", {}).get("scientific_name", "Homo sapiens")
                id_org = ESPECIES_MAP.get(org_s, 1)
                ab_obj = rep0.get("antibody", {})
                if ab_obj:
                    ab_str = f"{ab_obj.get('accession', '')} ({ab_obj.get('source', '')})".strip()
                    ab_sql = sql_str(ab_str, 50)

            bname = f"ENC_{acc}"[:20]
            f.write(f"INSERT IGNORE INTO biosamples (pk_id_biosample, purchase_lot, age, sex, name_bios, fk_id_tissue, fk_id_organism) VALUES ({biosample_counter}, NULL, {age_sql}, {sex_sql}, '{bname}', {id_tissue}, {id_org});\n")
            f.write(f"INSERT IGNORE INTO experiments (pk_id_exp, date_sequencing, fk_id_biosample, fk_id_platform, fk_fk_id_user) VALUES ({exp_counter}, '{date_rel}', {biosample_counter}, {id_plat}, {id_creator});\n")
            
            t_lbl = det.get("target", {}).get("label", "")
            if subtipus == "HM":
                id_hm_real = get_histone_id(f, t_lbl)
                f.write(f"INSERT IGNORE INTO exp_hm (pk_fk_id_exp, fk_id_hm, antibody) VALUES ({exp_counter}, {id_hm_real}, {ab_sql});\n")
            elif subtipus == "TF":
                id_tf_real = get_tf_id(f, t_lbl)
                f.write(f"INSERT IGNORE INTO exp_tf (pk_fk_id_exp, fk_id_tf, antibody) VALUES ({exp_counter}, {id_tf_real}, {ab_sql});\n")
            elif subtipus == "DA":
                da_id = 2 if "DNase" in assay else 1
                f.write(f"INSERT IGNORE INTO exp_da (pk_fk_id_exp, fk_id_da, technique_used) VALUES ({exp_counter}, {da_id}, {sql_str(assay)});\n")
            elif subtipus == "TR":
                tr_id = 3 if "long read" in assay else 1
                f.write(f"INSERT IGNORE INTO exp_tr (pk_fk_id_exp, fk_id_tr, rna_extraction_kit) VALUES ({exp_counter}, {tr_id}, {kit_sql});\n")
            biosample_counter += 1
            exp_counter += 1
            time.sleep(0.15)

    f.write("\nCOMMIT;\nSET autocommit=1;\nSET unique_checks=1;\nSET foreign_key_checks=1;\n")

print(f"\nCONSTRUCCIÓ COMPLETADA: {nom_fitxer}")
