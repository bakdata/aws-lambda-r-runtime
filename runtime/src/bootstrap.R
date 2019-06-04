source('/opt/runtime.R')
api <- RuntimeAPI$new()
tryCatch({
    function_name <- initializeRuntime()
    while (TRUE) {
        api$handle_request(function_name)
        rm(list=ls())
        source('/opt/runtime.R')
        api <- RuntimeAPI$new()
        function_name <- initializeRuntime()
    }
}, error = api$throwInitError)
