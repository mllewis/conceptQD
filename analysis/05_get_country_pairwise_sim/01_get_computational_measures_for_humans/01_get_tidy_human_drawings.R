# get tidy version of drawings that were used in human judgments

library(here)
library(tidyverse)
library(jsonlite)
library(parallel)

TARGET_DRAWINGS <- here("data/processed/by_item_human_means.csv")
DRAWING_DIRECTORY <- here("data/raw/raw_human_drawings/full_simplified_")
OUTPATH_DIRECTORY <- here("data/processed/tidy_human_drawings/")

############# FUNCTIONS ##########
get_long_coordinates <- function(draw){ # similiar to tidy_qd but vectorized
  long_draw <- map_dfr(draw, function(st) {
    tibble::tibble(x = st[[1]], y = 255 - st[[2]])},
    .id = "stroke")
  long_draw
}

get_tidy_for_one_human_category <- function(category,
                                                drawing_key_ids,
                                                drawing_path,
                                                outpath){

  path <- paste0(drawing_path,
                 category, ".ndjson")

  json_path <- file(here(path))
  raw_json <- jsonlite::stream_in(json_path, simplifyMatrix = FALSE)

  target_ids <- pull(drawing_key_ids, drawing_key_id)

  qd_tidy <- raw_json %>%
    filter(key_id %in% target_ids) %>% # filter to only human drawings
    mutate(item = 1:n(),
           temp = map(drawing, get_long_coordinates)) %>%
    select(-drawing) %>%
    unnest() %>%
    mutate(stroke = as.numeric(stroke))

  full_outpath <- here(paste0(outpath, "/",
                                "tidy_human_", category, "_drawings.csv"))
  write_csv(qd_tidy, full_outpath)

}

target_drawings <- read_csv(TARGET_DRAWINGS) # drawings we have human judgments for

nested_target_ids <- target_drawings %>%
  select(category, drawing_key_id_1, drawing_key_id_2) %>%
  pivot_longer(cols= c("drawing_key_id_1", "drawing_key_id_2"), values_to = "drawing_key_id") %>%
  select(-name) %>%
  mutate(drawing_key_id = as.character(drawing_key_id)) %>%
  group_by(category) %>%
  nest() %>%
  ungroup()

walk2(nested_target_ids$category,
      nested_target_ids$data,
      get_tidy_for_one_human_category,
      DRAWING_DIRECTORY,
      OUTPATH_DIRECTORY)

