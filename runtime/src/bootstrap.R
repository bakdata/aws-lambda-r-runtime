source('/opt/runtime.R')
tryCatch({
    function_name <- initializeRuntime()
    while (TRUE) {
        handle_request(function_name)
        logReset()
        rm(list=ls())
        source('/opt/runtime.R')
        function_name <- initializeRuntime()
    }
}, error = throwInitError)
