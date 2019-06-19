to_str <- function(x) {
    return(paste(capture.output(print(x)), collapse = "\n"))
}

error_to_payload <- function(error) {
    return(list(errorMessage = toString(error), errorType = class(error)[1]))
}

post_error <- function(error, url) {
    logerror(error, logger = 'runtime')
    res <- POST(url,
                add_headers("Lambda-Runtime-Function-Error-Type" = "Unhandled"),
                body = error_to_payload(error),
                encode = "json")
    logdebug("Posted result:\n%s", to_str(res), logger = 'runtime')
}

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

invoke_lambda <- function(function_name, params) {
    logdebug("Invoking function '%s' with parameters:\n%s", function_name, to_str(params), logger = 'runtime')
    result <- do.call(function_name, params)
    logdebug("Function returned:\n%s", to_str(result), logger = 'runtime')
    return(result)
}

initialize_logging <- function() {
    library(logging)

    basicConfig()
    addHandler(writeToConsole, logger = 'runtime')
    log_level <- Sys.getenv('LOGLEVEL', unset = NA)
    if (!is.na(log_level)) {
        setLevel(log_level, 'runtime')
    }
}

initialize_runtime <- function() {
    library(httr)
    library(jsonlite)

    initialize_logging()
    HANDLER <- Sys.getenv("_HANDLER")
    HANDLER_split <- strsplit(HANDLER, ".", fixed = TRUE)[[1]]
    file_base_name <- HANDLER_split[1]
    file_name <- get_source_file_name(file_base_name)
    logdebug("Sourcing '%s'", file_name, logger = 'runtime')
    source(file_name)
    function_name <- HANDLER_split[2]
    if (!exists(function_name, mode = "function")) {
        stop(paste0('Function "', function_name, '" does not exist'))
    }
    return(function_name)
}

AWS_LAMBDA_RUNTIME_API <- Sys.getenv("AWS_LAMBDA_RUNTIME_API")
API_ENDPOINT <- paste0("http://", AWS_LAMBDA_RUNTIME_API, "/2018-06-01", "/runtime")
INVOCATION_ENDPOINT <- paste0(API_ENDPOINT, "/invocation")

get_request_endpoint <- function(REQUEST_ID) {
    return(paste0(INVOCATION_ENDPOINT, "/", REQUEST_ID))
}

throw_init_error <- function(error) {
    url <- paste0(API_ENDPOINT, "/init", "/error")
    post_error(error, url)
    stop()
}

throw_runtime_error <- function(error, REQUEST_ID) {
    url <- paste0(get_request_endpoint(REQUEST_ID), "/error")
    post_error(error, url)
}

post_result <- function(result, REQUEST_ID) {
    url <- paste0(get_request_endpoint(REQUEST_ID), "/response")
    res <- POST(url, body = toJSON(result, auto_unbox = TRUE), encode = "raw", content_type_json())
    logdebug("Posted result:\n%s", to_str(res), logger = 'runtime')
}

parse_params <- function(raw_data) {
    EVENT_DATA <- rawToChar(raw_data)
    return(fromJSON(EVENT_DATA))
}

handle_request <- function(function_name) {
    event_url <- paste0(INVOCATION_ENDPOINT, "/next")
    event_response <- GET(event_url)
    REQUEST_ID <- event_response$headers$`Lambda-Runtime-Aws-Request-Id`
    tryCatch({
        params <- parse_params(event_response$content)
        result <- invoke_lambda(function_name, params)
        post_result(result, REQUEST_ID)
    },
    error = function(error) {
        throw_runtime_error(error, REQUEST_ID)
    })
}
