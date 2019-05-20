library(aws.s3)

handler <- function() {
	usercsvobj <- get_object(object='data.csv', bucket='bakdata-public', check_region= FALSE, region='eu-central-1')
	csvcharobj <- rawToChar(usercsvobj)
	con <- textConnection(csvcharobj)
	data <- read.csv(con)
	close(con)
	return(rowSums(data)
}
