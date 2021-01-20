# sample drawing pairs for an item by country

library(tidyverse)
library(feather)
library(here)

ITEM <- "chair"
MIN_DRAWINGS_BY_COUNTRY <- 250 # only considering drawings with at least MIN_DRAWINGS_BY_COUNTRY drawings for this item
N_SAMPLES_PER_COUNTRY <- 200
DATA_PATH <- paste0("/Volumes/wilbur_the_great/CONCEPTVIZ/raw_data/feathers/all/", ITEM, '_tidy.txt')
OUTFILE <- here(paste0("experiments/conceptviz_2/data/drawing_samples/", ITEM, "_country_balanced_sample.csv"))

raw_data <- read_feather(DATA_PATH)

n_drawings_by_country <- raw_data %>%
  distinct(countrycode, key_id) %>%
  count(countrycode) %>%
  filter(n >= MIN_DRAWINGS_BY_COUNTRY)

sample_ids <- raw_data %>%
  filter(countrycode %in% n_drawings_by_country$countrycode) %>%
  distinct(countrycode, key_id) %>%
  group_by(countrycode) %>%
  sample_n(N_SAMPLES_PER_COUNTRY)

write_csv(sample_ids, OUTFILE)
