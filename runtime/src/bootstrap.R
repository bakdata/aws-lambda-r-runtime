source('/opt/runtime.R')
tryCatch({
    function_name <- initialize_runtime()
    while (TRUE) {
        handle_request(function_name)
        logReset()
        rm(list=ls())
        source('/opt/runtime.R')
        function_name <- initialize_runtime()
    }
}, error = throw_init_error)
