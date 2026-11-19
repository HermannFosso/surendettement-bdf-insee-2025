
-- 10 | AUDIT DE TRACABILITE ET DE REPRODUCTIBILITE - BDF x INSEE
-- Lecture seule : aucune table, vue ou donnée n'est modifiée.
-- Base projet, MySQL 8+.
USE surendettement_bdf;

-- Q1. Inventaire des objets techniques réellement présents.
SELECT TABLE_NAME AS objet, TABLE_TYPE AS type_objet
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'surendettement_bdf'
ORDER BY TABLE_TYPE, TABLE_NAME;

-- Q2. Volumétrie EXACTE des cinq tables (ne pas utiliser TABLE_ROWS InnoDB).
SELECT '01_global' AS objet, COUNT(*) AS nb_lignes FROM regions_endettement_global_2025
UNION ALL SELECT '02_consommation', COUNT(*) FROM regions_dettes_consommation_2025
UNION ALL SELECT '03_referentiel_bdf', COUNT(*) FROM bdf_ref_indicateur_2025
UNION ALL SELECT '04_observations_bdf', COUNT(*) FROM bdf_observation_2025
UNION ALL SELECT '05_contexte_insee', COUNT(*) FROM insee_contexte_regions;

-- Q3. Cles primaires et etrangeres : verification structurelle.
SELECT TABLE_NAME AS objet, CONSTRAINT_NAME AS contrainte,
       COLUMN_NAME AS colonne, ORDINAL_POSITION AS position_colonne,
       REFERENCED_TABLE_NAME AS table_reference,
       REFERENCED_COLUMN_NAME AS colonne_reference
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'surendettement_bdf'
  AND (CONSTRAINT_NAME = 'PRIMARY' OR REFERENCED_TABLE_NAME IS NOT NULL)
ORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION;

-- Q4. Provenance declaree dans le referentiel : tableau, onglet, plage.
-- Elle permet de RETROUVER la cellule source ;
-- elle ne prouve pas encore la justesse de l'extraction.
SELECT tableau_source, domaine, code_indicateur, famille, libelle,
       unite, population_reference, onglet_source, plage_source
FROM bdf_ref_indicateur_2025
ORDER BY tableau_source, code_indicateur;

-- Q5. 75 indicateurs x 14 territoires = 1050 observations attendues.
-- Retour vide attendu pour les indicateurs incomplets.
SELECT i.code_indicateur, i.tableau_source, i.libelle,
       COUNT(o.region) AS nb_territoires
FROM bdf_ref_indicateur_2025 AS i
LEFT JOIN bdf_observation_2025 AS o
    ON o.code_indicateur = i.code_indicateur
GROUP BY i.code_indicateur, i.tableau_source, i.libelle
HAVING COUNT(o.region) <> 14;

-- Q6. Controle des doublons logiques BDF (retour vide attendu).
SELECT annee, region, code_indicateur, COUNT(*) AS nb_occurrences
FROM bdf_observation_2025
GROUP BY annee, region, code_indicateur
HAVING COUNT(*) > 1;

-- Q7. Taux BDF en dehors des bornes 0-100 (retour vide attendu).
SELECT o.region, o.code_indicateur, i.libelle, o.valeur
FROM bdf_observation_2025 AS o
JOIN bdf_ref_indicateur_2025 AS i
    ON i.code_indicateur = o.code_indicateur
WHERE i.unite = 'PCT' AND (o.valeur < 0 OR o.valeur > 100);

-- Q8. Controle de cardinalite de la vue de rapprochement.
SELECT COUNT(*) AS nb_lignes,
       COUNT(DISTINCT region) AS nb_regions_distinctes,
       SUM(CASE WHEN taux_chomage_2025_pct IS NULL
                  OR taux_pauvrete_2023_pct IS NULL
                  OR niveau_vie_median_2023_eur IS NULL
                THEN 1 ELSE 0 END) AS nb_lignes_insee_manquantes
FROM v_bdf_insee_regions_2025;

-- Q9. Cohérence interne entre observations et vue de profil.
-- Controle entre transformations SQL,
-- PAS une verification independante face au XLSX BDF.
-- T02_C02 : dossiers sans personne a charge ;
-- T05_C02 : locataires.
SELECT p.region,
       p.part_dossiers_sans_personne_charge_pct AS vue_sans_charge,
       MAX(CASE WHEN o.code_indicateur = 'T02_C02'
                THEN o.valeur END) AS obs_sans_charge,
       p.part_dossiers_locataires_pct AS vue_locataires,
       MAX(CASE WHEN o.code_indicateur = 'T05_C02'
                THEN o.valeur END) AS obs_locataires
FROM v_bdf_profil_regions_2025 AS p
LEFT JOIN bdf_observation_2025 AS o
   ON o.region = p.region AND o.annee = p.annee
  AND o.code_indicateur IN ('T02_C02', 'T05_C02')
GROUP BY p.region, p.part_dossiers_sans_personne_charge_pct,
         p.part_dossiers_locataires_pct
ORDER BY p.region;

-- Q10. Verification des millesimes et des bornes de la table INSEE.
SELECT COUNT(*) AS nb_regions,
       SUM(CASE WHEN annee_chomage <> 2025 OR annee_filosofi <> 2023
                THEN 1 ELSE 0 END) AS annees_incorrectes,
       SUM(CASE WHEN taux_chomage_2025_pct NOT BETWEEN 0 AND 100
                  OR taux_pauvrete_2023_pct NOT BETWEEN 0 AND 100
                  OR niveau_vie_median_2023_eur <= 0
                THEN 1 ELSE 0 END) AS valeurs_hors_bornes
FROM insee_contexte_regions;

-- IMPORTANT : l'audit final devra comparer des valeurs sélectionnées
-- au fichier source officiel BDF ou INSEE.
