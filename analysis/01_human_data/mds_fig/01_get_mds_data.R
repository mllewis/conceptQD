# get pairwise predicted distances for sample of 50 items for making mds figures
library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(proxy)
library(tidyverse)
library(here)

HUMAN_DATA_PATH <- here("data/processed/tidy_human_data_with_computational_measures.csv")
MODEL_PARAMS <- here("data/processed/human_data_predic_model_params.csv")
DRAWING_DIRECTORY <- here("data/processed/tidy_human_drawings/")
OUTFILE <-  here("analysis/01_human_data/mds_fig/bird_100_pairwise_distances.csv")
TARGET_CATEGORY <- "bird"
N_DRAWINGS <- 100

human_data <- read_csv(HUMAN_DATA_PATH)

target_items <- human_data %>%
  filter(category == TARGET_CATEGORY) %>%
  select(pair_id, category, drawing_key_id_1, drawing_key_id_2) %>%
  pivot_longer(3:4, values_to = "key_id") %>%
  sample_n(N_DRAWINGS) %>%
  mutate(key_id = as.character(key_id))

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
        # eucllidean2 = euc2,
         avg_haus = avgh
  )
}



target_drawings <-
  read_csv(here(paste0(DRAWING_DIRECTORY, "/", "tidy_human_", TARGET_CATEGORY, "_drawings.csv")))

target_items <- target_drawings %>%
  mutate(key_id = as.character(key_id)) %>%
  group_by(key_id) %>%
  nest() %>%
  filter(key_id %in% target_items$key_id)

all_target_pairs <- cross_df(list(drawing_key_id_1 = target_items$key_id,
                                  drawing_key_id_2 = target_items$key_id))

drawing_pairs_with_data <- all_target_pairs %>%
  mutate_all(as.character) %>%
  left_join(target_items, by  = c("drawing_key_id_1" = "key_id")) %>%
  rename(data1 = data) %>%
  left_join(target_items, by  = c("drawing_key_id_2" = "key_id")) %>%
  rename(data2 = data)

drawing_distances <- list(drawing_pairs_with_data$drawing_key_id_1,
                          drawing_pairs_with_data$drawing_key_id_2,
                          drawing_pairs_with_data$data1,
                          drawing_pairs_with_data$data2) %>%
  pmap_df(get_similarity_for_one_drawing_pair)


# get predictions with mutliple measures
params <- read_csv(MODEL_PARAMS)

intercept <- params %>% filter(term == "(Intercept)") %>% pull(estimate)
haus_beta <- params %>% filter(term == "log_avg_haus") %>% pull(estimate)
mahal_beta <- params %>% filter(term == "mahalanobis") %>% pull(estimate)
euc_beta <- params %>% filter(term == "euclidean") %>% pull(estimate)


df_with_predics <- drawing_distances %>%
  dplyr::mutate(log_avg_haus = log(avg_haus),
         human_predic_sim = intercept +
           (haus_beta*log_avg_haus) +
           (mahal_beta*mahalanobis) +
           (euc_beta *euclidean))


write_csv(df_with_predics, OUTFILE)
