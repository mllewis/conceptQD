# computing the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

# library(pracma) # hausdorff_dist()
library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(proxy)
library(quickdraw)
library(here)
library(tidyverse)
library(corpus)
library(foreach)
library(doParallel)


CATEGORY_INFO_PATH <- here("data/raw/288_categories.csv")
TARGET_COUNTRIES_PATH <- here("data/raw/20_countries.csv")
DRAWING_DIRECTORY <- file.path("C:/Users/binz7/Documents/sampled_drawings")
OUTPATH_DIRECTORY <- file.path("C:/Users/binz7/Documents/distances_by_country_pairs")


twenty_countries <- read_csv(TARGET_COUNTRIES_PATH) %>%
  arrange(countries) %>%
  mutate(num = 1:20)

country_pairs_to_loop <- crossing(country1 = twenty_countries$countries,
                                  country2 = twenty_countries$countries) %>%
  filter(country1 < country2) %>%
  as.data.frame()

country_num_to_loop <- crossing(country1_num = twenty_countries$num,
                                country2_num = twenty_countries$num) %>%
  filter(country1_num < country2_num) %>%
  as.data.frame()

categories <- read_csv(CATEGORY_INFO_PATH)


### Some helper functions for getting the ndjsons files

get_ndjson_for_one_country_one_category <- function(country,
                                                    category,
                                                    drawing_path)
{
  path <- paste0(drawing_path, "/",
                 category, "_",
                 country, "_sampled_drawings.ndjson")

  json_path <- file(path)
  df <- read_ndjson(json_path)
}

get_20_ndjsons_for_one_category <- function(category,
                                            drawing_path,
                                            target_countries)
{
  ndjsons_in_a_list <- map(target_countries,
                           get_ndjson_for_one_country_one_category,
                           category,
                           drawing_path)

  names(ndjsons_in_a_list) <- paste0(target_countries)

  return(ndjsons_in_a_list)
}

###


# To do: get this more efficient
get_similarity_for_one_drawing_pair <- function(i, c1_df, c2_df)
{
  tidied1 <- qd_tidy(c1_df, i)
  tidied2 <- qd_tidy(c2_df, i)

  drawing1 <- matrix(c(tidied1$x, tidied1$y), length(tidied1$x), 2)
  drawing2 <- matrix(c(tidied2$x, tidied2$y), length(tidied2$x), 2)

  maha <- mean(mahalanobis.dist(drawing1, drawing2))
  eucl <- mean(proxy::dist(x = drawing1, y = drawing2, method = "euclidean"))
  # original eucl <- euclidean_dist(drawing1, drawing2)

  drawing1 <- matrix(c(tidied1$x, tidied1$y), 2, length(tidied1$x), byrow = TRUE)
  drawing2 <- matrix(c(tidied2$x, tidied2$y), 2, length(tidied2$x), byrow = TRUE)

  avgh <- computeAverageHausdorffDistance(drawing1, drawing2)

  id1 = c1_df$key_id[i]
  id2 = c2_df$key_id[i]

  tibble(drawing_id_1 = id1,
         drawing_id_2 = id2,
         mahalanobis = maha,
         euclidean = eucl,
         avg_haus = avgh)
}



get_distances_for_one_country_pair_and_category <- function(c1_num,
                                                            c2_num,
                                                            target_category,
                                                            distance_outpath,
                                                            list_of_ndjsons,
                                                            target_countries)
{
  print(Sys.time())

  c1_data <- list_of_ndjsons[[c1_num]]
  c2_data <- list_of_ndjsons[[c2_num]]

  c1 = target_countries[c1_num]
  c2 = target_countries[c2_num]

  target_number_of_pairs <- min(nrow(c1_data), nrow(c2_data))

  # Looping over individual pairs of drawings
  distances_for_one_pair_one_cat <- map_df(1:target_number_of_pairs,
                                           get_similarity_for_one_drawing_pair,
                                           c1_data,
                                           c2_data) %>%
    mutate(category = target_category,
           country1 = c1,
           country2 = c2)

  path <- paste0(distance_outpath, "/",
                 c1, "_",
                 c2, "_",
                 target_category,
                 "_distances.csv")
  write_csv(distances_for_one_pair_one_cat, path, col_names = T)
}



get_distances_for_one_category_for_all_country_pairs <- function(category,
                                                                 outpath,
                                                                 drawing_path,
                                                                 looping_nums,
                                                                 target_countries)
{
  print(category)

  # Getting the drawings all at once outside to not repeatedly read in the drawings inside
  ndjsons <- get_20_ndjsons_for_one_category(category,
                                             drawing_path,
                                             target_countries)

  # Looping over country pairs
  walk2(looping_nums$country1_num,
        looping_nums$country2_num,
        get_distances_for_one_country_pair_and_category,
        category,
        outpath,
        ndjsons,
        target_countries)
}

