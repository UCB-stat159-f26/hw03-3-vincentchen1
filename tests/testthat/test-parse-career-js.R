read_fixture <- function(filename) {
  paste(readLines(testthat::test_path("fixtures", filename)), collapse = "\n")
}

test_that("female records preserve opponent birth dates", {
  rows <- parse_career_js(read_fixture("FemalePlayerCareer.js"))
  expect_length(rows, 3L)
  expect_identical(rows[[1]][[12]], "Anne Miller")
  expect_identical(rows[[1]][[17]], "19770119")
  expect_identical(rows[[3]][[17]], "19790301")
})

test_that("male records preserve numeric opponent age strings", {
  rows <- parse_career_js(read_fixture("MalePlayerCareer.js"))
  expect_length(rows, 3L)
  expect_identical(rows[[1]][[12]], "Guillermo Platel")
  expect_equal(as.numeric(rows[[1]][[17]]), 22.264202601)
  expect_identical(rows[[3]][[5]], "W")
})

test_that("surrounding JavaScript and quoted brackets are handled", {
  js <- read_fixture("FemalePlayerCareer.js")
  js <- sub("Canadian Open", "Canadian [Open]", js, fixed = TRUE)
  js <- paste('var other = ["ignore"];', js, 'var later = [1, 2];')
  rows <- parse_career_js(js)
  expect_length(rows, 3L)
  expect_identical(rows[[1]][[2]], "Canadian [Open]")
})

test_that("empty match arrays are accepted", {
  expect_identical(parse_career_js("var morematchmx = [];"), list())
})

test_that("invalid content produces meaningful errors", {
  expect_error(parse_career_js(NA_character_), "single non-missing")
  expect_error(parse_career_js(c("a", "b")), "single non-missing")
  expect_error(parse_career_js("var other = [];"), "missing morematchmx")
  expect_error(parse_career_js("var morematchmx = [["), "incomplete")
  expect_error(parse_career_js("var morematchmx = [[oops]];"), "invalid JSON")
  expect_error(parse_career_js('var morematchmx = [["short"]];'), "invalid structure")
  expect_error(parse_career_js("var morematchmx = [1, 2];"), "invalid structure")
})
