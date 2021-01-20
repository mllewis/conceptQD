# get workers to reject after running 100, and stim to remove (make new stim sheet)
library(tidyverse)
library(here)

DATA_PATH1 <- here("experiments/conceptviz_2/data/run1/")
DATA_PATH2 <- here("experiments/conceptviz_2/data/run2/")
DATA_PATH3 <- here("experiments/conceptviz_2/data/run3/")


STIM_OUT <- here("experiments/conceptviz_2/get_stimuli/data/experiment_stimuli/all_stim_data_run3.csv")

run1 <- list.files(DATA_PATH1, full.names = T)
run2 <- list.files(DATA_PATH2, full.names = T)
run3 <- list.files(DATA_PATH3, full.names = T)

run1_ids <- map(run1, str_extract_all, "\\d+") %>%
  map_chr(~.[[1]][4])
run2_ids <- map(run2, str_extract_all, "\\d+") %>%
  map_chr(~.[[1]][4])

### get workers to reject
all_data <- map_df(c(run1, run2, run3),
                   read_csv, col_names = c("subj_id", "trial_num", "pair_id", "category", "trial_type", "hd_bin",
                                           "hd_sim", "key_id_1", "key_id_2", "rt", "rating", "completion_code"),
                   col_types = c("cddccddccddc")) %>%
  mutate(run = case_when(subj_id %in% run1_ids ~ "run1",
                         subj_id %in% run2_ids ~ "run2",
                         TRUE ~ "run3"))

complete_subj_ids <- all_data %>%
  count(subj_id) %>%
  filter(n > 50) %>%
  pull(subj_id)

missed_two <- all_data %>%
  filter(subj_id %in% complete_subj_ids) %>%
  filter(run == "run3") %>%
  select(subj_id, trial_type, rating, completion_code) %>%
  filter(trial_type == "attention_check") %>%
  filter(rating > 2) %>%
  data.frame() %>%
  count(subj_id, completion_code) %>%
  filter(n == 2)

##### get stim for next run
missed_one <- all_data %>%
  filter(subj_id %in% complete_subj_ids) %>%
  select(subj_id, trial_type, rating, completion_code) %>%
  filter(trial_type == "attention_check") %>%
  filter(rating > 2) %>%
  data.frame() %>%
  count(subj_id, completion_code)  %>%
  pull(subj_id)


new_data  <- all_data %>%
  filter(trial_type == "critical_trial" ) %>%
  filter(!(subj_id %in% missed_one))

new_data_tidy <- new_data  %>%
  count(category,key_id_1, key_id_2, pair_id, name = "n_participants") %>%
  mutate(source = "new")


FILE_PATH <- here("experiments/conceptviz_2/get_stimuli/data/experiment_stimuli/all_stim_tidy.csv")

all_stim <- read_csv(FILE_PATH, col_types = c("dcccdd"))

# I screwed up the pair ids somehow (the new stimsheet and the
# old data have different stim ids for bread and tree)
PREVIOUS_DATA <- here("experiments/conceptviz_1/data/conceptviz_1_by_item_data.csv")

previous_data <- read_csv(PREVIOUS_DATA) %>%
  rename(pair_id_old = pair_id,
         key_id_1 = drawing_key_id_1,
         key_id_2 = drawing_key_id_2) %>%
  mutate(key_id_1 = as.character(key_id_1),
         key_id_2 = as.character(key_id_2))

previous_data_items <- previous_data %>%
  select(category, pair_id_old, key_id_1, key_id_2)

current_data_items <- all_stim %>%
  rename(pair_id = trial_ID) %>%
  filter(category %in% c("bread", "tree")) %>%
  select(category, pair_id, key_id_1, key_id_2) %>%
  distinct(category, pair_id, key_id_1, key_id_2)

pair_id_key <- full_join(previous_data_items, current_data_items) %>%
  select(category, contains("pair_id"), everything())

previous_data_tidy <- previous_data %>%
  left_join(pair_id_key) %>%
  select(pair_id, category, key_id_1, key_id_2, n_participants) %>%
  mutate(source = "old")

# remove pairs with 20 for tree/bread or 10 for other categorys
complete_data <- bind_rows(new_data_tidy, previous_data_tidy) %>%
  group_by(pair_id, category, key_id_1, key_id_2) %>%
  summarize(total_participants = sum(n_participants)) %>%
  mutate(complete = case_when(category == "bread" ~ total_participants >=20,
                              category == "tree" ~ total_participants >= 22,
                              TRUE ~ total_participants >= 10)) %>%
  full_join(all_stim %>% select(key_id_1, key_id_2, hd_sim, hd_bin) %>%
              distinct()) %>%
  mutate(complete = case_when(is.na(total_participants) ~ FALSE,
                              TRUE ~ complete),
         total_participants = case_when(is.na(total_participants) ~ 0,
                                        TRUE ~ total_participants))

new_stim_tidy <- complete_data %>%
  filter(!complete) %>%
  rename(trial_ID = pair_id) %>%
  select(trial_ID, category, key_id_1, key_id_2) %>%
  arrange(category, trial_ID) %>%
  left_join(all_stim %>% distinct(category, trial_ID, .keep_all = T) %>% select(trial_ID, category, hd_bin, hd_sim))

write_csv(new_stim_tidy, STIM_OUT)
