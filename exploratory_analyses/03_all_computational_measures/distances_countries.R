library(quickdraw)
library(tidyverse)
library(here)
library(pracma)
library(StatMatch)

countries_data_path <- here("data/processed/computational_distance_measures/top_50.csv")
countries_data <- read_csv(countries_data_path)

combinations <- as.data.frame(combn(countries_data$countrycode, 2))
combinations <- data.frame(t(combinations))
combinations <- rename(combinations, country1 = X1, country2 = X2)
combinations <- as.tibble(combinations)

combinations %>%
  dplyr::mutate(hausdorff = 0, mahalanobis = 0, euclidean = 0) -> combinations

bread <- qd_read("bread")

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
  row1 = which(countries_data$countrycode == country1)
  row2 = which(countries_data$countrycode == country2)
  
  for (i in 1:100)
  {
    tidied1 <- qd_tidy(samples, (row1 - 1) * 100 + i)
    tidied2 <- qd_tidy(samples, (row2 - 1) * 100 + i)
    
    drawing1 <- matrix(c(tidied1$x, tidied1$y), length(tidied1$x), 2)
    drawing2 <- matrix(c(tidied2$x, tidied2$y), length(tidied2$x), 2)
    
    distances$hausdorff[i] <- hausdorff_dist(drawing1, drawing2)
    distances$mahalanobis[i] <- mean(mahalanobis.dist(drawing1, drawing2))
    distances$euclidean[i] <- euclidean_dist(drawing1[,1], drawing1[,2], drawing2[,1], drawing2[,2])
  }
  return (distances)
}

distances <- data.frame(hausdorff = 1:100,
                        mahalanobis = 1:100,
                        euclidean = 1:100)

for (i in 238:1225)
{
  d <- country_pair(combinations$country1[i], combinations$country2[i], bread_samples, distances)
  combinations$hausdorff[i] <- mean(d$hausdorff)
  combinations$mahalanobis[i] <- mean(d$mahalanobis)
  combinations$euclidean[i] <- mean(d$euclidean)
}

write.csv(combinations,"C:\\Users\\binz7\\Desktop\\countries_similarity.csv")




