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
  header = logo_header(),
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
    theme: _brand.yml
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
change the logo *content* (text, colors, paths), update both. The
`height` set on the `<svg>` tag is an intentional exception — Shiny's
navbar currently uses `45px` and Quarto's uses `50px` to match each
navbar's own proportions. The `viewBox` height also differs: Shiny's 
copy uses `0 0 85 45` (widened from the logo's natural `85 40` to fix 
a vertical-centering bug specific to bslib's flex nav-item layout);
Quarto's copy keeps the original `0 0 85 40` since it never showed that 
bug.There's no need to keep these numbers in sync; only the underlying 
logo geometry/fixes need to match.

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

## Testing slbrand

This package ships with three layers of testing: automated regression
tests, a bundled Shiny test app, and a bundled Quarto test site. This
doc explains what each is for and — importantly — how the Quarto test
site is wired up via symlinks so local edits are testable *before*
pushing to GitHub.

### 1. Automated tests (`tests/testthat/test-logo.R`)

Run with `devtools::test()`. These catch structural regressions —
things that broke silently once already in this project's history and
are easy to reintroduce by accident:

- CSS `letter-spacing` creeping back onto `.logo-text` (the root cause
  of a Safari-vs-Arc rendering mismatch that took many iterations to
  find and fix — see the "Why the logo looks the way it does" section
  below).
- The dead `lengthAdjust: spacing;` CSS declaration (that property only
  exists as an SVG XML attribute, never as CSS — it was mistakenly
  added to a `<style>` block once and silently did nothing).
- `textLength` values or the `viewBox` dimensions changing without
  anyone deciding that on purpose.
- `logo_nav_item()` / `logo_header()` losing expected content.

These are fast, run in CI, and don't require a browser.

### 2. Bundled Shiny test app (`inst/apps/shiny-test-app/`)

Launch with:

```r
slbrand::run_shiny_test_app()
```

A minimal `page_navbar()` app with a few placeholder tabs, so the logo
renders as a real flex sibling among other nav items — this matters
because layout bugs (like the vertical-centering issue below) only
show up when the logo sits alongside real tabs, not in isolation.

**What to check by eye, in both Safari and Arc/Chrome:**
- Logo is vertically centered relative to the tab labels
- Hovering the logo plays the underline animation
- Toggling light/dark mode updates the rect cutout's fill to match
- Narrowing the window doesn't clip or overflow the logo

This is a manual QA tool, not an automated test — visual/cross-browser
rendering can't be reliably asserted by `testthat`.

### 3. Bundled Quarto test site (`inst/quarto-test-site/`)

This is where local iteration gets tricky, and why the setup below
uses symlinks rather than `quarto add`.

#### Why not just `quarto add shelbylevel/slbrand`?

`quarto add owner/repo` always downloads from the **remote** GitHub
repo's current default branch. If you're actively editing
`_extensions/shelbylevel/brand/logo-header.html` locally and haven't
committed and pushed yet, `quarto add` would silently ignore all of
that and install whatever was last pushed — meaning you'd be testing
old code, not your change.

#### The symlink fix

A symlink (`ln -s`) doesn't copy a file — it creates a pointer to the
real file's location on disk. Editing the real file immediately
changes what you see through the symlink too, because they're the same
underlying file accessed via two paths, not two copies kept in sync.
There's no "syncing" step to forget, and nothing can drift out of date
between them.

Two symlinks make this work:

```bash
# from the slbrand repo root
mkdir -p inst/quarto-test-site/_extensions/shelbylevel
ln -s ../../../../_extensions/shelbylevel/brand \
      inst/quarto-test-site/_extensions/shelbylevel/brand

ln -s ../_brand.yml inst/quarto-test-site/_brand.yml
```

Resulting layout (`→` marks a symlink, not a real copy):

```
slbrand/
├── inst/
│   ├── _brand.yml
│   ├── img/sl-logo.svg
│   └── quarto-test-site/
│       ├── _quarto.yml
│       ├── index.qmd
│       ├── _brand.yml → ../_brand.yml
│       └── _extensions/
│           └── shelbylevel/
│               └── brand → ../../../../_extensions/shelbylevel/brand
└── _extensions/
    └── shelbylevel/
        └── brand/
            ├── _extension.yml
            └── logo-header.html
```

`inst/quarto-test-site/_quarto.yml` points at both:

```yaml
project:
  type: website

format:
  html:
    theme: _brand.yml
    include-in-header:
      - _extensions/shelbylevel/brand/logo-header.html
```

**Day-to-day workflow:** edit `_extensions/shelbylevel/brand/logo-header.html`
or `inst/_brand.yml` directly, then `quarto render` inside
`inst/quarto-test-site/` — changes show up immediately, no commit or
push required.

#### When to actually use `quarto add` / `quarto update`

Once a change is finished and pushed, do a **separate**, one-time check
in a throwaway directory (not the symlinked test site) to confirm the
real install path works for an external consumer — this answers "does
a stranger installing this from GitHub get what I intended," which is
a different question from "does my local edit look right":

```bash
mkdir -p /tmp/slbrand-install-check && cd /tmp/slbrand-install-check
quarto add shelbylevel/slbrand
```

#### Symlinks and package building

`inst/quarto-test-site/` is excluded from the built R package via
`.Rbuildignore`:

```
^inst/quarto-test-site$
```

This is because symlinks inside `inst/` can behave inconsistently
across R versions/OSes during `R CMD build` / `devtools::install()`,
and this directory is a dev-time testing aid — not something an end
user needs bundled when they `remotes::install_github()` the package.

### Why the logo looks the way it does (context for future edits)

A few non-obvious things in `inst/img/sl-logo.svg` exist to fix specific
bugs, not by accident — worth knowing before "simplifying" them away:

- **No CSS `letter-spacing`** — replaced with `textLength` +
  `lengthAdjust="spacing"` on each `<text>` element. Safari and
  Chromium-based browsers (e.g. Arc) compute `text-anchor="middle"` +
  `letter-spacing` differently, causing text to clip or shift
  inconsistently between browsers. `textLength` forces both engines to
  render the same total width regardless of their own font metrics.
- **`x="42.5"` on "SHELBY"** — the true mathematical center of the
  85-unit-wide viewBox (not a rounder-looking number), confirmed via
  `getBBox()`.
- **`viewBox="0 0 85 45"` in the Shiny copy** (vs. `85 40` in the Quarto
  copy) — widened specifically to fix a vertical-centering bug in
  bslib's flex nav-item layout; Quarto's navbar never showed this bug,
  so its copy keeps the original ratio. This is an intentional
  difference, not a sync error.
- **`height` differs between the two copies on purpose** — `32px`
  (Shiny) vs. `60px` (Quarto), matched to each navbar's own proportions.

### The two-copies-of-everything situation

The logo SVG and its script currently exist in two places:
`inst/img/sl-logo.svg` (read via `system.file()` for Shiny) and inlined
inside `_extensions/shelbylevel/brand/logo-header.html` (for Quarto).
If you change the logo's **content** (text, colors, paths), update
both. The **height** and **viewBox** values are intentional exceptions
— see above — and do not need to match between the two.
