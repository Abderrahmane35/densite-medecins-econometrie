# ============================================================================
# 01_graphiques_descriptifs.R
# Figures descriptives et de diagnostic du rapport.
#
# Ces fonctions remplacent les graphiques base R du premier jet :
#   - histogramme de DENS_MED_LIB, redessiné avec densité et moyenne
#   - panel comparatif des distributions standardisées (remplace des boxplots
#     isolés, non comparables entre eux)
#   - nuages de points en échelle log uniquement (la version utile au modèle)
#   - matrice de corrélation via ggcorrplot (remplace corrplot)
#   - panel 2x2 de diagnostic des résidus via patchwork (remplace qqnorm,
#     plot(model, which = 4/5) et plot(fitted, residuals))
#   - barres de comparaison des R² entre spécifications
# ============================================================================

library(ggplot2)
library(dplyr)
library(patchwork)
source("R/00_theme_palette.R")

# ---- 1. Histogramme de la densité de médecins -----------------------------
# Gardé : c'est la variable expliquée, sa distribution doit ouvrir le rapport.
# Amélioration : densité + ligne de moyenne + suppression du remplissage vert
# "par défaut".

fig_histogramme_densite <- function(data) {
  moyenne <- mean(data$DENS_MED_LIB, na.rm = TRUE)

  ggplot(data, aes(x = DENS_MED_LIB)) +
    geom_histogram(aes(y = after_stat(density)), bins = 24,
                    fill = pal$primaire, color = pal$fond, linewidth = 0.2) +
    geom_density(color = pal$accent, linewidth = 0.8) +
    geom_vline(xintercept = moyenne, color = pal$accent, linetype = "dashed",
               linewidth = 0.5) +
    annotate("text", x = moyenne, y = Inf, label = paste0("Moyenne : ", round(moyenne, 1)),
             color = pal$accent, vjust = 1.6, hjust = -0.05, size = 3, family = .font_base) +
    labs(
      title = "Une densité médicale relativement homogène sur le territoire",
      subtitle = "Distribution de la densité de médecins généralistes libéraux par zone d'emploi, 2024",
      x = "Densité de médecins libéraux (pour 10 000 habitants)",
      y = "Densité (échelle de probabilité)",
      caption = source_caption("CartoSanté, 2024")
    ) +
    theme_zones_emploi(grid = "y")
}

# ---- 2. Panel comparatif des distributions (remplace les 2 boxplots isolés)
# Un boxplot isolé ne permet aucune comparaison ; on standardise (z-score)
# les variables explicatives clés et on les affiche sur une même échelle,
# ce qui montre d'un coup d'oeil quelles variables sont les plus dispersées /
# asymétriques (utile pour justifier les transformations log qui suivent).

fig_distributions_comparees <- function(data,
                                         vars = c("PART_TRANS_COMM", "PART_IMPOT",
                                                   "PART_75", "TAUX_ACTIV", "PART_PHARMA")) {
  data_std <- data |>
    transmute(across(all_of(vars), ~ as.numeric(scale(.x)))) |>
    tidyr::pivot_longer(everything(), names_to = "variable", values_to = "z")

  ggplot(data_std, aes(x = reorder(variable, z, FUN = function(x) IQR(x, na.rm = TRUE)),
                        y = z)) +
    geom_hline(yintercept = 0, color = pal$grille, linewidth = 0.4) +
    geom_boxplot(width = 0.45, fill = pal$secondaire, color = pal$primaire,
                 outlier.color = pal$accent, outlier.size = 1.4, outlier.alpha = 0.7) +
    coord_flip() +
    labs(
      title = "Des variables explicatives inégalement dispersées",
      subtitle = "Distributions standardisées (z-scores), classées par dispersion croissante",
      x = NULL, y = "Écart-type par rapport à la moyenne",
      caption = source_caption("Insee, CartoSanté")
    ) +
    theme_zones_emploi(grid = "x")
}

# ---- 3. Corrélation (remplace corrplot base R) -----------------------------

fig_correlation <- function(data) {
  vars_num <- data |> select(where(is.numeric))
  corr_mat <- cor(vars_num, use = "complete.obs")

  ggcorrplot::ggcorrplot(
    corr_mat, type = "upper", lab = TRUE, lab_size = 2.8,
    colors = c(pal$accent, "#F5F3F0", pal$primaire),
    outline.color = pal$fond, hc.order = TRUE
  ) +
    labs(title = "Matrice de corrélation des variables explicatives",
         subtitle = "Coefficients de Pearson — aucune paire n'excède |0,8|",
         caption = source_caption("Insee, CartoSanté")) +
    theme_zones_emploi(grid = "none") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# ---- 4. Nuages de points (log uniquement, panel à 2) -----------------------

fig_nuages_log <- function(data) {
  g1 <- ggplot(data, aes(x = log(PART_75), y = DENS_MED_LIB)) +
    geom_point(color = pal$secondaire, size = 1.6, alpha = 0.75) +
    geom_smooth(method = "lm", color = pal$accent, fill = pal$secondaire,
                linewidth = 0.7, alpha = 0.25) +
    labs(x = "log(Part des 75 ans ou plus)", y = "Densité de médecins libéraux") +
    theme_zones_emploi(grid = "both")

  g2 <- ggplot(data, aes(x = log(PART_IMPOT), y = DENS_MED_LIB)) +
    geom_point(color = pal$secondaire, size = 1.6, alpha = 0.75) +
    geom_smooth(method = "lm", color = pal$accent, fill = pal$secondaire,
                linewidth = 0.7, alpha = 0.25) +
    labs(x = "log(Part des ménages imposables)", y = NULL) +
    theme_zones_emploi(grid = "both")

  (g1 | g2) +
    plot_annotation(
      title = "Relations linéarisées avec la variable expliquée",
      subtitle = "Transformation logarithmique retenue dans le modèle de référence",
      caption = source_caption("Insee, CartoSanté"),
      theme = theme_zones_emploi()
    )
}

# ---- 5. Panel de diagnostic des résidus (remplace 4 plots base R) ----------

fig_diagnostic_residus <- function(model) {
  df <- data.frame(
    fitted    = fitted(model),
    residuals = residuals(model),
    std_resid = rstandard(model),
    cook      = cooks.distance(model)
  )
  df$obs <- seq_len(nrow(df))

  # a) résidus vs valeurs ajustées
  g1 <- ggplot(df, aes(fitted, residuals)) +
    geom_hline(yintercept = 0, color = pal$accent, linewidth = 0.5) +
    geom_point(color = pal$primaire, alpha = 0.6, size = 1.3) +
    geom_smooth(se = FALSE, color = pal$accent, linewidth = 0.5, method = "loess") +
    labs(title = "Résidus vs. valeurs ajustées", x = "Valeurs ajustées", y = "Résidus") +
    theme_zones_emploi(grid = "both")

  # b) QQ-plot
  g2 <- ggplot(df, aes(sample = std_resid)) +
    stat_qq(color = pal$primaire, alpha = 0.6, size = 1.3) +
    stat_qq_line(color = pal$accent, linewidth = 0.6) +
    labs(title = "QQ-plot des résidus", x = "Quantiles théoriques", y = "Quantiles observés") +
    theme_zones_emploi(grid = "both")

  # c) échelle-localisation (homoscédasticité)
  g3 <- ggplot(df, aes(fitted, sqrt(abs(std_resid)))) +
    geom_point(color = pal$primaire, alpha = 0.6, size = 1.3) +
    geom_smooth(se = FALSE, color = pal$accent, linewidth = 0.5, method = "loess") +
    labs(title = "Échelle-Localisation", x = "Valeurs ajustées",
         y = expression(sqrt("|Résidus standardisés|"))) +
    theme_zones_emploi(grid = "both")

  # d) distance de Cook
  seuil <- 4 / nrow(df)
  g4 <- ggplot(df, aes(obs, cook)) +
    geom_hline(yintercept = seuil, color = pal$accent, linetype = "dashed", linewidth = 0.5) +
    geom_segment(aes(xend = obs, yend = 0), color = pal$secondaire, linewidth = 0.3) +
    geom_point(color = pal$primaire, size = 1.2) +
    labs(title = "Distance de Cook", x = "Zone d'emploi (index)", y = "Distance de Cook") +
    theme_zones_emploi(grid = "y")

  (g1 | g2) / (g3 | g4) +
    plot_annotation(
      title = "Diagnostic des résidus du modèle retenu",
      caption = source_caption("Calculs des auteurs"),
      theme = theme_zones_emploi()
    )
}

# ---- 6. Comparaison des R² entre spécifications (nouveau, complète le tableau)

fig_comparaison_r2 <- function(r2 = c("1. Base" = 0.7411,
                                       "2. Log(PART_75, PART_IMPOT)" = 0.7419,
                                       "3. + quadratique pharma" = 0.7417,
                                       "4. + interactions" = 0.7238)) {
  df <- data.frame(
    modele = factor(names(r2), levels = names(r2)),
    r2 = as.numeric(r2)
  )
  df$meilleur <- df$r2 == max(df$r2)

  ggplot(df, aes(x = modele, y = r2, fill = meilleur)) +
    geom_col(width = 0.55) +
    scale_fill_manual(values = c("FALSE" = pal$secondaire, "TRUE" = pal$accent),
                      guide = "none") +
    geom_text(aes(label = scales::number(r2, accuracy = 0.001)),
              vjust = -0.6, color = pal$primaire, size = 3.4, family = .font_base) +
    coord_cartesian(ylim = c(0.7, 0.75)) +
    labs(
      title = "Un gain d'ajustement marginal au-delà du modèle log",
      subtitle = "R² selon la spécification retenue",
      x = NULL, y = expression(R^2)
    ) +
    theme_zones_emploi(grid = "y") +
    theme(axis.text.x = element_text(angle = 20, hjust = 1))
}
