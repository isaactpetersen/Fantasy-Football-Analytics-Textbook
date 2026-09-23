# Download Weekly Projections

# Specify Season and Week Number ----

season <- 2026
weekNumber <- 3

# Processing ----
season <- as.character(season)
weekNumber <- as.character(weekNumber)

# Libraries ----
library("ffanalytics") # remotes::install_github("FantasyFootballAnalytics/ffanalytics")
library("tidyverse")

# Download Weekly Projections ----
players_projections_weekly_raw <- ffanalytics::scrape_data(
  pos = c("QB", "RB", "WR", "TE", "K", "DST"), # include this line (i.e., uncomment it out) if get an error in downstream steps due to insufficient sources of IDP projections
  season = NULL, # NULL grabs the current season
  week = NULL) # NULL grabs the current week

# Save Raw Projections ----
save(
  players_projections_weekly_raw,
  file = "./data/players_projections_weekly_raw.RData"
)

# Scoring Settings ----
scoring_obj_default <- ffanalytics::scoring

scoring_obj <- scoring_obj_default

## Offense ----
scoring_obj$pass$pass_int <- -2
#scoring_obj$rec$rec <- 1
scoring_obj$misc$fumbles_lost <- -2

## Kickers ----
scoring_obj$kick$fg_miss <- -1

## Defense/Special Teams ----
scoring_obj$dst$dst_blk <- 2

scoring_obj$pts_bracket <- list(
  list(threshold = 0, points = 5),
  list(threshold = 6, points = 4),
  list(threshold = 13, points = 3),
  list(threshold = 17, points = 1),
  list(threshold = 27, points = 0),
  list(threshold = 45, points = -3),
  list(threshold = 99, points = -5)
)

# Calculate Projected Points ----

## By Source ----
players_projectedPoints_weekly <- ffanalytics:::impute_and_score_sources(
  data_result = players_projections_weekly_raw,
  scoring_rules = scoring_obj)

## Averaged Across Sources ----
players_projectedStatsAverage_weekly <- ffanalytics::projections_table(
  players_projections_weekly_raw,
  scoring_rules = scoring_obj,
  return_raw_stats = TRUE)

players_projectedPointsAverage_weekly <- ffanalytics::projections_table(
  players_projections_weekly_raw,
  scoring_rules = scoring_obj,
  return_raw_stats = FALSE)

# Merge ----
players_projections_weekly_average <- full_join(
  players_projectedPointsAverage_weekly,
  players_projectedStatsAverage_weekly,
  by = c("id","avg_type","pos" = "position")
)

# Add Additional Player Information ----
players_projections_weekly_average <- players_projections_weekly_average |> 
  add_ecr() |> 
  add_uncertainty() |> # comment out if throws an error
  add_player_info()

# Save Projected Points ----

save(
  players_projectedPoints_weekly, players_projections_weekly_average,
  file = "./data/players_projectedPoints_weekly.RData"
)

save(
  players_projectedPoints_weekly, players_projections_weekly_average,
  file = paste("./data/by_year/players_projectedPoints_weekly_", season, "_", "week", weekNumber, ".RData", sep = "")
)
