# use umap algorithm to get similarity distances

library(tidyverse)
library(quickdraw)
library(here)
library(uwot)
library(parallel)
library(broom)
library(lsa)

NCLUSTERS <- 3
OUTPATH <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations11.csv")
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


human_data <- read_csv(HUMAN_DATA_PATH,
                       col_types = c("cdccdddddd"))

item_human_data <- human_data %>%
  filter(category == ITEM_NAME) %>%
  slice(1:200)

# get metadata for target items
target_meta_data_large <- item_meta_data_large %>%
  filter(key_id %in% c(item_human_data$drawing_key_id_1,
                       item_human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)

training_row_ids <- target_meta_data_large$row_id

# params1
params <- cross(list(
     n_components = c(30, 50),
     n_neighbors = c(5, 50),
     learning_rate = c( .5, .75),
     metric = "euclidean",
     scale = FALSE,
     min_dist =  .01,
     local_connectivity = c(2,10),
     bandwidth = 1,
     repulsion_strength = 2,
     n_epochs = c(1000)
))


# local_connectivity = 10
# n_components = 100
# n_neighbors = 5 # or larger #? # 50
# repulsion_strength = 2 #? # 10?
# learning_rate = .5 # or smaller? #.25, .1
# min_dist = .01 # (default)
# bandwidth = 1 # (default)
# scale = FALSE # (defualt)
# metric = "euclidean" # (default)
#
# # params2
# params <- cross(list(
#   local_connectivity =c(1,2,3),
#   n_components = c(20, 30, 40, 50),
#   n_neighbors = c(2, 3,4,5),
#   repulsion_strength =c(20, 50, 100)
#
# ))
#
# #params3
# #params <- cross(list(
# #local_connectivity =c(50),
# #n_components = c(50, 100),
# #n_neighbors = c(5, 10, 15),
# #repulsion_strength =c(1)
# #))
#
# #params <- cross(list(
# #  local_connectivity =c(50),
# #  n_components = c(100, 200, 500),
# #  n_neighbors = c(5, 10, 15, 50, 100),
# #  repulsion_strength =c(1)
# #))
#
# params <- cross(list(
#   local_connectivity = c(2, 10),
#   n_components = 100,
#   n_neighbors = c(5, 50, 100, 200, 50, 100, 200),
#   repulsion_strength =c(1, 1, 1, 1, 2, 2, 2, 2, 2)
# ))


get_umap_corr <- function(params, bitmaps, ids, meta, human, path){

# get bitmap coordinates
umap_coordinates <- umap(
    bitmaps[ids,],   # item_bitmap[target_meta_data$row_id,],
    n_components = params$n_components,
    n_neighbors = params$n_neighbors,
    local_connectivity = params$local_connectivity,
    repulsion_strength = params$repulsion_strength,
    learning_rate = params$learning_rate,
    metric = params$metric,
    scale = params$scale,
    min_dist =  params$min_dist,
    bandwidth = params$bandwidth,
    n_epochs = params$n_epochs,
    init = "random") %>%
  as_tibble() %>%
  mutate(row_id = ids) %>%
  left_join(meta %>% select(row_id, key_id)) %>%
  filter(key_id %in% meta$key_id)

  full_df <- map2_df(human$drawing_key_id_1,
                           human$drawing_key_id_2,
                   get_ummap_distances,
                   umap_coordinates) %>%
  left_join(human)

  cor_df <- tidy(cor.test(full_df$mean, full_df$cosine_distance)) %>%
    bind_cols(data.frame(
      n_components = params$n_components,
      n_neighbors = params$n_neighbors,
      local_connectivity = params$local_connectivity,
      repulsion_strength = params$repulsion_strength,
      learning_rate = params$learning_rate,
      metric = params$metric,
      scale = params$scale,
      min_dist =  params$min_dist,
      bandwidth = params$bandwidth,
      n_epochs = params$n_epochs
    ))

  write_csv(cor_df, path, append = T)

}



############# DO THE THING ##########

# INITIATE CLUSTER
cluster <- makeCluster(NCLUSTERS, type = "FORK")

# WRAPPER FUNCTION
parallel_wrapper <- function(param){
  get_umap_corr(param,
                item_bitmap,
                training_row_ids,
                target_meta_data_large,
                item_human_data,
                OUTPATH)

}

for (i in 1:10){
# DO THE THING (IN PARALLEL)
parLapply(cluster, params, parallel_wrapper)
}
