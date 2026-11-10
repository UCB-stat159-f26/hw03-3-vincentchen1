fixture_rows <- function(filename) {
  path <- testthat::test_path("fixtures", filename)
  parse_career_js(paste(readLines(path), collapse = "\n"))
}

test_that("female birth dates become opponent ages", {
  rows <- fixture_rows("FemalePlayerCareer.js")
  matches <- clean_career_matches(rows, "Serena Williams", "19810926")
  expect_s3_class(matches, "data.frame")
  expect_equal(nrow(matches), 3L)
  expect_s3_class(matches$match_date, "Date")
  expect_identical(matches$opponent[1], "Anne Miller")
  expected <- as.numeric(as.Date("1995-10-30") - as.Date("1977-01-19")) / 365.25
  expect_equal(matches$opponent_age[1], expected)
  expect_equal(matches$player_age[1],
               as.numeric(as.Date("1995-10-30") - as.Date("1981-09-26")) / 365.25)
})

test_that("male opponent ages are preserved", {
  rows <- fixture_rows("MalePlayerCareer.js")
  matches <- clean_career_matches(rows, "Rafael Nadal", "19860603")
  expect_equal(matches$opponent_age,
               c(22.264202601, 24.2902121834, 18.7597535934))
  expect_identical(matches$result, c("L", "L", "W"))
  expect_identical(matches$surface, c("Hard", "Clay", "Clay"))
})

test_that("missing and invalid opponent ages preserve match rows", {
  rows <- fixture_rows("MalePlayerCareer.js")
  rows[[1]][[17]] <- ""
  rows[[2]][[17]] <- "unknown"
  rows[[3]][[17]] <- "-5"
  matches <- clean_career_matches(rows, "Rafael Nadal", "19860603")
  expect_equal(nrow(matches), 3L)
  expect_true(all(is.na(matches$opponent_age)))
})

test_that("invalid dates become missing", {
  dates <- parse_match_dates(c("20230230", "", "bad", "20240229"))
  expect_true(all(is.na(dates[1:3])))
  expect_equal(dates[4], as.Date("2024-02-29"))
})

test_that("invalid player birth dates produce an error", {
  expect_error(
    clean_career_matches(list(), "Player", "not-a-date"),
    "Player birth date"
  )
})

test_that("empty careers return a data frame with the same columns", {
  matches <- clean_career_matches(list(), "Player", "19810926")
  expect_equal(nrow(matches), 0L)
  expect_named(matches, c(
    "player", "match_date", "tournament", "surface", "result",
    "opponent", "player_age", "opponent_age"
  ))
})
