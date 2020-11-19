# get number of drawings per country per category
library(tidyverse)
library(here)
library(corpus) # for reading raw ndjson files

CATEGORY_INFO_PATH <- here("data/raw/google_categories_coded.csv")
RAW_DRAWING_PATH <- file.path("C:/Users/binz7/Documents/.quickdraw") ## ndjson files of the quickdraw drawings that's downloaded locally
COUNT_OUTPATH <- here("data/processed/category_counts.csv")

categories <- read_csv(CATEGORY_INFO_PATH)

target_categories <- categories %>%
  filter(exclude == 0) %>%
  select(google_category_name) %>%
  rename(category = google_category_name) %>%
  arrange(category)

get_n_drawings_per_item <- function(category_name, file_path, out_path){
  name <- paste0(category_name, ".ndjson")
  json_path <- file.path(file_path, name)
  df <- read_ndjson(json_path)

  data_for_one_item <- df %>%
    count(countrycode) %>%
    mutate(category = category_name)

  write_csv(data_for_one_item, out_path, append = T)
  print(category_name)
  print(Sys.time())
}

walk(target_categories$category,
       get_n_drawings_per_item,
       RAW_DRAWING_PATH,
       COUNT_OUTPATH)

