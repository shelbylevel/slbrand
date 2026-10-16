test_that("brand_path() finds the installed _brand.yml", {
  path <- brand_path()
  expect_true(file.exists(path))
  expect_match(path, "_brand\\.yml$")
})

test_that("read_brand() parses expected top-level sections", {
  brand <- read_brand()
  expect_true(all(
    c("meta", "color", "typography", "defaults") %in% names(brand)
  ))
  expect_equal(brand$meta$name, "shelbylevel")
})

test_that("theme_sl() returns a bs_theme object", {
  skip_if_not_installed("bslib")
  theme <- theme_sl()
  expect_s3_class(theme, "bs_theme")
})

test_that("brand_colors() returns expected color subsets", {
  all_colors <- brand_colors("all")
  palette_colors <- brand_colors("palette")
  semantic_colors <- brand_colors("semantic")

  expect_true("primary" %in% names(semantic_colors))
  expect_true("deep-jade" %in% names(palette_colors))
  expect_equal(
    length(all_colors),
    length(palette_colors) + length(semantic_colors)
  )
})

test_that("extension _brand.yml and inst/_brand.yml are identical", {
  ext <- testthat::test_path("..", "..", "_extensions", "shelbylevel", "brand", "_brand.yml")
  skip_if_not(file.exists(ext), "extension not present (installed package)")
  expect_identical(readLines(ext), readLines(brand_path()))
})
