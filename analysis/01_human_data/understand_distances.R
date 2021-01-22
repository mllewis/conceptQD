# figure out distance matrix 

# computing the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(proxy)
library(here)
library(tidyverse)

TARGET_DRAWING_PAIRS <-here("data/processed/by_item_human_means.csv")
DRAWING_DIRECTORY <- here("data/processed/tidy_human_drawings/")
OUTPATH_DIRECTORY <- here("data/processed/tidy_human_data_with_computational_measures.csv")

############# FUNCTIONS ##########
get_similarity_for_one_drawing_pair <- function(id1, id2, c1_df, c2_df, full_matrix){
  
  # get euclidean and mahalanobis
  drawing1 <- matrix(c(c1_df$x, c1_df$y), length(c1_df$x), 2)
  drawing2 <- matrix(c(c2_df$x, c2_df$y), length(c2_df$x), 2)
  maha <- NA #this is necessary because maha fails when two drawings are identical (e.g. for line)
  maha <- try(mean(mahalanobis.dist(drawing1, drawing2)))
  eucl <- mean(proxy::dist(x = drawing1, y = drawing2, method = "euclidean"))
  
  # eucl2
  long_full_drawing1 <- full_matrix %>%
    left_join(c1_df %>% select(x, y) %>% mutate(point = 1)) %>%
    replace_na(list(point = 0))
  
  long_full_drawing2 <- full_matrix %>%
    left_join(c2_df %>% select(x, y) %>% mutate(point = 1)) %>%
    replace_na(list(point = 0))
  
  d1 <- xtabs(point ~ x + y, data = long_full_drawing1)
  d2 <-  xtabs(point ~ x + y, data = long_full_drawing2)
  
  euc2 <- sqrt(sum((d1-d2)^2))
  
  
  # get hausdorff
  drawing1 <- matrix(c(c1_df$x, c1_df$y), 2, length(c1_df$x), byrow = TRUE)
  drawing2 <- matrix(c(c2_df$x, c2_df$y), 2, length(c2_df$x), byrow = TRUE)
  
  avgh <- computeAverageHausdorffDistance(drawing1, drawing2)
  
  tibble(drawing_key_id_1 = id1,
         drawing_key_id_2 = id2,
         mahalanobis = maha,
         euclidean = eucl,
         eucllidean2 = euc2,
         avg_haus = avgh
  )
}


target_drawings_pairs <- read_csv(TARGET_DRAWING_PAIRS) # drawings we have human judgments for

all_tidy_drawings <- target_drawings_pairs %>%
  distinct(category) %>%
  pull(category) %>%
  map_df(~read_csv(here(paste0(DRAWING_DIRECTORY, "/",
                               "tidy_human_", ., "_drawings.csv"))))

nested_all_tidy_drawings <- all_tidy_drawings %>%
  mutate(key_id = as.character(key_id)) %>%
  group_by(key_id) %>%
  nest()

drawing_pairs_with_data <- target_drawings_pairs %>%
  select(category, drawing_key_id_1, drawing_key_id_2) %>%
  mutate_all(as.character) %>%
  left_join(nested_all_tidy_drawings, by  =c("drawing_key_id_1" = "key_id")) %>%
  rename(data1 = data) %>%
  left_join(nested_all_tidy_drawings, by  =c("drawing_key_id_2" = "key_id")) %>%
  rename(data2 = data)

c1_df = drawing_pairs_with_data$data1[[1]]
c2_df = drawing_pairs_with_data$data1[[1]]

# get euclidean distance
# each drawing is a matrix of x-y coordinates, ordered by stroke?
drawing1 <- matrix(c(c1_df$x, c1_df$y), length(c1_df$x), 2)
drawing2 <- matrix(c(c2_df$x, c2_df$y), length(c2_df$x), 2)

test_mat <- t(matrix(c(2, -1, -2, 2), nrow = 2)) # should be 5
dist(test_mat)

test_mat <- t(matrix(c(2, -1, -2, 2), nrow = 2)) # should be 5
dist(test_mat)

test_mat2 <- t(matrix(c(drawing1[1,], drawing2[1,]), nrow = 2)) 
dist(test_mat2)

proxy::dist(x = drawing1, y = drawing2, 
            method = "euclidean")

eucl <- mean(proxy::dist(x = drawing1, y = drawing2, 
                         method = "euclidean"))

full_matrix <- cross_df(list(x = 1:255, y = 1:255))

long_full_drawing1 <- full_matrix %>%
  left_join(c1_df %>% select(x, y) %>% mutate(point = 1)) %>%
  replace_na(list(point = 0))


long_full_drawing2 <- full_matrix %>%
  left_join(c2_df %>% select(x, y) %>% mutate(point = 1)) %>%
  replace_na(list(point = 0))


d1 <- xtabs(point ~ x + y, data = long_full_drawing1)
d2 <-  xtabs(point ~ x + y, data = long_full_drawing2)

euc2 <- sqrt(sum((d1-d2)^2))

long_full_drawing <- full_matrix %>%
  left_join(c1_df %>% select(x, y) %>% mutate(point = 1)) %>%
  replace_na(list(point = 0)) %>%
  mutate(id = 1:n())

d1_mat <- pivot_wider(long_full_drawing, names_from = x, values_from = point) %>%
  select(-y) %>%
  as.matrix() 

long_full_drawing <- full_matrix %>%
  left_join(c2_df %>% select(x, y) %>% mutate(point = 1)) %>%
  replace_na(list(point = 0))

d2_mat <- pivot_wider(long_full_drawing, names_from = x, values_from = point) %>%
  select(-y) %>%
  as.matrix() 

d1_mat == d2_mat

#euc2 <- sqrt(sum((drawing1-drawing2)^2))

