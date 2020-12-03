# computing the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

# library(pracma) # hausdorff_dist()
library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(quickdraw)
library(here)
library(tidyverse)
library(corpus)


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
  eucl <- euclidean_dist(drawing1, drawing2)

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
                 c2, "_distances.csv")
  write_csv(distances_for_one_pair_one_cat, path, append = T) #, col_names = T) 
  
  # Seems like including that part will add the column names more than once (every append also adds a row of column names)
  # Column names: c("drawing_id_1", "drawing_id_2",	"mahalanobis",	"euclidean",	"avg_haus",	"category",	"country1",	"country2")

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



# Looping over category
walk(categories$category,
     get_distances_for_one_category_for_all_country_pairs,
     OUTPATH_DIRECTORY,
     DRAWING_DIRECTORY,
     country_num_to_loop,
     twenty_countries$countries)



walk(c("bread", "tree", "bird", "chair", "house"),
     get_distances_for_one_category_for_all_country_pairs,
     OUTPATH_DIRECTORY,
     DRAWING_DIRECTORY,
     country_num_to_loop[1:5, ],
     twenty_countries$countries)
print(Sys.time())

# Running this took a little over 20 minutes.
# This is for 5 country pairs (AU/BR, AU/CA, AU/CZ, AU/DE, and AU/FI) for five categories
# Reading in the ndjson files was actually quite fast thanks to splitting it up wisely, but the time is takes to compute the similarity measures is not very good.

























# get_country_pair_distances_for_one_category <- function(target_category_name,
#                                                         country1,
#                                                         country2,
#                                                         data_directory ){
#   
#   # read in country1-cateogry file
#   country1data <- #some json thing after making full data path
#     
#     # read in country2-cateogry file
#     country2data <- #some json thing after making full data path
#     
#     target_number_of_pairs <- min(nrow(country1data), nrow(country2data))
#   
#   map_df(1:target_number_of_pairs,
#          get_similarity_for_one_drawing_pair,
#          country1data,
#          country2data) %>%
#     mutate(category = target_category_name)
#   
# }
# 
# get_country_pair_distances_for_all_categories <- function(c1,
#                                                           c2,
#                                                           category_names,
#                                                           drawing_directory,
#                                                           outpath_directory)
# {
#   
#   all_category_distances_for_one_country_pair <- map_df(category_names, 
#                                                         get_country_pair_distances_for_one_category, 
#                                                         c1, 
#                                                         c2, 
#                                                         drawing_directory) %>%
#     mutate(country1 = c1,
#            country2 = c2)
#   
#   
#   outpath <- paste(c1, "_", c2, outpath_directory)
#   write_csv(all_category_distances_for_one_country_pair, outpath)
#   
# }
# 
# 
# 
# walk2(countries_to_loop$country1[1],
#       countries_to_loop$country2[1],
#       get_country_pair_distances_for_all_categories,
#       target_categories[1],
#       DRAWING_DIRECTORY,
#       OUTPATH_DIRECTORY)

