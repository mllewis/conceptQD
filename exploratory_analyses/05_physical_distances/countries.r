library(quickdraw)
library(tidyverse)
library(here)

bread <- qd_read("bread")
tree <- qd_read("tree")
duck <- qd_read("duck")

bread %>%
  group_by(countrycode) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice(1:50) %>%
  rename(
    country_bread = countrycode,
    count_bread = count
  ) -> bread

tree %>%
  group_by(countrycode) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice(1:50) %>%
  rename(
    country_tree = countrycode,
    count_tree = count
  ) -> tree

duck %>%
  group_by(countrycode) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice(1:50) %>%
  rename(
    country_duck = countrycode,
    count_duck = count
  ) -> duck

m <- bind_cols(bread, tree, duck)

write.csv(m, here("data/processed/human_data/conceptviz_1_by_item_data.csv")



