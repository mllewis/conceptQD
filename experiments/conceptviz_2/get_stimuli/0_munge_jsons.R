# read in raw simplified json from google, munge into long form tidy data frame and write to feathers
# critically, long form data include info about stroke number
# takes ~5 min per item

# load packages
library(tidyverse)
library(rlist)
library(data.table)
library(feather)
library(jsonlite)

# specify params
SIMPLIFIED_RAW_DATA_PATH <- "/Volumes/wilbur_the_great/CONCEPTVIZ/raw_data/simplified/"
OUTPATH <- "/Volumes/wilbur_the_great/CONCEPTVIZ/raw_data/feathers/all/"

critical_categories <- read_csv("../../data/misc/google_categories_coded.csv")  %>%
  filter(exclude != 1)

# read in all file names
file_list <- list.files(SIMPLIFIED_RAW_DATA_PATH)

# check that have data for all critical files
downloaded_items <- map(file_list, ~ str_split(., "2F")) %>%
  map( ~ pluck(., 1,3)) %>%
  unlist() %>%
  map(~ str_split(., "\\.n")) %>%
  map( ~ pluck(., 1,1)) %>%
  unlist()

critical_file_list <- file_list[which(downloaded_items %in% critical_categories$google_category_name)]
#setdiff(critical_categories$google_category_name, downloaded_items)

# helper to get drawing coordinates into long from
unlist_drawing <- function(drawing_raw_coords, key_id){
  map2_df(drawing_raw_coords, 1:length(drawing_raw_coords), function(x,y)
  {data.frame(t(x), stroke_num = y)}) %>%
    mutate(key_id = key_id)
}

# read data, munge and write function
write_drawings_to_feather <- function(name){

  # print to item to console
  print(name)

  # read in json
  d <- stream_in(file(paste0(SIMPLIFIED_RAW_DATA_PATH, name)),
                           simplifyMatrix = FALSE)

  # get meta-data in wide form
  dc_wide <- d %>%
            mutate(drawing = lapply(drawing, lapply, function(x) { # bind together x and y values
                                  do.call(rbind, x)})) %>%
    data.table(key = "key_id")

  long_strokes <- map2_df(dc_wide$drawing,
                          dc_wide$key_id,
                          unlist_drawing) %>%
    data.table(key = "key_id")

  dc_wide[,drawing:=NULL]
  clean_df <- long_strokes[dc_wide, on = "key_id"] %>%
    select(word, key_id, countrycode, recognized,  X1,  X2, stroke_num, timestamp) %>%
    rename(x = X1,
           y = X2)

  # write to feather
  outname <- paste0(OUTPATH, gsub(" ", "", clean_df$word[1], fixed = TRUE), "_tidy.txt")
  write_feather(long_strokes, outname)
}

# DO THE THING: loop over all files
walk(rev(critical_file_list), write_drawings_to_feather)
