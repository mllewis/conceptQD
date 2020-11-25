# computing the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

# library(pracma) # hausdorff_dist()
library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(quickdraw)
library(here)
library(tidyverse)


# loop over country pairs
# loop of categories

# to do: get the sampled drawing pairs, read it in, and fix this code as needed
CATEGORY_INFO_PATH <- here("data/raw/google_categories_coded.csv")
TARGET_COUNTRIES <- c("AU", "BR", "CA", "CZ", "DE", "FI", "GB", "IT", "PL", "RU",
                      "SE", "US", "PH", "FR", "NL", "HU", "SA", "TH", "KR", "ID")
DRAWING_DIRECTORY <- "XXX"
OUTPATH_DIRECTORY <- "XXX"

countries_to_loop <- crossing(country1 = TARGET_COUNTRIES,
                              country2 = TARGET_COUNTRIES) %>%
  filter(country1 < country2) %>%
  as.data.frame()

categories <- read_csv(CATEGORY_INFO_PATH)

target_categories <- categories %>%
  filter(exclude == 0) %>%
  select(google_category_name) %>%
  rename(category = google_category_name) %>%
  arrange(category) %>%
  pull(category)


# find fast euclidean distance package
euclidean_dist <- function (drawing1, drawing2)
{
  x1 <- drawing1[,1]
  y1 <- drawing1[,2]
  x2 <- drawing2[,1]
  y2 <- drawing2[,2]
  e_dist <- 0

  for (i in 1:(length(x1)))
  {
    for (j in 1:(length(x2)))
    {
      e_dist <- e_dist + sqrt((x1[i] - x2[j])^2 + (y1[i] - y2[j])^2)
    }
  }

  e_dist / ((length(x1) * length(x2)))
}

get_similarity_for_one_drawing_pair <- function(i,
                                                c1_data,
                                                c2_data){

  tidied1 <- qd_tidy(c1_data, i)
  tidied2 <- qd_tidy(c2_data, i)

  drawing1 <- matrix(c(tidied1$x, tidied1$y), length(tidied1$x), 2)
  drawing2 <- matrix(c(tidied2$x, tidied2$y), length(tidied2$x), 2)

  #haus <- hausdorff_dist(drawing1, drawing2)
  maha <- mean(mahalanobis.dist(drawing1, drawing2))
  eucl <- euclidean_dist(drawing1, drawing2)

  drawing1 <- matrix(c(tidied1$x, tidied1$y), 2, length(tidied1$x), byrow = TRUE)
  drawing2 <- matrix(c(tidied2$x, tidied2$y), 2, length(tidied2$x), byrow = TRUE)

  avgh <- computeAverageHausdorffDistance(drawing1, drawing2)

  id1 =
  id2

  tibble(drawing_id_1 = id1,
         drawing_id_2 = id2,
         mahalanobis = maha,
         euclidean = eucl,
         avg_haus = avgh)

}

get_country_pair_distances_for_one_category <- function(target_category_name,
                                                        country1,
                                                        country2,
                                                        data_directory ){

  # read in country1-cateogry file
  country1data <- #some json thing after making full data path

  # read in country2-cateogry file
  country2data <- #some json thing after making full data path

  target_number_of_pairs <- min(nrow(country1data), nrow(country2data))

  map_df(1:target_number_of_pairs,
         get_similarity_for_one_drawing_pair,
         country1data,
         country2data) %>%
    mutate(category = target_category_name)

}

get_country_pair_distances_for_all_categories <- function(c1,
                                                          c2,
                                                          category_names,
                                                          drawing_directory,
                                                          outpath_directory){

  all_category_distances_for_one_country_pair <- map_df(category_names, get_country_pair_distances_for_one_category, c1, c2, drawing_directory) %>%
    mutate(country1 = c1,
           country2 = c2)


  outpath <- paste(c1, "_", c2, outpath_directory)
  write_csv(all_category_distances_for_one_country_pair, outpath)

}



walk2(countries_to_loop$country1[1],
      countries_to_loop$country2[1],
      get_country_pair_distances_for_all_categories,
      target_categories[1],
      DRAWING_DIRECTORY,
      OUTPATH_DIRECTORY)

