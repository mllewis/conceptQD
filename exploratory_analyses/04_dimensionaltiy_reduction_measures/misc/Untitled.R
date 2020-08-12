library(tidyverse)
library(quickdraw)
library(here)
library(uwot)
library(lsa)
bread <- qd_read("bread")
bread_bitmap <- qd_read_bitmap("bread")
dist_data_path <- here("data/processed/human_data/conceptviz_1_by_item_data.csv")
human_data <- read_csv(dist_data_path) %>%
  slice(1:200)
target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
dist_data_path <- here("data/processed/human_data/by_item_data.csv")
human_data <- read_csv(dist_data_path)
dist_data_path <- here("data/processed/human_data/by_item_means.csv")
human_data <- read_csv(dist_data_path)
human_data
dist_data_path <- here("data/processed/human_data/by_item_means.csv")
human_data <- read_csv(dist_data_path) %>%
  filter(category == "bread")
human_data
target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
target_breads
umap_coordinates <- umap(
  # bread_bitmap[target_breads$row_id,],
  bread_bitmap,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = 1:n()) %>%
  left_join(target_breads)
bread_bitmap[target_breads$row_id,]
nrow(  bread_bitmap[target_breads$row_id,]'')
nrow(  bread_bitmap[target_breads$row_id,])

umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = 1:n()) %>%
  left_join(target_breads)
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
map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
        get_ummap_distances, umap_coordinates)
human_data
umap_coordinates
head(umap_coordinates)
head(target_breads)
target_breads
bread %>%
  mutate(row_id = 1:n())
target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame()
umap_coordinates
target_breads
umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame()
bread_bitmap[target_breads$row_id,]
target_breads
head(bread)
nrow(bread)
nrow(target_breads)
nrow(bread_bitmap)
target_breads
umap_coordinates
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  mutate(key_id = target_breads$key_id)
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = target_breads$key_id)
umap_coordinates
head(umap_coordinates)
full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(human_data)
full_df
cor.test(full_df$human_rating_mean, full_df$euclidean_distance)
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 20,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 50,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 30,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 35,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 25,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 28,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 30,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 30,
  n_neighbors =10,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .2,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 5,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 30,
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
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 3,
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
sample_n(100, 1:100)
sample(100, 1:100)
sample(100, 1:100)
sample(100, 1:100)
sample(100, 1:100)
?sample
sample( 1:1000, 100)
sample(1:nrow(bread_bitmap), 1000)
training_breads <- sample(1:nrow(bread_bitmap), 1000) %>%
  c(target_breads$row_id)
training_breads
umap_coordinates <- umap(
  bread_bitmap[training_breads$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = bread$key_id) %>%
  filter(key_id %in% target_breads$key_id)
training_breads <- sample(1:nrow(bread_bitmap), 1000) %>%
  c(target_breads$row_id) %>%
  unique()
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[training_breads$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random")
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[training_breads,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = bread$key_id) %>%
  filter(key_id %in% target_breads$key_id)
training_breads_row_ids <- sample(1:nrow(bread_bitmap), 1000) %>%
  c(target_breads$row_id) %>%
  unique()
bread_bitmap[training_breads_row_ids, "key_id"]
bread_bitmap[training_breads_row_ids, ]
bread[training_breads_row_ids, "key_id"]
umap_coordinates <- umap(
  bread_bitmap[training_breads_row_ids,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = bread[training_breads_row_ids, "key_id"],) %>%
  filter(key_id %in% target_breads$key_id)
umap_coordinates
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[training_breads_row_ids,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = bread[training_breads_row_ids, "key_id"],)
umap_coordinates
bread
bread <- qd_read("bread") %>%
  mutate(row_id = 1:n())
bread_bitmap <- qd_read_bitmap("bread") %>%
  mutate(row_id = 1:n())
bread_bitmap
target_breads
bread
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[training_breads_row_ids,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = training_breads_row_ids) %>%
  left_join(bread %>% select(row_id, key_id)) %>%
  filter(key_id %in% target_breads$key_id)
umap_coordinates
nrow(umap_coordinates)
full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
training_breads_row_ids <- sample(1:nrow(bread_bitmap), 1) %>%
  c(target_breads$row_id) %>%
  unique()
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[training_breads_row_ids,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = training_breads_row_ids) %>%
  left_join(bread %>% select(row_id, key_id)) %>%
  filter(key_id %in% target_breads$key_id)
full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
training_breads_row_ids
training_breads_row_ids
target_breads
training_breads_row_ids
bread_bitmap[training_breads_row_ids,]
umap(
  bread_bitmap[training_breads_row_ids,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = training_breads_row_ids)
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[training_breads_row_ids,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = training_breads_row_ids) %>%
  left_join(bread %>% select(row_id, key_id)) %>%
  filter(key_id %in% target_breads$key_id)
full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
ITEM_NAME <- "bread"
HUMAN_DATA_PATH <- here("data/processed/human_data/by_item_means.csv")
human_data <- read_csv(HUMAN_DATA_PATH)
item_human_data <- human_data %>%
  filter(category == ITEM_NAME)
target_meta_data <- item_meta_data %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
training_row_ids <- sample(1:nrow(item_meta_data), 1) %>%
  c(target_breads$row_id) %>%
  unique()
ITEM_NAME <- "bread"
HUMAN_DATA_PATH <- here("data/processed/human_data/by_item_means.csv")
item_meta_data <- qd_read(ITEM_NAME) %>%
  mutate(row_id = 1:n())
item_bitmap <- qd_read_bitmap(ITEM_NAME)
human_data <- read_csv(HUMAN_DATA_PATH)
item_human_data <- human_data %>%
  filter(category == ITEM_NAME)
target_meta_data <- item_meta_data %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
training_row_ids <- sample(1:nrow(item_meta_data), 1) %>%
  c(target_breads$row_id) %>%
  unique()
# get bitmap coordinat
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[training_row_ids,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = training_row_ids) %>%
  left_join(item_meta_data %>% select(row_id, key_id)) %>%
  filter(key_id %in% target_meta_data$key_id)
full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(item_human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
full_df <- map2_df(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(item_human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
target_meta_data <- item_meta_data %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[target_meta_data$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random")
umap_coordinates
nrow(umap_coordinates)
# get bitmap coordinates
umap_coordinates <- umap(
  bread_bitmap[target_meta_data$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = target_meta_data$row_id) %>%
  left_join(item_meta_data %>% select(row_id, key_id))
full_df <- map2_df(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(item_human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
setwd("~/Documents/research/Projects/1_in_progress/conceptQD/exploratory_analyses/04_dimensionaltiy_reduction_measures")
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
item_meta_data <- qd_read(ITEM_NAME) %>%
  mutate(row_id = 1:n())
item_bitmap <- qd_read_bitmap(ITEM_NAME)
human_data <- read_csv(HUMAN_DATA_PATH)
item_human_data <- human_data %>%
  filter(category == ITEM_NAME)
target_meta_data <- item_meta_data %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
# get bitmap coordinates
umap_coordinates <- umap(
  item_bitmap[target_meta_data$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = target_meta_data$row_id) %>%
  left_join(item_meta_data %>% select(row_id, key_id))
target_meta_data
full_df <- map2_df(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(item_human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
library(tidyverse)
library(quickdraw)
library(here)
library(uwot)
library(lsa)
bread <- qd_read("bread")
bread_bitmap <- qd_read_bitmap("bread")
dist_data_path <- here("data/processed/human_data/conceptviz_1_by_item_data.csv")
human_data <- read_csv(dist_data_path) %>%
  slice(1:200)
target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  left_join(target_breads)
dist_data_path <- here("data/processed/human_data/by_item_means.csv")
human_data <- read_csv(dist_data_path) %>%
  slice(1:200)
target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  left_join(target_breads)
dist_data_path <- here("data/processed/human_data/by_item_means.csv")
human_data <- read_csv(dist_data_path) %>%
  slice(1:200)
target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
bread_bitmap[target_breads$row_id,]
target_breads
bread
human_data$drawing_key_id_1
human_data <- read_csv(HUMAN_DATA_PATH)
human_data
HUMAN_DATA_PATH <- here("data/processed/human_data/by_item_means.csv")
human_data <- read_csv(HUMAN_DATA_PATH)%>%
  slice(1:200)
human_data
human_data$drawing_key_id_1,
human_data$drawing_key_id_1
target_meta_data
item_meta_data
item_human_data
item_meta_data %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1, item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2))
head(item_meta_data)
human_data <- read_csv(dist_data_path) %>%
  filter(category == "bread")
target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
target_breads
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  left_join(target_breads)
umap_coordinates
umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = target_breads$row_id) %>%
  left_join(target_breads)
umap_coordinates
target_breads
full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(human_data)
cor.test(full_df$human_rating_mean, full_df$euclidean_distance)
cor.test(full_df$human_rating_mean, full_df$cosine_distance)
human_data
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
target_meta_data
item_bitmap[target_meta_data$row_id,]
item_meta_data
item_bitmap
item_bitmap[target_meta_data$row_id,]
item_bitmap[target_meta_data$row_id,] %>% dim(0)
item_bitmap[target_meta_data$row_id,] %>% dim()
target_meta_data$row_idtarget_meta_data
target_meta_data
item_meta_data
target_meta_data
umap_coordinates <- umap(
  item_bitmap[target_meta_data$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = target_meta_data$row_id) %>%
  left_join(target_meta_data)
full_df <- map2_df(item_human_data$drawing_key_id_1,
                   item_human_data$drawing_key_id_2,
                   get_ummap_distances,
                   umap_coordinates) %>%
  left_join(item_human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
item_human_data
?read_csv
human_data <- read_csv(HUMAN_DATA_PATH,
                       col_types = c("cdccdddddd"))
human_data <- read_csv(HUMAN_DATA_PATH,
                       col_types = c("cdccdddddd"))
item_human_data <- human_data %>%
  filter(category == ITEM_NAME)
target_meta_data <- item_meta_data %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1,
                       item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)
# get bitmap coordinates
umap_coordinates <- umap(
  item_bitmap[target_meta_data$row_id,],
  n_components = 30,
  n_neighbors = 5,
  learning_rate = .5,
  local_connectivity = 2,
  bandwidth = 1,
  repulsion_strength = 2,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = target_meta_data$row_id) %>%
  left_join(target_meta_data)
full_df <- map2_df(item_human_data$drawing_key_id_1,
                   item_human_data$drawing_key_id_2,
                   get_ummap_distances,
                   umap_coordinates) %>%
  left_join(item_human_data)
cor.test(full_df$mean, full_df$euclidean_distance)
cor.test(full_df$mean, full_df$cosine_distance)
human_data
item_human_data <- human_data %>%
  filter(category == ITEM_NAME)
item_human_data
umap_coordinates <- umap(
  item_bitmap[target_meta_data$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = target_meta_data$row_id) %>%
  left_join(target_meta_data)
full_df <- map2_df(item_human_data$drawing_key_id_1,
                   item_human_data$drawing_key_id_2,
