# CatchGene — Base de Dades Genòmica i Epigenòmica

**CatchGene** és una base de dades relacional en MySQL dissenyada per integrar anotacions genòmiques, ontologies funcionals (GO), muntatges cromosòmics (*assemblies*) i dades experimentals de seqüenciació (ChIP-seq d'histones i factors de transcripció, ATAC-seq, DNase-seq i RNA-seq) a través de 15 espècies.

---

## Estructura del Repositori

* `catchGENE.sql`: Script DDL amb la creació de les 23 taules, restriccions d'integritat referencial, especialització ISA, columnes generades i *triggers* de validació.
* `build_catchgene.py`: Script ETL en Python que consulta les APIs públiques oficials per generar el fitxer de càrrega massiva (`populate_catchgene_final.sql`).
* `carregar_mysql.py`: Script d'importació segura per carregar les sentències SQL línia a línia al servidor MySQL sense col·lapsar la memòria de l'editor visual.
* `comprovar_DB.py`: Script de verificació ràpida per auditar el recompte de registres i mostrar una mostra de les 23 taules per terminal.

---

## Origen i Fidelitat de les Dades

El dataset generat per `build_catchgene.py` combina dades **100% reals** extretes de consorcis bioinformàtics internacionals amb un conjunt mínim de dades sintètiques necessàries per satisfer les restriccions del model relacional:

### 1. Dades 100% Reals (APIs Oficials)
* **UniProt REST API (`rest.uniprot.org`):**
  * **15 espècies** amb els seus noms científics i `TaxID` oficials.
  * **47.840 gens ortòlegs** amb les seves descripcions funcionals (`cc_function`) i **13.309 termes Gene Ontology (GO)** filtrats pels 5 més rellevants per gen.
* **Ensembl (`ensembl.org`):**
  * **18 assemblies de referència** (incloent-hi múltiples versions per a Humà, Ratolí i Ximpanzé) amb les seves dates de publicació, versions i puntuacions de completesa **BUSCO**.
* **EMBL-EBI Expression Atlas (`ebi.ac.uk/gxa`):**
  * Estudis *baseline* filtrats exclusivament per factor anatòmic (`organism part`) per garantir **teixits i òrgans reals** (*brain*, *liver*, *heart*, *kidney*, *skeletal muscle*, etc.).
  * **Més de 570.000 valors reals d'expressió (TPM)** extrets de la mediana de les matrius oficials `-tpms.tsv`.
* **Consorci ENCODE (`encodeproject.org`):**
  * Metadades reals d'experiments de **Histone ChIP-seq**, **TF ChIP-seq**, **ATAC-seq**, **DNase-seq** i **Long-read RNA-seq** (incloent-hi plataformes **Oxford Nanopore** i **Illumina**).
  * Codis d'accés reals (`ENCSR...`), laboratoris i investigadors principals (`award.pi`), anticossos reals (`ENCAB...`), mètodes de construcció de llibreries, sexe (`male`, `female`, `mixed`) i edat real dels donants convertida a anys (o `NULL` si no consta al registre públic).

### 2. Dades Sintètiques o Aproximades (Per integritat del model)
* **Coordenades cromosòmiques (`TSS` i `TES` a `gene_ass`):** Com que el flux massiu d'UniProt no inclou posicions cromosòmiques, les coordenades s'han generat espaiades de manera determinista respectant la longitud proporcional de cada proteïna i simulant tant la cadena directa (`TSS < TES`) com la cadena inversa (`TSS > TES`).
* **Usuaris lectors (`users_readers`) i `queries`:** S'han definit 5 perfils de lectors vinculats a institucions reals (CRG, CNAG, EMBL-EBI) amb límits diaris (`max_QxD`) i consultes SQL d'exemple per poblar l'historial d'activitat.
* **Identificadors ORCID (`users_creators`):** Generats seqüencialment per complir la restricció `UNIQUE NOT NULL` en aquells investigadors d'ENCODE que no tenen l'ORCID públic vinculat al seu perfil.
* **Lots de compra (`purchase_lot`):** Establerts a `NULL` a `biosamples`, ja que les mostres provenen de repositoris científics públics i no de compres comercials.

---

## Requisits Previs

* **MySQL Server 8.0+**
* **Python 3.10+** amb les llibreries `requests` i `mysql-connector-python`:
  ```bash
  pip install requests mysql-connector-python
  ```

---

## Guia d'Instal·lació i Càrrega des de Zero

1. **Crear l'esquema de la base de dades:**
   Executa el fitxer `catchGENE.sql` des de MySQL Workbench (o el teu client SQL) per crear la base de dades `catchgene`, les 23 taules, les vistes i els *triggers*.

2. **Generar el dataset real (ETL):**
   Executa l'script de descàrrega i processament per obtenir les dades reals d'UniProt, EMBL-EBI i ENCODE:
   ```bash
   python build_catchgene.py
   ```
   *(Aquest pas generarà l'arxiu `populate_catchgene_final.sql` a la mateixa carpeta).*

3. **Importar les dades a MySQL:**
   Executa el carregador i introdueix el teu usuari i contrasenya de MySQL quan t'ho demani (la contrasenya queda oculta per seguretat):
   ```bash
   python carregar_mysql.py
   ```

4. **Verificar la càrrega:**
   Executa l'script d'auditoria per comprovar el recompte de files i visualitzar una mostra de cada taula:
   ```bash
   python comprovar_DB.py
   ```
