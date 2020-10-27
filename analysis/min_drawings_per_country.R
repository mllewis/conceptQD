library(tidyverse)
library(here)
library(corpus)

path1 <- here("data\\raw\\google_categories_coded.csv")
path2 <- file.path("C:/Users/binz7/Documents/.quickdraw")
categories <- read.csv(path1)

categories %>%
  filter(exclude == 0) %>%
  select(ï..google_category_name) %>%
  rename(category = ï..google_category_name) %>%
  arrange(category) %>%
  mutate(total_drawings = 0, lowest_country = "", lowest_drawings = 0, fiftiety_country = "", fiftiety_drawings = 0) -> data

for (i in length(data$category))
{
  name <- paste0(data$category[i], ".ndjson")
  json_file <- file.path(path2, name)
  df <- read_ndjson(json_file)
  data$total_drawings[i] <- length(df$word)
  df %>%
    group_by(countrycode) %>%
    summarise(count = n()) %>%
    arrange(count) -> a
  arrange(a, desc(count)) -> b
  data$lowest_country[i] <- a[1,1]
  data$lowest_drawings[i] <- a[1,2]
  data$fiftiety_country[i] <- b[50,1]
  data$fiftiety_drawings[i] <- b[50,2]
}

