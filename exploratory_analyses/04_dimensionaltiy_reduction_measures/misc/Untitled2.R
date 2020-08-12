

target_breads <- bread %>%
  mutate(row_id = 1:n()) %>%
  filter(key_id %in% c(human_data$drawing_key_id_1, human_data$drawing_key_id_2)) %>%
  select(row_id, key_id)


umap_coordinates <- umap(
  bread_bitmap[target_breads$row_id,],
  init = "random") %>%
  as.data.frame() %>%
  mutate(key_id = target_breads$key_id)

full_df <- map2_df(human_data$drawing_key_id_1, human_data$drawing_key_id_2,
                   get_ummap_distances, umap_coordinates) %>%
  left_join(human_data)
full_df
cor.test(full_df$mean, full_df$euclidean_distance)
