# get by item pair rating means, combining conceptviz 1 and conceptviz 2 (1000 items, 5 categories)

library(tidyverse)
library(here)
library(jsonlite)
library(langcog)

DATA_PATH_CV1_1 <- here("experiments/conceptviz_1/data/conceptviz_1_raw_data.csv")
DATA_PATH_CV2_12 <- here("experiments/conceptviz_2/data/run12/")
DATA_PATH_CV2_3 <- here("experiments/conceptviz_2/data/run3/")
BY_PAIR_MEANS <- here("experiments/conceptviz_2/data/by_item_means.csv")


##### Conceptviz1 #####
cv1_data_json <- read_csv(DATA_PATH_CV1_1)

cv1_data <- map_df(cv1_data_json$data, fromJSON, simplifyDataFrame = TRUE) %>%
  bind_cols(subj_id = cv1_data_json$subj_id) %>%
  select(subj_id, everything())

cv1_data_tidy <- cv1_data %>%
  gather(variable, value, -subj_id) %>%
  separate(variable, c("variable", "trial_num"), sep = "_T") %>%
  spread(variable, value) %>%
  mutate_at(c("trial_num", "haus_sim", "rating", "RT", "trial_ID",  "haus_bin"), as.numeric) %>%
  mutate_at(c("category", "drawing_key_id_1", "drawing_key_id_2","trial_type", "subj_id"), as.factor) %>%
  mutate(run = "run0") %>%
  rename(rt = "RT",
         pair_id_old = "trial_ID")

##### Conceptviz2 #####
run12 <- list.files(DATA_PATH_CV2_12, full.names = T)
run3 <- list.files(DATA_PATH_CV2_3, full.names = T)

run12_ids <- map(run12, str_extract_all, "\\d+") %>%
  map_chr(~.[[1]][4])
run3_ids <- map(run3, str_extract_all, "\\d+") %>%
  map_chr(~.[[1]][4])

cv2_data_tidy <- map_df(c(run12, run3),
                   read_csv, col_names = c("subj_id", "trial_num", "pair_id", "category", "trial_type", "haus_bin",
                                           "haus_sim", "drawing_key_id_1", "drawing_key_id_2", "rt", "rating", "completion_code"),
                   col_types = c("cddccddccddc")) %>%
  mutate(run = case_when(subj_id %in% run12_ids ~ "run12",
                         subj_id %in% run3_ids  ~ "run3")) %>%
  select(-completion_code)

all_data <- bind_rows(cv1_data_tidy, cv2_data_tidy)

#####  do subject exclusions #####
incomplete_subj_ids <- all_data %>% # get sub
  count(subj_id) %>%
  filter(n == 52) %>%
  pull(subj_id)

missed_one_attention_subj_ids <- all_data %>%
  select(subj_id, trial_type, rating) %>%
  filter(trial_type == "attention_check",
         rating > 2) %>%
  count(subj_id)  %>%
  pull(subj_id)

all_data_filtered  <- all_data %>%
  filter(trial_type == "critical_trial",
         !(subj_id %in% incomplete_subj_ids), # remove subj who didn't do all trials
         !(subj_id %in% missed_one_attention_subj_ids), # remove subjs who missed one attention check
         !(is.na(rating))) %>% # data on a minority of first trials was lost
  select(run, subj_id, category, trial_num, pair_id, pair_id_old,
         drawing_key_id_1, drawing_key_id_2, haus_bin, haus_sim, rating, rt)

#####  get menas by item pair #####
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
