-- AJC Dataviz / Banque de France 2025
-- Vue regionale pour Tableau / Power BI : une ligne par region.
-- Le perimetre exclut le total France metropolitaine.
-- Sources : tableaux 2, 5, 9 et 12 du classeur BDF de comparaisons regionales.
-- T02_C02 : proportion des dossiers sans personne a charge.
-- T05_C02 : proportion des dossiers de locataires.
-- T09_C02 : proportion des dossiers avec ressources mensuelles par UC < 1 122 EUR.
-- Les trois pourcentages sont en points de pourcentage : 77.79 = 77.79 %.
-- Aucune table d'origine n'est modifiee par CREATE VIEW.
USE surendettement_bdf;

CREATE OR REPLACE VIEW v_bdf_profil_regions_2025 AS
SELECT
    g.annee,
    g.region,
    g.nb_dossiers_traites,
    g.endettement_median_eur,
    ROUND(MAX(CASE WHEN o.code_indicateur = 'T02_C02' THEN o.valeur END), 2)
        AS part_dossiers_sans_personne_charge_pct,
    ROUND(MAX(CASE WHEN o.code_indicateur = 'T05_C02' THEN o.valeur END), 2)
        AS part_dossiers_locataires_pct,
    ROUND(MAX(CASE WHEN o.code_indicateur = 'T09_C02' THEN o.valeur END), 2)
        AS part_dossiers_ressources_uc_inf_1122_pct
FROM regions_endettement_global_2025 AS g
LEFT JOIN bdf_observation_2025 AS o
    ON o.annee = g.annee
   AND o.region = g.region
   AND o.code_indicateur IN ('T02_C02','T05_C02','T09_C02')
WHERE g.annee = 2025
  AND g.niveau_territorial = 'REGION'
GROUP BY
    g.annee, g.region, g.nb_dossiers_traites, g.endettement_median_eur;

-- Controle du grain et de la completude : 13 regions, 0 NULL par indicateur.
SELECT
    COUNT(*) AS nb_regions,
    COUNT(DISTINCT region) AS nb_regions_distinctes,
    SUM(part_dossiers_sans_personne_charge_pct IS NULL) AS manque_sans_charge,
    SUM(part_dossiers_locataires_pct IS NULL) AS manque_locataires,
    SUM(part_dossiers_ressources_uc_inf_1122_pct IS NULL) AS manque_ressources
FROM v_bdf_profil_regions_2025;

-- Apercu des mesures : une ligne par region, sans double comptage.
SELECT *
FROM v_bdf_profil_regions_2025
ORDER BY part_dossiers_locataires_pct DESC;
