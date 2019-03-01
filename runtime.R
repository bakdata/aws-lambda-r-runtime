library(httr)
library(jsonlite)

HANDLER <- Sys.getenv("_HANDLER")
AWS_LAMBDA_RUNTIME_API <- Sys.getenv("AWS_LAMBDA_RUNTIME_API")
args = commandArgs(trailingOnly = TRUE)
EVENT_DATA <- args[1]
REQUEST_ID <- args[2]

HANDLER_split <- strsplit(HANDLER, ".", fixed = TRUE)[[1]]
file_name <- paste0(HANDLER_split[1], ".r")
function_name <- HANDLER_split[2]
print(paste0("Sourcing '", file_name, "'"))
source(file_name)
print(paste0("Invoking function '", function_name, "'' with parameters:"))
params <- fromJSON(EVENT_DATA)
print(params)
result <- do.call(function_name, params)
print("Function returned:")
print(result)
url <- paste0("http://",
              AWS_LAMBDA_RUNTIME_API,
              "/2018-06-01/runtime/invocation/",
              REQUEST_ID,
              "/response")
res <- POST(url, body = list(result = result), encode = "json")
print("Posted result:")
print(res)
