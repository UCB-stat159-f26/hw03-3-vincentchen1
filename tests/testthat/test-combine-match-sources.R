test_that("regular matchmx arrays can be parsed", {
  path <- testthat::test_path("fixtures", "FemalePlayerCareer.js")
  text <- paste(readLines(path), collapse = "\n")
  recent <- sub("morematchmx", "matchmx", text, fixed = TRUE)
  expect_identical(parse_recent_matches(recent), parse_career_js(text))
  expect_identical(parse_recent_matches("var matchmx = [];"), list())
})

test_that("overlapping matches appear once and recent records take priority", {
  path <- testthat::test_path("fixtures", "MalePlayerCareer.js")
  rows <- parse_career_js(paste(readLines(path), collapse = "\n"))
  updated <- rows[[1]]
  updated[[17]] <- "19790529"
  combined <- combine_match_rows(rows, list(updated))
  expect_length(combined, 3L)
  expect_identical(combined[[1]][[17]], "19790529")
})

test_that("different rounds are preserved", {
  path <- testthat::test_path("fixtures", "MalePlayerCareer.js")
  rows <- parse_career_js(paste(readLines(path), collapse = "\n"))
  extra <- rows[[1]]
  extra[[9]] <- "Q1"
  expect_length(combine_match_rows(rows, list(extra)), 4L)
})

test_that("male records can contain either age representation", {
  ages <- get_opponent_ages(
    c("22.264202601", "19790529"),
    as.Date(c("2001-09-10", "2001-09-10"))
  )
  expect_equal(ages[1], 22.264202601)
  expect_equal(
    ages[2],
    as.numeric(as.Date("2001-09-10") - as.Date("1979-05-29")) / 365.25
  )
})

test_that("empty sources combine safely", {
  expect_identical(combine_match_rows(list(), list()), list())
})
