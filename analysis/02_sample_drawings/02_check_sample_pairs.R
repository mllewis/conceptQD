# check that sampled drawing pairs pass tests

library(tidyverse)
library(googledrive)
library(here)

# download pair id file
KEY_PAIR_DF_GOOGLE_ID <- "1xmi1zgD_lnkWLO8dh0K8yssLCZbQe3Dl" # google file ID
KEY_PAIR_DF_OUTPUT_PATH <- here("data/processed/sample_pairs.csv")

#temp <- drive_download(file = as_id(KEY_PAIR_DF_GOOGLE_ID), path = KEY_PAIR_DF_OUTPUT_PATH)

key_pairs <- read_csv(KEY_PAIR_DF_OUTPUT_PATH,
                      col_names = c("category", "country", "key_id_1", "key_id_2"),
                      col_types = c("cccc"))

# check number of countries
count(key_pairs, country) %>%
  arrange(n)

# check number of categories
count(key_pairs, category) %>%
  arrange(n)

# check that all key_ids for a country-category pair are unique
key_pairs %>%
  filter(category == "bread", country == "ID") %>%
  select(key_id_1, key_id_2) %>%
  gather() %>%
  distinct(value)

m = key_pairs %>%
  select(key_id_1, key_id_2) %>%
  gather() %>%
  distinct(value)

# TO DO: check that country codes correctly map on to key_ids
# category_country_sampled_drawings.csv
# "airplane_BR_sampled_drawings.csv"




