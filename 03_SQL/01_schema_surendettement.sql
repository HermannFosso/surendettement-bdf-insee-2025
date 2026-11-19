-- AJC Dataviz : Surendettement Banque de France, 2025
-- Deux extractions contrôlées du fichier Comparaisons régionales :
-- Tableau 12 (A5:E18) et Tableau 15 (A65:G78)
-- CSV : UTF-8, séparateur ;, 1 ligne d'en-têtes, nombres décimaux avec point.
USE surendettement_bdf;

CREATE TABLE IF NOT EXISTS regions_endettement_global_2025 (
    annee SMALLINT NOT NULL,
    niveau_territorial VARCHAR(25) NOT NULL,
    region VARCHAR(100) NOT NULL,
    encours_dettes_milliers_eur DECIMAL(18,6) NOT NULL,
    nb_dossiers_traites INT NOT NULL,
    endettement_median_eur DECIMAL(14,3),
    nb_median_dettes INT,
    PRIMARY KEY (annee,region),
    CONSTRAINT ck_total_annee CHECK (annee = 2025),
    CONSTRAINT ck_total_encours CHECK (encours_dettes_milliers_eur >= 0),
    CONSTRAINT ck_total_dossiers CHECK (nb_dossiers_traites >= 0)
);

CREATE TABLE IF NOT EXISTS regions_dettes_consommation_2025 (
    annee SMALLINT NOT NULL,
    niveau_territorial VARCHAR(25) NOT NULL,
    region VARCHAR(100) NOT NULL,
    encours_consommation_milliers_eur DECIMAL(18,6) NOT NULL,
    nb_dossiers_concernes INT NOT NULL,
    part_endettement_global_pct DECIMAL(9,5),
    part_dossiers_concernes_pct DECIMAL(9,5),
    endettement_median_eur DECIMAL(14,3),
    nb_median_dettes INT,
    PRIMARY KEY (annee,region),
    CONSTRAINT ck_conso_annee CHECK (annee = 2025),
    CONSTRAINT ck_conso_encours CHECK (encours_consommation_milliers_eur >= 0),
    CONSTRAINT ck_conso_part CHECK (part_endettement_global_pct BETWEEN 0 AND 100),
    CONSTRAINT ck_conso_dossiers CHECK (part_dossiers_concernes_pct BETWEEN 0 AND 100)
);
