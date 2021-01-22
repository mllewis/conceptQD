# Sample up to 1000 drawings per country for all 288 categories.
# Create pairs among the sampled drawings within the country (up to 500 pairs)
# Countries: AU BR CA CZ DE FI GB IT PL RU SE US PH FR NL HU SA TH KR ID

library(here)
library(tidyverse)
library(corpus)
library(data.table)
library(jsonlite)

CATEGORY_INFO_PATH <- here("data/raw/google_categories_coded.csv")
RAW_DRAWING_PATH <- file.path("C:/Users/binz7/Documents/.quickdraw") # ndjson files of the quickdraw drawings that's downloaded locally
SAMPLE_OUTPATH <- here("data/processed/sample_pairs.csv")
CATEGORY_OUTPATH <- here("data/raw/288_categories.csv")
COUNTRIES_OUTPATH <- here("data/raw/20_countries.csv")

set.seed(12321)

# get country codes into vector
x <- "AUBRCACZDEFIGBITPLRUSEUSPHFRNLHUSATHKRID"
sst <- strsplit(x, "")[[1]]
countries <- paste0(sst[c(TRUE, FALSE)], sst[c(FALSE, TRUE)])


# categories
categories <- read_csv(CATEGORY_INFO_PATH)

all_categories <- categories %>%
  filter(exclude == 0) %>%
  select(google_category_name) %>%
  rename(category = google_category_name) %>%
  arrange(category)

# saving these for future
write_csv(data.frame(country = countries), COUNTRIES_OUTPATH)
write_csv(all_categories, CATEGORY_OUTPATH)

# get_sample_per_item <- function(category_name, file_path, drawings_out_path, sample_out_path)
get_sample_per_item <- function(category_name, file_path, sample_out_path, all_countries){

  # reading the file and filtering the countries
  name <- paste0(category_name, ".ndjson")
  json_path <- file.path(file_path, name)
  df <- read_ndjson(json_path)
  df %>%
    filter(countrycode %in% all_countries) -> df

  # sampling at most 1000 drawings per country
  dt <- data.table(countrycode = df$countrycode, key_id = df$key_id)
  dt_sample <- dt[, .SD[sample(x = .N, size = min(1000, ifelse(.N %% 2 == 0, .N, .N-1)))], by = countrycode]
  dt_sample <- dt_sample[, ID := .I, by = countrycode]

  # pairing them up
  dt1 <- dt_sample[, .SD[sample(x = .N, size = .N/2)], by = countrycode]
  dt2 <- dt_sample[!dt1[,ID]]
  sample_pairs <- tibble(category = category_name,
                        country = dt1[,countrycode],
                        key_id_1 = dt1[,key_id],
                        key_id_2 = dt2[,key_id])

  write_csv(sample_pairs, sample_out_path, append = T)

  print(category_name)
  print(Sys.time())
}


walk(all_categories$category,
     get_sample_per_item,
     RAW_DRAWING_PATH,
     SAMPLE_OUTPATH,
     countries)
