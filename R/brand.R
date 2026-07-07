#' Path to the Shelby Level `_brand.yml` file
#'
#' Returns the installed path to the package's bundled `_brand.yml`, so it
#' can be passed to [bslib::bs_theme()] from any Shiny app without copying
#' the file into every project.
#'
#' @return A file path (character string).
#' @export
#'
#' @examples
#' brand_path()
brand_path <- function() {
  path <- system.file("_brand.yml", package = "slbrand")
  if (identical(path, "")) {
    cli::cli_abort(c(
      "Could not find {.file _brand.yml} in the installed package.",
      "i" = "Try reinstalling {.pkg slbrand}."
    ))
  }
  path
}

#' Read the Shelby Level brand.yml as a list
#'
#' Convenience wrapper around [yaml::read_yaml()] for cases where you need
#' the raw color/typography values directly (e.g. for `ggplot2`, `gt`, or
#' `reactable` styling) rather than a `bslib` theme object.
#'
#' @return A nested list parsed from `_brand.yml`.
#' @export
#'
#' @examples
#' brand <- read_brand()
#' brand$color$primary
read_brand <- function() {
  yaml::read_yaml(brand_path())
}

#' Build a `bslib` theme from the Shelby Level brand
#'
#' Drop-in replacement for `bslib::bs_theme(brand = "_brand.yml")` that
#' points at the package's bundled brand file instead of a local copy.
#' Pass this to the `theme` argument of any `bslib` page function
#' (`page_sidebar()`, `page_navbar()`, `fluidPage()`, etc.).
#'
#' @param ... Additional arguments passed to [bslib::bs_theme()], letting
#'   you override or extend brand defaults per-app if needed (e.g. a
#'   one-off `bg`/`fg` tweak for a specific dashboard).
#'
#' @return A `bs_theme` object.
#' @export
#'
#' @examples
#' \dontrun{
#' library(bslib)
#' ui <- page_sidebar(
#'   title = "Hockey R Learning Hub",
#'   theme = theme_sl(),
#'   sidebar = sidebar("..."),
#'   "..."
#' )
#' }
theme_sl <- function(...) {
  bslib::bs_theme(brand = brand_path(), ...)
}

#' Apply Shelby Level brand colors/fonts to plots via `thematic`
#'
#' Wraps [thematic::thematic_shiny()] so `ggplot2` plots rendered inside a
#' Shiny app automatically pick up brand colors and fonts, without hardcoding
#' hex values in every plotting function.
#'
#' Call this once near the top of `app.R`, alongside [theme_sl()].
#'
#' @param font Passed to `thematic::thematic_shiny(font = ...)`.
#'   Defaults to `"auto"`.
#' @param ... Additional arguments passed to `thematic::thematic_shiny()`.
#'
#' @return Invisibly returns `NULL`. Called for its side effect.
#' @export
#'
#' @examples
#' \dontrun{
#' use_sl_thematic()
#' }
use_sl_thematic <- function(font = "auto", ...) {
  if (!requireNamespace("thematic", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg thematic} package is required for this function.",
      "i" = "Install it with {.code install.packages('thematic')}."
    ))
  }
  thematic::thematic_shiny(font = font, ...)
  invisible(NULL)
}

#' Named vector of Shelby Level brand colors
#'
#' Combines the raw palette (`deep-jade`, `faded-jade`, etc.) with the
#' semantic color mapping (`primary`, `secondary`, `danger`, etc.) from
#' `_brand.yml` into one flat named character vector, handy for
#' `scale_color_manual()` / `scale_fill_manual()` in `ggplot2`.
#'
#' @param which One of `"palette"`, `"semantic"`, or `"all"` (default).
#'
#' @return A named character vector of hex colors.
#' @export
#'
#' @examples
#' brand_colors("semantic")
brand_colors <- function(which = c("all", "palette", "semantic")) {
  which <- match.arg(which)
  brand <- read_brand()

  palette <- unlist(brand$color$palette)

  semantic_keys <- c(
    "foreground",
    "background",
    "primary",
    "secondary",
    "tertiary",
    "success",
    "info",
    "warning",
    "danger",
    "light",
    "dark"
  )
  semantic <- unlist(brand$color[intersect(semantic_keys, names(brand$color))])

  switch(
    which,
    palette = palette,
    semantic = semantic,
    all = c(palette, semantic)
  )
}
