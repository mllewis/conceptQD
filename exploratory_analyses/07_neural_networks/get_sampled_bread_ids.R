# Get the key ids of 500 drawings of bread per country for the 20 selected countries

library(tidyverse)
library(here)

PAIRS_PATH <- here("data/processed/sample_pairs.csv")
OUTPATH <- here("exploratory_analyses/07_neural_networks/sampled_bread_ids.csv")


pairs <- read_csv(PAIRS_PATH,
                  col_names = c("category", "country", "key_id_1", "key_id_2"),
                  col_types = c("cccc"))

set.seed(123)

df <- pairs %>%
  filter(category == "bread") %>%
  gather(key = "key", value = "key_id", key_id_1, key_id_2) %>%
  select(-key) %>%
  group_by(country) %>%
  sample_n(500)

write_csv(df, OUTPATH)

