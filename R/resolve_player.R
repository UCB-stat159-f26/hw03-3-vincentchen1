# Compare names without spaces, punctuation, case, or common accents.
player_name_key <- function(name) {
  folded <- iconv(name, from = "UTF-8", to = "ASCII//TRANSLIT")
  gsub("[^a-z0-9]", "", tolower(folded))
}

# Convert spaced or CamelCase input into a search query.
player_search_query <- function(player_name) {
  if (!is.character(player_name) || length(player_name) != 1L ||
      is.na(player_name) || !nzchar(player_name_key(player_name))) {
    stop("Player name must be one non-empty character string.", call. = FALSE)
  }
  query <- gsub("([a-z])([A-Z])", "\\1 \\2", player_name)
  tolower(trimws(gsub("\\s+", " ", query)))
}

# Require an exact name match rather than choosing the first search result.
select_player <- function(results, player_name) {
  names <- vapply(results, function(player) player$name, character(1))
  matches <- which(player_name_key(names) == player_name_key(player_name))
  if (!length(matches)) {
    stop(paste0("No player found for '", player_name, "'."), call. = FALSE)
  }
  if (length(matches) > 1L) {
    stop("Player name is ambiguous; provide a more specific name.", call. = FALSE)
  }
  results[[matches]]
}

resolve_player <- function(player_name) {
  query <- player_search_query(player_name)
  url <- paste0("https://www.tennisabstract.com/cgi-bin/search.cgi?q=",
                utils::URLencode(query, reserved = TRUE))
  results <- jsonlite::fromJSON(download_tennis_text(url), simplifyVector = FALSE)
  select_player(results, player_name)
}
