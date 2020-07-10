library(Rtsne)


test_mat = matrix(c(1,1,1,1,1,0,1,1,1,1,0,0,0,0,1,0, 1,1,0,1,1,0,1,1,1,1,0,0,0,0,1,0,1,1,1), nrow = 5)
out <- Rtsne(test_mat, dims = 1,
             perplexity = 1)

out$Y
