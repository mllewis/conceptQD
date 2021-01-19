# computing MEAN the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

library(here)
library(tidyverse)


DISTANCE_PATH <- "/Volumes/molly\ backup/distances_by_country_pairs/"
OUTFILE <- here("data/processed/mean_log_pairwise_dists.csv")

all_files <- list.files(DISTANCE_PATH, full.names = T)


get_mean_distance <- function(file_name, outfile){
  df <- read_csv(file_name) %>%
    group_by(category, country1, country2) %>%
    summarize(mahalanobis_log_mean = mean(log(mahalanobis), na.rm = T),
              euclidean_log_mean = mean(log(euclidean), na.rm = T),
              avg_haus_log_mean = mean(log(avg_haus), na.rm = T),
              mahalanobislog_sd = sd(log(mahalanobis), na.rm = T),
              euclidean_log_sd = sd(log(euclidean), na.rm = T),
              avg_haus_log_sd = sd(log(avg_haus), na.rm = T))

  write_csv(df, outfile, append = T)

}

walk(all_files, get_mean_distance, OUTFILE)
