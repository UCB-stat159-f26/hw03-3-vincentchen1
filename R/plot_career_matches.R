# Validate the supplied data before plotting.
validate_plot_matches <- function(matches) {
  required <- c("player", "player_age", "opponent_age", "result")
  if (!is.data.frame(matches) || !all(required %in% names(matches))) {
    stop("Supply a data frame returned by get_player_matches().", call. = FALSE)
  }
  if (!is.numeric(matches$player_age) || !is.numeric(matches$opponent_age)) {
    stop("Player and opponent ages must be numeric.", call. = FALSE)
  }
}

# Keep usable matches and calculate their age differences.
prepare_plot_matches <- function(matches) {
  validate_plot_matches(matches)
  keep <- is.finite(matches$player_age) & is.finite(matches$opponent_age)
  keep <- keep & !is.na(matches$result) & matches$result %in% c("W", "L")
  if (any(!keep)) {
    warning("Omitting matches with missing ages or non-W/L results.",
            call. = FALSE)
  }
  matches <- matches[keep, , drop = FALSE]
  if (!nrow(matches)) stop("No valid matches to plot.", call. = FALSE)
  if (anyNA(matches$player) || length(unique(matches$player)) != 1L) {
    stop("Plot data must contain exactly one player.", call. = FALSE)
  }
  matches$age_difference <- matches$player_age - matches$opponent_age
  matches
}

career_plot_theme <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "#E5E7EB"),
      legend.position = "top",
      plot.title = ggplot2::element_text(face = "bold"),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA)
    )
}

career_plot_labels <- function(matches) {
  ggplot2::labs(
    title = paste(unique(matches$player), "Career Matches"),
    subtitle = "Positive values mean the player was older than the opponent",
    x = "Player age (years)",
    y = "Player age minus opponent age (years)",
    colour = NULL,
    caption = "Source: Tennis Abstract"
  )
}

career_plot_scales <- function() {
  list(
    ggplot2::scale_x_continuous(position = "top"),
    ggplot2::scale_y_continuous(
      labels = function(x) ifelse(x == 0, "Same age", sprintf("%+g", x))
    ),
    ggplot2::scale_colour_manual(
      values = c(W = "#25A7CE", L = "#963D88"), breaks = c("W", "L"),
      labels = c("Win", "Loss"), drop = FALSE
    )
  )
}

#' Plot career matches by player age and opponent age difference
#'
#' @param matches A data frame returned by [get_player_matches()].
#' @return A ggplot object that can be printed or saved with
#'   [ggplot2::ggsave()].
#' @details Positive age differences mean the player was older than the
#'   opponent. Missing ages and results other than W/L are omitted with
#'   a warning. Subset the input to select a historical period.
#' @export
#' @examples
#' matches <- data.frame(
#'   player = c("Example Player", "Example Player"),
#'   player_age = c(20, 21),
#'   opponent_age = c(23, 19),
#'   result = c("W", "L")
#' )
#' plot_career_matches(matches)
plot_career_matches <- function(matches) {
  matches <- prepare_plot_matches(matches)
  ggplot2::ggplot(matches, ggplot2::aes(
    x = player_age, y = age_difference, colour = result
  )) +
    ggplot2::geom_hline(
      yintercept = 0, colour = "#6B7280", linewidth = 0.5
    ) +
    ggplot2::geom_point(size = 2, alpha = 0.75) +
    career_plot_scales() +
    career_plot_labels(matches) +
    career_plot_theme()
}