local configuration = {
    shard = {
        bucketIdField = 2
    }
}

local configure = function(newConfiguration)
    configuration.shard = newConfiguration.shard
end

return {
    configuration = configuration,
    configure = configure
}
