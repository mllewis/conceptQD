#Making a function to calculate the Hausdorff distance between two drawings by concatenating 
#all of the strokes
qd_hausdorff <- function(drawing1, drawing2) 
{
  #Getting the drawings
  drawing1 <- drawing1$drawing
  drawing2 <- drawing2$drawing
  
  #Something I found on stack exchange that allows me to do the next step, I'm basically going 
  max_length <- max(unlist(lapply (drawing1, FUN = length)))
  drawing1 <- sapply (drawing1, function (x) {length (x) <- max_length; return (x)})
  max_length2 <- max(unlist(lapply (drawing2, FUN = length)))
  drawing2 <- sapply (drawing2, function (x) {length (x) <- max_length2; return (x)})
  
  #Essentially combining all the strokes into one long single stroke to because the hausdorff_dist 
  #function can only compare a curve to another curve, not a set of curves to another set of curves
  transpose(drawing1)  %>%
    map(flatten_dbl) %>%
    list -> drawing1
  transpose(drawing2)  %>%
    map(flatten_dbl) %>%
    list -> drawing2
  
  #Formatting these into matrices, definitely could be simpler
  drawing1 <- matrix(c(drawing1[[1]][[1]], drawing1[[1]][[2]]), length(drawing1[[1]][[1]]), 2)
  drawing2 <- matrix(c(drawing2[[1]][[1]], drawing2[[1]][[2]]), length(drawing2[[1]][[1]]), 2)
  
  return (hausdorff_dist(drawing1, drawing2))
}