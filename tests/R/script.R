handler <- function(x) {
    return(x + 1)
}

handler_with_multiple_arguments <- function(x, y) {
    return(list(x = x, y = y))
}

handler_with_variable_arguments <- function(...) {
    return(1)
}

handler_as_variable <- "foo"

handler_with_debug_logging <- function(x) {
    return(1)
}