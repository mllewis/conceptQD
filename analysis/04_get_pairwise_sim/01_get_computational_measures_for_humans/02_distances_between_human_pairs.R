# computing the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(proxy)
library(here)
library(tidyverse)

TARGET_DRAWING_PAIRS <- here("experiments/conceptviz_2/data/processed/by_item_means.csv")
DRAWING_DIRECTORY <- "data/processed/tidy_human_drawings/"
OUTPATH_DIRECTORY <- here("data/processed/tidy_human_data_with_computational_measures.csv")

############# FUNCTIONS ##########
get_similarity_for_one_drawing_pair <- function(id1, id2, c1_df, c2_df){

  # get euclidean and mahalanobis
  drawing1 <- matrix(c(c1_df$x, c1_df$y), length(c1_df$x), 2)
  drawing2 <- matrix(c(c2_df$x, c2_df$y), length(c2_df$x), 2)
  maha <- NA #this is necessary because maha fails when two drawings are identical (e.g. for line)
  maha <- try(mean(mahalanobis.dist(drawing1, drawing2)))
  eucl <- mean(proxy::dist(x = drawing1, y = drawing2, method = "euclidean"))

  # get hausdorff
  drawing1 <- matrix(c(c1_df$x, c1_df$y), 2, length(c1_df$x), byrow = TRUE)
  drawing2 <- matrix(c(c2_df$x, c2_df$y), 2, length(c2_df$x), byrow = TRUE)

  avgh <- computeAverageHausdorffDistance(drawing1, drawing2)

  tibble(drawing_key_id_1 = id1,
         drawing_key_id_2 = id2,
         mahalanobis = maha,
         euclidean = eucl,
         avg_haus = avgh
         )
}


target_drawings_pairs <- read_csv(TARGET_DRAWING_PAIRS) # drawings we have human judgments for

all_tidy_drawings <- target_drawings_pairs %>%
  distinct(category) %>%
  pull(category) %>%
  map_df(~read_csv(here(paste0(DRAWING_DIRECTORY, "/",
                           "tidy_human_", ., "_drawings.csv"))))

nested_all_tidy_drawings <- all_tidy_drawings %>%
  mutate(key_id = as.character(key_id)) %>%
  group_by(key_id) %>%
  nest()

drawing_pairs_with_data <- target_drawings_pairs %>%
  select(category, drawing_key_id_1, drawing_key_id_2) %>%
  mutate_all(as.character) %>%
  left_join(nested_all_tidy_drawings, by  =c("drawing_key_id_1" = "key_id")) %>%
  rename(data1 = data) %>%
  left_join(nested_all_tidy_drawings, by  =c("drawing_key_id_2" = "key_id")) %>%
  rename(data2 = data)

drawing_distances <- list(drawing_pairs_with_data$drawing_key_id_1,
     drawing_pairs_with_data$drawing_key_id_2,
     drawing_pairs_with_data$data1,
     drawing_pairs_with_data$data2) %>%
  pmap_df(get_similarity_for_one_drawing_pair)

distances_with_human_data <- target_drawings_pairs %>%
  mutate(drawing_key_id_1 = as.character(drawing_key_id_1),
         drawing_key_id_2 = as.character(drawing_key_id_2)) %>%
  left_join(drawing_distances)

write_csv(distances_with_human_data, OUTPATH_DIRECTORY)


