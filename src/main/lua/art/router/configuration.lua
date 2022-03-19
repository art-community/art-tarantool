local configuration = {
    bucketIdField = 2
}

local configure = function(newConfiguration)
    configuration.bucketIdField = newConfiguration.bucketIdField
end

return {
    configuration = configuration,
    configure = configure
}
