import mysql.connector
import getpass

usuari = input("Usuari de MySQL [jpcebria]: ").strip() or "jpcebria"
contrasenya = getpass.getpass("Contrasenya de MySQL: ")

conn = mysql.connector.connect(
    host="localhost",
    port=3306,
    user=usuari,
    password=contrasenya,
    database="catchgene"
)
cursor = conn.cursor()

fitxer = "populate_catchgene_final.sql"
print(f"Carregant {fitxer} a MySQL...")
comptador = 0

with open(fitxer, "r", encoding="utf-8") as f:
    for linia in f:
        linia = linia.strip()
        if not linia or linia.startswith("--"):
            continue
        cursor.execute(linia)
        comptador += 1
        if comptador % 50000 == 0:
            conn.commit()
            print(f"  -> {comptador} sentències executades...")

# Afegim directament les 3 consultes d'exemple a 'queries'
cursor.execute("""
    INSERT IGNORE INTO queries (fk_fk_id_user, query_number, target_topic, query_text) VALUES 
    (1, 1, 'genes', 'SELECT * FROM genes WHERE name_gene = "TP53";'),
    (1, 2, 'tissues', 'SELECT * FROM tissues;'),
    (1, 3, 'experiments', 'SELECT COUNT(*) FROM experiments;');
""")

conn.commit()
print(f"\nBASE DE DADES CATCHGENE CARREGADA AL 100% ({comptador} sentències + 3 queries)!")
cursor.close()
conn.close()
