# Run from the repository root after installing tenniscareer.
library(tenniscareer)

dir.create("outputs", showWarnings = FALSE)

snapshot_path <- "outputs/carlos_alcaraz_matches.csv"

# Download once; subsequent runs reuse the saved snapshot.
if (!file.exists(snapshot_path)) {
  matches <- get_player_matches("Carlos Alcaraz")
  write.csv(matches, snapshot_path, row.names = FALSE)
  writeLines(
    paste("Retrieved from Tennis Abstract on", Sys.Date()),
    "outputs/carlos_alcaraz_source.txt"
  )
}

matches <- read.csv(snapshot_path, stringsAsFactors = FALSE)
matches$match_date <- as.Date(matches$match_date)

plot <- plot_career_matches(matches)

ggplot2::ggsave(
  "outputs/carlos_alcaraz_career.png",
  plot = plot,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)

cat("Saved Carlos Alcaraz data snapshot and plot in outputs/\n")