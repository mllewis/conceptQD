# get by item pair rating means, combining conceptviz 1 and conceptviz 2 (1000 items, 5 categories)

library(tidyverse)
library(here)
library(jsonlite)
library(langcog)

DATA_PATH_CV1_1 <- here("experiments/conceptviz_1/data/raw/conceptviz_1_raw_data.csv")
DATA_PATH_CV2_12 <- here("experiments/conceptviz_2/data/raw/run12/")
DATA_PATH_CV2_3 <- here("experiments/conceptviz_2/data/raw/run3/")
TIDY_RAW_HUMAN <- here("data/processed/tidy_raw_human_data.csv")


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

write_csv(all_data, TIDY_RAW_HUMAN)
