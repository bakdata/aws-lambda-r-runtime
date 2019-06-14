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

invoke_lambda <- function(EVENT_DATA, function_name) {
    params <- fromJSON(EVENT_DATA)
    logdebug("Invoking function '%s' with parameters:\n%s", function_name, to_str(params), logger = 'runtime')
    result <- do.call(function_name, params)
    logdebug("Function returned:\n%s", to_str(result), logger = 'runtime')
    return(result)
}

initializeLogging <- function() {
    library(logging)

    basicConfig()
    addHandler(writeToConsole, logger='runtime')
    log_level <- Sys.getenv('LOGLEVEL', unset = NA)
    if (!is.na(log_level)) {
        setLevel(log_level, 'runtime')
    }
}

initializeRuntime <- function() {
    library(httr)
    library(jsonlite)

    initializeLogging()
    HANDLER <- Sys.getenv("_HANDLER")
    HANDLER_split <- strsplit(HANDLER, ".", fixed = TRUE)[[1]]
    file_base_name <- HANDLER_split[1]
    file_name <- get_source_file_name(file_base_name)
    logdebug("Sourcing '%s'", file_name, logger = 'runtime')
    source(file_name)
    function_name <- HANDLER_split[2]
    if (!exists(function_name, mode = "function")) {
        stop(paste0("Function \"", function_name, "\" does not exist"))
    }
    return(function_name)
}

AWS_LAMBDA_RUNTIME_API <- Sys.getenv("AWS_LAMBDA_RUNTIME_API")
API_ENDPOINT <- paste0("http://", AWS_LAMBDA_RUNTIME_API, "/2018-06-01/runtime/")

throwInitError <- function(error) {
    url <- paste0(API_ENDPOINT, "init/error")
    post_error(error, url)
    stop()
}

throwRuntimeError <- function(error, REQUEST_ID) {
    url <- paste0(API_ENDPOINT, "invocation/", REQUEST_ID, "/error")
    post_error(error, url)
}

postResult <- function(result, REQUEST_ID) {
    url <- paste0(API_ENDPOINT, "invocation/", REQUEST_ID, "/response")
    res <- POST(url, body = toJSON(result, auto_unbox = TRUE), encode = "raw", content_type_json())
    logdebug("Posted result:\n%s", to_str(res), logger = 'runtime')
}

handle_request <- function(function_name) {
    event_url <- paste0(API_ENDPOINT, "invocation/next")
    event_response <- GET(event_url)
    REQUEST_ID <- event_response$headers$`Lambda-Runtime-Aws-Request-Id`
    tryCatch({
        EVENT_DATA <- rawToChar(event_response$content)
        result <- invoke_lambda(EVENT_DATA, function_name)
        postResult(result, REQUEST_ID)
    },
    error = function(error) {
        throwRuntimeError(error, REQUEST_ID)
    })
}
