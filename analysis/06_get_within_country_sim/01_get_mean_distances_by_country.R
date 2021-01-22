# computing MEAN the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean, and human predicted distances)

library(here)
library(tidyverse)


DISTANCE_PATH <- "/Volumes/molly\ backup/within_country_distances/"
MODEL_PARAMS <- here("data/processed/human_data_predic_model_params.csv")
OUTFILE <- here("data/processed/mean_sim_by_country_item.csv")

all_files <- list.files(DISTANCE_PATH, full.names = T)


get_mean_distance <- function(file_name, params, outfile){

  print(file_name)

  intercept <- params %>% filter(term == "(Intercept)") %>% pull(estimate)
  haus_beta <- params %>% filter(term == "log_avg_haus") %>% pull(estimate)
  mahal_beta <- params %>% filter(term == "mahalanobis") %>% pull(estimate)
  euc_beta <- params %>% filter(term == "euclidean") %>% pull(estimate)

  df <- read_csv(file_name)

  df_with_predics <- df %>%
    mutate(log_avg_haus = log(avg_haus),
          human_predic_sim = intercept +
             (haus_beta*log_avg_haus) +
             (mahal_beta*mahalanobis) +
             (euc_beta *euclidean),
          log_human_predic_sim = log(human_predic_sim))

  df_with_predics_mean <- df_with_predics %>%
    group_by(category, country) %>%
    summarize(log_avg_haus_mean = mean(log_avg_haus, na.rm = T),
              log_avg_haus_sd = sd(log_avg_haus, na.rm = T),
              mahalanobis_mean = mean(mahalanobis, na.rm = T),
              mahalanobis_sd = sd(mahalanobis, na.rm = T),
              euclidean_mean = mean(euclidean, na.rm = T),
              euclidean_sd = sd(euclidean, na.rm = T),
              human_predic_sim_mean = mean(human_predic_sim, na.rm = T),
              human_predic_sim_sd = sd(human_predic_sim, na.rm = T),
              log_human_predic_sim_mean = mean(log_human_predic_sim, na.rm = T),
              log_human_predic_sim_sd = sd(log_human_predic_sim, na.rm = T))

  write_csv(df_with_predics_mean, outfile, append = T)

}
model_params <- read_csv(MODEL_PARAMS)
walk(all_files, get_mean_distance, model_params,  OUTFILE)
