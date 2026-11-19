# Surendettement des ménages en France — Disparités régionales 2025

**Projet individuel de Data Analysis et de Data Quality — Banque de France × INSEE**  
**Outils :** Excel, MySQL, Navicat Premium Lite, Tableau Desktop  
**Périmètre :** 13 régions de France métropolitaine ; les tableaux BDF contiennent également une ligne agrégée « France métropolitaine ».

## 1. Problématique

Comment comparer les situations régionales de surendettement sans confondre le volume des dossiers, leur niveau d'endettement, la présence de certaines catégories de dettes et leur poids financier ? Comment documenter la fiabilité et les limites des rapprochements avec le contexte socio-économique ?

Ce projet exploite des **statistiques régionales agrégées**, pas des données individuelles de ménages.

## 2. Sources et périmètres

- **Banque de France — Typologie du surendettement des ménages, comparaisons régionales 2025.** Classeur de référence : `_SUREN-2025_COMPARAISONS-REGIONALES.xlsx` (notamment tableau 12 : endettement global ; tableau 15 : dettes à la consommation ; autres tableaux de typologie).
- **INSEE — Niveau de vie médian régional 2023** : fichier `TCRD_022.xlsx` (Filosofi 2023).
- **INSEE — Taux de pauvreté régional 2023** : fichier `TCRD_024.xlsx` (Filosofi 2023).
- **INSEE — Taux de chômage localisé 2025** : fichier `TCRD_087.xlsx`.

**Attention aux millésimes et populations :** BDF 2025 décrit des dossiers de surendettement traités ; les indicateurs INSEE décrivent la population régionale et sont issus de 2023 ou de 2025 selon l'indicateur. La ligne BDF « France métropolitaine » ne doit pas être comptée comme une quatorzième région dans les analyses transversales.

La localisation, la version et les conditions de réutilisation des fichiers originaux sont à vérifier avant de les republier ; au besoin, conserver dans ce dépôt uniquement leurs références et les fichiers préparés autorisés.

## 3. Préparation et modèle de données

Les tableaux sources destinés à la lecture humaine ont été transformés en fichiers CSV structurés, puis chargés dans la base MySQL `surendettement_bdf`.

| Table MySQL | Lignes contrôlées | Rôle |
|---|---:|---|
| `regions_endettement_global_2025` | 14 | Montants et dossiers par région + total métropolitain |
| `regions_dettes_consommation_2025` | 14 | Fréquence et poids financier des dettes à la consommation |
| `bdf_ref_indicateur_2025` | 75 | Référentiel : code, libellé, unité, population, emplacement source |
| `bdf_observation_2025` | 1 050 | Mesures au format long : année, région, code indicateur, valeur |
| `insee_contexte_regions` | 13 | Indicateurs socio-économiques régionaux INSEE |

Deux vues analytiques sont également présentes : `v_bdf_profil_regions_2025` et `v_bdf_insee_regions_2025`.

Le champ `code_indicateur` relie `bdf_observation_2025` à `bdf_ref_indicateur_2025`. Par exemple, pour l'Île-de-France, `T05_C02` correspond à **Locataires**, unité `PCT`, valeur `77,096384` (soit 77,10 % après arrondi), avec une référence au tableau source. La jointure enrichit la lecture : elle **ne crée pas** la valeur mesurée.

## 4. Contrôles Data Quality

Contrôles exécutés sur la base de travail :

- **Volumétrie :** 14 / 14 / 75 / 1 050 / 13 lignes, conformes aux comptages attendus.
- **Unicité :** aucune répétition de la clé logique `(annee, region, code_indicateur)` détectée dans les 1 050 observations ; une clé primaire composite protège également cette unicité.
- **Validité :** aucune valeur hors de `[0, 100]` parmi les observations dont l'unité est `PCT`.
- **Traçabilité :** libellés, unités, population de référence et plages des tableaux sources conservés dans le référentiel des indicateurs.

Ces vérifications ne constituent **pas** une certification de l'exactitude des valeurs originales. Les règles de cohérence, d'intégrité référentielle et de comparaison aux exports doivent être accompagnées de leurs requêtes/résultats pour permettre une vérification indépendante.

## 5. Résultats métiers — cinq plans Tableau

1. **Panorama régional :** 18 187 dossiers traités en Île-de-France contre 18 067 dans les Hauts-de-France ; endettements médians respectifs de **24 380 €** et **15 158 €**. Des volumes proches peuvent masquer des niveaux d'endettement très différents.
2. **Dettes à la consommation :** en Provence-Alpes-Côte d'Azur, 77,69 % des dossiers en comportent, mais elles représentent 43,59 % de l'endettement global. Dans les Hauts-de-France : 68,58 % et 46,78 %. Fréquence et poids financier ont des dénominateurs distincts.
3. **Situation résidentielle :** parts de dossiers concernant des locataires proches en Île-de-France (77,10 %) et Hauts-de-France (77,79 %), sans niveaux médians d'endettement comparables.
4. **Niveau de vie et endettement :** corrélation linéaire régionale de Pearson `r = +0,717` sur 13 régions, ramenée à `r = +0,408` hors Île-de-France. L'association descriptive dépend du périmètre ; **aucune causalité démontrée**.
5. **Conclusion :** croisement des indicateurs, traçabilité, contrôles et limites d'interprétation.

## 6. Organisation du projet

L'organisation de travail est conservée, avec ses dossiers existants :

```text
.
├── README.md
├── 01_Sources/          # Références des fichiers originaux BDF / INSEE
├── 02_Preparation/      # CSV préparés
├── 03_SQL/              # Schéma, chargements, vues et requêtes de contrôle
├── 04_Tableau/          # Classeur Tableau et exports éventuels
├── 05_Presentation/     # Synthèse, captures et restitution
└── 06_Controles_DQ/    # Résultats de tests et preuves de vérification
```

**Contenu publié progressivement :** le dépôt peut être incomplet au premier commit. Les fichiers listés ne sont à considérer comme publiés que lorsqu'ils figurent effectivement dans le dépôt.

## 7. Reproduction — procédure à vérifier sur un environnement neuf

1. Installer MySQL et disposer d'un client compatible (Navicat Premium Lite a été utilisé pour ce projet).
2. Créer la base `surendettement_bdf` ; exécuter les scripts SQL du dossier `03_SQL` dans l'ordre documenté, puis charger les CSV autorisés du dossier `02_Preparation`.
3. Contrôler les cinq effectifs, les clés logiques, les valeurs hors bornes et les correspondances des indicateurs.
4. Ouvrir le classeur depuis `04_Tableau` et mettre à jour, si nécessaire, les paramètres de connexion MySQL **sans publier d'identifiants**.
5. Examiner les cinq plans de l'histoire Tableau et leurs limites.

**État :** la reproduction complète sur une machine vierge reste à tester ; ne pas considérer cette procédure comme validée avant cet essai.

## 8. Limites

- Seulement 13 régions pour les comparaisons interrégionales.
- Statistiques agrégées : aucune inférence sur le comportement d'un ménage individuel.
- Millésimes et dénominateurs différents entre BDF et INSEE.
- Corrélation et régression descriptives, sans validation de performance prédictive ni causalité.
- Le nombre de dossiers traités n'est pas un taux de surendettement rapporté à la population.

## 9. État et suite

**Présentation orale réalisée le 17 novembre 2026** dans le cadre de la formation AJC Data Analyst. Dépôt en cours de conditionnement. Prolongements possibles : enrichissement historique, validations indépendantes des valeurs sources, documentation de la reproductibilité et suivi formalisé des anomalies de qualité.
