-- 08 | Enrichissement socioeconomique INSEE pour le projet Banque de France
-- Source chômage 2025 (moyenne annuelle, colonne Ensemble) :
-- https://www.insee.fr/fr/statistiques/2134411
-- Source pauvreté 2023 (Filosofi 2, colonne Ensemble) :
-- https://www.insee.fr/fr/statistiques/2012803
-- Source niveau de vie médian annuel 2023 :
-- https://www.insee.fr/fr/statistiques/2012717
-- Les valeurs sont transcrites des tableaux régionaux officiels INSEE, et non du CSV brut INSEE.
-- Sur les taux, 7.40 représente 7,40 %, pas 0,0740.
-- Les 13 libellés régionaux sont harmonisés aux clés de la table BDF existante.
-- Ne modifie aucune des quatre tables BDF. Script re-executable (upsert).
USE surendettement_bdf;

CREATE TABLE IF NOT EXISTS insee_contexte_regions (
  region VARCHAR(100) NOT NULL,
  annee_chomage SMALLINT NOT NULL,
  taux_chomage_2025_pct DECIMAL(5,2) NOT NULL,
  annee_filosofi SMALLINT NOT NULL,
  taux_pauvrete_2023_pct DECIMAL(5,2) NOT NULL,
  niveau_vie_median_2023_eur DECIMAL(10,0) NOT NULL,
  PRIMARY KEY (region),
  CONSTRAINT ck_insee_chomage_2025 CHECK (annee_chomage = 2025 AND taux_chomage_2025_pct BETWEEN 0 AND 100),
  CONSTRAINT ck_insee_pauvrete_2023 CHECK (annee_filosofi = 2023 AND taux_pauvrete_2023_pct BETWEEN 0 AND 100),
  CONSTRAINT ck_insee_niveau_vie CHECK (niveau_vie_median_2023_eur > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Le DDL ci-dessus est valide independamment de la transaction : MySQL le valide implicitement.
START TRANSACTION;
INSERT INTO insee_contexte_regions
  (region, annee_chomage, taux_chomage_2025_pct, annee_filosofi, taux_pauvrete_2023_pct, niveau_vie_median_2023_eur)
VALUES
  ('Auvergne-Rhône-Alpes', 2025, 6.6, 2023, 14.2, 26920),
  ('Bourgogne-Franche-Comté', 2025, 6.9, 2023, 14.2, 25640),
  ('Bretagne', 2025, 6.2, 2023, 11.6, 26240),
  ('Centre-Val de Loire', 2025, 7.1, 2023, 14.5, 25490),
  ('Corse', 2025, 6.6, 2023, 20.0, 25020),
  ('Grand Est', 2025, 7.3, 2023, 15.9, 25850),
  ('Hauts-de-France', 2025, 9.2, 2023, 19.0, 23950),
  ('Île-de-France', 2025, 7.4, 2023, 17.3, 28210),
  ('Normandie', 2025, 7.3, 2023, 14.7, 25200),
  ('Nouvelle-Aquitaine', 2025, 6.9, 2023, 14.6, 25520),
  ('Occitanie', 2025, 9.1, 2023, 18.6, 24650),
  ('Pays de la Loire', 2025, 6.2, 2023, 11.5, 26040),
  ('Provence-Alpes-Côte d''Azur', 2025, 8.1, 2023, 18.9, 25560)

AS incoming
ON DUPLICATE KEY UPDATE
  annee_chomage = incoming.annee_chomage,
  taux_chomage_2025_pct = incoming.taux_chomage_2025_pct,
  annee_filosofi = incoming.annee_filosofi,
  taux_pauvrete_2023_pct = incoming.taux_pauvrete_2023_pct,
  niveau_vie_median_2023_eur = incoming.niveau_vie_median_2023_eur;
COMMIT;

-- Verification 1 : 13 regions, 0 valeurs nulles.
SELECT COUNT(*) AS nb_regions,
       COUNT(DISTINCT region) AS nb_regions_distinctes,
       SUM(annee_chomage <> 2025 OR annee_filosofi <> 2023) AS annees_incorrectes,
       SUM(taux_chomage_2025_pct IS NULL OR taux_pauvrete_2023_pct IS NULL
           OR niveau_vie_median_2023_eur IS NULL) AS lignes_incompletes
FROM insee_contexte_regions;

-- Verification 2 : toutes les regions BDF correspondent a INSEE.
SELECT g.region AS region_bdf_sans_insee
FROM regions_endettement_global_2025 AS g
LEFT JOIN insee_contexte_regions AS i ON i.region = g.region
WHERE g.annee = 2025 AND g.niveau_territorial = 'REGION' AND i.region IS NULL;

-- Verification 3 : aucune region INSEE hors referentiel BDF regional.
SELECT i.region AS region_insee_sans_bdf
FROM insee_contexte_regions AS i
LEFT JOIN regions_endettement_global_2025 AS g
  ON g.region = i.region AND g.annee = 2025 AND g.niveau_territorial = 'REGION'
WHERE g.region IS NULL;

-- Verification 4 : valeurs visibles pour comparer avec le CSV et les pages sources INSEE.
SELECT * FROM insee_contexte_regions ORDER BY region;
