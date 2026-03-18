# Analyse Économétrique de la Densité de Médecins Libéraux en France

**Master 1 MAS — Université de Rennes**  

## Présentation

Ce projet analyse les déterminants socio-économiques et structurels de la densité de médecins généralistes libéraux dans les zones d'emploi françaises, à travers plusieurs méthodes économétriques avancées.

## Problématique

*Quels facteurs expliquent la densité de médecins généralistes libéraux par zones d'emploi ?*

## Méthodes

- **Partie 1** — Régression MCO & diagnostics du modèle (hétéroscédasticité, normalité, test de Chow)
- **Partie 2** — Endogénéité & variables instrumentales
- **Partie 3** — Multicolinéarité 
- **Partie 4** — Double Machine Learning 

## Variables principales

| Variable | Description |
| `DENS_MED_LIB` | Densité de médecins libéraux *(variable dépendante)* |
| `DENSITE` | Densité de population |
| `PART_75` | Part des 75 ans et plus |
| `TAUX_ACTIV` | Taux d'activité |
| `PART_IMPOT` | Part des foyers imposables |
| `UNIV` | Présence d'une université |
| `DENS_INF` | Densité d'infirmiers |
| `DENS_KIN` | Densité de kinésithérapeutes |
| `PART_PHARMA` | Part de pharmacies |
| `PART_TRANS_COMM` | Part des transports en commun |

## Sources des données

- [INSEE — Statistiques locales](https://statistiques-locales.insee.fr/)
- [Eurostat](https://ec.europa.eu/eurostat/fr/web/main/data)


## Structure du projet

.
├── Projet.Rmd        # Rapport principal (R Markdown)
├── data/             # Données sources
├── README.md
└── .gitignore
