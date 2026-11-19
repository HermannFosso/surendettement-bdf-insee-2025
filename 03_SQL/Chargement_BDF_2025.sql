-- AJC Dataviz / Banque de France 2025 : chargement direct pour Navicat Premium Lite.
-- Genere a partir des deux CSV fournis dans 02_Preparation (separateur point-virgule).
-- Evite l'assistant CSV de Navicat qui reconnait tout en une seule colonne.
-- Tables pre-creees par 01_schema_surendettement.sql. MySQL 8.0.x.
-- Idempotent: si une cle (annee, region) existe, les valeurs source sont actualisees.
-- Les fichiers Excel originaux ne sont pas modifies.
USE surendettement_bdf;
START TRANSACTION;

-- regions_endettement_global_2025: 14 lignes (13 regions et une reference nationale)
INSERT INTO regions_endettement_global_2025 (
    `annee`, `niveau_territorial`, `region`, `encours_dettes_milliers_eur`, `nb_dossiers_traites`, `endettement_median_eur`, `nb_median_dettes`
) VALUES
  (2025, 'REGION', 'Auvergne-Rhône-Alpes', 539214.220180, 13431, 19133.330, 7),
  (2025, 'REGION', 'Bourgogne-Franche-Comté', 238321.987340, 5840, 19438.890, 7),
  (2025, 'REGION', 'Bretagne', 166348.111190, 4317, 17744.340, 7),
  (2025, 'REGION', 'Centre-Val de Loire', 258543.475490, 5599, 20226.870, 7),
  (2025, 'REGION', 'Corse', 24933.711380, 566, 18056.575, 6),
  (2025, 'REGION', 'Grand Est', 390113.029710, 10192, 18042.300, 7),
  (2025, 'REGION', 'Hauts-de-France', 585339.724190, 18067, 15158.140, 6),
  (2025, 'REGION', 'Île-de-France', 895662.367920, 18187, 24379.750, 6),
  (2025, 'REGION', 'Normandie', 263913.802560, 7329, 18111.470, 7),
  (2025, 'REGION', 'Nouvelle-Aquitaine', 507342.588210, 11561, 18955.030, 7),
  (2025, 'REGION', 'Occitanie', 416550.817460, 9918, 19333.340, 7),
  (2025, 'REGION', 'Pays de la Loire', 228162.074870, 5610, 18536.805, 7),
  (2025, 'REGION', 'Provence-Alpes-Côte d''Azur', 450270.680320, 9856, 21515.650, 6),
  (2025, 'TOTAL_METROPOLE', 'France métropolitaine', 4964716.590820, 120473, 19277.670, 7)
ON DUPLICATE KEY UPDATE
  `niveau_territorial` = VALUES(`niveau_territorial`),
  `encours_dettes_milliers_eur` = VALUES(`encours_dettes_milliers_eur`),
  `nb_dossiers_traites` = VALUES(`nb_dossiers_traites`),
  `endettement_median_eur` = VALUES(`endettement_median_eur`),
  `nb_median_dettes` = VALUES(`nb_median_dettes`);

-- regions_dettes_consommation_2025: 14 lignes (13 regions et une reference nationale)
INSERT INTO regions_dettes_consommation_2025 (
    `annee`, `niveau_territorial`, `region`, `encours_consommation_milliers_eur`, `nb_dossiers_concernes`, `part_endettement_global_pct`, `part_dossiers_concernes_pct`, `endettement_median_eur`, `nb_median_dettes`
) VALUES
  (2025, 'REGION', 'Auvergne-Rhône-Alpes', 231657.372580, 9868, 42.96203, 73.47182, 14421.785, 3),
  (2025, 'REGION', 'Bourgogne-Franche-Comté', 104775.291630, 4286, 43.96375, 73.39041, 14512.260, 3),
  (2025, 'REGION', 'Bretagne', 68310.112050, 3108, 41.06456, 71.99444, 12373.545, 3),
  (2025, 'REGION', 'Centre-Val de Loire', 102293.326270, 3985, 39.56523, 71.17342, 15241.230, 3),
  (2025, 'REGION', 'Corse', 10055.693320, 395, 40.32971, 69.78799, 16125.530, 3),
  (2025, 'REGION', 'Grand Est', 171150.225980, 7279, 43.87196, 71.41876, 14399.600, 3),
  (2025, 'REGION', 'Hauts-de-France', 273848.544220, 12391, 46.78455, 68.58361, 12758.310, 3),
  (2025, 'REGION', 'Île-de-France', 375844.541440, 13803, 41.96275, 75.89487, 18179.770, 3),
  (2025, 'REGION', 'Normandie', 121518.018720, 5338, 46.04459, 72.83395, 13892.055, 3),
  (2025, 'REGION', 'Nouvelle-Aquitaine', 226920.420750, 8598, 44.72726, 74.37073, 14745.210, 3),
  (2025, 'REGION', 'Occitanie', 188895.506820, 7544, 45.34753, 76.06372, 15238.480, 3),
  (2025, 'REGION', 'Pays de la Loire', 98266.273050, 4105, 43.06863, 73.17291, 13729.000, 3),
  (2025, 'REGION', 'Provence-Alpes-Côte d''Azur', 196271.801500, 7657, 43.58974, 77.68872, 16477.600, 4),
  (2025, 'TOTAL_METROPOLE', 'France métropolitaine', 2169807.128330, 88357, 43.70455, 73.34174, 14880.350, 3)
ON DUPLICATE KEY UPDATE
  `niveau_territorial` = VALUES(`niveau_territorial`),
  `encours_consommation_milliers_eur` = VALUES(`encours_consommation_milliers_eur`),
  `nb_dossiers_concernes` = VALUES(`nb_dossiers_concernes`),
  `part_endettement_global_pct` = VALUES(`part_endettement_global_pct`),
  `part_dossiers_concernes_pct` = VALUES(`part_dossiers_concernes_pct`),
  `endettement_median_eur` = VALUES(`endettement_median_eur`),
  `nb_median_dettes` = VALUES(`nb_median_dettes`);

COMMIT;

-- Controle rapide : 14 lignes attendues dans chaque table.
SELECT 'endettement_global' AS table_source, COUNT(*) AS nb_lignes FROM regions_endettement_global_2025
UNION ALL
SELECT 'dettes_consommation', COUNT(*) FROM regions_dettes_consommation_2025;

-- Referentiel : 13 regions et un total metropolitain.
SELECT niveau_territorial, COUNT(*) AS nb_lignes
FROM regions_endettement_global_2025 GROUP BY niveau_territorial;

-- Controle de coherence : rapprocher les sommes regionales et le total officiel.
SELECT
  SUM(CASE WHEN niveau_territorial = 'REGION' THEN nb_dossiers_traites ELSE 0 END) AS total_dossiers_regions,
  MAX(CASE WHEN niveau_territorial = 'TOTAL_METROPOLE' THEN nb_dossiers_traites END) AS total_dossiers_metropole,
  ROUND(SUM(CASE WHEN niveau_territorial = 'REGION' THEN encours_dettes_milliers_eur ELSE 0 END), 2) AS total_encours_regions_k_eur,
  ROUND(MAX(CASE WHEN niveau_territorial = 'TOTAL_METROPOLE' THEN encours_dettes_milliers_eur END), 2) AS total_encours_metropole_k_eur
FROM regions_endettement_global_2025;
