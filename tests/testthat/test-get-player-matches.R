test_that("required name formats produce equivalent search queries", {
  inputs <- c("serena williams", "Serena Williams", "SerenaWilliams")
  queries <- vapply(
    inputs, player_search_query, character(1), USE.NAMES = FALSE
  )
  expect_identical(queries, rep("serena williams", 3))
  expect_identical(player_search_query("RafaelNadal"), "rafael nadal")
})

test_that("invalid name inputs are rejected", {
  inputs <- list("", "   ", NA_character_, NULL, 123, c("A", "B"))
  for (input in inputs) {
    expect_error(
      player_search_query(input), "one non-empty character string"
    )
  }
})

test_that("lookup requires an exact normalized match", {
  results <- list(
    list(name = "Venus Williams", tour = "W", url = "venus"),
    list(name = "Serena Williams", tour = "W", url = "serena")
  )
  expect_identical(
    select_player(results, "SerenaWilliams"), results[[2]]
  )
  expect_error(select_player(results, "Williams"), "No player found")
  expect_error(
    select_player(list(), "GastonSanchez"), "No player found"
  )
})

test_that("duplicate exact names produce an ambiguity error", {
  player <- list(name = "Example Player", tour = "M", url = "example")
  expect_error(
    select_player(list(player, player), "Example Player"),
    "ambiguous"
  )
})

test_that("public retrieval works with entirely mocked downloads", {
  path <- testthat::test_path("fixtures", "FemalePlayerCareer.js")
  career <- paste(readLines(path), collapse = "\n")
  search <- paste0(
    '[{"name":"Serena Williams","tour":"W","url":',
    '"https://www.tennisabstract.com/cgi-bin/wplayer.cgi?',
    'p=200033/SerenaWilliams"}]'
  )
  profile <- paste(
    "<title>Tennis Abstract: Serena Williams Match Results</title>",
    "var dob = 19810926;"
  )
  testthat::local_mocked_bindings(download_tennis_text = function(url) {
    if (grepl("search.cgi?", url, fixed = TRUE)) return(search)
    if (grepl("player.cgi?", url, fixed = TRUE)) return(profile)
    if (endsWith(url, "SerenaWilliamsCareer.js")) return(career)
    if (endsWith(url, "/SerenaWilliams.js")) {
      return("var matchmx = [];")
    }
    stop("Unexpected URL in offline test.")
  })
  matches <- get_player_matches("serena williams")
  expect_equal(nrow(matches), 3L)
  expect_identical(unique(matches$player), "Serena Williams")
  expect_identical(matches$opponent[1], "Anne Miller")
})

test_that("unknown players fail without making a live request", {
  testthat::local_mocked_bindings(
    download_tennis_text = function(url) "[]"
  )
  expect_error(get_player_matches("GastonSanchez"), "No player found")
})