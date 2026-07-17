#' Path to the Shelby Level logo SVG
#'
#' @export
logo_path <- function() {
  path <- system.file("img", "sl-logo.svg", package = "slbrand")
  if (identical(path, "")) {
    cli::cli_abort(c(
      "Could not find {.file sl-logo.svg} in the installed package.",
      "i" = "Try reinstalling {.pkg slbrand}."
    ))
  }
  path
}

#' Shelby Level logo as a navbar nav_item, linked to the brand site
#'
#' Pass to `page_navbar(nav_item = logo_nav_item())`. Pair with
#' [logo_header()] so the logo's cutout rectangle matches the navbar
#' background in both light and dark mode.
#'
#' @param href URL the logo links to. Defaults to the `meta.link` value
#'   in `_brand.yml`.
#'
#' @export
logo_nav_item <- function(href = read_brand()$meta$link) {
  svg_lines <- suppressWarnings(readLines(logo_path()))
  svg_html <- htmltools::HTML(paste(svg_lines, collapse = "\n"))

  bslib::nav_item(
    htmltools::tags$a(
      href = href,
      target = "_blank",
      rel = "noopener noreferrer",
      style = "text-decoration: none; display: inline-block;",
      svg_html
    )
  )
}

#' Header script that keeps the logo cutout matched to the navbar color
#'
#' Pass to `page_navbar(header = logo_header())`.
#'
#' @export
logo_header <- function() {
  htmltools::tags$head(
    htmltools::tags$script(htmltools::HTML(
      "
      function updateLogoRectColor() {
        const navbar = document.querySelector('.navbar');
        const rect = document.querySelector('#logo-svg rect');
        if (navbar && rect) {
          rect.setAttribute('fill', getComputedStyle(navbar).backgroundColor);
        }
      }
      document.addEventListener('DOMContentLoaded', updateLogoRectColor);
      $(document).on('shiny:inputchanged', function(event) {
        setTimeout(updateLogoRectColor, 50);
      });
    "
    ))
  )
}
