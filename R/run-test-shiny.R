#' Launch the bundled logo/branding test Shiny app
#'
#' Opens a minimal Shiny app for manually checking the brand logo across
#' browsers: vertical alignment, hover animation, and dark/light rect-color
#' matching. Not an automated test — check by eye in each browser you
#' care about (Safari and Arc/Chromium, at minimum, given past
#' cross-browser rendering differences).
#'
#' @export
run_shiny_test_app <- function() {
  app_dir <- system.file("apps", "shiny-test-app", package = "slbrand")
  if (identical(app_dir, "")) {
    cli::cli_abort(
      "Could not find the bundled test app. Try reinstalling {.pkg slbrand}."
    )
  }
  shiny::runApp(app_dir)
}
