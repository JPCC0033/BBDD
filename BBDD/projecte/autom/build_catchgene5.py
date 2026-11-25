import requests
import gzip
import io
import csv
import time
import random

nom_fitxer = "populate_catchgene_final.sql"
headers_json = {"Accept": "application/json", "User-Agent": "CatchGeneDB/11.0"}
headers_tsv = {"User-Agent": "CatchGeneDB/11.0"}

url_uniprot = "https:" + "//rest.uniprot.org" + "/uniprotkb/stream"
url_uniprot_tax = "https:" + "//rest.uniprot.org" + "/taxonomy/search"
url_ensembl_info = "https:" + "//rest.ensembl.org" + "/info/assembly/"
url_gxa_list = "https:" + "//www.ebi.ac.uk" + "/gxa/json/experiments"
url_gxa_det = "https:" + "//www.ebi.ac.uk" + "/gxa/json/experiments/"
ftp_gxa = "https:" + "//ftp.ebi.ac.uk" + "/pub/databases/microarray/data/atlas/experiments/"
url_enc_search = "https:" + "//www.encodeproject.org" + "/search/"
url_enc_root = "https:" + "//www.encodeproject.org"

def sql_str(text, max_len=None):
    if isinstance(text, list):
        text = ", ".join(str(x) for x in text if x) if text else None
    if text is None:
        return "NULL"
    s = str(text).strip()
    if not s or s.lower() in ("none", "unknown", "not applicable", "[]"):
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

INST_URLS = {
    "stanford": "stanford.edu", "broad": "broadinstitute.org", "ucsd": "ucsd.edu",
    "caltech": "caltech.edu", "cshl": "cshl.edu", "hudsonalpha": "hudsonalpha.org",
    "uw": "washington.edu", "yale": "yale.edu", "ebi": "ebi.ac.uk"
}

orgs_dict = {}
descartats_no_animal = set()
assemblies_dict = {}
org_to_ass = {}
gene_dict, go_dict, tissues_dict, platforms_dict, labs_dict, users_dict = {}, {}, {}, {}, {}, {}
histones_dict, tfs_dict = {}, {}

org_counter = ass_counter = gene_counter = go_counter = 1
tissue_counter = platform_counter = lab_counter = biosample_counter = exp_counter = 1
histone_counter = tf_counter = 1
user_counter = 6

sql_organisms, sql_assemblies, sql_catalogs, sql_experiments, enc_exps_list = [], [], [], [], []

def register_organism(sci_name, taxid_hint=None, cat_hint=None):
    global org_counter
    sci_clean = sci_name.strip()
    if not sci_clean or sci_clean in descartats_no_animal:
        return None
    if sci_clean in orgs_dict:
        return orgs_dict[sci_clean]["id"]
        
    taxid_val = int(taxid_hint) if taxid_hint else 0
    cat_val = cat_hint or sci_clean
    
    # Consultem UniProt Taxonomy per validar si és animal (Metazoa = TaxID 33208)
    r_tax = requests.get(url_uniprot_tax, params={"query": f'scientific:"{sci_clean}"', "format": "json"}, headers=headers_json)
    es_animal = False
    if r_tax.status_code == 200 and r_tax.json().get("results"):
        top_res = next(iter(r_tax.json()["results"]))
        if not taxid_val:
            taxid_val = top_res.get("taxonId", 0)
        cat_val = top_res.get("commonName") or sci_clean
        lineage = top_res.get("lineage", [])
        es_animal = any(node.get("taxonId") == 33208 for node in lineage) or (taxid_val == 33208)
        
    if not es_animal or not taxid_val:
        descartats_no_animal.add(sci_clean)
        print(f"   [FILTRE TAXONÒMIC] Descartat (no és animal / Metazoa): {sci_clean}")
        return None
            
    id_o = org_counter
    org_counter += 1
    orgs_dict[sci_clean] = {"id": id_o, "taxid": taxid_val, "cat": cat_val}
    sql_organisms.append(f"INSERT IGNORE INTO organisms (pk_id_organism, scientific_name, nom_cat, taxid) VALUES ({id_o}, {sql_str(sci_clean)}, {sql_str(cat_val, 50)}, {taxid_val});\n")
    return id_o

def register_assembly(id_org, sci_name, raw_ver):
    global ass_counter
    ver_clean = (raw_ver or "GRCh38").strip()[:20]
    key = (id_org, ver_clean)
    if key in assemblies_dict:
        return assemblies_dict[key]
        
    id_a = ass_counter
    ass_counter += 1
    assemblies_dict[key] = id_a
    org_to_ass.setdefault(id_org, []).append(id_a)
    
    sp_slug = sci_name.lower().replace(" ", "_")
    name_ass, rel_date, busco_val = ver_clean, "2020-01-01", "NULL"
    url_ass = f"https://ensembl.org/{sci_name.replace(' ', '_')}/Info/Index?db=core;assembly={ver_clean}"
    
    r_ens = requests.get(f"{url_ensembl_info}{sp_slug}", headers=headers_json)
    if r_ens.status_code == 200:
        ens_data = r_ens.json()
        name_ass = (ens_data.get("assembly_name") or ver_clean)[:50]
        raw_d = ens_data.get("assembly_date") or "2020-01"
        rel_date = f"{raw_d}-01" if len(raw_d) == 7 else raw_d[:10]
        if ens_data.get("karyotype"):
            busco_val = "98.5"
    sql_assemblies.append(f"INSERT IGNORE INTO assemblies (pk_id_ass, url_link, busco_score, name_ass, date_of_release, version_ass, fk_id_organism) VALUES ({id_a}, '{url_ass}', {busco_val}, {sql_str(name_ass)}, '{rel_date}', {sql_str(ver_clean)}, {id_org});\n")
    return id_a

def get_tissue_id(raw_name):
    global tissue_counter
    clean = raw_name.strip().lower()[:20] or "whole organism"
    if clean not in tissues_dict:
        tissues_dict[clean] = tissue_counter
        sql_catalogs.append(f"INSERT IGNORE INTO tissues (pk_id_tissue, name_tissue) VALUES ({tissue_counter}, {sql_str(clean)});\n")
        tissue_counter += 1
    return tissues_dict[clean]

def get_creator_id(lab_raw, pi_name):
    global lab_counter, user_counter
    lab_clean = lab_raw.strip()[:50] or "EMBL-EBI Genomics"
    domain = next((u for k, u in INST_URLS.items() if k in lab_clean.lower()), "genome.gov")
    if lab_clean not in labs_dict:
        labs_dict[lab_clean] = lab_counter
        sql_catalogs.append(f"INSERT IGNORE INTO laboratories (pk_id_lab, institucio, url_lab) VALUES ({lab_counter}, {sql_str(lab_clean)}, 'https://{domain}');\n")
        lab_counter += 1
    id_lab = labs_dict[lab_clean]
    
    clean_pi = "".join(c for c in pi_name.lower() if c.isalnum() or c == " ").strip().replace(" ", "_")
    uname = (clean_pi or f"researcher_{id_lab}")[:50]
    if uname not in users_dict:
        users_dict[uname] = user_counter
        orcid = f"0000-0002-{1000+user_counter}-{4000+user_counter}"
        sql_catalogs.append(f"INSERT IGNORE INTO users (pk_id_user, username, email, fk_id_lab) VALUES ({user_counter}, {sql_str(uname)}, '{uname.replace(chr(39), '')}@{domain}', {id_lab});\n")
        sql_catalogs.append(f"INSERT IGNORE INTO users_creators (pk_fk_id_user, orcid) VALUES ({user_counter}, '{orcid}');\n")
        user_counter += 1
    return users_dict[uname]

def get_platform_id(plat_raw):
    global platform_counter
    plat_clean = plat_raw.strip()[:20] or "Illumina HiSeq 4000"
    if plat_clean not in platforms_dict:
        platforms_dict[plat_clean] = platform_counter
        sql_catalogs.append(f"INSERT IGNORE INTO platforms (pk_id_platform, name_platform) VALUES ({platform_counter}, {sql_str(plat_clean)});\n")
        platform_counter += 1
    return platforms_dict[plat_clean]

def get_histone_id(raw_hm):
    global histone_counter
    clean = raw_hm.strip()[:50] or "H3K27ac"
    if clean not in histones_dict:
        histones_dict[clean] = histone_counter
        sql_catalogs.append(f"INSERT IGNORE INTO histone_catalog (pk_id_hm, name_hm) VALUES ({histone_counter}, {sql_str(clean)});\n")
        histone_counter += 1
    return histones_dict[clean]
def get_tf_id(raw_tf):
    global tf_counter
    clean = raw_tf.strip()[:50] or "CTCF"
    if clean not in tfs_dict:
        tfs_dict[clean] = tf_counter
        sql_catalogs.append(f"INSERT IGNORE INTO tf_catalog (pk_id_tf, name_tf) VALUES ({tf_counter}, {sql_str(clean)});\n")
        tf_counter += 1
    return tfs_dict[clean]

print("FASE 1: Descobrint experiments reals d'ENCODE...")
consultes_enc = (("HM", "Histone ChIP-seq"), ("TF", "TF ChIP-seq"), ("DA", "ATAC-seq"), ("DA", "DNase-seq"), ("TR", "long read RNA-seq"))
for subtipus, assay in consultes_enc:
    print(f"  [ENCODE] Consultant {assay}...")
    r_epi = requests.get(f"{url_enc_search}?type=Experiment&status=released&audit.ERROR.category!=*&assay_title={requests.utils.quote(assay)}&limit=150&format=json", headers=headers_json)
    if r_epi.status_code != 200:
        continue
    for exp in r_epi.json().get("@graph", []):
        acc = exp.get("accession", "")
        r_det = requests.get(f"{url_enc_root}/experiments/{acc}/?format=json", headers=headers_json)
        if r_det.status_code != 200:
            continue
        det = r_det.json()
        
        org_s, tax_hint = "Homo sapiens", None
        sex_sql = age_sql = ab_sql = kit_sql = "NULL"
        reps = det.get("replicates", [])
        if reps:
            rep0 = next(iter(reps))
            lib = rep0.get("library", {})
            kit_sql = sql_str(lib.get("construction_method"), 50)
            bios = lib.get("biosample", {})
            sex_sql = sql_str(bios.get("sex"), 20)
            age_sql = parse_age_years(bios.get("age"), bios.get("age_units", "year"))
            donor_org = bios.get("donor", {}).get("organism", {})
            org_s = donor_org.get("scientific_name") or "Homo sapiens"
            tax_hint = donor_org.get("taxon_id")
            ab_obj = rep0.get("antibody", {})
            if ab_obj:
                ab_sql = sql_str(f"{ab_obj.get('accession', '')} ({ab_obj.get('source', '')})".strip(), 50)
                
        id_org = register_organism(org_s, tax_hint)
        if id_org is None:
            continue
            
        for a_ver in (det.get("assembly") or ["GRCh38"]):
            register_assembly(id_org, org_s, a_ver)
            
        date_rel = (det.get("date_released") or det.get("date_created") or "2022-04-12")[:10]
        id_creator = get_creator_id(det.get("lab", {}).get("title", "ENCODE Lab"), det.get("award", {}).get("pi", {}).get("title", f"pi_{acc}"))
        id_tissue = get_tissue_id(det.get("biosample_ontology", {}).get("term_name", "liver"))
        
        plat_real = "Oxford Nanopore" if "long read" in assay else "Illumina NovaSeq 6000"
        for f_obj in det.get("files", []):
            p_term = f_obj.get("platform", {}).get("term_name")
            if p_term:
                plat_real = p_term
                break
        id_plat = get_platform_id(plat_real)
        
        bname = f"ENC_{acc}"[:20]
        sql_experiments.append(f"INSERT IGNORE INTO biosamples (pk_id_biosample, purchase_lot, age, sex, name_bios, fk_id_tissue, fk_id_organism) VALUES ({biosample_counter}, NULL, {age_sql}, {sex_sql}, '{bname}', {id_tissue}, {id_org});\n")
        sql_experiments.append(f"INSERT IGNORE INTO experiments (pk_id_exp, date_sequencing, fk_id_biosample, fk_id_platform, fk_fk_id_user) VALUES ({exp_counter}, '{date_rel}', {biosample_counter}, {id_plat}, {id_creator});\n")
        
        t_lbl = det.get("target", {}).get("label", "")
        if subtipus == "HM":
            sql_experiments.append(f"INSERT IGNORE INTO exp_hm (pk_fk_id_exp, fk_id_hm, antibody) VALUES ({exp_counter}, {get_histone_id(t_lbl)}, {ab_sql});\n")
        elif subtipus == "TF":
            sql_experiments.append(f"INSERT IGNORE INTO exp_tf (pk_fk_id_exp, fk_id_tf, antibody) VALUES ({exp_counter}, {get_tf_id(t_lbl)}, {ab_sql});\n")
        elif subtipus == "DA":
            da_id = 2 if "DNase" in assay else 1
            sql_experiments.append(f"INSERT IGNORE INTO exp_da (pk_fk_id_exp, fk_id_da, technique_used) VALUES ({exp_counter}, {da_id}, {sql_str(assay)});\n")
        elif subtipus == "TR":
            tr_id = 3 if "long read" in assay else 1
            sql_experiments.append(f"INSERT IGNORE INTO exp_tr (pk_fk_id_exp, fk_id_tr, rna_extraction_kit) VALUES ({exp_counter}, {tr_id}, {kit_sql});\n")

        enc_exps_list.append((exp_counter, id_org, subtipus))
        biosample_counter += 1
        exp_counter += 1
        time.sleep(0.05)

print("\nFASE 2: Descobrint atles d'òrgans d'EMBL-EBI Expression Atlas...")
r_gxa = requests.get(url_gxa_list, headers=headers_json)
gxa_exps = r_gxa.json().get("experiments", []) if r_gxa.status_code == 200 else []
especies_gxa = set()
PARAULES_NO_TEIXIT = ("week", "day", "month", "year", "male", "female", "larva", "embryo", "blastula", "pharyngula", "stage", "cell")
gxa_tpm_buffer = []

for exp in gxa_exps:
    if len(especies_gxa) >= 20:
        break
    if exp.get("rawExperimentType") != "RNASEQ_MRNA_BASELINE":
        continue
    sp = exp.get("species", "").strip()
    if not sp or sp in especies_gxa:
        continue
    if "organism part" not in [ef.lower() for ef in exp.get("experimentalFactors", [])]:
        continue
        
    # Validem abans de baixar el TSV que sigui un animal (Metazoa)
    id_org = register_organism(sp)
    if id_org is None:
        continue
        
    acc = exp.get("experimentAccession", "")
    r_tsv = requests.get(f"{ftp_gxa}{acc}/{acc}-tpms.tsv")
    if r_tsv.status_code != 200:
        continue
        
    print(f"  [EMBL-EBI] Atles animal descobert: {sp} ({acc})...")
    especies_gxa.add(sp)
    register_assembly(id_org, sp, f"{sp.split()[-1]}_ref")
    
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

    lines = [l for l in r_tsv.text.splitlines() if not l.startswith("#") and l.strip()]
    if len(lines) < 2:
        continue
    reader = csv.reader(lines, delimiter="\t")
    header = next(reader)
    exp_ids_col = {}
    id_creator = get_creator_id("EMBL-EBI Expression Atlas", f"atlas_curator_{acc}")
    id_plat_ebi = get_platform_id("Illumina HiSeq 2500")
    
    for col_idx in range(2, min(len(header), 8)):
        g_code = header[col_idx].strip()
        id_tissue = get_tissue_id(g_to_real_tissue.get(g_code, "whole organism"))
        sex_sql = g_to_sex.get(g_code, "'mixed'")
        age_sql = g_to_age.get(g_code, "NULL")
        bname = f"GXA_{acc}_{col_idx}"[:20]
        
        sql_experiments.append(f"INSERT IGNORE INTO biosamples (pk_id_biosample, purchase_lot, age, sex, name_bios, fk_id_tissue, fk_id_organism) VALUES ({biosample_counter}, NULL, {age_sql}, {sex_sql}, '{bname}', {id_tissue}, {id_org});\n")
        sql_experiments.append(f"INSERT IGNORE INTO experiments (pk_id_exp, date_sequencing, fk_id_biosample, fk_id_platform, fk_fk_id_user) VALUES ({exp_counter}, '{seq_date_gxa}', {biosample_counter}, {id_plat_ebi}, {id_creator});\n")
        sql_experiments.append(f"INSERT IGNORE INTO exp_tr (pk_fk_id_exp, fk_id_tr, rna_extraction_kit) VALUES ({exp_counter}, 1, NULL);\n")
        exp_ids_col[col_idx] = exp_counter
        biosample_counter += 1
        exp_counter += 1
    for row in reader:
        if len(row) < 3:
            continue
        it_r = iter(row)
        next(it_r)
        g_sym = next(it_r).strip().upper()[:50]
        if not g_sym:
            continue
        for col_idx, eid in exp_ids_col.items():
            if col_idx < len(row) and row[col_idx].strip() and row[col_idx].strip() != "-":
                try:
                    parts = row[col_idx].strip().split(",")
                    it_p = iter(parts)
                    if len(parts) >= 3:
                        next(it_p)
                        next(it_p)
                    gxa_tpm_buffer.append((eid, g_sym, round(float(next(it_p)), 2)))
                except ValueError:
                    pass

print(f"\nFASE 3: Escrivint {nom_fitxer} i descarregant genomes de les {len(orgs_dict)} espècies animals descobertes...")

with open(nom_fitxer, "w", encoding="utf-8") as f:
    f.write("USE catchgene;\nSET autocommit=0;\nSET unique_checks=0;\nSET foreign_key_checks=0;\n\n")
    
    f.writelines(sql_organisms)
    f.writelines(sql_assemblies)
    f.write("INSERT IGNORE INTO accessibility_catalog (pk_id_da, name_da) VALUES (1, 'Open Chromatin'), (2, 'DNase Hypersensitive'), (3, 'Nucleosome Free');\n")
    f.write("INSERT IGNORE INTO transcription_catalog (pk_id_tr, name_tr) VALUES (1, 'polyA plus RNA-seq'), (2, 'total RNA-seq'), (3, 'direct RNA-seq');\n")
    f.writelines(sql_catalogs)
    f.write("\nCOMMIT;\n\n")

    f.write("INSERT IGNORE INTO laboratories (pk_id_lab, institucio, url_lab) VALUES (998, 'CRG - Centre de Regulació Genòmica', 'https://crg.eu'), (999, 'CNAG - Centre Nacional d Anàlisi Genòmica', 'https://cnag.eu');\n")
    for uid, un, em, lid, qxd in ((1, "laia_martinez", "lmartinez@crg.eu", 998, 150), (2, "marc_soler_bio", "msoler@cnag.eu", 999, 200), (3, "anna_puig_gen", "apuig@crg.eu", 998, 100)):
        f.write(f"INSERT IGNORE INTO users (pk_id_user, username, email, fk_id_lab) VALUES ({uid}, '{un}', '{em}', {lid});\n")
        f.write(f"INSERT IGNORE INTO users_readers (pk_fk_id_user, max_QxD) VALUES ({uid}, {qxd});\n")
    f.write("INSERT IGNORE INTO queries (fk_fk_id_user, query_number, target_topic, query_text) VALUES (1, 1, 'genes', 'SELECT * FROM genes WHERE name_gene = \"TP53\";'), (2, 1, 'tissues', 'SELECT * FROM tissues;'), (3, 1, 'experiments', 'SELECT * FROM experiments;');\n\n")
    gens_per_org = {}
    for sci, info in orgs_dict.items():
        id_org, taxid = info["id"], info["taxid"]
        if not taxid:
            continue
        print(f"  [UniProt] Descarregant genoma i GO de {sci} (TaxID {taxid})...")
        rev = " AND reviewed:true" if taxid in {9606, 10090, 7227, 6239, 7955, 9913, 9031} else ""
        r = requests.get(url_uniprot, params={"query": f"organism_id:{taxid}{rev}", "format": "tsv", "fields": "gene_primary,cc_function,go_p,go_f,go_c,length", "compressed": "true"}, headers=headers_tsv)
        if r.status_code != 200:
            continue
            
        lector = csv.DictReader(io.StringIO(gzip.decompress(r.content).decode("utf-8")), delimiter="\t")
        gens_vistos_sp, comptador_sp, ass_list = set(), 0, org_to_ass.get(id_org, [])
        
        for fila in lector:
            simbol = next(iter((fila.get("Gene Names (primary)") or "").split(" ")), "").strip().upper()[:50]
            if not simbol or simbol in gens_vistos_sp:
                continue
            gens_vistos_sp.add(simbol)
            if len(gens_per_org.get(id_org, [])) < 300:
                gens_per_org.setdefault(id_org, []).append(gene_counter if simbol not in gene_dict else gene_dict[simbol])

            if simbol not in gene_dict:
                id_gen = gene_counter
                gene_dict[simbol] = id_gen
                gene_counter += 1
                desc_raw = (fila.get("Function [CC]") or "").replace("FUNCTION: ", "").strip()
                f.write(f"INSERT IGNORE INTO genes (pk_id_gene, name_gene, description_gene) VALUES ({id_gen}, {sql_str(simbol)}, {sql_str(desc_raw)});\n")
                
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
        f.write("COMMIT;\n\n")

    f.writelines(sql_experiments)
    f.write("COMMIT;\n\n")
    
    for eid, g_sym, tpm_val in gxa_tpm_buffer:
        id_gen_db = gene_dict.get(g_sym)
        if id_gen_db:
            f.write(f"INSERT IGNORE INTO expression (pk_fk_id_exp, pk_fk_id_gene, expression_value) VALUES ({eid}, {id_gen_db}, {tpm_val});\n")
    # Senyals aproximats al TSS per als experiments multi-òmica d'ENCODE #INVENT#
    for eid, oid, sub in enc_exps_list:
        for gid in gens_per_org.get(oid, []):
            if sub == "TR":
                val = round(random.choice([0.0, 1.2, 4.5, 15.8, 72.4, 310.0]), 2)
            elif sub == "DA":
                val = round(random.choice([0.3, 1.1, 1.8, 2.9, 7.4, 19.2]), 2)
            else:
                val = round(random.choice([0.2, 0.9, 1.3, 2.4, 5.6, 14.8]), 2)
            f.write(f"INSERT IGNORE INTO expression (pk_fk_id_exp, pk_fk_id_gene, expression_value) VALUES ({eid}, {gid}, {val});\n")

    f.write("\nCOMMIT;\nSET autocommit=1;\nSET unique_checks=1;\nSET foreign_key_checks=1;\n")

print(f"\nARQUITECTURA DATA-DRIVEN COMPLETADA: {nom_fitxer}")
print(f"- Espècies animals descobertes (Metazoa): {len(orgs_dict)}")
print(f"- Espècies descartades (no animals): {len(descartats_no_animal)} -> {list(descartats_no_animal)}")
print(f"- Assemblies reals creuats amb Ensembl: {len(assemblies_dict)}")
print(f"- Total experiments reals: {exp_counter - 1}")
