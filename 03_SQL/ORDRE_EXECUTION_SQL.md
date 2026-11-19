# Reconstitution SQL — Banque de France × INSEE 2025

## Statut

- Audit **statique des scripts** réalisé le 19 novembre 2026 : dépendances, versions, doublons et ordre logique.
- La reconstruction complète sur une instance MySQL neuve **n'a pas été testée** par cet audit.
- Environnement : MySQL **8.0.19 ou ultérieur** (le script INSEE utilise un alias de ligne `AS incoming` dans `INSERT ... ON DUPLICATE KEY UPDATE`), client Navicat Premium Lite ou équivalent.
- Les CSV de `02_Preparation/` sont des **exports préparés de référence** ; les scripts de chargement `INSERT` contiennent déjà les valeurs. **Ne pas charger les CSV une seconde fois pour reproduire cette procédure.**

## Préparation de l'environnement

Sur une instance MySQL de test dédiée, exécuter une fois :

```sql
CREATE DATABASE IF NOT EXISTS surendettement_bdf
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Ne pas exécuter les scripts de création et d'insertion sur une base hébergeant d'autres données sans les examiner d'abord.

## Ordre exact d'exécution

| Ordre | Script | Effet attendu |
|---:|---|---|
| 1 | `01_schema_surendettement.sql` | Création des deux tables régionales BDF |
| 2 | `Chargement_BDF_2025.sql` | 14 lignes BDF global + 14 lignes consommation |
| 3 | `04_schema_enrichissement_bdf.sql` | Création du référentiel et des observations, version **corrigée** sans `ck_observation_annee_2025` |
| 4 | `05_chargement_indicateurs_bdf.sql` | 75 indicateurs et 1 050 observations |
| 5 | `07_vue_profil_regions_2025.sql` | Création de `v_bdf_profil_regions_2025` (13 régions) |
| 6 | `08_chargement_insee_contexte_regions.sql` | Création et chargement de `insee_contexte_regions` (13 régions) |
| 7 | `09_vue_bdf_insee_regions.sql` | Création de `v_bdf_insee_regions_2025` (13 régions) |
| 8 | `06_controles_et_requetes_SQL.sql` | Requêtes de contrôle BDF (lecture seule) |
| 9 | `10_audit_tracabilite_bdf_insee.sql` | Inventaire, clés, traçabilité, cardinalités, contrôles BDF × INSEE (lecture seule) |

Le fichier `03_chargement_direct_surendettement_2025.sql` d'origine est strictement identique à `Chargement_BDF_2025.sql` : **ne pas exécuter les deux**. Le fichier `02_controles_et_analyse.sql` est une ancienne version d'exploration non nécessaire à la chaîne principale.

## Vérifications minimales

Nombre de lignes attendu après reconstruction :

| Objet | Nombre attendu |
|---|---:|
| `regions_endettement_global_2025` | 14 |
| `regions_dettes_consommation_2025` | 14 |
| `bdf_ref_indicateur_2025` | 75 |
| `bdf_observation_2025` | 1 050 |
| `insee_contexte_regions` | 13 |
| `v_bdf_profil_regions_2025` | 13 |
| `v_bdf_insee_regions_2025` | 13 |

- Clé logique des observations : `(annee, region, code_indicateur)` sans doublons.
- Valeurs en unité `PCT` dans `[0, 100]`.
- Aucun indicateur manquant parmi les 14 territoires attendus, et aucune des 13 régions sans contexte INSEE.
- Comparer des échantillons avec les classeurs officiels : **l'intégrité interne ne démontre pas l'exactitude des sources**.

## Points de vigilance

- Les séries INSEE ont des millésimes distincts : chômage **2025**, pauvreté et niveau de vie **2023**.
- Les comparaisons se font sur 13 régions ; la ligne « France métropolitaine » est un total, pas une région.
- Les requêtes du script `10` présentent des résultats et des listes d'anomalies ; il faut les examiner, pas seulement vérifier que le script s'exécute.
- La connexion du classeur Tableau à une nouvelle instance MySQL reste à tester ; ne jamais publier les mots de passe et paramètres secrets.
