-- Ateliers SQL / Data Quality | Banque de France 2025
USE surendettement_bdf;

-- 1. Comptage EXACT, contrairement aux estimations information_schema.TABLES.
SELECT '01_global' AS source, COUNT(*) AS n FROM regions_endettement_global_2025
UNION ALL SELECT '02_consommation',COUNT(*) FROM regions_dettes_consommation_2025
UNION ALL SELECT '03_referentiel_indicateurs',COUNT(*) FROM bdf_ref_indicateur_2025
UNION ALL SELECT '04_observations',COUNT(*) FROM bdf_observation_2025;

-- 2. Cles primaires existantes.
SELECT TABLE_NAME, COLUMN_NAME, SEQ_IN_INDEX
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA='surendettement_bdf' AND INDEX_NAME='PRIMARY'
ORDER BY TABLE_NAME, SEQ_IN_INDEX;

-- 3. Cles etrangeres (migration de la cle composite annee + region).
SELECT TABLE_NAME,COLUMN_NAME,REFERENCED_TABLE_NAME,REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA='surendettement_bdf' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME,CONSTRAINT_NAME,ORDINAL_POSITION;

-- 4. Nombre de lignes et indicateurs par tableau d'origine.
SELECT i.tableau_source, i.domaine,
       COUNT(DISTINCT i.code_indicateur) AS nb_indicateurs,
       COUNT(*) AS nb_observations
FROM bdf_observation_2025 v
JOIN bdf_ref_indicateur_2025 i ON i.code_indicateur=v.code_indicateur
GROUP BY i.tableau_source,i.domaine
ORDER BY i.tableau_source;

-- 5. Doublons logiques : zero attendu (PK interdit les vrais doublons).
SELECT annee,region,code_indicateur,COUNT(*) AS doublons
FROM bdf_observation_2025
GROUP BY annee,region,code_indicateur HAVING COUNT(*)>1;

-- 6. Indicateurs de pourcentage hors bornes : 0 ligne attendue.
SELECT v.region,v.code_indicateur,v.valeur
FROM bdf_observation_2025 v
JOIN bdf_ref_indicateur_2025 i ON i.code_indicateur=v.code_indicateur
WHERE i.unite='PCT' AND (v.valeur<0 OR v.valeur>100);

-- 7. Controles de completude : 14 territoires par indicateur attendus.
SELECT i.code_indicateur,i.libelle,COUNT(v.region) AS nb_territoires
FROM bdf_ref_indicateur_2025 i
LEFT JOIN bdf_observation_2025 v ON v.code_indicateur=i.code_indicateur
GROUP BY i.code_indicateur,i.libelle HAVING COUNT(v.region)<>14;

-- 8. Reconstitution de 100% pour les 7 tableaux de repartition.
-- Attention : sommes exactes uniquement sur les tableaux sans recouvrement de categories.
SELECT v.region,i.tableau_source,ROUND(SUM(v.valeur),3) AS somme_pourcentages
FROM bdf_observation_2025 v
JOIN bdf_ref_indicateur_2025 i ON i.code_indicateur=v.code_indicateur
WHERE i.tableau_source IN (1,2,5,7,8,9,10)
GROUP BY v.region,i.tableau_source
HAVING ABS(SUM(v.valeur)-100)>0.02;

-- 9. JOIN : volumes, mediane, et part des ressources issues des minima sociaux.
SELECT g.region,g.nb_dossiers_traites,
       ROUND(g.endettement_median_eur,2) AS endettement_median_eur,
       ROUND(o.valeur,2) AS part_minima_sociaux_pct
FROM regions_endettement_global_2025 g
LEFT JOIN bdf_observation_2025 o
       ON o.annee=g.annee AND o.region=g.region AND o.code_indicateur='T08_C06'
WHERE g.niveau_territorial='REGION'
ORDER BY g.nb_dossiers_traites DESC;

-- 10. Rapprochement PARTIEL des encours. ATTENTION aux categories non couvertes !
-- Les 5 tableaux ci-dessous ne couvrent pas toutes les dettes financieres ;
-- ne pas appeler le residu un defaut DQ sans verifier les autres dettes bancaires.
SELECT g.region,
  ROUND(g.encours_dettes_milliers_eur,2) AS global_k_eur,
  ROUND(c.encours_consommation_milliers_eur
    + MAX(CASE WHEN o.code_indicateur='T14_C02' THEN o.valeur ELSE 0 END)
    + MAX(CASE WHEN o.code_indicateur='T16_C02' THEN o.valeur ELSE 0 END)
    + MAX(CASE WHEN o.code_indicateur='T17_C02' THEN o.valeur ELSE 0 END)
    + MAX(CASE WHEN o.code_indicateur='T18_C02' THEN o.valeur ELSE 0 END),2) AS somme_categories_selectionnees_k_eur,
  ROUND(g.encours_dettes_milliers_eur - (
    c.encours_consommation_milliers_eur
    + MAX(CASE WHEN o.code_indicateur='T14_C02' THEN o.valeur ELSE 0 END)
    + MAX(CASE WHEN o.code_indicateur='T16_C02' THEN o.valeur ELSE 0 END)
    + MAX(CASE WHEN o.code_indicateur='T17_C02' THEN o.valeur ELSE 0 END)
    + MAX(CASE WHEN o.code_indicateur='T18_C02' THEN o.valeur ELSE 0 END)
  ),2) AS residu_non_couvert_k_eur
FROM regions_endettement_global_2025 g
JOIN regions_dettes_consommation_2025 c ON c.annee=g.annee AND c.region=g.region
JOIN bdf_observation_2025 o ON o.annee=g.annee AND o.region=g.region
WHERE g.niveau_territorial='REGION'
GROUP BY g.region,g.encours_dettes_milliers_eur,c.encours_consommation_milliers_eur
ORDER BY g.region;

-- 11. Piege DQ : ne pas sommer les taux d'effacement (tableau 19).
-- Population differente : dossiers CLOS (tableau 19), non dossiers TRAITES (tableaux 12-18).
SELECT o.region,ROUND(o.valeur,2) AS taux_effacement_global_pct
FROM bdf_observation_2025 o
WHERE o.code_indicateur='T19_C07' AND o.region<>'France métropolitaine'
ORDER BY o.valeur DESC;
