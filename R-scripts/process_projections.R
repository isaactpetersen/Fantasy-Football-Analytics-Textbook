# Process Projections

library("stringr")
library("tidyverse")
library("purrr")

# Weekly Projections ----

filenames <- list.files(
  path = "./data/by_year",
  pattern = "players_projectedPoints_weekly_.*\\.RData",
  recursive = TRUE,
  full.names = TRUE)

filenames_season <- str_extract(filenames, "\\d{4}")
filenames_week <- str_extract(filenames, "week\\d+") %>% 
  str_remove("week") %>% 
  as.integer()

objectNames_projectedPoints <- paste("players_projectedPoints_weekly_", filenames_season, "_", "week", filenames_week, sep = "")
objectNames_projectedPoints_combined <- paste("players_projectedPoints_weekly_combined_", filenames_season, "_", "week", filenames_week, sep = "")
objectNames_projections <- paste("players_projections_weekly_average_", filenames_season, "_", "week", filenames_week, sep = "")

## Loop by Season ----
for(i in unique(filenames_season)){
  filenames_subset <- filenames[which(filenames_season %in% i)]
  filenames_week_subset <- filenames_week[which(filenames_season %in% i)]
  
  objectNames_projectedPoints_subset <- objectNames_projectedPoints[which(filenames_season %in% i)]
  objectNames_projectedPoints_combined_subset <- objectNames_projectedPoints_combined[which(filenames_season %in% i)]
  objectNames_projections_subset <- objectNames_projections[which(filenames_season %in% i)]
  
  ### Loop by Week ----
  for(j in 1:length(filenames_week_subset)){
    rm(players_projectedPoints_weekly)
    rm(players_projectedPoints_weekly_combined)
    rm(players_projections_weekly_average)
    
    objectName_projectedPoints <- objectNames_projectedPoints_subset[j] #paste("players_projectedPoints_weekly_", i, "_", "week", j, sep = "")
    objectName_projectedPoints_combined <- objectNames_projectedPoints_combined_subset[j]
    objectName_projections <- objectNames_projections_subset[j] #paste("players_projections_weekly_average_", i, "_", "week", j, sep = "")
    fullFilepath <- filenames_subset[j] #paste("./data/by_year/", objectName_projectedPoints, ".RData", sep = "")
    
    load(file = fullFilepath)
    
    # Projected Points
    players_projectedPoints_weekly$QB$season <- i
    players_projectedPoints_weekly$QB$week <- filenames_week_subset[j]
    
    players_projectedPoints_weekly$RB$season <- i
    players_projectedPoints_weekly$RB$week <- filenames_week_subset[j]
    
    players_projectedPoints_weekly$WR$season <- i
    players_projectedPoints_weekly$WR$week <- filenames_week_subset[j]
    
    players_projectedPoints_weekly$TE$season <- i
    players_projectedPoints_weekly$TE$week <- filenames_week_subset[j]
    
    players_projectedPoints_weekly$K$season <- i
    players_projectedPoints_weekly$K$week <- filenames_week_subset[j]
    
    players_projectedPoints_weekly$DST$season <- i
    players_projectedPoints_weekly$DST$week <- filenames_week_subset[j]
    
    players_projectedPoints_weekly$DL$season <- i
    players_projectedPoints_weekly$DL$week <- filenames_week_subset[j]
    
    players_projectedPoints_weekly$LB$season <- i
    players_projectedPoints_weekly$LB$week <- filenames_week_subset[j]
    
    players_projectedPoints_weekly$DB$season <- i
    players_projectedPoints_weekly$DB$week <- filenames_week_subset[j]
    
    # Projected Points - Combined
    players_projectedPoints_weekly_combined <- bind_rows(players_projectedPoints_weekly)
    players_projectedPoints_weekly_combined <- players_projectedPoints_weekly_combined %>% 
      select(season, week, everything())
    
    # Projections
    players_projections_weekly_average$season <- i
    players_projections_weekly_average$week <- filenames_week_subset[j]
    
    # Assign to object
    assign(objectName_projectedPoints, players_projectedPoints_weekly)
    assign(objectName_projectedPoints_combined, players_projectedPoints_weekly_combined)
    assign(objectName_projections, players_projections_weekly_average)
    
    # Remove temporary objects
    rm(players_projectedPoints_weekly)
    rm(players_projectedPoints_weekly_combined)
    rm(players_projections_weekly_average)
  }
  
  ## Combine Across Seasons ----
  
  objectName_projectedPoints_combined_merged <- paste("players_projectedPoints_weekly_combined_", i, sep = "")
  objectName_projections_merged <- paste("players_projections_weekly_average_", i, sep = "")
  
  players_projectedPoints_weekly_combined_merged <- objectNames_projectedPoints_combined_subset %>%
    map(get) %>%  # retrieve each object by name
    bind_rows() %>% # bind all data frames by row
    arrange(season, week)
  
  players_projections_weekly_average_merged <- objectNames_projections_subset %>%
    map(get) %>%  # retrieve each object by name
    bind_rows() %>% # bind all data frames by row
    arrange(season, week)
  
  assign(objectName_projectedPoints_combined_merged, players_projectedPoints_weekly_combined_merged)
  assign(objectName_projections_merged, players_projections_weekly_average_merged)
  
  # Save Merged Data
  save(
    list = c(objectName_projectedPoints_combined_merged, objectName_projections_merged),
    file = paste("./data/by_year/players_projectedPoints_weekly", "_", i, ".RData", sep = "")
  )
}

objectNames_projectedPoints_combined_acrossSeasons <- paste("players_projectedPoints_weekly_combined_", unique(filenames_season), sep = "")
objectNames_projections_weekly_average_acrossSeasons <- paste("players_projections_weekly_average_", unique(filenames_season), sep = "")

players_projectedPoints_weekly_combined <- objectNames_projectedPoints_combined_acrossSeasons %>%
  map(get) %>%  # retrieve each object by name
  bind_rows() %>% # bind all data frames by row
  arrange(season, week)

players_projections_weekly_average_merged <- objectNames_projections_weekly_average_acrossSeasons %>%
  map(get) %>%  # retrieve each object by name
  bind_rows() %>% # bind all data frames by row
  select(season, week, everything()) %>% 
  arrange(season, week)

save(
  players_projectedPoints_weekly_combined, players_projections_weekly_average_merged,
  file = paste("./data/players_projections_weekly", ".RData", sep = "")
)

# Seasonal Projections ----

filenamesSeasonal <- list.files(
  path = "./data/by_year",
  pattern = "players_projectedPoints_seasonal_.*\\.RData",
  recursive = TRUE,
  full.names = TRUE)

filenamesSeasonal_season <- str_extract(filenamesSeasonal, "\\d{4}")

objectNames_seasonal <- paste("players_projectedPoints_seasonal_", filenamesSeasonal_season, sep = "")

for(i in 1:length(filenamesSeasonal_season)){
  objectName_seasonal_subset <- objectNames_seasonal[i]
  
  rm(players_projectedPoints_seasonal)
  
  fullFilepath <- filenamesSeasonal[i]
  
  load(file = fullFilepath)
  
  players_projectedPoints_seasonal$QB$season <- filenamesSeasonal_season[i]
  players_projectedPoints_seasonal$RB$season <- filenamesSeasonal_season[i]
  players_projectedPoints_seasonal$WR$season <- filenamesSeasonal_season[i]
  players_projectedPoints_seasonal$TE$season <- filenamesSeasonal_season[i]
  players_projectedPoints_seasonal$K$season <- filenamesSeasonal_season[i]
  players_projectedPoints_seasonal$DST$season <- filenamesSeasonal_season[i]
  players_projectedPoints_seasonal$DL$season <- filenamesSeasonal_season[i]
  players_projectedPoints_seasonal$LB$season <- filenamesSeasonal_season[i]
  players_projectedPoints_seasonal$DB$season <- filenamesSeasonal_season[i]
  
  players_projectedPoints_seasonal_combined <- bind_rows(players_projectedPoints_seasonal)
  players_projectedPoints_seasonal_combined <- players_projectedPoints_seasonal_combined %>% 
    select(season, everything())
  
  # Assign to object
  assign(objectName_seasonal_subset, players_projectedPoints_seasonal_combined)
  
  rm(players_projectedPoints_seasonal)
}

## Combine Across Seasons ----

objectNames_seasonal_acrossSeasons <- paste("players_projectedPoints_seasonal_", unique(filenamesSeasonal_season), sep = "")

players_projectedPoints_seasonal_combined <- objectNames_seasonal_acrossSeasons %>%
  map(get) %>%  # retrieve each object by name
  bind_rows() %>% # bind all data frames by row
  arrange(season)

save(
  players_projectedPoints_seasonal_combined,
  file = paste("./data/players_projections_seasonal", ".RData", sep = "")
)
