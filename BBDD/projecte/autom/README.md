# CatchGene — Base de Dades Genòmica i Epigenòmica

**CatchGene** és una base de dades relacional MySQL dissenyada per integrar anotacions genòmiques, ontologies GO i dades experimentals multi-òmica (ChIP-seq, ATAC-seq, RNA-seq) per a espècies animals (*Metazoa*), amb limitacions taxonòmiques i dades d'accessibilitat simulades per a entorns de proves.

## Estructura del Repositori

- `catchGENE.sql`: Script DDL amb la creació de taules, claus forànies i *triggers*.
- `build_catchgene5.py`: Script ETL en Python per generar dades poblacionals.
- `carregar_mysql.py` i `comprovar_DB.py`: Scripts d'importació i auditoria de registres.

## Origen i Fidelitat de les Dades

### 1. Dades 100% Reals (APIs Oficials)

- **Filtre Taxonòmic Dinàmic (Metazoa — TaxID: 33208):** L'script valida automàticament cada espècie contra l'API de taxonomia d'UniProt per descartar plantes, fongs o bacteris, incorporant només animals.
- **Limitació a 20 Espècies Animals (EMBL-EBI Expression Atlas):** Es limita la descoberta d'atles d'òrgans a 20 espècies animals per equilibrar la representativitat evolutiva i el rendiment de càrrega. D'aquí s'extreuen **més d'1,2 milions de lectures reals d'expressió (TPM)** en prop de 200 teixits anatòmics.
- **Consorci ENCODE (~860 experiments totals):** Metadades reals d'experiments de Histone ChIP-seq (150), TF ChIP-seq (150), ATAC-seq (150), DNase-seq (150) i Long-read RNA-seq (150) sense errors greus d'auditoria (`audit.ERROR.category!=*`), amb investigadors, laboratoris, plataformes, anticossos (`ENCAB...`), sexe i edat reals.
- **UniProt i Ensembl:** **Més de 60.000 gens ortòlegs** amb les seves descripcions funcionals, **més de 14.000 termes Gene Ontology (GO)** i **26 assemblies de referència** amb dates reals de llançament.


### 2. Dades Sintètiques o Aproximades (Per integritat i consultes multi-òmica)

- **Senyals multi-òmica al TSS (`expression` a ENCODE):** Per habilitar consultes creuades, s'han simulat valors de senyal sobre **300 gens reals** (~225.000 registres) per a histones (`exp_hm`), factors de transcripció (`exp_tf`), accessibilitat (`exp_da`) i RNA-seq (`exp_tr`), validats pel trigger `trg_threshold_signal_type` segons els llindars de cada tècnica (`>= 5.0` TPM en transcripció, `>= 2.0` en accessibilitat i `>= 1.5` en histones/TF).
- **Coordenades cromosòmiques (`TSS` i `TES` a `gene_ass`):** Calculades de forma determinista segons la longitud proporcional de cada proteïna (tant en cadena directa com inversa).
- **Usuaris, consultes i ORCID:** Inclou 3 perfils de lectors d'institucions com el CRG o CNAG, consultes d'exemple i codis `ORCID` seqüencials per a investigadors sense ORCID públic.
- **Lots de compra (`purchase_lot`):** Definits com a `NULL` a `biosamples` per tractar-se de mostres de dipòsits públics.


## Requisits Previs

- **MySQL Server 8.0+**
- **Python 3.10+** amb les llibreries necessàries (`requests`, `mysql-connector-python`).

## Guia d'Instal·lació i Càrrega

1. **Base de dades:** Executa `catchGENE.sql` per crear les taules, restriccions i *triggers*.
2. **ETL:** Executa `python build_catchgene5.py` per generar el fitxer de dades.
3. **Importació:** Executa `python carregar_mysql.py` per bolcar les dades a MySQL.
4. **Verificació:** Executa `python comprovar_DB.py` per auditar la integritat de les 23 taules.
