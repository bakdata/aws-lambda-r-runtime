library(Matrix)

handler <- function(x) {
    return(Matrix(1:6, 3, 2)[, 2])
}
