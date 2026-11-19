# Preuves Data Quality — BDF 2025

## Portée des contrôles

La comparaison des trois CSV préparés avec les exports MySQL réexportés par Navicat est décrite dans [`13_rapport_cloture_audit_exports_BDF_2025.md`](13_rapport_cloture_audit_exports_BDF_2025.md), réalisée le **14 novembre 2026**.

### Résultats documentés et revérifiés le 19 novembre 2026

| Table BDF | Lignes | Valeurs numériques rapprochées | Écarts | Empreinte SHA-256 export conforme au rapport |
|---|---:|---:|---:|---|
| `regions_endettement_global_2025` | 14 | 56 | 0 | Oui |
| `regions_dettes_consommation_2025` | 14 | 84 | 0 | Oui |
| `bdf_observation_2025` | 1 050 | 1 050 | 0 | Oui |
| **Total** | **1 078** | **1 190** | **0** | **3/3** |

Un nouveau contrôle indépendant sur les fichiers disponibles a confirmé : mêmes ensembles de colonnes ; mêmes clés métier ; aucune différence numérique après conversion `Decimal`, sans tolérance ; aucun doublon sur les clés ; SHA-256 des trois exports identique à celui du rapport. Les deux agrégats de volumes ont également été retrouvés : **120 473 dossiers traités** et **88 357 dossiers concernant les dettes à la consommation** pour la France métropolitaine.

### Pourquoi ne pas republier les exports CSV Navicat ?

Les trois exports contrôlés sont des **preuves de vérification**, déjà conservées dans le dossier de travail local `06_Controles_DQ/Exports_MySQL/`. Leur version métier figure dans `02_Preparation/` du dépôt. Les republier ferait doublon. Le rapport et les empreintes suffisent à documenter cette vérification ; les exports restent disponibles localement pour contre-expertise.

### Ce que les preuves ne démontrent pas encore

- Reconstitution intégrale du projet dans une base MySQL vide.
- Validation sémantique indépendante de chacun des 75 indicateurs.
- Rapprochement exhaustif des exports INSEE et de la source initiale.
- Capacité du classeur Tableau à se reconnecter automatiquement à une autre instance MySQL.

**Statut recommandé : contrôles de fidélité BDF documentés et vérifiés ; reproductibilité bout-en-bout à tester.**
