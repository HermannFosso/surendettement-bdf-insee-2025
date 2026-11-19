-- 09 | Vue de rapprochement entre les dossiers BDF 2025 et les indicateurs INSEE
-- Une ligne par region metropolitaine, PAS une ligne par dossier individuel.
-- Annee BDF = 2025 ; chomage = 2025 ; pauvrete/niveau de vie = 2023.
-- Les populations ne sont pas identiques : dossiers BDF vs population territoriale.
-- Les nombres ci-dessous ne prouvent pas de causalite.
USE surendettement_bdf;

CREATE OR REPLACE VIEW v_bdf_insee_regions_2025 AS
SELECT
  b.annee AS annee_bdf,
  b.region,
  b.nb_dossiers_traites,
  b.endettement_median_eur,
  b.part_dossiers_locataires_pct,
  b.part_dossiers_sans_personne_charge_pct,
  i.annee_chomage,
  i.taux_chomage_2025_pct,
  i.annee_filosofi,
  i.taux_pauvrete_2023_pct,
  i.niveau_vie_median_2023_eur
FROM v_bdf_profil_regions_2025 AS b
LEFT JOIN insee_contexte_regions AS i ON b.region = i.region;

-- Controle grain et completude : attendu 13, 13, 0.
SELECT COUNT(*) AS nb_lignes,
       COUNT(DISTINCT region) AS nb_regions_distinctes,
       SUM(taux_chomage_2025_pct IS NULL OR taux_pauvrete_2023_pct IS NULL
           OR niveau_vie_median_2023_eur IS NULL) AS nb_lignes_insee_manquantes
FROM v_bdf_insee_regions_2025;

-- Lecture exploratoire, sans causalite : regions a chomage relativement eleve.
SELECT region,
       nb_dossiers_traites,
       endettement_median_eur,
       taux_chomage_2025_pct,
       taux_pauvrete_2023_pct,
       niveau_vie_median_2023_eur
FROM v_bdf_insee_regions_2025
ORDER BY taux_chomage_2025_pct DESC, region;
