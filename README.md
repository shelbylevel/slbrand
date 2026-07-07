# slbrand

Centralized `_brand.yml` + helper functions for applying consistent Shelby
Level branding across every Shiny dashboard (`hockeyHub`, the Lyme/climate
dashboard, etc.) from one source of truth, instead of copying `_brand.yml`
into each app repo separately.

## Install

Locally, from the package source directory:

```r
devtools::install("path/to/slbrand")
```

Or, once you push this to GitHub:

```r
remotes::install_github("shelbylevel/slbrand")
```

Whichever route you use, add `slbrand` to each dashboard's
`DESCRIPTION`/`renv.lock` so it gets bundled when you deploy to
shinyapps.io — it needs to be an installed dependency at deploy time, not
just present on your machine.

## Usage in a Shiny app

```r
library(bslib)
library(slbrand)

ui <- page_sidebar(
  title = "Dashboard Title",
  theme = theme_sl(),
  sidebar = sidebar(...),
  ...
)
```

`theme_sl()` is a drop-in wrapper around
`bslib::bs_theme(brand = "_brand.yml")` that points at the package's
installed copy of the file rather than a local one. Pass extra arguments
straight through if a specific dashboard needs a one-off override:

```r
theme = theme_sl(bg = "#ffffff")
```

## Matching your ggplot2 plots to the brand

```r
library(slbrand)

use_sl_thematic()  # call once, near the top of app.R
```

After that, `ggplot2` plots rendered inside the app inherit brand colors
and fonts automatically. For static plots (outside Shiny) or manual scales,
pull colors directly:

```r
brand_colors("semantic")
#>   foreground   background      primary    secondary ...
#>    "#000000"    "#ffffff"    "#45767a"    "#7fa6ad" ...

ggplot(df, aes(x, y, color = group)) +
  geom_line() +
  scale_color_manual(values = brand_colors("palette"))
```

## Using the same file in Quarto

`bslib`/Shiny and Quarto both just read a `_brand.yml` file directly (not
through each other). To reuse this same brand in a Quarto project, copy
`inst/_brand.yml` from this package into the Quarto project root (or point
`_quarto.yml` at it):

```yaml
format:
  html:
    theme: _brand.yml
```

## Updating the brand

Edit `inst/_brand.yml`, bump `Version` in `DESCRIPTION`, reinstall, and
redeploy each dashboard — no manual file-syncing across repos.

## Functions

| Function | Purpose |
|---|---|
| `theme_sl()` | Build a `bs_theme()` for a Shiny page function |
| `use_sl_thematic()` | Auto-theme ggplot2 plots inside Shiny |
| `brand_colors()` | Named vector of hex colors (palette/semantic/all) |
| `read_brand()` | Raw parsed `_brand.yml` as a list |
| `brand_path()` | File path to the installed `_brand.yml` |
