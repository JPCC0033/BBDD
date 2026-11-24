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

# Obtenim el llistat de totes les taules de la base de dades
cursor.execute("SHOW TABLES;")
taules = [next(iter(fila)) for fila in cursor.fetchall()]

for taula in taules:
    # Comptem el total de files de la taula
    cursor.execute(f"SELECT COUNT(*) FROM `{taula}`;")
    total = next(iter(cursor.fetchone()))
    
    print("=" * 75)
    print(f"TAULA: {taula.upper()}  (Total registres: {total})")
    print("=" * 75)
    
    # Mostrem les 5 primeres files (pots canviar LIMIT 5 si en vols veure més)
    cursor.execute(f"SELECT * FROM `{taula}` LIMIT 15;")
    columnes = [next(iter(desc)) for desc in cursor.description]
    files = cursor.fetchall()
    
    print(" | ".join(columnes))
    print("-" * 75)
    for fila in files:
        # Retallem textos molt llargs (com description_gene) a 35 caràcters perquè càpiga bé a pantalla
        fila_neta = [str(val)[:35] + ("..." if len(str(val)) > 35 else "") for val in fila]
        print(" | ".join(fila_neta))
    print("\n")

cursor.close()
conn.close()
