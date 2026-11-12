plot_fixture <- function() {
  data.frame(
    player = rep("Example Player", 2),
    player_age = c(20, 21),
    opponent_age = c(23, 19),
    result = c("W", "L")
  )
}

test_that("age differences have the correct direction", {
  matches <- prepare_plot_matches(plot_fixture())
  expect_equal(matches$age_difference, c(-3, 2))
})

test_that("plotted coordinates and colors represent the supplied matches", {
  plot <- plot_career_matches(plot_fixture())
  expect_true(inherits(plot, "ggplot"))
  points <- ggplot2::ggplot_build(plot)$data[[2]]
  expect_equal(points$x, c(20, 21))
  expect_equal(points$y, c(-3, 2))
  expect_identical(points$colour, c("#25A7CE", "#963D88"))
})

test_that("invalid plot inputs produce meaningful errors", {
  expect_error(plot_career_matches(data.frame()), "data frame returned")
  matches <- plot_fixture()
  matches$player_age <- c("20", "21")
  expect_error(plot_career_matches(matches), "must be numeric")
  matches <- plot_fixture()
  matches$player[2] <- "Another Player"
  expect_error(plot_career_matches(matches), "exactly one player")
})

test_that("missing ages are omitted with a warning", {
  matches <- plot_fixture()
  matches$opponent_age[1] <- NA_real_
  expect_warning(clean <- prepare_plot_matches(matches), "Omitting")
  expect_equal(nrow(clean), 1L)
})

test_that("non-W/L results are omitted with a warning", {
  matches <- plot_fixture()
  matches$result[1] <- "Unknown"
  expect_warning(clean <- prepare_plot_matches(matches), "Omitting")
  expect_equal(nrow(clean), 1L)
})

test_that("empty plot data are rejected", {
  expect_error(
    plot_career_matches(plot_fixture()[FALSE, ]),
    "No valid matches"
  )
})

test_that("preparing plot data does not change the original input", {
  matches <- plot_fixture()
  original <- matches
  prepare_plot_matches(matches)
  expect_identical(matches, original)
})