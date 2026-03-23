# Analyse Économétrique de la Densité de Médecins Libéraux en France

> **Master 1 Mathématiques Appliquées & Statistique — Université de Rennes**

---

## Problématique

**Quels facteurs expliquent la densité de médecins généralistes libéraux par zones d'emploi en France ?**

D'après la DREES, 6 % des territoires français sont sous-dotés en médecins généralistes. Face à ce constat, ce projet vise à identifier et quantifier les déterminants socio-économiques, démographiques et structurels de l'offre de soins libérale, à l'échelle des 306 zones d'emploi françaises.

---

## Données

| Source | Variables extraites |
|---|---|
| [INSEE — Statistiques locales](https://statistiques-locales.insee.fr/) | Densité de population, taux d'activité, part des 75 ans+, transports en commun, foyers imposables |
| [CartoSanté](sante.atlasante.fr/) | Densité de médecins, infirmiers et kinésithérapeutes libéraux, pharmacies |
| Recensement des facultés de médecine | Présence d'une université de médecine par zone |

### Variables du modèle

| Variable | Description | Rôle |
|---|---|---|
| `DENS_MED_LIB` | Densité de médecins généralistes libéraux (pour 100 000 hab.) | Variable dépendante |
| `DENSITE` | Densité de population (hab./km²) | Explicative — suspecte d'endogénéité |
| `PART_75` | Part des personnes âgées de 75 ans ou plus | Explicative |
| `TAUX_ACTIV` | Taux d'activité des 25-59 ans | Explicative |
| `PART_IMPOT` | Part des ménages fiscaux imposés | Explicative |
| `PART_TRANS_COMM` | Part des actifs utilisant les transports en commun | Explicative |
| `UNIV` | Présence d'une faculté de médecine | Explicative (catégorielle) |
| `PART_PHARMA` | Part de bénéficiaires de produits pharmaceutiques | Explicative |
| `DENS_PARA` | Densité de paramédicaux libéraux (infirmiers + kinés) | Explicative — suspecte d'endogénéité |

---

## Structure du projet

```
densite-medecins-econometrie/
├── data/
│   └── medecins.csv          # Jeu de données (306 zones d'emploi)
├── src/
│   └── Projet.Rmd            # Rapport principal R Markdown
├── README.md
└── .gitignore
```

---

## Avancement du projet

### Partie 1 — Modèle MCO & diagnostics

Construction d'un modèle de régression linéaire multiple par la méthode des Moindres Carrés Ordinaires (MCO), visant à expliquer la densité de médecins libéraux à partir de 9 variables explicatives.

**Tests réalisés :**
- Test de normalité des résidus (Shapiro-Wilk, QQ-plot)
- Test d'hétéroscédasticité (Breusch-Pagan, White)
- Test de changement structurel (test de Chow selon la présence d'une université)
- Transformations logarithmiques et quadratiques pour améliorer la spécification

**Résultats clés :** Le modèle retenu explique environ 74 % de la variance de la densité de médecins (R² ≈ 0.74). Les variables les plus significatives sont le taux d'activité, la densité de paramédicaux, la présence d'une université et la part de pharmacies.

---

### Partie 2 — Endogénéité & Variables Instrumentales *(en cours)*

Deux variables sont suspectées d'endogénéité pour des raisons économiques :

- **`DENS_INF`** 
- **`DENS_KIN`** 

simultanéité : médecins et paramédicaux s'installent selon les mêmes logiques territoriales, générant une corrélation avec le terme d'erreur.

**Approche retenue :**
- Test de Hausman (régression augmentée) pour confirmer l'endogénéité
- Estimation par Variables Instrumentales — Moindres Carrés en Deux Étapes (2SLS) via `ivreg()`
- Test des instruments faibles (F-stat > 10, règle de Stock & Yogo)
- Test de Sargan pour valider l'exogénéité des instruments (condition de sur-identification)

---

### 📋 Partie 3 — Multicolinéarité *(à venir)*

Détection et traitement des problèmes de multicolinéarité entre variables explicatives.

**Approche prévue :**
- Matrice de corrélations et heatmap
- Calcul des Variance Inflation Factors (VIF)
- Régression ridge comme alternative aux MCO en cas de multicolinéarité sévère


---

## Prérequis

R ≥ 4.0 avec les packages suivants :

```r
install.packages(c(
  "AER",        # Variables instrumentales (ivreg)
  "lmtest",     # Tests économétriques
  "sandwich",   # Erreurs robustes
  "car",        # VIF, tests linéaires
  "DoubleML",   # Double Machine Learning
  "rmdformats", # Format du rapport R Markdown
  "ggplot2",    # Visualisations
  "dplyr",      # Manipulation des données
  "stargazer"   # Tableaux de résultats
))
```

---

## Bibliographie

- Legendre, B. (2020). *En 2018, les territoires sous-dotés en médecins généralistes concernent près de 6 % de la population.* DREES, Études & Résultats n°1144.
- Delattre, E. & Samson, A.-L. (2013). *Stratégies de localisation des médecins généralistes français : mécanismes économiques ou hédonistes ?* HAL.
- Vergier, N. & Chaput, H. (2017). *Déserts médicaux : comment les définir ? Comment les mesurer ?* Dossiers DREES, n°17.
- Dumontet, M. (2015). *Féminisation, activité libérale et lieu d'installation : quels enjeux en médecine générale ?* Université Paris Dauphine.