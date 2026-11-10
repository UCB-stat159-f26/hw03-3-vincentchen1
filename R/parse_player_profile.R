# Extract one captured value, reporting missing profile information.
extract_profile_value <- function(html, pattern, field) {
  match <- regmatches(html, regexec(pattern, html, perl = TRUE))[[1]]
  if (length(match) < 2L) {
    stop(paste("Player profile is missing", field), call. = FALSE)
  }
  match[2L]
}

# Read metadata without executing any JavaScript.
parse_player_profile <- function(html) {
  dob <- extract_profile_value(
    html, "\\bvar\\s+dob\\s*=\\s*([0-9]{8})\\s*;", "a birth date."
  )
  name <- extract_profile_value(
    html, "<title>\\s*Tennis Abstract:\\s*(.*?)\\s+Match Results",
    "a player name."
  )
  if (is.na(parse_match_dates(dob))) {
    stop("Player profile contains an invalid birth date.", call. = FALSE)
  }
  list(name = name, dob = dob)
}
