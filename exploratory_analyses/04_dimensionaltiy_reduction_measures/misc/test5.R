# use umap algorithm to get similarity distances

library(tidyverse)
library(quickdraw)
library(here)
library(uwot)
library(lsa)

get_ummap_distances <- function(key_id_1, key_id_2, df){
  coordinates <- filter(df, key_id %in% c(key_id_1, key_id_2)) %>%
    select(-key_id)

  data.frame(drawing_key_id_1 = key_id_1,
             drawing_key_id_2 = key_id_2,
             euclidean_distance = dist(coordinates)[1],
             cosine_distance = lsa::cosine(as.matrix(t(coordinates)))[1,2])
}

ITEM_NAME <- "bread"
HUMAN_DATA_PATH <- here("data/processed/human_data/by_item_means.csv")

item_meta_data <- qd_read(ITEM_NAME)
item_bitmap <- qd_read_bitmap(ITEM_NAME)

human_data <- read_csv(HUMAN_DATA_PATH,
                       col_types = c("cdccdddddd"))

item_human_data <- human_data %>%
  filter(category == ITEM_NAME)

target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)

umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = target_breads$key_id)

full_df <- map2_df(human_data$drawing_key_id_1,
                   human_data$drawing_key_id_2,
                   get_ummap_distances,
                   umap_coordinates) %>%
  left_join(human_data)

cor.test(full_df$mean, full_df$euclidean_distance)


####################### The above works

full_df
head(full_df)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 5,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = target_breads$key_id)
get_ummap_distances <- function(key_id_1, key_id_2, df){
  coordinates <- filter(df, key_id %in% c(key_id_1, key_id_2)) %>%
    select(-key_id)
  data.frame(drawing_key_id_1 = key_id_1,
             drawing_key_id_2 = key_id_2,
             euclidean_distance = dist(coordinates)[1],
             cosine_distance = lsa::cosine(as.matrix(t(coordinates)))[1,2])
}
full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
umap_coordinates
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 10,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = target_breads$key_id)
get_ummap_distances <- function(key_id_1, key_id_2, df){
  coordinates <- filter(df, key_id %in% c(key_id_1, key_id_2)) %>%
    select(-key_id)
  data.frame(drawing_key_id_1 = key_id_1,
             drawing_key_id_2 = key_id_2,
             euclidean_distance = dist(coordinates)[1],
             cosine_distance = lsa::cosine(as.matrix(t(coordinates)))[1,2])
}
full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
