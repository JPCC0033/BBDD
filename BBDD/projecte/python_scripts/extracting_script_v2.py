import os
import re
import pandas as pd

# ==============================================================================
# CONFIGURACIÓ INICIAL (Pots modificar aquestes dades generals de l'estudi)
# ==============================================================================
ruta_fitxer = "C:/Users/Alumne_tarda1/Downloads/E-MTAB-6592-query-results.tpmss.tsv"  # Ex: "E-MTAB-2836-query-results.tpms.tsv"
carpeta_sortida = "csv_catchgene"
os.makedirs(carpeta_sortida, exist_ok=True)

# Dades fixes per a les taules pare (ajusta-ho si el teu estudi és de ratolí, etc.)
ORGANISME = {
    "pk_id_organism": 1,
    "scientific_name": "Homo sapiens",
    "nom_cat": "Humà",
    "taxid": 9606,
}
PLATAFORMA = {"pk_id_platform": 1, "name_platform": "Illumina RNA-Seq"[:20]}
LABORATORI = {
    "pk_id_lab": 1,
    "institucio": "EMBL-EBI Expression Atlas",
    "url_lab": "https://ebi.ac.uk",
}
USUARI = {
    "pk_id_user": 1,
    "username": "curator_rnaseq",
    "email": "curator@catchgene.org",
    "fk_id_lab": 1,
}
CREADOR = {"pk_fk_id_user": 1, "orcid": "0000-0002-1825-0097"}
CATALEG_TR = {"pk_id_tr": 1, "name_tr": "Bulk RNA-Seq"[:20]}

# ==============================================================================
# 1. LECTURA I NETEJA DEL FITXER TSV
# ==============================================================================
df = pd.read_csv(ruta_fitxer, sep="\t", comment="#")

if "Gene Name" in df.columns:
  col_gen = "Gene Name"
  if "Gene ID" in df.columns:
    df = df.drop(columns=["Gene ID"])
elif "Gene ID" in df.columns:
  col_gen = "Gene ID"
else:
  col_gen = df.columns[0]

df = df.rename(columns={col_gen: "name_gene"})
df = df[df["name_gene"].notna()]
df["name_gene"] = df["name_gene"].astype(str).str.strip().str.slice(0, 20)
df = df.groupby("name_gene", as_index=False).mean()

columnes_experiments = [col for col in df.columns if col != "name_gene"]

# ==============================================================================
# 2. EXPORTACIÓ DE TAULES CATÀLEG I USUARIS (1 sol registre per taula)
# ==============================================================================
pd.DataFrame([ORGANISME]).to_csv(
    f"{carpeta_sortida}/01_organisms.csv", index=False
)
pd.DataFrame([PLATAFORMA]).to_csv(
    f"{carpeta_sortida}/02_platforms.csv", index=False
)
pd.DataFrame([LABORATORI]).to_csv(
    f"{carpeta_sortida}/03_laboratories.csv", index=False
)
pd.DataFrame([USUARI]).to_csv(f"{carpeta_sortida}/04_users.csv", index=False)
pd.DataFrame([CREADOR]).to_csv(
    f"{carpeta_sortida}/05_users_creators.csv", index=False
)
pd.DataFrame([CATALEG_TR]).to_csv(
    f"{carpeta_sortida}/06_transcription_catalog.csv", index=False
)

# ==============================================================================
# 3. EXTRACCIÓ DE TISSUES, BIOSAMPLES, EXPERIMENTS I EXP_TR
# ==============================================================================
tissues_dict = {}  # Per evitar teixits duplicats: {nom_teixit: id_tissue}
tissues_rows = []
biosamples_rows = []
experiments_rows = []
exp_tr_rows = []

for idx, col_exp in enumerate(columnes_experiments, start=1):
  # Exemple de nom de columna: "10 week, reproductive" o "12 week, liver"
  parts = [p.strip() for p in str(col_exp).split(",")]

  # Extraiem l'edat numèrica de la primera part (parts[0])
  match_edat = re.search(r"(\d+(\.\d+)?)", parts[0])
  edat = float(match_edat.group(1)) if match_edat else 0.0

  # Extraiem el nom del teixit de la segona part (parts[1]) si n'hi ha
  nom_teixit_raw = parts[1] if len(parts) > 1 else parts[0]
  nom_teixit = nom_teixit_raw[:20]  # Límit VARCHAR(20) de la taula `tissues`

  # Registrem el teixit si és nou
  if nom_teixit not in tissues_dict:
    id_tissue = len(tissues_dict) + 1
    tissues_dict[nom_teixit] = id_tissue
    tissues_rows.append(
        {"pk_id_tissue": id_tissue, "name_tissue": nom_teixit}
    )
  else:
    id_tissue = tissues_dict[nom_teixit]

  # Creem la fila per a `biosamples` (un biosample per cada combinació teixit/setmana)
  nom_bios = re.sub(r"[^a-zA-Z0-9_]", "_", str(col_exp))[:20]
  biosamples_rows.append({
      "pk_id_biosample": idx,
      "purchase_lot": 1000 + idx,
      "age": round(edat, 2),
      "sex": "femella" if idx % 2 == 0 else "mascle",  # ENUM('mascle','femella')
      "name_bios": nom_bios,
      "fk_id_tissue": id_tissue,
      "fk_id_organism": 1,
  })

  # Creem la fila per a `experiments`
  experiments_rows.append({
      "pk_id_exp": idx,
      "date_sequencing": "2024-01-15",
      "fk_id_biosample": idx,
      "fk_id_platform": 1,
      "fk_fk_id_user": 1,
  })

  # Creem la fila per a la subtaula ISA `exp_tr`
  exp_tr_rows.append({
      "pk_fk_id_exp": idx,
      "fk_id_tr": 1,
      "rna_extraction_kit": "RNeasy Mini Kit (Qiagen)",
  })

pd.DataFrame(tissues_rows).to_csv(
    f"{carpeta_sortida}/07_tissues.csv", index=False
)
pd.DataFrame(biosamples_rows).to_csv(
    f"{carpeta_sortida}/08_biosamples.csv", index=False
)
pd.DataFrame(experiments_rows).to_csv(
    f"{carpeta_sortida}/09_experiments.csv", index=False
)
pd.DataFrame(exp_tr_rows).to_csv(
    f"{carpeta_sortida}/10_exp_tr.csv", index=False
)

# ==============================================================================
# 4. EXPORTACIÓ DE GENES (Amb ID correlatiu per mapar directament a expression)
# ==============================================================================
df_genes = pd.DataFrame({
    "pk_id_gene": range(1, len(df) + 1),
    "name_gene": df["name_gene"],
    "description_gene": "Imported from RNA-seq TPM matrix",
    "fk_id_GO": None,  # Es deixa buit (NULL) perquè és opcional
})
df_genes.to_csv(f"{carpeta_sortida}/11_genes.csv", index=False)

# ==============================================================================
# 5. EXPORTACIÓ DE LES 7 TAULES D'EXPRESSIÓ (Amb pk_fk_id_gene ja resolt!)
# ==============================================================================
for idx, col_exp in enumerate(columnes_experiments, start=1):
  df_exp = pd.DataFrame({
      "pk_fk_id_exp": idx,
      "pk_fk_id_gene": df_genes[
          "pk_id_gene"
      ],  # Coincideix exactament amb 11_genes.csv
      "expression_value": (
          pd.to_numeric(df[col_exp], errors="coerce")
          .fillna(0.0)
          .clip(upper=99999999.99)
          .round(2)
      ),
  })

  nom_net = re.sub(r"[^a-zA-Z0-9]+", "_", str(col_exp)).strip("_")
  nom_fitxer = f"{carpeta_sortida}/12_expression_exp{idx}_{nom_net}.csv"
  df_exp.to_csv(nom_fitxer, index=False)

print(
    f"Procés completat! Tots els fitxers s'han desat a la carpeta '{carpeta_sortida}/'."
)
