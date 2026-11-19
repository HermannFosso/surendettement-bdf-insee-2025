# Rapport de clôture — Audit CSV préparés ↔ exports MySQL (BDF 2025)

**Date du contrôle :** 14 novembre 2026  
**Projet :** `Dataviz_Surendettement_BDF_INSEE_V1`  
**Périmètre :** trois tables Banque de France (14 territoires dont agrégat métropolitain ; 75 indicateurs × 14 territoires).

## 1. Objet et méthode

Comparer les CSV réexportés depuis les tables MySQL dans Navicat aux CSV de préparation contenus dans `BDF_2025_Quatre_CSV_et_notice.zip` (`02_Preparation/`). La comparaison porte sur toutes les lignes et toutes les valeurs métier, après rapprochement par clé et indépendamment de l’ordre des lignes.

- Lecture des CSV d’origine (séparateur `;`) et des exports Navicat (séparateur `,`), en UTF-8.
- Contrôle du schéma (noms de colonnes), du nombre de lignes, de l’unicité de la clé métier et de l’ensemble des clés présentes.
- Comparaison exacte de chaque valeur numérique après normalisation en nombre décimal (`Decimal`), sans arrondi ni tolérance ; les différences de format texte des nombres n’affectent pas l’égalité numérique.
- Périmètre des clés : `(annee, niveau_territorial, region)` pour les deux tables régionales et `(annee, region, code_indicateur)` pour les observations.

## 2. Résultats exhaustifs

| Table | Lignes | Valeurs comparées | Écarts numériques | Clés manquantes / en plus | Doublons export | Schéma |
|---|---:|---:|---:|---:|---:|---|
| `regions_endettement_global_2025` | 14 | 56 | 0 | 0 / 0 | 0 | Identique |
| `regions_dettes_consommation_2025` | 14 | 84 | 0 | 0 / 0 | 0 | Identique |
| `bdf_observation_2025` | 1 050 | 1 050 | 0 | 0 / 0 | 0 | Identique |
| **Total** | **1 078** | **1 190** | **0** | **0 / 0** | **0** | **Identique** |

**Conclusion :** aucune divergence numérique constatée entre les CSV exportés de Navicat et les CSV préparés, sur l’intégralité des 1 190 valeurs comparables. Les clés sont concordantes, sans doublon, et les colonnes sont identiques.

## 3. Contrôle métier supplémentaire — agrégat géographique

- `regions_endettement_global_2025` : somme des dossiers traités pour les 13 régions = **120 473** ; total « France métropolitaine » = **120 473**.
- `regions_dettes_consommation_2025` : somme des dossiers concernés pour les 13 régions = **88 357** ; total « France métropolitaine » = **88 357**.
- Seuls les volumes additifs ont été comparés à leur total. **Ne pas additionner** les médianes ou pourcentages régionaux pour obtenir des indicateurs nationaux.

## 4. Empreintes SHA-256 des trois exports contrôlés

Les empreintes permettent de vérifier ultérieurement que les fichiers exportés n’ont pas changé.

| Fichier exporté | SHA-256 |
|---|---|
| `regions_endettement_global_2025.csv` | `15c841fc9c38291591d186430548f67672661192261d82ad53b29671bbd374dd` |
| `regions_dettes_consommation_2025.csv` | `7fef8253a4b4d1f9664e64dc9f8c707bc7261ed9b105c91a3141360744d05e1b` |
| `bdf_observation_2025(1).csv` | `fa0d8b29f7b95f132b5e24abbbbbab938a24e268435de379e0aa103b4bc36a58` |

## 5. Portée de la validation

**Validé :** fidélité exacte, pour les valeurs numériques, de la chaîne **CSV préparés → tables MySQL → exports Navicat** des trois tables BDF examinées. La comparaison précédente **Excel BDF → CSV préparés** fait l’objet du registre séparé `Audit_fidelite_BDF_2025_v1.xlsx` ; ce rapport ne répète pas cette analyse.

**Non couvert par le présent contrôle :**

- Export indépendant et comparaison exhaustive de `insee_contexte_regions` avec son CSV de préparation (les contrôles SQL antérieurs avaient validé sa cardinalité, ses années, ses bornes et ses correspondances).
- Relecture de la sémantique de chaque indicateur et de ses populations de référence par rapport à la documentation officielle ; les contrôles numériques ne valident pas à eux seuls l’interprétation métier.
- Reproductibilité intégrale dans un environnement vierge : dépendances MySQL, scripts d’installation et sources Tableau doivent encore être regroupés et testés.

## 6. Décision et suite

**Statut du chantier : VALIDÉ — Audit exhaustif des exports BDF.**

Il n’est pas nécessaire de réexporter ces trois tables. Pour finaliser le projet, la priorité devient la documentation concise du modèle, des sources, des tests de qualité et des limites analytiques, puis le packaging final du classeur Tableau et des scripts SQL.
