local configuration = {
    bucketIdField = 2,
    callTimeout = 0.5,
}

local configure = function(newConfiguration)
    if newConfiguration.bucketIdField ~= nil then
        configuration.bucketIdField = newConfiguration.bucketIdField
    end
    if newConfiguration.callTimeout ~= nil then
        configuration.callTimeout = newConfiguration.callTimeout
    end
end

return {
    configuration = configuration,
    configure = configure
}
