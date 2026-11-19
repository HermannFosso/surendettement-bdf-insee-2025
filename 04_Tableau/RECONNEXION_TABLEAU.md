# Tableau — Reconnexion et précautions de publication

## Fichier

`Dataviz_Surendettement_BDF_INSEE_V1.twb` est un **classeur Tableau sans données intégrées** (`.twb`), contenant 11 feuilles, huit dashboards de travail et deux objets Story, dont `Story_01_Surendettement_BDF_INSEE 1` (cinq plans). Une histoire de travail supplémentaire (`Histoire 2`) et une feuille de travail (`Feuille 11`) sont encore présentes.

## Connexion

Le classeur référence quatre sources MySQL dans la base `surendettement_bdf` :

- `regions_endettement_global_2025`
- `regions_dettes_consommation_2025`
- `v_bdf_profil_regions_2025`
- `v_bdf_insee_regions_2025`

Le serveur indiqué est `localhost`, port `3306`. Le fichier **ne contient pas d'extrait de données** ni de mot de passe enregistré. Pour ouvrir les vues et actualiser les résultats sur un autre poste, il faut :

1. Disposer de MySQL et du pilote compatible Tableau.
2. Recréer la base `surendettement_bdf` en suivant `03_SQL/ORDRE_EXECUTION_SQL.md`.
3. Ouvrir le classeur dans Tableau Desktop et renseigner un compte MySQL autorisé lors de la demande de reconnexion (ne jamais publier le mot de passe).
4. Actualiser les sources si nécessaire et vérifier les chiffres des plans.

## Précautions

Cette copie de diffusion a été nettoyée du nom d'utilisateur MySQL local ainsi que de certains identifiants techniques de l'auteur et de la machine présents dans les métadonnées du classeur. Elle n'a **pas** été ouverte et testée dans Tableau Desktop après nettoyage : vérifier son ouverture et les cinq plans avant de qualifier la publication de pleinement reproductible.

Ne pas modifier le classeur original de travail sous `Dataviz_Surendettement/04_Tableau`.
