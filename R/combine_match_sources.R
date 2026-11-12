# Reuse the safe array parser for the regular matchmx variable.
parse_recent_matches <- function(js_text) {
  renamed <- sub(
    "\\bvar\\s+matchmx\\s*=",
    "var morematchmx =",
    js_text, perl = TRUE
  )
  parse_career_js(renamed)
}

# Prefer regular-file records when the two sources overlap.
combine_match_rows <- function(historical, recent) {
  rows <- c(recent, historical)
  keys <- vapply(rows, function(row) {
    paste(unlist(row[c(1L, 2L, 9L, 12L)]), collapse = "\034")
  }, character(1))
  rows[!duplicated(keys)]
}

download_legacy_match_rows <- function(identifier) {
  base <- paste0("https://www.tennisabstract.com/jsmatches/", identifier)
  historical <- parse_career_js(
    download_tennis_text(paste0(base, "Career.js"))
  )
  recent <- parse_recent_matches(
    download_tennis_text(paste0(base, ".js"))
  )
  combine_match_rows(historical, recent)
}

# Current classic profiles can embed the match array directly.
download_classic_match_rows <- function(identifier) {
  url <- paste0(
    "https://www.tennisabstract.com/cgi-bin/player-classic.cgi?p=",
    identifier
  )
  parse_recent_matches(download_tennis_text(url))
}

# Fall back only for missing files, not connection or server failures.
download_match_rows <- function(identifier) {
  tryCatch(
    download_legacy_match_rows(identifier),
    error = function(error) {
      if (!grepl("HTTP 404", conditionMessage(error), fixed = TRUE)) {
        stop(error)
      }
      download_classic_match_rows(identifier)
    }
  )
}