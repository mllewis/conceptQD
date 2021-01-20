# save jpegs of stimuli sets

library(tidyverse)
library(feather)
library(here)

ITEM <- "tree"
GDRAW_SIZE <- 255
IMAGENET_SIZE <- 224
JPEG_SIZE <- IMAGENET_SIZE * 2
N_INTERPOLATE <- 500
INPATH <- here(paste0("experiments/conceptviz_2/get_stimuli/data/experiment_stimuli/sim_experiment_stimuli_", ITEM, ".csv"))
DATA_PATH <- paste0("/Volumes/wilbur_the_great/CONCEPTVIZ/raw_data/feathers/all/", ITEM, '_tidy.txt')
JPEG_PATH <- here(paste0("experiments/conceptviz_2/images/drawings2/", ITEM, "/"))



get_image_from_google_draw <- function(data,
                                       size1,
                                       size2,
                                       n_interpolate,
                                       return = "matrix",
                                       jpeg_size = NULL,
                                       jpeg_path = NULL){

  # for debugging
  # size1 = GDRAW_SIZE
  # size2= IMAGENET_SIZE
  # data = country_1_drawing

  key_id <- data$key_id[1]

  # get long form coordinates with lines interpolated
  image_draw <- data %>%
    dplyr::rename(x_end = x, y_end = y) %>%
    select(x_end, y_end, stroke_num) %>%
    mutate(x_start = lag(x_end),
           y_start = lag(y_end)) %>%
    mutate(transition = ifelse(stroke_num != lag(stroke_num),
                               1, 0)) %>%
    filter(transition != 1) %>% # remove connections between strokes
    drop_na() %>%   # deals with first row
    mutate(x_end = ifelse(x_end == x_start, x_end + .00000001, x_end), # spline can't deal with x's being equal
           y_end = abs(y_end - size1), # we're flipping the image on the x axis
           y_start = abs(y_start - size1)) %>%
    rowwise() %>%
    mutate(line = list(spline(c(x_start, x_end), # could also use approx function
                              c(y_start, y_end), n = n_interpolate)),
           x_line = list(line$x),
           y_line = list(line$y)) %>%
    ungroup() %>%
    select(x_line, y_line) %>%
    unnest() %>%
    mutate_all(round) # necessary for indexing matrix


  ## FIGURE OUT WHAT TO RETURN
  if (return == "matrix") {
    # make the drawing into a binary matrix
    mat <- array(0, c(size1, size1))
    mat[cbind(image_draw$x_line, image_draw$y_line)] <- 1

    data.frame(list(mat))

  } else if (return == "long") {
    # return long form
    data.table(image_draw) %>%
      mutate(key_id = key_id) %>%
      select(key_id, everything())

  } else if (return == "jpeg") {
    # write to pdf

    file_name <- paste0(jpeg_path, key_id , ".jpeg")

    jpeg(file_name, width  = jpeg_size, height = jpeg_size, quality = 100)
    print(
      ggplot(image_draw, aes(x = x_line, y = y_line)) +
        geom_point(size = .5) +
        theme(line = element_blank(),
              text = element_blank(),
              title = element_blank())
    )
    dev.off()
  }
}


stim <- read_csv(INPATH)

# get all crit ids
crit_ids <- unique(c(stim$key_id_1,
                   stim$key_id_2))

raw_data <- read_feather(DATA_PATH)

nested_raw <- raw_data %>%
  filter(key_id %in% crit_ids) %>%
  mutate(key_id_name = key_id) %>%
  group_by(key_id_name) %>%
  nest()

# DO THE THING

walk(nested_raw$data,
     get_image_from_google_draw,
     GDRAW_SIZE,
     IMAGENET_SIZE,
     N_INTERPOLATE,
     return = "jpeg",
     jpeg_size = JPEG_SIZE,
     jpeg_path = JPEG_PATH)
