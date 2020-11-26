# Create ndjson files for the sampled drawings by country and category
# category_country_sampled_drawings.ndjson
# Note: use read_ndjson() from the `corpus` package to read these files so then functions from the `quickdraw` package can be used

library(here)
library(tidyverse)
library(corpus)
library(jsonlite)

CATEGORY_PATH <- here("data/raw/288_categories.csv")
PAIRS_PATH <- here("data/processed/sample_pairs.csv")
COUNTRIES_PATH <- here("data/raw/20_countries.csv")
RAW_DRAWING_PATH <- file.path("C:/Users/binz7/Documents/.quickdraw") # ndjson files of the quickdraw drawings that's downloaded locally
SAMPLED_DRAWINGS_OUTPATH <- file.path("C:/Users/binz7/Documents/sampled_drawings") # saving the drawings locally (uploaded on google drive)


# reading in the csvs
categories <- read_csv(CATEGORY_PATH)
pairs <- read_csv(PAIRS_PATH,
                  col_names = c("category", "country", "key_id_1", "key_id_2"),
                  col_types = c("cccc"))
countries <- read_csv(COUNTRIES_PATH)




# writes the ndjson file for ~1000 drawings from a given country/category combo
write_drawings <- function(df, outpath, category, country)
{
  path <- paste0(outpath, "/", category, "_", country, "_sampled_drawings.ndjson")
  stream_out(file(path), 
             x = df)
}



# gets the sampled drawings for a category
get_sampled_drawings <- function(category_name, file_path, sample_out_path, all_countries, sampled_pairs)
{
  
  # read in the ndjson file for a given category and filtering the countries/key_ids
  name <- paste0(category_name, ".ndjson")
  json_path <- file.path(file_path, name)
  df <- read_ndjson(json_path)
  df %>%
    filter(countrycode %in% all_countries,
           key_id %in% sampled_pairs$key_id_1 | key_id %in% sampled_pairs$key_id_2) -> df1
  
  # writes a file per country for a given category
  df1 %>%
    group_by(countrycode) %>%
    group_walk(~ write_drawings(.x, 
                                SAMPLED_DRAWINGS_OUTPATH, 
                                category_name, 
                                .y$countrycode))
 
  print(category_name)
  print(Sys.time())
}


walk(categories$category,
     get_sampled_drawings,
     RAW_DRAWING_PATH,
     SAMPLED_DRAWINGS_OUTPATH,
     countries$country,
     pairs)


