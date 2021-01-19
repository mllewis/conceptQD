# sample 200 drawing pairs for each item to use in experiment

library(tidyverse)
library(feather)
library(here)

ITEM <- "bird"
N_ILE <- 10
TOTAL_PAIRS <- 200
HD_PATH <- here(paste0("experiments/conceptviz_2/get_stimuli/data/pairs_with_hd/", ITEM, "_sampled_pairs_with_hd.csv"))
OUTPATH <- here(paste0("experiments/conceptviz_2/get_stimuli/data/experiment_stimuli/sim_experiment_stimuli_", ITEM, ".csv"))

bad_ids <- c(5850710908338176, 4647307863654400, 6194759683014656, 477248381308108, 6024580265148416)
hd_data <- read_csv(HD_PATH) %>%
  filter(!(key_id_1 %in% bad_ids),
         !(key_id_2 %in% bad_ids))

final_sampled_pairs <- hd_data %>%
  mutate(hd_bin = ntile(hd_sim, N_ILE)) %>%
  group_by(hd_bin) %>%
  sample_n(TOTAL_PAIRS/N_ILE) %>%
  ungroup() %>%
  mutate(trial_ID = 1:n(),
         category = ITEM) %>%
  select(trial_ID, category, everything())

write_csv(final_sampled_pairs, OUTPATH)

