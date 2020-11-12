library(tidyverse)
library(quickdraw)
library(here)

here()

dist_data_path_2<- here("data/processed/human_data/all_stim_tidy.csv")
new_data <- read_csv(dist_data_path_2)

bread <- qd_read("bread")
tree <- qd_read("tree")
chair <- qd_read("chair")
bird <- qd_read("bird")
house <- qd_read("house")

all_drawing <- bind_rows(bread, tree, chair, bird, house)

new_data %>%
  dplyr::mutate(country_1 = "adsf", country_2 = "qwerty") -> with_countries

for (i in 1:1000)
{
  id1 <- toString(with_countries$key_id_1[i])
  id2 <- toString(with_countries$key_id_2[i])
  
  row1 <- which(all_drawing$key_id == id1)
  row2 <- which(all_drawing$key_id == id2)
  
  with_countries$country_1[i] <- all_drawing$countrycode[row1]
  with_countries$country_2[i] <- all_drawing$countrycode[row2]
}

write.csv(with_countries, here("data/processed/human_data/all_stim_tidy_with_countries.csv"))
