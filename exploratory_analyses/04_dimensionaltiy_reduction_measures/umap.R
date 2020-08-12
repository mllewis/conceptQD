# use umap algorithm to get similarity distances

library(tidyverse)
library(quickdraw)
library(here)
library(uwot)
library(lsa)


get_ummap_distances <- function(key_id_1, key_id_2, df){
  coordinates <- filter(df, key_id %in% c(key_id_1, key_id_2)) %>%
    select(contains("V"))

  data.frame(drawing_key_id_1 = key_id_1,
             drawing_key_id_2 = key_id_2,
             euclidean_distance = dist(coordinates)[1],
             cosine_distance = lsa::cosine(as.matrix(t(coordinates)))[1,2])
}
ITEM_NAME <- "bread"
HUMAN_DATA_PATH <- here("data/processed/human_data/by_item_means.csv")

item_meta_data_large <- qd_read(ITEM_NAME) %>%
  mutate(row_id = 1:n())

item_bitmap <- qd_read_bitmap(ITEM_NAME)


##
human_data <- read_csv(HUMAN_DATA_PATH,
                       col_types = c("cdccdddddd"))

item_human_data <- human_data %>%
  filter(category == ITEM_NAME)

# get metadata for target items
target_meta_data_large <- item_meta_data_large %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1,
                       item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)

training_row_ids <- sample(1:nrow(item_meta_data), 1) %>%
  c(target_meta_data_large$row_id) %>%
  unique()

# get bitmap coordinates
umap_coordinates_large <- umap(
    item_bitmap[training_row_ids,],   # item_bitmap[target_meta_data$row_id,],
    n_components = 30, #30
    n_neighbors = 5,
    learning_rate = .5,
    local_connectivity = 2,
    bandwidth = 1,
    repulsion_strength = 2,
    init = "random") %>%
  as_tibble() %>%
  mutate(row_id = training_row_ids) %>%
  left_join(item_meta_data_large %>% select(row_id, key_id)) %>%
  filter(key_id %in% target_meta_data_large$key_id)

full_df_large <- map2_df(item_human_data$drawing_key_id_1,
                   item_human_data$drawing_key_id_2,
                   get_ummap_distances,
                   umap_coordinates_large) %>%
  left_join(item_human_data)

cor.test(full_df_large$mean, full_df_large$euclidean_distance)
cor.test(full_df_large$mean, full_df_large$cosine_distance)


ggplot(full_df_large, aes(x = cosine_distance, y = mean)) +
  geom_point() +
  geom_smooth(method = "lm")

ggplot(full_df_large, aes(x = cosine_distance, y = haus_sim) )+
  geom_point() +
  geom_smooth(method = "lm")

cor.test(full_df_large$haus_sim, full_df_large$cosine_distance)

lm(mean~ haus_sim * cosine_distance, full_df_large) %>%
  summary()

# compare to tsne
