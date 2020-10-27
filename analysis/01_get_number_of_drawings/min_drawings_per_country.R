# get number of drawings per country per category
library(tidyverse)
library(here)
library(corpus) # for reading jaw ndjson files

CATEGORY_INFO_PATH <- here("data/raw/google_categories_coded.csv") #here("data\\raw\\google_categories_coded.csv")
RAW_DRAWING_PATH <- here("analysis/01_get_number_of_drawings/temp/") #file.path("C:/Users/binz7/Documents/.quickdraw") ## the ndjson files of the quickdraw package are downloaded on my laptop
COUNT_OUTPATH <- here("analysis/01_get_number_of_drawings/temp/temp_category_counts.csv")

categories <- read_csv(CATEGORY_INFO_PATH)

target_categories <- categories %>%
  filter(exclude == 0) %>%
  select(google_category_name) %>%
  rename(category = google_category_name) %>%
  arrange(category) %>%
  filter(category %in% c("triangle", "line"))

get_n_drawings_per_item <- function(category_name, file_path){
  name <- paste0(category_name, ".ndjson")
  json_file <- file.path(file_path, name)
  df <- read_ndjson(json_file)

  df %>%
    count(countrycode) %>%
    mutate(category = category_name)
}

all_category_counts <- map_df(target_categories$category,
       get_n_drawings_per_item,
       RAW_DRAWING_PATH) %>%
  arrange(category, n)

write_csv(all_category_counts, COUNT_OUTPATH)






