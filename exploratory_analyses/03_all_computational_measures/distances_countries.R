library(quickdraw)
library(tidyverse)
library(here)
library(pracma)
library(StatMatch)

euclidean_dist <- function (x1, y1, x2, y2)
{
  e_dist <- 0
  for (i in 1:(length(x1)))
  {
    for (j in 1:(length(x2)))
    {
      e_dist <- e_dist + sqrt((x1[i] - x2[j])^2 + (y1[i] - y2[j])^2)
    }
  }
  return (e_dist / ((length(x1) * length(x2))))
}

country_pair <- function (country1, country2, samples, distances)
{
  row1 <- which(countries_data$countrycode == country1)
  row2 <- which(countries_data$countrycode == country2)
  
  for (i in 1:100)
  {
    tidied1 <- qd_tidy(samples, (row1 * 100) - 100 + i)
    tidied2 <- qd_tidy(samples, (row2 * 100) - 100 + i)
    
    drawing1 <- matrix(c(tidied1$x, tidied1$y), length(tidied1$x), 2)
    drawing2 <- matrix(c(tidied2$x, tidied2$y), length(tidied2$x), 2)
    
    distances$hausdorff[i] <- hausdorff_dist(drawing1, drawing2)
    distances$mahalanobis[i] <- mean(mahalanobis.dist(drawing1, drawing2))
    distances$euclidean[i] <- euclidean_dist(drawing1[,1], drawing1[,2], drawing2[,1], drawing2[,2])
    distances$drawing_key_id_1[i] <- tidied1$key_id[1]
    distances$drawing_key_id_2[i] <- tidied2$key_id[1]
  }
  return (distances)
}

countries_data_path <- here("data/processed/computational_distance_measures/top_50.csv")
countries_data <- read_csv(countries_data_path)

combinations <- as.data.frame(combn(countries_data$countrycode, 2))
combinations <- data.frame(t(combinations))
combinations <- rename(combinations, country1 = X1, country2 = X2)
c_pairs <- combinations
combinations %>% 
  slice(rep(1:n(), each = 100)) -> combinations

combinations %>%
  dplyr::mutate(drawing_key_id_1 = "0", 
                drawing_key_id_2 = "0", 
                hausdorff = 0, 
                mahalanobis = 0, 
                euclidean = 0) -> combinations

comb_bread <- combinations
comb_tree <- combinations
comb_chair <- combinations
comb_house <- combinations
comb_bird <- combinations

bread <- qd_read("bread")
tree <- qd_read("tree")
chair <- qd_read("chair")
house <- qd_read("house")
bird <- qd_read("bird")

bread %>%
  filter(countrycode == countries_data$countrycode[1]) %>%
  sample_n(100) -> bread_samples

for (i in 2:50)
{
  bread %>%
    filter(countrycode == countries_data$countrycode[i]) %>%
    sample_n(100) %>%
    bind_rows(bread_samples, .) -> bread_samples
}

tree %>%
  filter(countrycode == countries_data$countrycode[1]) %>%
  sample_n(100) -> tree_samples

for (i in 2:50)
{
  tree %>%
    filter(countrycode == countries_data$countrycode[i]) %>%
    sample_n(100) %>%
    bind_rows(tree_samples, .) -> tree_samples
}

chair %>%
  filter(countrycode == countries_data$countrycode[1]) %>%
  sample_n(100) -> chair_samples

for (i in 2:50)
{
  chair %>%
    filter(countrycode == countries_data$countrycode[i]) %>%
    sample_n(100) %>%
    bind_rows(chair_samples, .) -> chair_samples
}

house %>%
  filter(countrycode == countries_data$countrycode[1]) %>%
  sample_n(100) -> house_samples

for (i in 2:50)
{
  house %>%
    filter(countrycode == countries_data$countrycode[i]) %>%
    sample_n(100) %>%
    bind_rows(house_samples, .) -> house_samples
}

bird %>%
  filter(countrycode == countries_data$countrycode[1]) %>%
  sample_n(100) -> bird_samples

for (i in 2:50)
{
  bird %>%
    filter(countrycode == countries_data$countrycode[i]) %>%
    sample_n(100) %>%
    bind_rows(bird_samples, .) -> bird_samples
}

distances <- tibble(drawing_key_id_1 = "0", 
                    drawing_key_id_2 = "0",
                    hausdorff = 1:100,
                    mahalanobis = 1:100,
                    euclidean = 1:100)

for (i in 1:1225)
{
  d <- country_pair(c_pairs$country1[i], c_pairs$country2[i], bread_samples, distances)
  comb_bread$drawing_key_id_1[((i*100)-99):(i*100)] <- d$drawing_key_id_1[1:100]
  comb_bread$drawing_key_id_2[((i*100)-99):(i*100)] <- d$drawing_key_id_2[1:100]
  comb_bread$hausdorff[((i*100)-99):(i*100)] <- d$hausdorff[1:100]
  comb_bread$mahalanobis[((i*100)-99):(i*100)] <- d$mahalanobis[1:100]
  comb_bread$euclidean[((i*100)-99):(i*100)] <- d$euclidean[1:100]
  
  d <- country_pair(c_pairs$country1[i], c_pairs$country2[i], tree_samples, distances)
  comb_tree$drawing_key_id_1[((i*100)-99):(i*100)] <- d$drawing_key_id_1[1:100]
  comb_tree$drawing_key_id_2[((i*100)-99):(i*100)] <- d$drawing_key_id_2[1:100]
  comb_tree$hausdorff[((i*100)-99):(i*100)] <- d$hausdorff[1:100]
  comb_tree$mahalanobis[((i*100)-99):(i*100)] <- d$mahalanobis[1:100]
  comb_tree$euclidean[((i*100)-99):(i*100)] <- d$euclidean[1:100]
  
  d <- country_pair(c_pairs$country1[i], c_pairs$country2[i], house_samples, distances)
  comb_house$drawing_key_id_1[((i*100)-99):(i*100)] <- d$drawing_key_id_1[1:100]
  comb_house$drawing_key_id_2[((i*100)-99):(i*100)] <- d$drawing_key_id_2[1:100]
  comb_house$hausdorff[((i*100)-99):(i*100)] <- d$hausdorff[1:100]
  comb_house$mahalanobis[((i*100)-99):(i*100)] <- d$mahalanobis[1:100]
  comb_house$euclidean[((i*100)-99):(i*100)] <- d$euclidean[1:100]
  
  d <- country_pair(c_pairs$country1[i], c_pairs$country2[i], chair_samples, distances)
  comb_chair$drawing_key_id_1[((i*100)-99):(i*100)] <- d$drawing_key_id_1[1:100]
  comb_chair$drawing_key_id_2[((i*100)-99):(i*100)] <- d$drawing_key_id_2[1:100]
  comb_chair$hausdorff[((i*100)-99):(i*100)] <- d$hausdorff[1:100]
  comb_chair$mahalanobis[((i*100)-99):(i*100)] <- d$mahalanobis[1:100]
  comb_chair$euclidean[((i*100)-99):(i*100)] <- d$euclidean[1:100]
  
  d <- country_pair(c_pairs$country1[i], c_pairs$country2[i], bird_samples, distances)
  comb_bird$drawing_key_id_1[((i*100)-99):(i*100)] <- d$drawing_key_id_1[1:100]
  comb_bird$drawing_key_id_2[((i*100)-99):(i*100)] <- d$drawing_key_id_2[1:100]
  comb_bird$hausdorff[((i*100)-99):(i*100)] <- d$hausdorff[1:100]
  comb_bird$mahalanobis[((i*100)-99):(i*100)] <- d$mahalanobis[1:100]
  comb_bird$euclidean[((i*100)-99):(i*100)] <- d$euclidean[1:100]
}

write.csv(comb_bread, here("data/processed/computational_distance_measures/countries_similarity_bread.csv"))
write.csv(comb_tree, here("data/processed/computational_distance_measures/countries_similarity_tree.csv"))
write.csv(comb_house, here("data/processed/computational_distance_measures/countries_similarity_house.csv"))
write.csv(comb_chair, here("data/processed/computational_distance_measures/countries_similarity_chair.csv"))
write.csv(comb_bird, here("data/processed/computational_distance_measures/countries_similarity_bird.csv"))




