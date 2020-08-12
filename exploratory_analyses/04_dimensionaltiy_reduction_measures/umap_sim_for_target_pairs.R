# use umap algorithm to get similarity distances for each target pair

library(tidyverse)
library(quickdraw)
library(here)
library(uwot)
library(lsa)

ITEMS <- c("bread", "chair", "house", "tree", "bird")
HUMAN_DATA_PATH <- here("data/processed/human_data/by_item_means.csv")
OUTFILE <- here("data/processed/computational_distance_measures/umap_distances.csv")

human_data <- read_csv(HUMAN_DATA_PATH,
                       col_types = c("cdccdddddd"))

get_umap_distances_for_one_pair <- function(key_id_1, key_id_2, df){
  coordinates <- filter(df, key_id %in% c(key_id_1, key_id_2)) %>%
    select(contains("V"))

  data.frame(drawing_key_id_1 = key_id_1,
             drawing_key_id_2 = key_id_2,
             euclidean_distance = dist(coordinates)[1],
             cosine_distance = lsa::cosine(as.matrix(t(coordinates)))[1,2])
}

get_umap_distances <- function(run_num, item_human_data, bitmap, meta_data, training_row_ids){

  # get bitmap coordinates
  umap_coordinates <- umap(
      bitmap[training_row_ids,],   # item_bitmap[target_meta_data$row_id,],
      local_connectivity = 2, # 1 is default could do that
      n_components = 30,
      n_neighbors = 5,
      repulsion_strength = 2,
      learning_rate = .5,
      min_dist = .01, # (default)
      bandwidth = 1, # (default)
      scale = FALSE, # (defualt)
      metric = "euclidean", # (default)
      n_epochs = 1000,
      init = "random") %>%
    as_tibble() %>%
    mutate(row_id = training_row_ids) %>%
    left_join(meta_data %>% select(row_id, key_id)) %>%
    filter(key_id %in% meta_data$key_id)

  map2_df(item_human_data$drawing_key_id_1,
          item_human_data$drawing_key_id_2,
          get_umap_distances_for_one_pair,
          umap_coordinates) %>%
    left_join(item_human_data) %>%
    mutate(run = run_num)
}

get_item_sim <- function(target_item, human_df){

  meta_data <- qd_read(target_item) %>%
    mutate(row_id = 1:n())

  bitmap <- qd_read_bitmap(target_item)

  item_human_data <- human_df %>%
    filter(category == target_item)

  # get metadata for target items
  target_meta_data <- meta_data %>%
    filter(key_id %in% c(item_human_data$drawing_key_id_1,
                         item_human_data$drawing_key_id_2)) %>%
    select(row_id, key_id)

  training_row_ids <- c(target_meta_data$row_id)

  # take mean across samples
  map_df(1:10, get_umap_distances, item_human_data, bitmap, meta_data, training_row_ids) %>%
    group_by(drawing_key_id_1, drawing_key_id_2) %>%
    summarize(mean_umap_cosine = mean(cosine_distance)) %>%
    mutate(item = target_item)

}

all_umap_sims <- map_df(ITEMS, get_item_sim, human_data)

write_csv(all_umap_sims, OUTFILE)
