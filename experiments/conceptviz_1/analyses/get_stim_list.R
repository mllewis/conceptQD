library(tidyverse)
library(jsonlite)
library(langcog)
library(here)

HUMAN_DATA <- here("experiments/conceptviz_1/data/conceptviz_1_raw_data.csv")
TIDY_HUMAN_RATINGS <-  here("experiments/conceptviz_1/data/conceptviz_1_by_item_data.csv")

d_raw <- read_csv(HUMAN_DATA)
d <- map_df(d_raw$data, fromJSON, simplifyDataFrame = TRUE) %>%
  bind_cols(subj_id = d_raw$subj_id) %>%
  select(subj_id, everything())


d_tidy <- d %>%
  gather(variable, value, -subj_id) %>%
  separate(variable, c("variable", "trial_num"), sep = "_T") %>%
  spread(variable, value) %>%
  mutate_at(c("trial_num", "haus_sim", "rating", "RT", "trial_ID",  "haus_bin"), as.numeric) %>%
  mutate_at(c("category", "drawing_key_id_1", "drawing_key_id_2","trial_type", "subj_id"), as.factor)

mean_attention_check_ratings = d_tidy %>%
  filter(trial_type == "attention_check") %>%
  group_by(subj_id) %>%
  summarize(mean = mean(rating)) %>%
  filter(mean < 3) # there were two attention checks where the images were identical  (correct answer == 1)

d_tidy_crit <- d_tidy %>%
  filter(subj_id %in% mean_attention_check_ratings$subj_id) %>%
  filter(trial_type == "critical_trial")

means_ratings_by_drawing_pair <- d_tidy_crit %>%
  group_by(category, drawing_key_id_1, drawing_key_id_2) %>%
  multi_boot_standard(col = "rating", na.rm = TRUE)

participant_counts <- d_tidy_crit %>%
  count(category, drawing_key_id_1, drawing_key_id_2)

tidy_means_ratings_by_drawing_pair <- means_ratings_by_drawing_pair %>%
  left_join(participant_counts) %>%
  ungroup() %>%
  mutate(pair_id = 1:n()) %>%
  rename(human_rating_mean = mean,
         n_participants = n,
         ci_lower_human = ci_lower,
         ci_upper_human = ci_upper) %>%
  select(pair_id, everything())


write_csv(tidy_means_ratings_by_drawing_pair, TIDY_HUMAN_RATINGS)
