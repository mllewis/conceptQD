library(quickdraw)
library(tidyverse)
library(here)
library(pracma)
library(parallel)
library(doParallel)
library(foreach)

mahalanobis.dist <- function(data.x, data.y=NULL, vc=NULL){
  
  vc <- var(rbind(data.x,data.y))
  
  ny <- nrow(data.y)
  md <- matrix(0,nrow(data.x), ny)
  for(i in 1:ny){
    md[,i] <- mahalanobis(data.x, data.y[i,], cov=vc)
  }
  
  dimnames(md) <- list(rownames(data.x), rownames(data.y))
  sqrt(md)
}

qd_td <- function(object, item = 1:nrow(object)){

  tidy_single <- function(id){
    x <- purrr::map_dfr(object$drawing[[id]], function(id){
      tibble::tibble(x = id[[1]],
                     y = 255 - id[[2]])
    },.id = "stroke") 
      
      dplyr::mutate(x, key_id = object$key_id[id])
  }
  
  purrr::map_dfr(item, tidy_single)
}

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

country_pair <- function (country1, country2, n, samples)
{
  row1 <- which(countries_data$countrycode == country1)
  row2 <- which(countries_data$countrycode == country2)
  
  tidied1 <- qd_td(samples, (row1 * 100) - 100 + n)
  tidied2 <- qd_td(samples, (row2 * 100) - 100 + n)
    
  drawing1 <- matrix(c(tidied1$x, tidied1$y), length(tidied1$x), 2)
  drawing2 <- matrix(c(tidied2$x, tidied2$y), length(tidied2$x), 2)
  
  data.frame(country_1 = country1,
             country_2 = country2,
             key_id_1 = tidied1$key_id[1], 
             key_id_2 = tidied2$key_id[1], 
             hausdorff = hausdorff_dist(drawing1, drawing2),
             mahalanobis = mean(mahalanobis.dist(drawing1, drawing2)),
             euclidean = euclidean_dist(drawing1[,1], drawing1[,2], drawing2[,1], drawing2[,2]))
}

countries_data_path <- here("data/processed/computational_distance_measures/top_50.csv")
countries_data <- read_csv(countries_data_path)

combinations <- as.data.frame(combn(countries_data$countrycode, 2))
combinations <- data.frame(t(combinations))
combinations <- rename(combinations, country1 = X1, country2 = X2)
c_pairs <- combinations
combinations %>% 
  slice(rep(1:n(), each = 100)) -> combinations

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

cl <- parallel::makeCluster(4)

doParallel::registerDoParallel(cl)

foreach(i = 1:122500, .packages=c("pracma", "StatMatch"), .combine=rbind) %dopar% {
  country_pair(combinations$country1[i], combinations$country2[i], ((i-1)%%100)+1, bread_samples)
} -> comb_bread

foreach(i = 1:122500, .packages=c("pracma", "StatMatch"), .combine=rbind) %dopar% {
  country_pair(combinations$country1[i], combinations$country2[i], ((i-1)%%100)+1, tree_samples)
} -> comb_tree

foreach(i = 1:122500, .packages=c("pracma", "StatMatch"), .combine=rbind) %dopar% {
  country_pair(combinations$country1[i], combinations$country2[i], ((i-1)%%100)+1, chair_samples)
} -> comb_chair

foreach(i = 1:122500, .packages=c("pracma", "StatMatch"), .combine=rbind) %dopar% {
  country_pair(combinations$country1[i], combinations$country2[i], ((i-1)%%100)+1, bird_samples)
} -> comb_bird

foreach(i = 1:122500, .packages=c("pracma", "StatMatch"), .combine=rbind) %dopar% {
  country_pair(combinations$country1[i], combinations$country2[i], ((i-1)%%100)+1, house_samples)
} -> comb_house

write.csv(comb_bread, here("data/processed/computational_distance_measures/countries_similarity_bread.csv"))
write.csv(comb_tree, here("data/processed/computational_distance_measures/countries_similarity_tree.csv"))
write.csv(comb_house, here("data/processed/computational_distance_measures/countries_similarity_house.csv"))
write.csv(comb_chair, here("data/processed/computational_distance_measures/countries_similarity_chair.csv"))
write.csv(comb_bird, here("data/processed/computational_distance_measures/countries_similarity_bird.csv"))




