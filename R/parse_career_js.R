# Extract the match array while ignoring brackets inside quoted strings.
extract_match_array <- function(js_text) {
  marker <- regexpr("\\bmorematchmx\\s*=\\s*\\[", js_text, perl = TRUE)
  if (marker[1] < 0L) stop("Career JS is missing morematchmx.", call. = FALSE)
  start <- as.integer(marker) + attr(marker, "match.length") - 1L
  text <- substring(js_text, start)
  tokens <- gregexpr('"(?:[^"\\\\]|\\\\.)*"|\\[|\\]', text, perl = TRUE)[[1]]
  values <- regmatches(text, list(tokens))[[1]]
  depth <- cumsum((values == "[") - (values == "]"))
  end <- which(depth == 0L)[1]
  if (is.na(end)) stop("Career match array is incomplete.", call. = FALSE)
  substr(text, 1L, tokens[end])
}

# Match records must contain at least the fields used by our cleaner.
validate_match_rows <- function(rows) {
  valid_row <- function(row) {
    is.list(row) && length(row) >= 19L &&
      all(vapply(row, function(value) {
        is.character(value) && length(value) == 1L && !is.na(value)
      }, logical(1)))
  }
  if (!is.list(rows) || !all(vapply(rows, valid_row, logical(1)))) {
    stop("Career match records have an invalid structure.", call. = FALSE)
  }
  rows
}

# Parse JSON data only; never evaluate the downloaded JavaScript.
parse_career_js <- function(js_text) {
  if (!is.character(js_text) || length(js_text) != 1L || is.na(js_text)) {
    stop("JS content must be a single non-missing character string.", call. = FALSE)
  }
  array <- extract_match_array(js_text)
  rows <- tryCatch(
    jsonlite::fromJSON(array, simplifyVector = FALSE),
    error = function(error) stop("Career match array contains invalid JSON.", call. = FALSE)
  )
  validate_match_rows(rows)
}
