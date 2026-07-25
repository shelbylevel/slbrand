test_that("logo SVG file exists and is readable", {
  path <- logo_path()
  expect_true(file.exists(path))
  svg_content <- paste(readLines(path), collapse = "\n")
  expect_match(svg_content, "id='logo-svg'")
})

test_that("logo_nav_item() returns expected structure", {
  item <- logo_nav_item()
  expect_s3_class(item, "shiny.tag")
  rendered <- htmltools::doRenderTags(item)
  expect_match(rendered, "logo-svg")
  expect_match(rendered, "shelbylevel.org")
})

test_that("logo_nav_item() respects href override", {
  item <- logo_nav_item(href = "https://example.com")
  rendered <- htmltools::doRenderTags(item)
  expect_match(rendered, "https://example.com")
  expect_no_match(rendered, "shelbylevel.org")
})

test_that("logo_header() includes the rect-color-sync script", {
  header <- logo_header()
  rendered <- htmltools::doRenderTags(header)
  expect_match(rendered, "syncLogoRectColor")
  expect_match(rendered, "logo-svg rect")
})
