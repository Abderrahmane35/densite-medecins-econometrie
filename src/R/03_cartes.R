# ============================================================================
# 03_cartes.R
# Cartographie choroplèthe des zones d'emploi (France métropolitaine).
# ============================================================================

library(ggplot2)
library(dplyr)
source("R/00_theme_palette.R")

chemin_fond_defaut <- "../data/geo/fonds_ze2020_2026/ze2020_2026/ze2020_2026.shp"

charger_fond_carte <- function(chemin = chemin_fond_defaut) {
  if (!file.exists(chemin)) {
    stop("Fond de carte introuvable : ", chemin,
         "\nVoir la section Installation du README.", call. = FALSE)
  }

  sf::st_read(chemin, quiet = TRUE) |>
    sf::st_transform(2154) |>
    sf::st_simplify(dTolerance = 200)
}

# Normalise un libellé de zone d'emploi pour la jointure (ASCII, majuscules).
normaliser_zone <- function(x) {
  toupper(stringi::stri_trans_general(x, "Latin-ASCII"))
}

# Jointure du fond de carte avec les données de l'analyse.
joindre_donnees <- function(fond_carte, data) {
  fond_carte$ZONE_STD <- normaliser_zone(fond_carte$libze2020)
  data$ZONE_STD <- normaliser_zone(data$ZONE)
  left_join(fond_carte, data, by = "ZONE_STD")
}

cadre_metropole <- coord_sf(xlim = c(0, 1300000), ylim = c(6000000, 7200000))

# ---- 1. Carte : densité de médecins libéraux -----------------------------

carte_densite_medecins <- function(fond_carte, data) {
  carte <- joindre_donnees(fond_carte, data)

  ggplot(carte) +
    geom_sf(aes(fill = DENS_MED_LIB), color = pal$fond, linewidth = 0.05) +
    scale_fill_gradientn(
      colors = pal_seq(7),
      name = "Médecins\n/ 10 000 hab.",
      na.value = pal$grille
    ) +
    labs(
      title = "Une offre médicale libérale contrastée sur le territoire",
      subtitle = "Densité de médecins généralistes libéraux par zone d'emploi, 2024",
      caption = source_caption("CartoSanté, fond de carte Insee, zones d'emploi 2020")
    ) +
    cadre_metropole +
    theme_carte_zones_emploi()
}

# ---- 2. Carte des universités de médecine (superposition) ----------------
# Même choroplèthe, avec le contour en accent des zones dotées d'une faculté :
# permet de voir si les concentrations de médecins coïncident avec les pôles
# universitaires.

carte_universites <- function(fond_carte, data) {
  carte <- joindre_donnees(fond_carte, data)

  ggplot(carte) +
    geom_sf(aes(fill = DENS_MED_LIB), color = pal$fond, linewidth = 0.05) +
    geom_sf(
      data = filter(carte, UNIV == "Présente"),
      aes(color = "Faculté de médecine présente"),
      fill = NA, linewidth = 0.55, key_glyph = "path"
    ) +
    scale_fill_gradientn(
      colors = pal_seq(7),
      name = "Médecins\n/ 10 000 hab.",
      na.value = pal$grille
    ) +
    scale_color_manual(
      name = NULL,
      values = c("Faculté de médecine présente" = pal$accent)
    ) +
    guides(color = guide_legend(override.aes = list(linewidth = 1))) +
    labs(
      title = "Concentration de médecins et présence de facultés de médecine",
      caption = source_caption("CartoSanté, UniFac, fond de carte Insee")
    ) +
    cadre_metropole +
    theme_carte_zones_emploi() +
    theme(legend.box = "vertical")
}
