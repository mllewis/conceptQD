# computing the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

# library(pracma) # hausdorff_dist()
library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(proxy)
library(here)
library(tidyverse)
library(jsonlite)
#library(foreach)
#library(doParallel)
#library(dtpylr)
library(parallel)


CATEGORY_INFO_PATH <- here("data/raw/288_categories.csv")
TARGET_COUNTRIES_PATH <- here("data/raw/20_countries.csv")
DRAWING_DIRECTORY <- "/Users/mollylewis/Downloads/temp2/" #file.path("C:/Users/binz7/Documents/sampled_drawings")
OUTPATH_DIRECTORY <- "/Users/mollylewis/Downloads/temp2/"
N_COMP_CLUSTERS <- 3

### helper functions
get_similarity_for_one_drawing_pair <- function(c1_df, c2_df){

  # get euclidean and mahalanobis
  drawing1 <- matrix(c(c1_df$x, c1_df$y), length(c1_df$x), 2)
  drawing2 <- matrix(c(c2_df$x, c2_df$y), length(c2_df$x), 2)
  maha <- mean(mahalanobis.dist(drawing1, drawing2))
  eucl <- mean(proxy::dist(x = drawing1, y = drawing2, method = "euclidean"))

  # get hausdorff
  drawing1 <- matrix(c(c1_df$x, c1_df$y), 2, length(c1_df$x), byrow = TRUE)
  drawing2 <- matrix(c(c2_df$x, c2_df$y), 2, length(c2_df$x), byrow = TRUE)

  avgh <- computeAverageHausdorffDistance(drawing1, drawing2)

  tibble(drawing_id_1 = c1_df$key_id[1],
         drawing_id_2 = c1_df$key_id[1],
         mahalanobis = maha,
         euclidean = eucl,
         avg_haus = avgh)
}

get_long_coordinates <- function(draw){ # similiar to tidy_qd but vectorized
  long_draw <- map_dfr(draw, function(st) {
    tibble::tibble(x = st[[1]], y = 255 - st[[2]])},
    .id = "stroke")
  long_draw
}

get_tidy_for_one_country_one_category <- function(country,
                                                  category,
                                                  drawing_path){
  path <- paste0(drawing_path, "/",
                 category, "_",
                 country, "_sampled_drawings.ndjson")

  json_path <- file(path)
  raw_json <- jsonlite::stream_in(json_path, simplifyMatrix = FALSE)

  qd_tidy <- raw_json %>%
    mutate(item = 1:n(),
           temp = map(drawing, get_long_coordinates)) %>%
    select(-drawing) %>%
    unnest() %>%
    mutate(stroke = as.numeric(stroke),
           country = country)
}

get_distances_for_one_country_pair_and_category <- function(c1,
                                                            c2,
                                                            target_category,
                                                            distance_inpath,
                                                            distance_outpath) {
  #print(Sys.time())

  c1_data <- get_tidy_for_one_country_one_category(c1, target_category, distance_inpath) %>%
    group_by(item) %>%
    nest()

  c2_data <- get_tidy_for_one_country_one_category(c2, target_category, distance_inpath) %>%
    group_by(item) %>%
    nest()

  country_country_category_distances <- inner_join(c1_data, c2_data, by = "item")  %>% # gets minimum num in both countries
    mutate(temp = map2(data.x, data.y, get_similarity_for_one_drawing_pair)) %>%
    select(-contains("data")) %>%
    unnest() %>%
    mutate(category = target_category,
           country1 = c1,
           country2 = c2)

  path <- paste0(distance_outpath, "/",
                 c1, "_",
                 c2, "_",
                 target_category,
                 "_distances.csv")

  write_csv(country_country_category_distances, path, col_names = T)
}

############# DO THE THING ##########
twenty_countries <- read_csv(TARGET_COUNTRIES_PATH) %>%
  arrange(countries) %>%
  filter(countries %in%  c("SE", "TH", "US"))

categories <- read_csv(CATEGORY_INFO_PATH)

country_category_pairs_to_loop <- crossing(country1 = twenty_countries$countries,
                                           country2 = twenty_countries$countries,
                                           categories$category) %>%
                                          # category = c("zigzag", "bread")) %>%
  filter(country1 < country2) %>%
  as.data.frame()


# INITIATE CLUSTER
cluster <- makeCluster(N_COMP_CLUSTERS, type = "FORK")

parallel_wrapper <- function(i, combos, prefix_path, outpath){
  country1 <- combos %>% slice(i) %>% pull(country1)
  country2 <- combos %>% slice(i) %>% pull(country2)
  category <-  combos %>% slice(i) %>% pull(category)

 get_distances_for_one_country_pair_and_category(country1,
                                                          country2,
                                                          category,
                                                          prefix_path,
                                                          outpath)
}

print(Sys.time())

# DO THE THING (IN PARALLEL)
parLapply(cluster,
          1:nrow(country_category_pairs_to_loop),
          parallel_wrapper,
          country_category_pairs_to_loop,
          DRAWING_DIRECTORY,
          OUTPATH_DIRECTORY)

print(Sys.time())

get_distances_for_one_country_pair_and_category("SE",
                                                "TH",
                                                "bread",
                                                DRAWING_DIRECTORY,
                                                OUTPATH_DIRECTORY)

t1 = Sys.time()
c2_data <- get_tidy_for_one_country_one_category("TH", "bread", DRAWING_DIRECTORY)
t2 = Sys.time()

t2 - t1

write_csv(c2_data, paste(OUTPATH_DIRECTORY, "TH_bread.csv"))

t1 = Sys.time()
read_csv(out)
t2 = Sys.time()

t2 - t1
