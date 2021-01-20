# read in raw simplified json from google, munge into long form tidy data frame and write to feathers
# critically, long form data include info about stroke number
# takes ~5 min per item

# load packages
library(tidyverse)
library(rlist)
library(data.table)
library(feather)
library(jsonlite)
library(here)

# specify params
SIMPLIFIED_RAW_DATA_PATH <- "/Volumes/wilbur_the_great/CONCEPTVIZ/raw_data/simplified/full_simplified_"
OUTPATH <- "/Volumes/wilbur_the_great/CONCEPTVIZ/raw_data/feathers/all/"
ITEMS <- c("bird", "chair")

# read in all file names

# helper to get drawing coordinates into long from
unlist_drawing <- function(drawing_raw_coord s, key_id){
  map2_df(drawing_raw_coords, 1:length(drawing_raw_coords), function(x,y)
  {data.frame(t(x), stroke_num = y)}) %>%
    mutate(key_id = key_id)
}

# read data, munge and write function
write_drawings_to_feather <- function(name, inpath, outpath){

  # print to item to console
  print(name)

  simplified_data_path <- paste0(inpath, name, ".ndjson")

  # read in json
  d <- stream_in(file(simplified_data_path),
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
  outname <- paste0(outpath, name, "_tidy.txt")
  write_feather(long_strokes, outname)
}

# DO THE THING: loop over all files
walk(ITEMS, write_drawings_to_feather, SIMPLIFIED_RAW_DATA_PATH, OUTPATH)
