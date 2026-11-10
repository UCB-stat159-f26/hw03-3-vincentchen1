# Convert YYYYMMDD strings into dates, leaving invalid values missing.
parse_match_dates <- function(values) {
  dates <- suppressWarnings(as.Date(values, format = "%Y%m%d"))
  valid <- !is.na(values) & grepl("^[0-9]{8}$", values)
  valid <- valid & !is.na(dates) & format(dates, "%Y%m%d") == values
  dates[is.na(valid) | !valid] <- as.Date(NA)
  dates
}

# Female records contain birth dates; male records contain decimal ages.
get_opponent_ages <- function(values, match_dates) {
  birth_date <- !is.na(values) & grepl("^[0-9]{8}$", values)
  ages <- suppressWarnings(as.numeric(values))
  ages[birth_date] <- as.numeric(
    match_dates[birth_date] - parse_match_dates(values[birth_date])
  ) / 365.25
  ages[!is.finite(ages) | ages < 0 | ages > 100] <- NA_real_
  ages
}

# The retrieval function will supply the player's name and birth date.
clean_career_matches <- function(rows, player_name, player_dob) {
  rows <- validate_match_rows(rows)
  dob <- parse_match_dates(player_dob)
  if (length(dob) != 1L || is.na(dob)) {
    stop("Player birth date must be a valid YYYYMMDD string.", call. = FALSE)
  }
  field <- function(index) vapply(rows, function(row) row[[index]], character(1))
  match_dates <- parse_match_dates(field(1L))
  data.frame(
    player = rep(player_name, length(rows)),
    match_date = match_dates,
    tournament = field(2L),
    surface = field(3L),
    result = field(5L),
    opponent = field(12L),
    player_age = as.numeric(match_dates - dob) / 365.25,
    opponent_age = get_opponent_ages(field(17L), match_dates),
    stringsAsFactors = FALSE
  )
}
