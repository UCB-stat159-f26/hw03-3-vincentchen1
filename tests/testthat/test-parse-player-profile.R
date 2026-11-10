test_that("player name and birth date are extracted from profile HTML", {
  html <- paste(
    "<title>Tennis Abstract: Serena Williams Match Results, Splits, and Analysis</title>",
    "<script>var dob = 19810926;</script>"
  )
  expect_identical(
    parse_player_profile(html),
    list(name = "Serena Williams", dob = "19810926")
  )
})

test_that("profile parsing supports another player and whitespace", {
  html <- paste(
    "<title>Tennis Abstract: Rafael Nadal Match Results, Splits, and Analysis</title>",
    "<script>var dob=19860603 ;</script>"
  )
  expect_identical(
    parse_player_profile(html),
    list(name = "Rafael Nadal", dob = "19860603")
  )
})

test_that("missing or invalid metadata gives meaningful errors", {
  title <- "<title>Tennis Abstract: Example Player Match Results</title>"
  expect_error(parse_player_profile(title), "missing a birth date")
  expect_error(
    parse_player_profile("var dob = 19810926;"),
    "missing a player name"
  )
  expect_error(
    parse_player_profile(paste(title, "var dob = 20230230;")),
    "invalid birth date"
  )
})
