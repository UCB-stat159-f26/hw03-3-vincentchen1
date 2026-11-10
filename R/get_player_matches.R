# Keep network access separate so automated tests can replace it.
download_tennis_text <- function(url) {
  tryCatch({
    response <- httr2::request(url) |>
      httr2::req_timeout(30) |>
      httr2::req_perform()
    httr2::resp_body_string(response)
  }, error = function(error) {
    stop(paste("Could not retrieve Tennis Abstract data:",
               conditionMessage(error)), call. = FALSE)
  })
}

#' Retrieve a player's career matches
#'
#' @param player_name A full player name, spaced or in CamelCase.
#'   Examples include "serena williams", "Serena Williams", and "SerenaWilliams".
#' @return A data frame containing player, match_date, tournament, surface,
#'   result, opponent, player_age, and opponent_age. Ages are decimal years
#'   calculated using 365.25 days per year. Missing opponent ages remain NA.
#' @details Requires internet access. Names are matched exactly after
#'   normalization. Match dates are the dates supplied by Tennis Abstract,
#'   which may represent tournament dates rather than individual match days.
#' @export
#' @examples
#' \dontrun{
#' serena <- get_player_matches("serena williams")
#' rafa <- get_player_matches("Rafael Nadal")
#' }
get_player_matches <- function(player_name) {
  player <- resolve_player(player_name)
  identifier <- sub("^.*[=/]", "", player$url)
  base <- "https://www.tennisabstract.com/"
  profile_url <- paste0(base, "cgi-bin/player.cgi?p=", identifier)
  profile <- parse_player_profile(download_tennis_text(profile_url))
  rows <- download_match_rows(identifier)
  clean_career_matches(rows, profile$name, profile$dob)
}
