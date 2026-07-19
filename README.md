# slbrand

Centralized `_brand.yml` + helper functions for applying consistent Shelby
Level branding across every Shiny dashboard and Quarto output, from one source of truth — instead of copying brand files into each repo
separately.

## Install

This package depends on the `brand.yml` package (used internally by
`bslib` to parse `_brand.yml`). If a plain `install.packages("brand.yml")`
doesn't find it on your CRAN mirror, install from Posit's r-universe:

```r
install.packages(
  "brand.yml",
  repos = c("https://posit-dev.r-universe.dev", "https://cloud.r-project.org")
)
```

Then install `slbrand` itself from GitHub:

```r
remotes::install_github("shelbylevel/slbrand")
```

Add `slbrand` to each dashboard's `DESCRIPTION`/`renv.lock` so it gets
bundled when you deploy to shinyapps.io — it needs to be an installed
dependency at deploy time, not just present on your machine.

## Usage in a Shiny app

```r
library(bslib)
library(slbrand)

ui <- page_sidebar(
  title = "Dashboard Title",
  theme = theme_sl(),
  nav_item = logo_nav_item(),
  sidebar = sidebar(...),
  ...
)
```

| Function | Purpose |
|---|---|
| `theme_sl()` | drop-in wrapper around `bslib::bs_theme(brand = "_brand.yml")` pointing at the package's installed copy. Pass extra args through for a one-off override: `theme_sl(bg = "#ffffff")` |
| `logo_nav_item()` | renders the brand SVG logo as a `bslib::nav_item()`, wrapped in a link. Defaults to linking to `meta.link` in `_brand.yml` (currently `https://www.shelbylevel.org`); override with `logo_nav_item(href = "...")` if a specific dashboard needs to link elsewhere |
| `logo_header()` | returns the `tags$head()` script that keeps the logo's cutout rectangle color-matched to the navbar background, including after a dark-mode toggle. Always pair with `logo_nav_item()` |

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

## Usage in the Quarto website

The logo and its accompanying script are also distributed as a **Quarto
extension**, bundled in this same repo under `_extensions/shelbylevel/brand/`.

**Install once, per Quarto project:**

```bash
quarto add shelbylevel/slbrand
```

This installs the extension into that project's own
`_extensions/shelbylevel/brand/` folder. Commit that installed copy to the
project's repo — Quarto extensions are meant to be vendored per-project,
similar to how `renv` vendors an R library.

**Then add one line to that project's `_quarto.yml`**, under your existing
`html:` format block:

```yaml
format:
  html:
    include-in-header:
      - _extensions/shelbylevel/brand/logo-header.html
```

> **Why an explicit reference, not automatic:** Quarto extensions that
> contribute keys under an existing base format (`html`) don't merge
> into your project's plain `html` format automatically — they define a
> *new* derived format (e.g. `brand-html`) that only activates if you
> explicitly opt into it. Rather than rename your project's format and
> re-declare your existing theme/navbar config under it, we reference
> the extension's file directly. You still get centralized updates via
> `quarto update` below — this just skips relying on auto-merge behavior
> that doesn't actually apply here.

The logo SVG and its color-matching/hover-animation script are both
**inlined directly** inside `logo-header.html` (via a hidden `<template>`
tag) rather than fetched as a separate file at render time. This was a
deliberate choice: Quarto extensions can't reliably contribute
project-level static assets (an open Quarto limitation,
[quarto-cli#9515](https://github.com/quarto-dev/quarto-cli/issues/9515)),
so inlining avoids depending on that mechanism entirely.

**When the brand updates:** edit
`_extensions/shelbylevel/brand/logo-header.html` in *this* repo, bump the
extension's `version` in `_extensions/shelbylevel/brand/_extension.yml`,
commit and push. Then, in each Quarto project:

```bash
quarto update shelbylevel/slbrand
quarto render
```

## Updating the R-side brand.yml

Edit `inst/_brand.yml`, bump `Version` in `DESCRIPTION`, reinstall, and
redeploy each dashboard — no manual file-syncing across repos.

```r
devtools::document()
devtools::install()
```

## Repo layout

```
slbrand/
├── DESCRIPTION
├── NAMESPACE
├── LICENSE
├── README.md
├── .Rbuildignore
├── R/
│   ├── brand.R              # theme_sl(), brand_colors(), read_brand()
│   └── logo.R               # logo_nav_item(), logo_header() (Shiny)
├── inst/
│   ├── _brand.yml
│   └── img/
│       └── sl-logo.svg      # source-of-truth SVG for the R/Shiny side
├── tests/
│   └── testthat/
│       └── test-brand.R
└── _extensions/
    └── shelbylevel/
        └── brand/
            ├── _extension.yml
            └── logo-header.html   # SVG inlined here for the Quarto side
```

Note: the SVG currently lives in two places — `inst/img/sl-logo.svg` (read
via `system.file()` for Shiny) and inlined inside
`_extensions/shelbylevel/brand/logo-header.html` (for Quarto). If you
change the logo, update both.

## Functions (R package)

| Function | Purpose |
|---|---|
| `theme_sl()` | Build a `bs_theme()` for a Shiny page function |
| `logo_nav_item()` | Brand logo as a linked `nav_item()` for a Shiny navbar |
| `logo_header()` | Header script keeping the logo cutout matched to navbar color |
| `use_sl_thematic()` | Auto-theme ggplot2 plots inside Shiny |
| `brand_colors()` | Named vector of hex colors (palette/semantic/all) |
| `read_brand()` | Raw parsed `_brand.yml` as a list |
| `brand_path()` | File path to the installed `_brand.yml` |
| `logo_path()` | File path to the installed `sl-logo.svg` |
