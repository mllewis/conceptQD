library(quickdraw)
library(corpus) # for reading jaw ndjson files

FULL_DATA_PATH <- file.path("C:/Users/binz7/Documents/full_drawings")

airplane_qd <- qd_read("airplane")
angel_qd <- qd_read("angel")

airplane_full <- read_ndjson(file.path(FULL_DATA_PATH, "full_simplified_airplane.ndjson"))
angel_full <- read_ndjson(file.path(FULL_DATA_PATH, "full_simplified_angel.ndjson"))

head(angel_full)
