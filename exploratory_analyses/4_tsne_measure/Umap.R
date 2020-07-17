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
  # bread_bitmap[target_breads$row_id,],
  bread_bitmap,
  init = "random") %>%
  as.data.frame() %>%
  mutate(row_id = 1:n()) %>%
  left_join(target_breads)


umap_coordinates <- umap(
    bread_bitmap,
   # bread_bitmap,
    n_components = 5,
    n_neighbors = 5,
    learning_rate = .5,
    local_connectivity = 2,
    bandwidth = 1,
    repulsion_strength = 2,
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


cor.test(full_df$human_rating_mean, full_df$euclidean_distance)
cor.test(full_df$human_rating_mean, full_df$cosine_distance)


ggplot(full_df, aes(x = cosine_distance, y = human_rating_mean)) +
  geom_point() +
  geom_smooth(method = "lm")

# compare to tsne
