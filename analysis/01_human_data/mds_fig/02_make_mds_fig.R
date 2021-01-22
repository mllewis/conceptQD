# computing the distances between the across-country drawing pairs within a given category (mahalanobis, avg_hausdorff, euclidean)

library(here)
library(tidyverse)
library(ggimage)
library(magick)


MDS_DATA_PATH <-  here("analysis/01_human_data/mds_fig/bird_100_pairwise_distances.csv")

mds_data <- read_csv(MDS_DATA_PATH)

mds_data_long <- mds_data %>%
  select(drawing_key_id_1,
         drawing_key_id_2,
         human_predic_sim)
 # filter(drawing_key_id_1 != drawing_key_id_2)

mds_matrix <- mds_data_long %>%
  pivot_wider(names_from = drawing_key_id_2, values_from = human_predic_sim) %>%
  column_to_rownames("drawing_key_id_1") %>%
  as.matrix()

fit <- cmdscale(stats::as.dist(mds_matrix, diag = F), k = 2) # k is the number of dim

mds_plotting_df <- fit %>%
  as.data.frame() %>%
  rownames_to_column("key_id")

# get version of drawings with white background
DRAWING_FILE_PATH <- here("experiments/conceptviz_2/images/drawings/bird/")
CLEAN_DRAWINGS_PATH <- here("analysis/01_human_data/mds_fig/fig_drawings/")

long_files = paste0(DRAWING_FILE_PATH, mds_plotting_df$key_id, ".jpeg")

for (i in 1:length(long_files)){
  g <- image_read(long_files[i]) %>%
      image_oilpaint() %>%
      image_flatten('Modulate')
  image_write(g, paste0(CLEAN_DRAWINGS_PATH, mds_plotting_df$key_id[i], "_hc"))
}


mds_plotting_df_with_figs <- mds_plotting_df %>%
  mutate(image = paste0(CLEAN_DRAWINGS_PATH, key_id, "_hc"))

ggplot(mds_plotting_df_with_figs, aes(V1, V2)) +
  geom_image(aes(image=image), size=.05) +
  theme_void()

