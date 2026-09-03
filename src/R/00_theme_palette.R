# ============================================================================
# 00_theme_palette.R
# Identité visuelle du projet — thème ggplot maison + palette
#
# Esprit : publications INSEE / DREES / Banque de France.
# Le thème n'est PAS theme_minimal()/theme_bw()/theme_classic()/theme_light()
# appelé tel quel : il part du squelette neutre theme_grey() et redéfinit
# explicitement chaque élément (grille, typo, titres, marges) pour obtenir
# un objet propre au projet, distinct des thèmes ggplot par défaut.
# ============================================================================

library(ggplot2)

# ---- 1. Palette --------------------------------------------------------
# Volontairement restreinte : un bleu-gris foncé (structure), un gris clair
# (neutre / non-significatif), une seule couleur d'accent (mise en avant).

pal <- list(
  fond       = "#FFFFFF",
  grille     = "#E4E3E0",   # gris très clair, quasi invisible
  texte      = "#53575C",   # gris chaud, lisible mais discret
  primaire   = "#1F3350",   # bleu-gris foncé — couleur structurante
  secondaire = "#AEB3BA",   # gris clair — catégories neutres / non signif.
  accent     = "#B5502C"    # terracotta — LA seule couleur d'accent
)

# Rampe monochrome pour cartes choroplèthes (du plus clair au primaire)
pal_seq <- grDevices::colorRampPalette(c("#EEF1F5", pal$primaire))

# Rampe divergente sobre (accent <-> blanc <-> primaire), pour résidus /
# signes de coefficients — seulement 2 teintes de part et d'autre du blanc
pal_div <- function(n = 11) {
  grDevices::colorRampPalette(c(pal$accent, "#F5F3F0", pal$primaire))(n)
}

# ---- 2. Police -----------------------------------------------------------
# Pas de dépendance obligatoire à une police externe (portabilité GitHub /
# Rmd -> HTML/PDF). Si `showtext` + une police type "Source Serif Pro" ou
# "Public Sans" est disponible sur la machine, on l'active silencieusement ;
# sinon on retombe sur la police système, sans erreur.

.font_base  <- "sans"
.font_title <- "sans"

if (requireNamespace("showtext", quietly = TRUE) &&
    requireNamespace("sysfonts", quietly = TRUE)) {
  try({
    sysfonts::font_add_google("Source Sans 3", "src_sans")
    sysfonts::font_add_google("Source Serif 4", "src_serif")
    showtext::showtext_auto()
    .font_base  <- "src_sans"
    .font_title <- "src_serif"   # empattements sobres pour les titres = "académique"
  }, silent = TRUE)
}

# ---- 3. Thème --------------------------------------------------------------

theme_zones_emploi <- function(base_size = 11,
                                grid = c("y", "x", "both", "none"),
                                legend_position = "top") {

  grid <- match.arg(grid)

  grid_major_y <- if (grid %in% c("y", "both"))
    element_line(color = pal$grille, linewidth = 0.35) else element_blank()
  grid_major_x <- if (grid %in% c("x", "both"))
    element_line(color = pal$grille, linewidth = 0.35) else element_blank()

  theme_grey(base_size = base_size, base_family = .font_base) %+replace%
    theme(
      # --- fond ---
      plot.background  = element_rect(fill = pal$fond, color = NA),
      panel.background = element_rect(fill = pal$fond, color = NA),
      panel.border     = element_blank(),

      # --- grille : discrète, jamais les deux directions à fond ---
      panel.grid.major.y = grid_major_y,
      panel.grid.major.x = grid_major_x,
      panel.grid.minor    = element_blank(),

      # --- axes ---
      axis.line        = element_line(color = pal$texte, linewidth = 0.3),
      axis.ticks        = element_line(color = pal$texte, linewidth = 0.3),
      axis.ticks.length = unit(3, "pt"),
      axis.text         = element_text(color = pal$texte, size = rel(0.82)),
      axis.title        = element_text(color = pal$primaire, size = rel(0.92),
                                        face = "bold"),
      axis.title.x      = element_text(margin = margin(t = 8)),
      axis.title.y      = element_text(margin = margin(r = 8), angle = 90),

      # --- titres hiérarchisés ---
      plot.title    = element_text(family = .font_title, color = pal$primaire,
                                    face = "bold", size = rel(1.35), hjust = 0,
                                    margin = margin(b = 4)),
      plot.subtitle = element_text(color = pal$texte, size = rel(1.02),
                                    hjust = 0, margin = margin(b = 12)),
      plot.caption  = element_text(color = pal$texte, size = rel(0.68),
                                    hjust = 1, margin = margin(t = 10),
                                    face = "italic"),
      plot.caption.position = "plot",
      plot.title.position   = "plot",

      # --- légende : discrète, sans cadre ---
      legend.position   = legend_position,
      legend.background = element_blank(),
      legend.key        = element_blank(),
      legend.title      = element_text(color = pal$primaire, face = "bold",
                                        size = rel(0.85)),
      legend.text       = element_text(color = pal$texte, size = rel(0.8)),

      # --- facettes ---
      strip.background = element_rect(fill = pal$grille, color = NA),
      strip.text        = element_text(color = pal$primaire, face = "bold",
                                        size = rel(0.85), margin = margin(4,4,4,4)),

      plot.margin = margin(14, 18, 10, 12)
    )
}

# Thème dédié aux cartes (pas d'axes, pas de grille)
theme_carte_zones_emploi <- function(base_size = 11) {
  theme_zones_emploi(base_size = base_size, grid = "none", legend_position = "right") %+replace%
    theme(
      axis.line   = element_blank(),
      axis.ticks  = element_blank(),
      axis.text   = element_blank(),
      axis.title  = element_blank(),
      panel.grid  = element_blank()
    )
}

# ---- 4. Scales pratiques --------------------------------------------------

scale_color_zones_emploi <- function(...) {
  ggplot2::scale_color_manual(values = c(pal$primaire, pal$accent, pal$secondaire), ...)
}
scale_fill_zones_emploi <- function(...) {
  ggplot2::scale_fill_manual(values = c(pal$primaire, pal$accent, pal$secondaire), ...)
}

# Source standard à mettre en bas de chaque figure
source_caption <- function(txt) {
  paste0("Source : ", txt, ". Calculs des auteurs.")
}
