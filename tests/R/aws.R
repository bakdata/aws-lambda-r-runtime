library(aws.s3)

handler <- function() {
    usercsvobj <- get_object(object = 'examples/medicare/Medicare_Hospital_Provider.csv', bucket = 'awsglue-datasets', check_region = FALSE, region = 'us-east-1')
    csvcharobj <- rawToChar(usercsvobj)
    con <- textConnection(csvcharobj)
    data <- read.csv(con)
    close(con)
    return(data[1,])
}
