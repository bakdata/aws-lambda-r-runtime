library(httr)
library(jsonlite)
library(logging)

to_str <- function(x) {
  return(paste(capture.output(print(x)), collapse = "\n"))
}

HANDLER <- Sys.getenv("_HANDLER")
AWS_LAMBDA_RUNTIME_API <- Sys.getenv("AWS_LAMBDA_RUNTIME_API")
args = commandArgs(trailingOnly = TRUE)
EVENT_DATA <- args[1]
REQUEST_ID <- args[2]

HANDLER_split <- strsplit(HANDLER, ".", fixed = TRUE)[[1]]
file_name <- paste0(HANDLER_split[1], ".R")
function_name <- HANDLER_split[2]
loginfo("Sourcing '%s'", file_name)
source(file_name)
params <- fromJSON(EVENT_DATA)
loginfo("Invoking function '%s' with parameters: %s", function_name, to_str(params))
result <- do.call(function_name, params)
loginfo("Function returned: %s", to_str(result))
url <- paste0("http://",
              AWS_LAMBDA_RUNTIME_API,
              "/2018-06-01/runtime/invocation/",
              REQUEST_ID,
              "/response")
res <- POST(url, body = list(result = result), encode = "json")
loginfo("Posted result: %s", to_str(res))
