# computing the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(proxy)
library(here)
library(tidyverse)
#library(foreach)
#library(doParallel)
library(parallel)

CATEGORY_INFO_PATH <- here("data/raw/288_categories.csv")
TARGET_COUNTRIES_PATH <- here("data/raw/20_countries.csv")
DRAWING_DIRECTORY <- "/Users/mollylewis/Downloads/temp2/" #file.path("C:/Users/binz7/Documents/sampled_drawings")
OUTPATH_DIRECTORY <- "/Users/mollylewis/Downloads/temp2/"
N_COMP_CLUSTERS <- 3

############# FUNCTIONS ##########
get_similarity_for_one_drawing_pair <- function(c1_df, c2_df){

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

  tibble(drawing_id_1 = c1_df$key_id[1],
         drawing_id_2 = c1_df$key_id[1],
         mahalanobis = maha,
         euclidean = eucl,
         avg_haus = avgh
         )
}

get_distances_for_one_country_pair_and_category <- function(c1,
                                                            c2,
                                                            target_category,
                                                            distance_inpath,
                                                            distance_outpath) {

  # read in tidy csvs for each country
  path1 <- paste0(distance_inpath, "/",
                  target_category, "_",
                  c1, "_sampled_drawings.csv")

  c1_data <- read_csv(path1) %>%
    group_by(item) %>%
    nest()

  path2 <- paste0(distance_inpath, "/",
                  target_category, "_",
                  c2, "_sampled_drawings.csv")

  c2_data <- read_csv(path2) %>%
    group_by(item) %>%
    nest()

  # calculate distances
  country_country_category_distances <- inner_join(c1_data, c2_data, by = "item")  %>% # gets minimum num in both countries
    mutate(temp = map2(data.x, data.y, get_similarity_for_one_drawing_pair)) %>%
    select(-contains("data")) %>%
    unnest() %>%
    mutate(category = target_category,
           country1 = c1,
           country2 = c2)

  full_outpath <- paste0(distance_outpath, "/",
                 c1, "_",
                 c2, "_",
                 target_category,
                 "_distances.csv")

  write_csv(country_country_category_distances, full_outpath, col_names = T)
}

############# DO THE THING (IN PARALLEL) ##########
twenty_countries <- read_csv(TARGET_COUNTRIES_PATH) %>%
  arrange(countries)

categories <- read_csv(CATEGORY_INFO_PATH)

country_category_pairs_to_loop <- crossing(country1 = twenty_countries$countries,
                                           country2 = twenty_countries$countries,
                                           categories$category) %>%
  filter(country1 < country2) %>%
  as.data.frame()

# INITIATE CLUSTER
cluster <- makeCluster(N_COMP_CLUSTERS, type = "FORK")

parallel_wrapper <- function(i, combos, prefix_path, outpath){
  country1 <- combos %>% slice(i) %>% pull(country1)
  country2 <- combos %>% slice(i) %>% pull(country2)
  category <-  combos %>% slice(i) %>% pull(category)

 temp <- get_distances_for_one_country_pair_and_category(country1,
                                                         country2,
                                                         category,
                                                         prefix_path,
                                                         outpath)
}

parLapply(cluster,
          1:nrow(country_category_pairs_to_loop),
          parallel_wrapper,
          country_category_pairs_to_loop,
          DRAWING_DIRECTORY,
          OUTPATH_DIRECTORY)
