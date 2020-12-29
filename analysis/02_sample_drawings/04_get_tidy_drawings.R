# get tidy version country-category drawing files (convert from json to csv)

library(here)
library(tidyverse)
library(jsonlite)
library(parallel)


CATEGORY_INFO_PATH <- here("data/raw/288_categories.csv")
TARGET_COUNTRIES_PATH <- here("data/raw/20_countries.csv")
DRAWING_DIRECTORY <- "/Users/mollylewis/Downloads/temp2/" #file.path("C:/Users/binz7/Documents/sampled_drawings")
OUTPATH_DIRECTORY <- "/Users/mollylewis/Downloads/temp2/"
N_COMP_CLUSTERS <- 3

### helper functions
get_long_coordinates <- function(draw){ # similiar to tidy_qd but vectorized
  long_draw <- map_dfr(draw, function(st) {
    tibble::tibble(x = st[[1]], y = 255 - st[[2]])},
    .id = "stroke")
  long_draw
}

get_tidy_for_one_country_one_category <- function(country,
                                                  category,
                                                  drawing_path,
                                                  outpath){
  path <- paste0(drawing_path, "/",
                 category, "_",
                 country, "_sampled_drawings.ndjson")

  json_path <- file(path)
  raw_json <- jsonlite::stream_in(json_path, simplifyMatrix = FALSE)

  qd_tidy <- raw_json %>%
    mutate(item = 1:n(),
           temp = map(drawing, get_long_coordinates)) %>%
    select(-drawing) %>%
    unnest() %>%
    mutate(stroke = as.numeric(stroke),
           country = country)

  full_outpath <- paste0(outpath, "/",
                                category, "_",
                                country, "_sampled_drawings.csv")
  write_csv(qd_tidy, full_outpath)
}


############# DO THE THING ##########
twenty_countries <- read_csv(TARGET_COUNTRIES_PATH) %>%
  arrange(countries)

categories <- read_csv(CATEGORY_INFO_PATH)

country_category_pairs_to_loop <- crossing(country = twenty_countries$countries,
                                           categories$category) %>%
  as.data.frame() %>%
  slice(1)


get_tidy_for_one_country_one_category("SE",
                                      "bread",
                                      DRAWING_DIRECTORY,
                                      DRAWING_DIRECTORY)

# INITIATE CLUSTER
cluster <- makeCluster(N_COMP_CLUSTERS, type = "FORK")

parallel_wrapper <- function(i, combos, prefix_path, outpath){
  country <- combos %>% slice(i) %>% pull(country)
  category <-  combos %>% slice(i) %>% pull(category)

  get_tidy_for_one_country_one_category(country,
                                        category,
                                        prefix_path,
                                        outpath)
}

