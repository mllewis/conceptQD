# merge final drawings into single csv so can use only tabletop functionality for reading data into js (using bread spread sheeet for conceptviz 1)

library(tidyverse)
library(here)

FILE_PATH <- here("experiments/conceptviz_2/get_stimuli/data/experiment_stimuli/")
OUTPATH <- here("experiments/conceptviz_2/all_stim_data.csv")
all_stim_files <- list.files(FILE_PATH, full.names = T)

all_stim_data <- map_df(all_stim_files, read_csv) %>%
  mutate_if(is.numeric, as.character) # get rid of scientific notation

write_csv( all_stim_data, OUTPATH)
