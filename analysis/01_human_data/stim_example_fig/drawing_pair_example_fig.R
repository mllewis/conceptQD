library(tidyverse)
library(here)

RUN_ID <- 16 # change this manually to get multiple sample grids

STIM_ID_PATH <- here("data/processed/by_item_human_means.csv")

all_stim <- read_csv(STIM_ID_PATH)

bread_stim <- all_stim %>%
  filter(category == "bread") %>%
  select(pair_id, drawing_key_id_1, drawing_key_id_2, haus_bin)

plot_ids_wide <- bread_stim %>%
  group_by(haus_bin) %>%
  sample_n(1)

plot_ids <- plot_ids_wide %>%
  gather("measure", "key_id_num", 2:3) %>%
  mutate(key_id_num = as.character(key_id_num)) %>%
  arrange(-haus_bin, pair_id)

DRAWING_FILE_PATH <- here("experiments/conceptviz_1/images/drawings/")
long_files = paste0(DRAWING_FILE_PATH, plot_ids$key_id_num, ".jpeg")

# get version of drawings with white background
CLEAN_DRAWINGS_PATH <- here("analysis/01_human_data/stim_example_fig/fig_drawings/")

for (i in 1:length(long_files)){
  g <-image_read(long_files[i]) %>%
    image_oilpaint() %>%
    image_flatten('Modulate')
  image_write(g, paste0(CLEAN_DRAWINGS_PATH, plot_ids$key_id_num[i], "_hc"))
}

# make 2 x 10 grid of drawings
make_one_grid <- function(inpath, outpath, plot_ids){
  pdf(outpath, height = 11, width = 3.5)

  N_COLS <- 2
  N_ROWS <- 10
  WIDTH <- 50 # pictures are square
  MARGIN <- .2

  pic_coords <- data.frame(x1 = rep(seq(0, (WIDTH * N_COLS-WIDTH), by = WIDTH), N_ROWS),
                           y1 = rep(seq(0, (WIDTH * N_ROWS-WIDTH), by = WIDTH),  each = N_COLS),
                           x2 = rep(seq(WIDTH, WIDTH * N_COLS, by = WIDTH), N_ROWS),
                           y2 = rep(seq(WIDTH, WIDTH * N_ROWS, by = WIDTH), each = N_COLS))

  pic_coords <- pic_coords %>%
    mutate(x1 = x1 + 6,
           x2 = x2 + 6)

  op <- par(mar=c(MARGIN, MARGIN, MARGIN, MARGIN))
  plot(c(0,N_COLS * WIDTH), c(0, N_ROWS * WIDTH),
       type = "n",
       axes = FALSE,
       xlab = "",
       ylab = "")

  for (i in 1:length(plot_ids)) {
    image <- image_read(paste0(inpath, plot_ids[i], "_hc"))
    rasterImage(image,
                pic_coords$x1[i],
                pic_coords$y1[i],
                pic_coords$x2[i],
                pic_coords$y2[i])
  }
  XX = 2.5
  X_POS = 1.2
  text(X_POS,475, "1", cex = XX)
  text(X_POS,425, "2", cex = XX)
  text(X_POS,375, "3", cex = XX)
  text(X_POS,325, "4", cex = XX)
  text(X_POS,275, "5", cex = XX)
  text(X_POS,225, "6", cex = XX)
  text(X_POS,175, "7", cex = XX)
  text(X_POS,125, "8", cex = XX)
  text(X_POS,75, "9", cex = XX)
  text(X_POS,25, "10", cex = XX)
  par(op)
  dev.off()
}

# sample grids to construct manual list
SAMPLE_GRID_IDS <- here("analysis/01_human_data/stim_example_fig/sample_grids/")
write_csv(plot_ids_wide, paste0(SAMPLE_GRID_IDS, "ids", RUN_ID, ".csv"))

SAMPLE_GRID_PATH <- here("analysis/01_human_data/stim_example_fig/sample_grids/")

make_one_grid(CLEAN_DRAWINGS_PATH,
              paste0(SAMPLE_GRID_PATH, "grid", RUN_ID, ".pdf"),
              plot_ids$key_id_num)
write_csv(plot_ids_wide, paste0(SAMPLE_GRID_IDS, "ids", RUN_ID, ".csv"))

# make final fig
MANUAL_STIM_PATH <-  here("analysis/01_human_data/stim_example_fig/drawing_pair_stim_manual.csv")

final_stim <- read_csv(MANUAL_STIM_PATH)

final_ids <- final_stim %>%
  gather("measure", "key_id_num", 2:3) %>%
  mutate(key_id_num = as.character(key_id_num)) %>%
  arrange(-haus_bin, pair_id)

FINAL_FIG <- here("analysis/01_human_data/stim_example_fig/example_grid_final.pdf")
make_one_grid(CLEAN_DRAWINGS_PATH,
              FINAL_FIG,
              final_ids$key_id_num)

