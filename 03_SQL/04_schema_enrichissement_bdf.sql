-- Banque de France 2025 | Extension du modele SQL | UTF-8 sans BOM
-- Les deux tables existantes ne sont ni modifiees ni supprimees.
-- Correction MySQL 8.0 : retrait de CHECK (annee=2025) incompatible avec ON UPDATE CASCADE sur la FK (annee,region).
-- Reference par cle etrangere : (annee, region) vers regions_endettement_global_2025.
USE surendettement_bdf;

CREATE TABLE IF NOT EXISTS bdf_ref_indicateur_2025 (
  code_indicateur VARCHAR(20) NOT NULL,
  tableau_source SMALLINT NOT NULL,
  domaine VARCHAR(30) NOT NULL,
  famille VARCHAR(160) NOT NULL,
  libelle VARCHAR(255) NOT NULL,
  unite VARCHAR(15) NOT NULL,
  population_reference VARCHAR(220) NOT NULL,
  onglet_source VARCHAR(90) NOT NULL,
  plage_source VARCHAR(25) NOT NULL,
  PRIMARY KEY (code_indicateur)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bdf_observation_2025 (
  annee SMALLINT NOT NULL,
  region VARCHAR(100) NOT NULL,
  code_indicateur VARCHAR(20) NOT NULL,
  valeur DECIMAL(20,6) NOT NULL,
  PRIMARY KEY (annee, region, code_indicateur),
  KEY idx_observation_indicateur (code_indicateur),
  CONSTRAINT fk_observation_region_2025
    FOREIGN KEY (annee, region)
    REFERENCES regions_endettement_global_2025 (annee, region)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_observation_indicateur_2025
    FOREIGN KEY (code_indicateur)
    REFERENCES bdf_ref_indicateur_2025 (code_indicateur)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_observation_positive CHECK (valeur >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verification des 4 tables du projet apres creation :
SHOW TABLES LIKE 'bdf_%';
