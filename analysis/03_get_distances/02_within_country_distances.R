# computing the distances between drawing pairs within countries for given categories (mahalanobis, avg_hausdorff, euclidean)

library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(proxy) # euclidean distance
library(here)
library(tidyverse)
library(foreach)
library(doParallel)
library(parallel)

CATEGORY_INFO_PATH <- here("data/raw/288_categories.csv")
TARGET_COUNTRIES_PATH <- here("data/raw/20_countries.csv")
DRAWING_DIRECTORY <- file.path("C:/Users/binz7/Documents/tidy_drawings")
OUTPATH_DIRECTORY <- file.path("C:/Users/binz7/Documents/within_country_distances")

############# FUNCTIONS ##########
get_similarity_for_one_drawing_pair <- function(df1, df2){
  
  # get euclidean and mahalanobis
  drawing1 <- matrix(c(df1$x, df1$y), length(df1$x), 2)
  drawing2 <- matrix(c(df2$x, df2$y), length(df2$x), 2)
  
  a <- try(mean(mahalanobis.dist(drawing1, drawing2)), silent = T)
  maha <- ifelse(typeof(a) == "double", a, NA)
  
  eucl <- mean(proxy::dist(x = drawing1, y = drawing2, method = "euclidean"))
  
  # get hausdorff
  drawing1 <- matrix(c(df1$x, df1$y), 2, length(df1$x), byrow = TRUE)
  drawing2 <- matrix(c(df2$x, df2$y), 2, length(df2$x), byrow = TRUE)
  
  avgh <- computeAverageHausdorffDistance(drawing1, drawing2)
  
  tibble(drawing_id_1 = df1$key_id[1],
         drawing_id_2 = df2$key_id[1],
         mahalanobis = maha,
         euclidean = eucl,
         avg_haus = avgh
  )
}

get_distances_for_one_country_category_pair <- function(target_country,
                                                        target_category,
                                                        distance_inpath,
                                                        distance_outpath) {
  
  # read in tidy csv the target category and target country
  path <- paste0(distance_inpath, "/",
                 target_category, "_",
                 target_country, "_sampled_drawings.csv")
  
  country_data <- read_csv(path, col_types = "cclcnnnnc") %>% 
    group_by(item) %>%
    nest()
  
  last <- nrow(country_data)
  mid <- floor(last/2)
  data1 <- country_data[1:mid,]
  data2 <- country_data[(mid+1):last, ]
  data2$item <- seq.int(nrow(data2))
  
  # calculate distances
  country_category_distances <- inner_join(data1, data2, by = "item") %>% # gets all pairs
    mutate(temp = map2(data.x, data.y, get_similarity_for_one_drawing_pair)) %>%
    select(-contains("data")) %>%
    unnest() %>%
    mutate(category = target_category,
           country = target_country) %>%
    ungroup() %>%
    select(-item)
  
  full_outpath <- paste0(distance_outpath, "/",
                         target_country, "_",
                         target_category,
                         "_distances.csv")
  
  write_csv(country_category_distances, full_outpath, col_names = T)
}

############# DO THE THING (IN PARALLEL) ##########
twenty_countries <- read_csv(TARGET_COUNTRIES_PATH) %>%
  arrange(countries)

categories <- read_csv(CATEGORY_INFO_PATH)

country_category_pairs_to_loop <- crossing(country = twenty_countries$countries,
                                           category = categories$category) %>%
  as.data.frame()

# INITIATE CLUSTER

parallel_wrapper <- function(i, combos, prefix_path, outpath){
  country <- combos %>% slice(i) %>% pull(country)
  category <-  combos %>% slice(i) %>% pull(category)
  
  temp <- get_distances_for_one_country_category_pair(country,
                                                      category,
                                                      prefix_path,
                                                      outpath)
}


num_cores <- detectCores() - 1
clusters <- parallel::makeCluster(num_cores)
registerDoParallel(clusters)

system.time(
foreach(i = 1:5760, .packages = c("ecr", "StatMatch", "proxy", "purrr", "tidyr", "dplyr", "readr")) %dopar% {
  parallel_wrapper(i, country_category_pairs_to_loop, DRAWING_DIRECTORY, OUTPATH_DIRECTORY)
}
)

stopCluster(clusters) 
