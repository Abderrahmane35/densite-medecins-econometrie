library(sf)
library(ggplot2)
library(dplyr)
library(stringi)
source("R/00_theme_palette.R")

charger_fond_carte <- function(
    chemin = "../data/geo/fonds_ze2020_2026/ze2020_2026/ze2020_2026.shp"
) {
  
  fond <- sf::st_read(chemin, quiet = TRUE) |>
    sf::st_transform(2154)
  
  fond |>
    sf::st_simplify(dTolerance = 200)
}


# ---- 1. Carte : densité de médecins libéraux ------------------

carte_densite_medecins <- function(fond_carte, data) {
  
  fond_carte$ZONE_STD <- fond_carte$libze2020 |>
    stringi::stri_trans_general("Latin-ASCII") |>
    toupper()
  
  data$ZONE_STD <- data$ZONE |>
    stringi::stri_trans_general("Latin-ASCII") |>
    toupper()
  
  carte <- left_join(
    fond_carte,
    data,
    by = "ZONE_STD"
  )
  
  ggplot(carte) +
    geom_sf(aes(fill = DENS_MED_LIB),
            color = pal$fond,
            linewidth = 0.05) +
    scale_fill_gradientn(
      colors = pal_seq(7),
      name = "Médecins\n/ 10 000 hab.",
      na.value = pal$grille
    ) +
    labs(
      title = "Une offre médicale libérale contrastée sur le territoire",
      subtitle = "Densité de médecins généralistes libéraux par zone d'emploi, 2024",
      caption = source_caption(
        "CartoSanté, fond de carte Insee — zones d'emploi 2020"
      )
    ) +
    coord_sf(
      xlim = c(0, 1300000),
      ylim = c(6000000, 7200000)
    )+
    theme_carte_zones_emploi()
}

# ---- 2. Carte des universités de médecine (superposition) -----------------
# Contours colorés selon la densité (comme ci-dessus), avec un contour épais
# et une seule couleur d'accent pour les zones dotées d'une faculté —
# permet de visualiser directement si les concentrations de médecins
# coïncident avec les pôles universitaires.

carte_universites <- function(fond_carte, data) {
  
  fond_carte$ZONE_STD <- fond_carte$libze2020 |>
    stringi::stri_trans_general("Latin-ASCII") |>
    toupper()
  
  data$ZONE_STD <- data$ZONE |>
    stringi::stri_trans_general("Latin-ASCII") |>
    toupper()
  
  carte <- left_join(
    fond_carte,
    data,
    by = "ZONE_STD"
  )
  
  ggplot(carte) +
    geom_sf(aes(fill = DENS_MED_LIB),
            color = pal$fond,
            linewidth = 0.05) +
    geom_sf(
      data = carte |> filter(UNIV %in% c("Présente", 1, "1")),
      aes(color = "Faculté de médecine présente"),
      fill = NA,
      linewidth = 0.55,
      key_glyph = "path"    # <- glyphe "trait" au lieu du carré par défaut
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
    guides(
      color = guide_legend(override.aes = list(linewidth = 1))
    ) +
    labs(
      title = "Concentration de médecins et présence de facultés de médecine",
      caption = source_caption("CartoSanté, UniFac, fond de carte Insee")
    ) +
    coord_sf(
      xlim = c(0, 1300000),
      ylim = c(6000000, 7200000)
    ) +
    theme_carte_zones_emploi() +
    theme(legend.box = "vertical")   # empile la légende couleur (contour) sous la légende de remplissage
}

