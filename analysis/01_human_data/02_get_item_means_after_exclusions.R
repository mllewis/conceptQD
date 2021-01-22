# get by item pair rating means, combining conceptviz 1 and conceptviz 2 (1000 items, 5 categories)

library(tidyverse)
library(here)
library(jsonlite)
library(langcog)

TIDY_RAW <- here("data/processed/tidy_raw_human_data.csv")
BY_PAIR_MEANS <- here("data/processed/by_item_human_means.csv")

all_data <- read_csv(TIDY_RAW, guess_max = 100000) %>%
  mutate(subj_id = as.factor(subj_id))

#####  do subject exclusions #####
complete_subj_ids <- all_data %>% # get sub
  count(subj_id) %>%
  filter(n == 52) %>%
  pull(subj_id)

all_data_complete <- all_data %>%
  filter((subj_id %in% complete_subj_ids)) # remove subj who didn't do all trials

missed_one_attention_subj_ids <- all_data_complete %>%
  select(subj_id, trial_type, rating) %>%
  filter(trial_type == "attention_check",
         rating > 2) %>%
  count(subj_id)  %>%
  pull(subj_id)

all_data_filtered  <- all_data_complete %>%
  filter(trial_type == "critical_trial",
         !(subj_id %in% missed_one_attention_subj_ids), # remove subjs who missed one attention check
         !(is.na(rating))) %>% # data on a minority of first trials was lost
  select(run, subj_id, category, trial_num, pair_id, pair_id_old,
         drawing_key_id_1, drawing_key_id_2, haus_bin, haus_sim, rating, rt)

#####  get means by item pair #####
means_by_pair <- all_data_filtered %>%
  group_by(category, drawing_key_id_1, drawing_key_id_2) %>%
  multi_boot_standard(col = "rating")

pair_meta <- all_data_filtered %>%
  group_by(category, drawing_key_id_1, drawing_key_id_2) %>%
  summarize(n = n(),
            haus_bin = haus_bin[1],
            haus_sim = haus_sim[1])

tidy_pair_means <- means_by_pair %>%
  left_join(pair_meta) %>%
  ungroup() %>%
  mutate(pair_id = 1:n()) %>%
  select(category, pair_id, everything())

write_csv(tidy_pair_means, BY_PAIR_MEANS)
