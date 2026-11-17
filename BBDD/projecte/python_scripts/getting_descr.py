import urllib.request
import pandas as pd

# 1. Llegim el teu fitxer 11_genes.csv
fitxer_entrada = "C:/Users/Alumne_tarda1/Downloads/csv_catchgene/11_genes.csv"
fitxer_sortida = "C:/Users/Alumne_tarda1/Downloads/csv_catchgene/11_genes_amb_descripcio.csv"

df_gens = pd.read_csv(fitxer_entrada)
print(f"S'han carregat {len(df_gens)} gens del teu CSV.")

# 2. Descarreguem el catàleg oficial complet de gens humans de HGNC (EMBL-EBI)
url_hgnc = "https://googleapis.com"
print("Descarregant el catàleg oficial d'HGNC (pot trigar 5 segons)...")

req = urllib.request.Request(url_hgnc, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resposta:
  df_hgnc = pd.read_csv(
      resposta,
      sep="\t",
      usecols=["symbol", "name", "ensembl_gene_id", "alias_symbol"],
      low_memory=False,
  )

print("Catàleg carregat! Creuant descripcions...")

# 3. Creem el diccionari per buscar per Symbol (TP53), Ensembl ID (ENSG...) i àlies
desc_dict = {}

for _, row in df_hgnc.iterrows():
  nom_oficial = str(row["name"]).strip()
  if not nom_oficial or nom_oficial == "nan":
    continue

  # Tallem a 255 caràcters per respectar VARCHAR(255) de MySQL
  desc_neta = nom_oficial[:255]

  # Mapegem pel símbol oficial (ex: A1BG)
  simbol = str(row["symbol"]).strip()
  if simbol and simbol != "nan" and simbol not in desc_dict:
    desc_dict[simbol] = desc_neta

  # Mapegem per l'ID d'Ensembl (ex: ENSG00000093100)
  ensg = str(row["ensembl_gene_id"]).strip()
  if ensg and ensg != "nan" and ensg not in desc_dict:
    desc_dict[ensg] = desc_neta

  # Mapegem també pels àlies antics si n'hi ha
  aliases = str(row["alias_symbol"]).strip()
  if aliases and aliases != "nan":
    for al in aliases.split("|"):
      al_net = al.strip()
      if al_net and al_net not in desc_dict:
        desc_dict[al_net] = desc_neta

# 4. Assignem la descripció a cada gen del teu fitxer
df_gens["description_gene"] = (
    df_gens["name_gene"]
    .astype(str)
    .str.strip()
    .map(desc_dict)
    .fillna("Gen o transcrit sense nom oficial HGNC")
)

# 5. Guardem el fitxer final llest per a MySQL
df_gens.to_csv(fitxer_sortida, index=False)

trobats = (
    df_gens["description_gene"] != "Gen o transcrit sense nom oficial HGNC"
).sum()
print(
    f"\nFet! S'han omplert {trobats} de {len(df_gens)} gens amb el seu nom"
    " oficial."
)
print(f"Fitxer guardat com a: '{fitxer_sortida}'\n")
print(df_gens[["pk_id_gene", "name_gene", "description_gene"]].head(10))
