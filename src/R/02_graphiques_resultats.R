# ============================================================================
# 02_graphiques_resultats.R
# Figures nouvelles, à forte valeur ajoutée narrative.
# ============================================================================

library(ggplot2)
library(dplyr)
source("R/00_theme_palette.R")

# ---- 1. Coefficient plot (figure centrale) ---------------------------------
# Coefficients estimés du modèle, classés par ampleur absolue, avec IC à 95 %.
# Couleur selon le signe (positif / négatif) ; gris pour les coefficients non
# significatifs au seuil de 5 %.

fig_coefficients <- function(model, titre = "Déterminants de la densité de médecins libéraux",
                              sous_titre = "Coefficients estimés, intervalles de confiance à 95 %") {

  tidy_mod <- broom::tidy(model, conf.int = TRUE) |>
    filter(term != "(Intercept)") |>
    mutate(
      signif = p.value < 0.05,
      sens   = case_when(
        !signif           ~ "Non significatif",
        estimate > 0      ~ "Effet positif",
        TRUE              ~ "Effet négatif"
      ),
      sens = factor(sens, levels = c("Effet positif", "Effet négatif", "Non significatif")),
      term = reorder(term, abs(estimate))
    )

  ggplot(tidy_mod, aes(x = estimate, y = term, color = sens)) +
    geom_vline(xintercept = 0, color = pal$texte, linewidth = 0.35) +
    geom_errorbar(aes(xmin = conf.low, xmax = conf.high), orientation = "y",
                  width = 0.18, linewidth = 0.6) +
    geom_point(size = 2.4) +
    scale_color_manual(values = c(
      "Effet positif"     = pal$primaire,
      "Effet négatif"     = pal$accent,
      "Non significatif"  = pal$secondaire
    )) +
    labs(
      title = titre, subtitle = sous_titre,
      x = "Coefficient estimé (± IC 95 %)", y = NULL, color = NULL,
      caption = source_caption("Insee, CartoSanté")
    ) +
    theme_zones_emploi(grid = "x", legend_position = "bottom")
}

# ---- 2. Université vs densité : violon + boxplot (raincloud simplifié) ----
# Nécessite le package `ggdist` pour une vraie "raincloud" (demi-violon +
# points bruts + boxplot fin). Fallback en violin+boxplot classique si
# `ggdist` n'est pas installé.

fig_universite_densite <- function(data) {
  data <- data |>
    mutate(UNIV = factor(UNIV, levels = c("Aucune", "Présente")))

  if (requireNamespace("ggdist", quietly = TRUE)) {
    ggplot(data, aes(x = UNIV, y = DENS_MED_LIB, fill = UNIV, color = UNIV)) +
      ggdist::stat_halfeye(adjust = 0.6, width = 0.55, justification = -0.25,
                            .width = c(0.5, 0.95), alpha = 0.85) +
      geom_boxplot(width = 0.14, outlier.shape = NA, alpha = 0.9,
                   position = position_nudge(x = -0.18)) +
      geom_point(size = 1.1, alpha = 0.5,
                 position = position_jitter(width = 0.05, height = 0, seed = 1)) +
      scale_fill_manual(values = c("Aucune" = pal$secondaire, "Présente" = pal$accent)) +
      scale_color_manual(values = c("Aucune" = pal$primaire, "Présente" = pal$accent)) +
      coord_flip() +
      labs(
        title = "La présence d'une faculté de médecine, un marqueur net",
        subtitle = "Distribution de la densité de médecins libéraux selon la présence d'une université de médecine",
        x = NULL, y = "Densité de médecins libéraux (pour 10 000 hab.)",
        caption = source_caption("CartoSanté, UniFac")
      ) +
      theme_zones_emploi(grid = "x", legend_position = "none")
  } else {
    # Fallback : violin + boxplot superposés, sans dépendance à ggdist
    ggplot(data, aes(x = UNIV, y = DENS_MED_LIB, fill = UNIV)) +
      geom_violin(color = NA, alpha = 0.55, width = 0.9) +
      geom_boxplot(width = 0.16, fill = pal$fond, color = pal$primaire,
                   outlier.color = pal$accent, outlier.size = 1.3) +
      scale_fill_manual(values = c("Aucune" = pal$secondaire, "Présente" = pal$accent)) +
      coord_flip() +
      labs(
        title = "La présence d'une faculté de médecine, un marqueur net",
        subtitle = "Distribution de la densité de médecins libéraux selon la présence d'une université de médecine",
        x = NULL, y = "Densité de médecins libéraux (pour 10 000 hab.)",
        caption = source_caption("CartoSanté, UniFac")
      ) +
      theme_zones_emploi(grid = "x", legend_position = "none")
  }
}

# ---- 3. Top / Bottom territoires -----------------------------------------
# Barres divergentes autour de la moyenne nationale, triées, avec libellés
# de zones. `id_col` est la colonne du nom de zone d'emploi (ZONE ici).

fig_top_bottom_territoires <- function(data, id_col = "ZONE", n = 15) {
  moyenne_nat <- mean(data[[ "DENS_MED_LIB" ]], na.rm = TRUE)

  df <- data |>
    rename(zone = !!id_col) |>
    arrange(desc(DENS_MED_LIB)) |>
    slice(c(1:n, (n() - n + 1):n())) |>
    mutate(
      groupe = if_else(DENS_MED_LIB >= moyenne_nat, "Mieux dotées", "Moins dotées"),
      zone   = reorder(zone, DENS_MED_LIB)
    )

  ggplot(df, aes(x = DENS_MED_LIB - moyenne_nat, y = zone, fill = groupe)) +
    geom_col(width = 0.68) +
    geom_vline(xintercept = 0, color = pal$primaire, linewidth = 0.4) +
    scale_fill_manual(values = c("Mieux dotées" = pal$primaire, "Moins dotées" = pal$accent)) +
    labs(
      title = paste0("Les ", n, " zones d'emploi les mieux et les moins dotées"),
      subtitle = paste0("Écart à la densité moyenne nationale (", round(moyenne_nat, 1),
                         " médecins pour 10 000 hab.)"),
      x = "Écart à la moyenne nationale (pour 10 000 hab.)", y = NULL, fill = NULL,
      caption = source_caption("CartoSanté, 2024")
    ) +
    theme_zones_emploi(grid = "x", legend_position = "bottom")
}
