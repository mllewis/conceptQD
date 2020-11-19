# computing the distances between the drawing pairs (hausdorff, mahalanobis, avg_hausdorff, euclidean)

library(pracma) # hausdorff_dist()
library(ecr) # computeAverageHausdorffDistance()
library(StatMatch) # mahalanobis.dist()
library(quickdraw)
library(here)

# to do: get the sampled drawing pairs, read it in, and fix this code as needed


# some paths and reading in data

eucl <- function (drawing1, drawing2)
{
  x1 <- drawing1[,1]
  y1 <- drawing1[,2]
  x2 <- drawing2[,1]
  y2 <- drawing2[,2]
  e_dist <- 0
  
  for (i in 1:(length(x1)))
  {
    for (j in 1:(length(x2)))
    {
      e_dist <- e_dist + sqrt((x1[i] - x2[j])^2 + (y1[i] - y2[j])^2)
    }
  }
  
  e_dist / ((length(x1) * length(x2)))
}

get_distances <- function(drawings, id1, id2) # ids as strings
{
  row1 <- which(drawings$key_id == id1)
  row2 <- which(drawings$key_id == id2)
  
  tidied1 <- qd_tidy(drawings, row1)
  tidied2 <- qd_tidy(drawings, row2)
  
  drawing1 <- matrix(c(tidied1$x, tidied1$y), length(tidied1$x), 2)
  drawing2 <- matrix(c(tidied2$x, tidied2$y), length(tidied2$x), 2)
  
  haus <- hausdorff_dist(drawing1, drawing2)
  maha <- mean(mahalanobis.dist(drawing1, drawing2))
  eucl <- euclidean_dist(drawing1, drawing2)
  
  drawing1 <- matrix(c(tidied1$x, tidied1$y), 2, length(tidied1$x), byrow = TRUE)
  drawing2 <- matrix(c(tidied2$x, tidied2$y), 2, length(tidied2$x), byrow = TRUE)
  
  avgh <- computeAverageHausdorffDistance(drawing1, drawing2)
  
  distances_for_one_pair <- tibble(drawings$category[row1], drawings$countrycode[row1], id1, id2, haus, maha, eucl, avgh)

  # some write.csv thing
}

# some walk thing and formatting thing