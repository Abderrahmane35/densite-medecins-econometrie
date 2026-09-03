# Déserts médicaux : les facteurs explicatifs de la densité de médecins libéraux en France

**Modélisation économétrique (MCO) de la densité de médecins généralistes libéraux sur les 306 zones d'emploi françaises.** Projet réalisé dans le cadre du Master 1 MAS à l'Université de Rennes 1.

------------------------------------------------------------------------

## En une phrase

Quels facteurs démographiques, économiques et structurels expliquent que certains territoires attirent des médecins généralistes libéraux et d'autres non ? Ce projet construit, estime et valide un modèle de régression linéaire multiple sur données Insee / CartoSanté, avec un traitement complet de la robustesse (résidus, hétéroscédasticité, multicolinéarité, points influents).

## Résultats en image

|  |  |
|-----------------------------------------|---------------------------------------|
| \*\*Déterminants du modèle\*\* Coefficients standardisés et significativité, variable par variable. ![Coefficients du modèle](src/figures/coefficients.png){width="388"} | \*\*Un effet université significatif\*\* Distribution de la densité médicale selon la présence d'une faculté de médecine. ![](images/clipboard-2984750214.png){width="368"} |
| \*\*Une offre très contrastée sur le territoire\*\* Densité de médecins libéraux par zone d'emploi, France entière. ![Carte de densité](src/figures/histogramme_densite.png){width="456"} | \*\*Un modèle ajusté\*\*
Panel de diagnostic des résidus (homoscédasticité, normalité, points influents)![Top / Bottom territoires](src/figures/diagnostic_residus.png) |

## Ce que montre l'analyse

-   Le **dynamisme économique** du territoire (taux d'activité, part des ménages imposables) est associé positivement à la densité de médecins.

-   La **présence d'une faculté de médecine** dans la zone d'emploi est le déterminant le plus net : +2 points de densité en moyenne, variance plus faible.

-   L'effet de la **structure démographique** (part des 75 ans et plus) devient significatif après transformation logarithmique, ce qui améliore la linéarité de la relation.

-   Un **test de Chow** ne détecte pas de rupture structurelle selon la présence d'une université :les mêmes déterminants opèrent partout, avec une intensité différente.

## Méthodologie

| Étape | Traitement |
|------------------|------------------------------------------------------|
| Données | 306 zones d'emploi françaises, Insee (2021-2022) + CartoSanté (2024) + UniFac |
| Nettoyage | Suppression des individus à valeurs manquantes |
| Modèle de référence | MCO, 9 variables explicatives |
| Spécification retenue | Transformations logarithmiques (PART_75, PART_IMPOT), R² = 0,742 après retrait des points influents |
| Validation | Test de moyenne nulle des résidus, Shapiro-Wilk, Breusch-Pagan, distance de Cook, VIF, règle de Klein, cohérence des signes |
| Robustesse | Comparaison MCO / MCG, test de Chow (rupture structurelle), régression PCR (colinéarité parfaite DENS_PARA) |

## Structure du dépôt

```         
.
├── data/
│   └── medecins.csv               # données sources (Insee, CartoSanté, UniFac)
├── R/
│   ├── 00_theme_palette.R         # thème ggplot + palette du projet
│   ├── 01_graphiques_descriptifs.R
│   ├── 02_graphiques_resultats.R
│   ├── 03_cartes.R                # cartographie des zones d'emploi
├── projet_econometrie.Rmd         # rapport complet, reproductible
└── README.md
```

## Reproduire l'analyse

``` bash
git clone https://github.com/<votre-utilisateur>/<nom-du-repo>.git
cd <nom-du-repo>
```

``` r
install.packages(c("dplyr", "ggplot2", "gridExtra", "viridis", "ellipse",
                    "GGally", "lmtest", "corrplot", "car", "knitr",
                    "stargazer", "ggcorrplot", "patchwork", "broom",
                    "sf", "ggdist", "pls"))

rmarkdown::render("projet_econometrie.Rmd")
```

Le fond de carte des zones d'emploi (Insee, 2020) doit être téléchargé séparément sur <https://www.insee.fr/fr/information/4652957>

## Stack technique

R · ggplot2 · dplyr · sf (cartographie) · patchwork · broom · lmtest / car (diagnostics économétriques) · pls (régression sur composantes principales) · R Markdown

## Sources

Insee (Statistiques Locales, zones d'emploi 2020) · CartoSanté (AtlaSanté) · UniFac

## Contact :

abderrahmane.mamoun\@univ-rennes.fr · [LinkedIn](https://www.linkedin.com/in/abderrahmane-mamoun-4183a6214/)
