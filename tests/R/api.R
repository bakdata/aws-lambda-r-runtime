library(jsonlite)

handler <- function(headers, multiValueHeaders, queryStringParameters, multiValueQueryStringParameters, pathParameters, body, ...) {
    return(
        list(
            statusCode = 200,
            headers = list("Content-Type" = "application/json"),
            body = toJSON(list(hello = queryStringParameters$who), auto_unbox = TRUE)
        )
    )
}
