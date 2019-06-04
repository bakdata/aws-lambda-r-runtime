to_str <- function(x) {
    return(paste(capture.output(print(x)), collapse = "\n"))
}

error_to_payload <- function(error) {
    return(list(errorMessage = toString(error), errorType = class(error)[1]))
}

post_error <- function(error, url) {
    logerror(error)
    res <- POST(url,
                add_headers("Lambda-Runtime-Function-Error-Type" = "Unhandled"),
                body = error_to_payload(error),
                encode = "json")
    loginfo("Posted result:\n%s", to_str(res))
}

Request <- setRefClass(
    "Request",
    fields = list(API_ENDPOINT = "character"),
    methods = list(
        initialize = function(API_ENDPOINT, REQUEST_ID) {
            API_ENDPOINT <<- paste0(API_ENDPOINT, "invocation/", REQUEST_ID)
        },
        throwRuntimeError = function(error) {
            url <- paste0(API_ENDPOINT, "/error")
            post_error(error, url)
        },
        postResult = function(result) {
            url <- paste0(API_ENDPOINT, "/response")
            res <- POST(url, body = list(result = result), encode = "json")
            loginfo("Posted result:\n%s", to_str(res))
        }
    )
)

invoke_lambda <- function(function_name, params) {
    loginfo("Invoking function '%s' with parameters:\n%s", function_name, to_str(params))
    result <- do.call(function_name, params)
    loginfo("Function returned:\n%s", to_str(result))
    return(result)
}

parseParams <- function(raw_data) {
    EVENT_DATA <- rawToChar(raw_data)
    return(fromJSON(EVENT_DATA))
}

RuntimeAPI <- setRefClass(
    "RuntimeAPI",
    fields = list(API_ENDPOINT = "character"),
    methods = list(
        initialize = function() {
            AWS_LAMBDA_RUNTIME_API <- Sys.getenv("AWS_LAMBDA_RUNTIME_API")
            API_ENDPOINT <<- paste0("http://", AWS_LAMBDA_RUNTIME_API, "/2018-06-01/runtime/")
        },
        throwInitError = function(error) {
            url <- paste0(API_ENDPOINT, "init/error")
            post_error(error, url)
            stop()
        },
        handle_request = function(function_name) {
            event_url <- paste0(API_ENDPOINT, "invocation/next")
            event_response <- GET(event_url)
            REQUEST_ID <- event_response$headers$`Lambda-Runtime-Aws-Request-Id`
            request <- Request$new(API_ENDPOINT = API_ENDPOINT, REQUEST_ID = REQUEST_ID)
            tryCatch({
                raw_data <- event_response$content
                params <- parseParams(raw_data)
                result <- invoke_lambda(function_name, params)
                request$postResult(result)
            },
            error = request$throwRuntimeError)
        }
    )
)

get_source_file_name <- function(file_base_name) {
    file_name <- paste0(file_base_name, ".R")
    if (! file.exists(file_name)) {
        file_name <- paste0(file_base_name, ".r")
    }
    if (! file.exists(file_name)) {
        stop(paste0('Source file does not exist: ', file_base_name, '.[R|r]'))
    }
    return(file_name)
}

initializeRuntime <- function() {
    library(httr)
    library(jsonlite)
    library(logging)

    HANDLER <- Sys.getenv("_HANDLER")
    HANDLER_split <- strsplit(HANDLER, ".", fixed = TRUE)[[1]]
    file_base_name <- HANDLER_split[1]
    file_name <- get_source_file_name(file_base_name)
    loginfo("Sourcing '%s'", file_name)
    source(file_name)
    return(HANDLER_split[2])
}
