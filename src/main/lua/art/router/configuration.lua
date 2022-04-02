local configuration = {
    bucketIdField = 2,
    callTimeout = 5,
}

local configure = function(newConfiguration)
    configuration.bucketIdField = newConfiguration.bucketIdField
    configuration.callTimeout = newConfiguration.callTimeout
end

return {
    configuration = configuration,
    configure = configure
}
