# Sources et traçabilité — Banque de France × INSEE

**Projet :** Surendettement des ménages en France — disparités régionales 2025  
**État de la documentation :** 19 novembre 2026  
**Périmètre analytique :** 13 régions métropolitaines ; la ligne « France métropolitaine » des tableaux Banque de France sert de référence agrégée et ne constitue pas une quatorzième région.

## 1. Banque de France — données de surendettement 2025

**Classeur source consulté :** `_SUREN-2025_COMPARAISONS-REGIONALES.xlsx` — *Typologie du surendettement des ménages*, tableaux de comparaisons régionales.

| Extraction | Feuille source | Tableau, plage | Fichier préparé |
|---|---|---|---|
| Endettement global | `Tableaux-12-à-18_Endettement` | Tableau 12, `A5:E18` | `../02_Preparation/regions_endettement_global_2025.csv` |
| Dettes à la consommation | `Tableaux-12-à-18_Endettement` | Tableau 15, `A65:G78` | `../02_Preparation/regions_dettes_consommation_2025.csv` |

Ces deux fichiers comportent 13 régions métropolitaines et une ligne nationale de référence. Les données sont **agrégées**, non nominatives.

### Transformations documentées au 13 novembre 2026

- Suppression des espaces superflus en fin des noms de région ; harmonisation des clés régionales.
- Ajout de l'année `2025` et du niveau territorial (`REGION` ou `TOTAL_METROPOLE`).
- Préservation des unités métier : **encours en milliers d'euros**, **endettement médian en euros**, pourcentages en points de pourcentage.
- Exports numériques formatés : encours à six décimales, médianes à trois décimales, pourcentages à cinq décimales ; contrôle des entiers.
- Classeur Excel source conservé inchangé lors de la préparation.

Cette liste reprend la notice de préparation initiale `README_IMPORT.txt` (version du 13 novembre 2026). Cette notice mentionnait une importation manuelle par Navicat. La reconstruction actuelle privilégie les scripts de `../03_SQL/ORDRE_EXECUTION_SQL.md` : **ne pas mélanger les deux procédures sans vérification**.

### Autres indicateurs Banque de France

Le projet comprend également :

- `../02_Preparation/bdf_ref_indicateur_2025.csv` — 75 indicateurs : code, libellé, unité, population de référence, tableau, onglet et plage de cellules sources.
- `../02_Preparation/bdf_observation_2025.csv` — 1 050 observations au grain *année × territoire × code indicateur*.

Le référentiel de métadonnées permet de remonter aux feuilles et plages déclarées. **La présence d'une plage source dans le référentiel ne garantit pas à elle seule une certification sémantique indépendante des 75 indicateurs.**

## 2. INSEE — contexte socio-économique des régions

Trois indicateurs ont été rapprochés des données BDF :

| Indicateur | Millésime | Classeur de référence | Page INSEE indiquée dans le script |
|---|---|---|---|
| Niveau de vie médian annuel, en euros | 2023 | `TCRD_022.xlsx` | https://www.insee.fr/fr/statistiques/2012717 |
| Taux de pauvreté, ensemble, en % | 2023 | `TCRD_024.xlsx` | https://www.insee.fr/fr/statistiques/2012803 |
| Taux de chômage localisé, moyenne annuelle, ensemble, en % | 2025 | `TCRD_087.xlsx` | https://www.insee.fr/fr/statistiques/2134411 |

Ces données ont été **retranscrites des tableaux régionaux** dans `08_chargement_insee_contexte_regions.sql` puis structurées dans `../02_Preparation/08_insee_contexte_regions_2025_2023.csv`. Ce CSV est un fichier dérivé du projet, **pas un export natif INSEE**.

La table `insee_contexte_regions` contient 13 régions. Les libellés régionaux ont été harmonisés pour le rapprochement sur `region`. Un taux comme `7.40` signifie **7,40 %**, et non `0,074`.

> Précaution : les chiffres de la Banque de France décrivent des dossiers traités, tandis que ceux de l'INSEE décrivent le contexte de la population régionale. Les populations de référence et les années diffèrent. Le croisement est descriptif ; il ne démontre aucune causalité.

## 3. Contrôles de fidélité et statut des preuves

Le rapport `../06_Controles_DQ/13_rapport_cloture_audit_exports_BDF_2025.md` documente un audit du 14 novembre 2026 : **1 078 lignes BDF, 1 190 valeurs numériques comparées entre CSV préparés et exports MySQL, zéro écart numérique, zéro clé manquante ou supplémentaire**.

Ce contrôle **ne couvre pas** une comparaison exhaustive indépendante des 39 valeurs INSEE aux originaux, ni l'exécution de toute la chaîne sur une instance MySQL vierge. Il ne remplace pas non plus la validation métier de la population de référence de chaque indicateur.

Règles métier à respecter :

- Ne jamais additionner la ligne `TOTAL_METROPOLE` aux 13 lignes régionales.
- Ne pas sommer ou moyenner les médianes régionales pour reconstituer une médiane nationale.
- Ne pas additionner des pourcentages régionaux.
- Ne pas confondre le nombre de dossiers traités avec le nombre de dossiers concernés par une catégorie de dettes, ni la fréquence des dossiers avec le poids financier des dettes.

## 4. Conservation des originaux et réutilisation

Les classeurs sources institutionnels ont été utilisés dans le dossier de travail original, distinct de la copie GitHub. Le dépôt publie les **références**, les **fichiers préparés** et les **scripts de transformation / chargement**. Les dates de téléchargement, versions exactes, empreintes des classeurs d'origine et conditions de redistribution doivent être revérifiées avant de republier les fichiers Excel sources.

**Traçabilité :** source officielle → tableau / plage → CSV préparé ou données SQL → tables et vues MySQL → Tableau → contrôles DQ.
