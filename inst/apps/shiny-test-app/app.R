library(shiny)
library(bslib)
library(slbrand)

ui <- page_navbar(
  title = "Logo Test",
  theme = theme_sl(),
  nav_panel("Home", "Placeholder tab"),
  nav_panel("About", "Placeholder tab"),
  nav_panel("Data", "Placeholder tab"),
  nav_spacer(),
  logo_nav_item(),
  header = logo_header(),
  sidebar = NULL
)

server <- function(input, output, session) {}

shinyApp(ui, server)
