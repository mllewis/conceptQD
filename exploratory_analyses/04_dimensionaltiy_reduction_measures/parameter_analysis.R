library(tidyverse)
library(here)
library(langcog)


COR_PATH1 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations.csv")

COR_PATH2 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations2.csv")
COR_PATH3 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations3.csv")

COR_PATH4 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations4.csv")
COR_PATH5 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations5.csv")
COR_PATH6 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations6.csv")
COR_PATH7 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations7.csv")
COR_PATH8 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations8.csv")
COR_PATH9 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations9.csv")
COR_PATH10 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations10.csv")
COR_PATH11 <- here("exploratory_analyses/04_dimensionaltiy_reduction_measures/param_correlations11.csv")



cols2 <- c("estimate" ,   "statistic" ,  "p.value"   ,  "parameter" ,  "conf.low" ,   "conf.high" ,  "method" ,
          "alternative",
               "n_components", "n_neighbors",
               "local_connectivity", "repulsion_strength")

cols1 <- c("estimate" ,   "statistic" ,  "p.value"   ,  "parameter" ,  "conf.low" ,   "conf.high" ,  "method" ,
          "alternative",
          "n_components", "n_neighbors","learning_rate","metric", "scale" ,"min_dist" ,
          "local_connectivity", "bandwidth","repulsion_strength")

cols3 <- c("estimate" ,   "statistic" ,  "p.value"   ,  "parameter" ,  "conf.low" ,   "conf.high" ,  "method" ,
           "alternative",
           "n_components", "n_neighbors","local_connectivity", "repulsion_strength","learning_rate","metric", "scale" ,"min_dist" ,
            "bandwidth", "n_epochs")



#corrs1 <- read_csv(COR_PATH1, col_names = cols1)

corrs2 <- read_csv(COR_PATH2, col_names = cols2)
corrs3 <- read_csv(COR_PATH3, col_names = cols2)

corrs4 <- read_csv(COR_PATH4, col_names = cols2)
corrs5 <- read_csv(COR_PATH5, col_names = cols2)
corrs6 <- read_csv(COR_PATH6, col_names = cols2)
corrs7 <- read_csv(COR_PATH7, col_names = cols2)
corrs8 <- read_csv(COR_PATH8, col_names = cols2)
corrs9 <- read_csv(COR_PATH9, col_names = cols2)

corrs10 <- read_csv(COR_PATH10, col_names = cols3) %>%
  filter(!is.na(n_epochs))

corrs11 <- read_csv(COR_PATH11, col_names = cols3)

corrs <- bind_rows(corrs, corrs2) %>%
  bind_rows(corrs4) %>%
  bind_rows(corrs5) %>%
  bind_rows(corrs6) %>%
  bind_rows(corrs7) %>%
  bind_rows(corrs8) %>%
  bind_rows(corrs9)



lm(estimate ~ n_components + n_neighbors +
     local_connectivity +  repulsion_strength, data = corrs) %>%
  summary()



corrs10 %>%
  select(-metric,) %>%
 # filter(learning_rate == .5, n_epochs == 1000) %>%
  #filter(n_components == 100) %>%
  pivot_longer(cols = c(n_components:n_epochs)) %>%
  group_by(name, value) %>%
  multi_boot_standard(col = "estimate") %>%
  ggplot(aes(x = value, y = mean)) +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper)) +
    geom_line() +
    facet_grid(.~name, scale = "free_x")





corrs %>%
  group_by(repulsion_strength) %>%
  summarize(mean = mean(estimate))


metric = c("euclidean")
local_connectivity = 10
n_components = 100,
n_neighbors = c(50, 100, 200, 50, 100, 200),
repulsion_strength =c(1, 1, 1, 1, 2, 2, 2, 2, 2)

local_connectivity =c(10),
n_components = c(100),
n_neighbors = c(50, 100, 200),
repulsion_strength =c(1),


local_connectivity = 10
n_components = 50
n_neighbors = 50 # or larger #? # 50
repulsion_strength = 2 #? # 10?
learning_rate = .5 # or smaller? #.25, .1
min_dist = .01 # (default)
bandwidth = 1 # (default)
scale = FALSE # (defualt)
metric = "euclidean" # (default)

m = corrs1 %>%
  group_by(n_components, n_neighbors, learning_rate, metric, scale, min_dist, local_connectivity, bandwidth, repulsion_strength) %>%
  summarize(mean = mean(estimate))

arrange(m, mean)

n = corrs11 %>%
  group_by(n_components, n_neighbors, learning_rate, metric, scale, min_dist, local_connectivity, bandwidth, repulsion_strength, n_epochs) %>%
  summarize(mean = mean(estimate))

arrange(n, mean)


## FINAL PARAMS
local_connectivity = 2 # 1 is default could do that
n_components = 30
n_neighbors = 5
repulsion_strength = 2
learning_rate = .5
min_dist = .01 # (default)
bandwidth = 1 # (default)
scale = FALSE # (defualt)
metric = "euclidean" # (default)
n_epochs = 1000


