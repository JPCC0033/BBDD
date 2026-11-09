CREATE DATABASE IF NOT EXISTS vendes;

USE vendes;
-- create tables clients
CREATE TABLE IF NOT EXISTS clients(
    pk_cif_nif varchar(10) PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    cognoms VARCHAR(30) NOT NULL,
    carrer VARCHAR(30) NOT NULL,
    numero int NOT NULL,
    ciutat VARCHAR(30) NOT NULL,
    codi_postal varchar(10) NOT NULL
);
-- insert data to the table
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("482159360X", "Henri", "Matisse", "de la Republique", 87, "Le Cateau-Cambrésis", "59360");
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("749301842E", "Marc",  "Chagall", "Sovietskaya", 25, "Vítebsk", 210026);
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("284710593X", "Frida",  "Kahlo", "Londres", 247, "Ciutat de Mèxic", 04100);
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("105938472N", "René",  "Magritte", "des d'Audenhove", 95, "Lessines", 07860);
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("03056073V", "Joan",  "Miró", "Passatge del crèdit", 4, "Barcelona", 08002);
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("839201475S", "Andy",  "Warhol", "Dawson", 3252, "Pittsburgh", 15213);
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("000000125X", "Pablo",  "Picasso", "Plaza de la Merced", 95, "Barcelona", 29012);
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("510394827X", "Salvador",  "Dalí", "Monturiol", 6, "Figueres", 17600);
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("629481053X", "Jaume",  "Roca", "Major", 10, "Salt", 17190);
INSERT INTO clients (pk_cif_nif, nom, cognoms, carrer, numero, ciutat, codi_postal) VALUES ("402938175W", "Ramon",  "Casas", "d'en Gignàs", 10, "Barcelona", 08002);


CREATE TABLE IF NOT EXISTS telefons(
    pk_telf varchar(15) PRIMARY KEY,
    fk_cif_nif varchar(10)
);
-- foreign keys
ALTER TABLE telefons 
ADD CONSTRAINT telfs_clients 
FOREIGN KEY (fk_cif_nif) REFERENCES clients(pk_cif_nif)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- insert data into the table
INSERT INTO telefons (pk_telf, fk_cif_nif) VALUES ('0033600111222', '482159360X');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0037529222333', '749301842E');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0052550333441', '284710593X');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0052550333442', '284710593X');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0032460444555', '105938472N');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0034600555666', '03056073V');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0014126667711', '839201475S');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0014126667712', '839201475S');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0014126667713', '839201475S');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0034600777888', '000000125X');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0034600888999', '510394827X');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0034600999000', '629481053X');
INSERT INTO telefons (pk_telf, fk_cif_nif)  VALUES ('0034600123456', '402938175W');


-- proveidors
CREATE TABLE IF NOT EXISTS proveidors(
    pk_cif_nif_prov varchar(9) PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    carrer VARCHAR(30) NOT NULL,
    numero int NOT NULL,
    ciutat VARCHAR(30) NOT NULL,
    codi_postal varchar(5) NOT NULL,
    web VARCHAR(255),
    telefon varchar(15) NOT NULL
);

INSERT INTO proveidors VALUES ("N0038472A", "Winsor & Newton", "Whitefriars Avenue", 14, "Harrow", "HA35R", "https://winsornewton.com", "00442084243");
INSERT INTO proveidors VALUES ("N0084920B", "Royal Talens", "Sophialaan", 46, "Apeldoorn", "7311P", "https://royaltalens.com", "00315552747");
INSERT INTO proveidors VALUES ("N0029381C", "H. Schmincke & Co.", "Otto-Hahn-Strasse", 2, "Erkrath", "40699", "https://schmincke.de", "00492112509");
INSERT INTO proveidors VALUES ("N0058392D", "Sennelier", "Quai Voltaire", 3, "París", "75007", "https://sennelier.fr", "00331426014");
INSERT INTO proveidors VALUES ("N0047291E", "Cartiere Miliani Fabriano", "Viale Pietro Miliani", 31, "Fabriano", "60044", "https://fabriano.com", "00390732701");
INSERT INTO proveidors VALUES ("B08493821", "Piera Fine Arts", "Carrer de Còrsega", 299, "Barcelona", "08008", "https://pierafinearts.com", "00349341533");
INSERT INTO proveidors VALUES ("B62938475", "Barna Art", "Carrer de Rosselló", 290, "Barcelona", "08037", "https://barnaart.com", "00349345754");
INSERT INTO proveidors VALUES ("B46928104", "Totenart", "Carrer de Corona", 35, "València", "46003", "https://totenart.com", "00349639172");
INSERT INTO proveidors VALUES ("N0010493F", "Papeteries Clairefontaine", "Rue du General Leclerc", 19, "Etival", "88480", "https://clairefontaine.com", "00333294242");
INSERT INTO proveidors VALUES ("N0058291G", "Da Vinci Künstlerpinsel", "Tillystrasse", 39, "Nuremberg", "90431", "https://davinci-defet.com", "00499119617");

CREATE TABLE IF NOT EXISTS categories(
    pk_id_categoria int PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    descrpicio VARCHAR(255)
);

-- insert data into the table
INSERT INTO categories VALUES (1, "Olis", "Pintures a l'oli professionals i de qualitat d'estudi");
INSERT INTO categories VALUES (2, "Aquarel·les", "Aquarel·les en pastilles i tubs, líquides o fixes");
INSERT INTO categories VALUES (3, "Acrílics", "Pintures acríliques d'alta viscositat o fluids");
INSERT INTO categories VALUES (4, "Paper i blocs", "Suports de cel·lulosa i cotó per a diferents tècniques");
INSERT INTO categories VALUES (5, "Pinzells i eines", "Pinzells de pèl natural o sintètic per a artistes");
INSERT INTO categories VALUES (6, "Suports i teles", "Bastidors de fusta, teles de lli o cotó preparades");

CREATE TABLE IF NOT EXISTS productes(
    pk_id_producte int PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    stock int UNSIGNED,
    preu_actual decimal(10,2),
    fk_cif_nif_prov varchar(9),
    fk_id_categoria int,
    CONSTRAINT preu_actual_positiu CHECK (preu_actual > 0)
);

-- foreign keys
ALTER TABLE productes 
ADD CONSTRAINT productes_proveidors 
FOREIGN KEY (fk_cif_nif_prov) REFERENCES proveidors(pk_cif_nif_prov)
ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE productes 
ADD CONSTRAINT productes_categoria 
FOREIGN KEY (fk_id_categoria) REFERENCES categories(pk_id_categoria)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- insert data into the table
INSERT INTO productes VALUES (1, "Cotman Pocket Set 12HP", 45, 76.99, "N0038472A", 2);
INSERT INTO productes VALUES (2, "Rembrandt Oil Tube 40ml", 120, 14.50, "N0084920B", 1);
INSERT INTO productes VALUES (3, "Mussini Extra Fine Oil", 60, 24.95, "N0029381C", 1);
INSERT INTO productes VALUES (4, "Sennelier Extra-Fine Gouache", 85, 11.20, "N0058392D", 2);
INSERT INTO productes VALUES (5, "Fabriano Watercolour Studio 50x70", 500, 1.19, "N0047291E", 4);
INSERT INTO productes VALUES (6, "Bastidor Fusta Okume 40x40", 25, 18.30, "B08493821", 6);
INSERT INTO productes VALUES (7, "Barna Art Acrilic Professional", 150, 6.80, "B62938475", 3);
INSERT INTO productes VALUES (8, "Tarlatana 100% Coto per Gravat", 300, 1.46, "B46928104", 5);
INSERT INTO productes VALUES (9, "Pastelmat Block A4 360g", 40, 32.40, "N0010493F", 4);
INSERT INTO productes VALUES (10, "Da Vinci Series 7 Kolinsky Sable", 30, 45.10, "N0058291G", 5);


CREATE TABLE IF NOT EXISTS factures(
    pk_id_factura int PRIMARY KEY,
    data_emissio DATE NOT NULL,
    descompte decimal(10,2),
    import_final decimal(10,2),
    fk_cif_nif varchar(10),
    CHECK (descompte >= 0 AND descompte <= import_final)
);
-- foreign keys
ALTER TABLE factures 
ADD CONSTRAINT facts_clients_c 
FOREIGN KEY (fk_cif_nif) REFERENCES clients(pk_cif_nif)
ON UPDATE CASCADE ON DELETE RESTRICT;


-- trigger per possibles errors a l'hora d'entrar l'import final 
DELIMITER $$

CREATE TRIGGER abans_inserir_factura_33
BEFORE INSERT ON factures
FOR EACH ROW
BEGIN
    IF NEW.import_final <= 0 THEN
        
        SIGNAL SQLSTATE "45000" 
        SET MESSAGE_TEXT = "Error: L'import final no pot ser negatiu. Comprova l'import final a insertar.";
        
    END IF;
END;

DELIMITER ;


-- insert into the TABLE 
INSERT INTO factures VALUES (1001, "2026-02-15", 20.00, 150.50, "482159360X");
INSERT INTO factures VALUES (1002, "2026-03-22", 10.00, 89.90, "749301842E");
INSERT INTO factures VALUES (1003, "2026-04-05", 5.50, 210.00, "284710593X");
INSERT INTO factures VALUES (1004, "2026-05-12", 0.00, 45.25, "105938472N");
INSERT INTO factures VALUES (1005, "2026-06-18", 20.00, 340.00, "03056073V");
INSERT INTO factures VALUES (1006, "2026-07-22", 0.00, 611.60, "839201475S");
INSERT INTO factures VALUES (1007, "2026-08-01", 50.00, 1250.00, "000000125X");
INSERT INTO factures VALUES (1008, "2026-09-09", 15.00, 425.10, "510394827X");
INSERT INTO factures VALUES (1009, "2026-10-14", 0.00, 75.00, "629481053X");
INSERT INTO factures VALUES (1010, "2026-11-02", 12.30, 195.40, "402938175W");
INSERT INTO factures VALUES (1011, "2026-11-05", 0.00, 310.20, "510394827X");
INSERT INTO factures VALUES (1012, "2026-11-08", 5.00, 125.00, "03056073V");



-- taules intermitges
CREATE TABLE IF NOT EXISTS fact_prod(
    fk_id_factura int,
    fk_id_producte int,
    quantitat int NOT NULL,
    preu_venda decimal(10,2) UNSIGNED CHECK (preu_venda > 0),
    iva decimal(10,2),
    CONSTRAINT fact_prod PRIMARY KEY (fk_id_factura, fk_id_producte)
);

-- foreign keys
ALTER TABLE fact_prod 
ADD CONSTRAINT factprod_factures 
FOREIGN KEY (fk_id_factura) REFERENCES factures(pk_id_factura)
ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE fact_prod 
ADD CONSTRAINT factprod_productes2 
FOREIGN KEY (fk_id_producte) REFERENCES productes(pk_id_producte)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- insert data into the table
INSERT INTO fact_prod VALUES (1001, 1, 2, 77, 21.00);
INSERT INTO fact_prod VALUES (1002, 2, 6, 15, 21.00);
INSERT INTO fact_prod VALUES (1003, 3, 8, 25, 21.00);
INSERT INTO fact_prod VALUES (1004, 10, 1, 45, 21.00);
INSERT INTO fact_prod VALUES (1005, 9, 10, 32, 21.00);
INSERT INTO fact_prod VALUES (1006, 1, 8, 77, 21.00);
INSERT INTO fact_prod VALUES (1007, 3, 50, 25, 21.00);
INSERT INTO fact_prod VALUES (1008, 6, 23, 18, 21.00);
INSERT INTO fact_prod VALUES (1009, 7, 11, 7, 21.00);
INSERT INTO fact_prod VALUES (1010, 5, 195, 1, 21.00);
INSERT INTO fact_prod VALUES (1011, 6, 17, 18, 21.00);
INSERT INTO fact_prod VALUES (1012, 7, 25, 5, 21.00);



INSERT INTO factures VALUES (9999, "2026-11-09", 0.00, -50.00, "482159360X");
-- MySQL Error (1644): Error: L'import final no pot ser negatiu. Comprova l'import final a insertar.
