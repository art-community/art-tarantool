local throw = require("art.router.error-thrower")
local constants = require("art.router.constants")
local storageFunctions = constants.storageFunctions
local notCreatedMessage = constants.notCreatedMessage
local configuration = require("art.router.configuration").configuration
local shards = require("art.router.shard-service")
local configuration = require("art.router.configuration").configuration

local schema = {
    createIndex = function(request)
        local options = request[3]
        local parts = options["parts"]
        for _, part in pairs(parts) do
            if part["field"] >= configuration.bucketIdField then
                part["field"] = part["field"] + 1
            end
        end
        shards.forEach(function(shard)
            local _, error = shard:callrw(storageFunctions.schemaCreateIndex, request, { timeout = configuration.timeout })
            if error ~= nil and error ~= notCreatedMessage then
                throw(error)
            end
        end)
    end,

    dropIndex = function(request)
        shards.forEach(function(shard)
            local _, error = shard:callrw(storageFunctions.schemaDropIndex, request, { timeout = configuration.timeout })
            if error ~= nil then
                throw(error)
            end
        end)
    end,

    renameSpace = function(request)
        shards.forEach(function(shard)
            local _, error = shard:callrw(storageFunctions.schemaRenameSpace, request, { timeout = configuration.timeout })
            if error ~= nil then
                throw(error)
            end
        end)
    end,

    formatSpace = function(request)
        shards.forEach(function(shard)
            local _, error = shard:callrw(storageFunctions.schemaFormat, request, { timeout = configuration.timeout })
            if error ~= nil then
                throw(error)
            end
        end)
    end,

    dropSpace = function(request)
        shards.forEach(function(shard)
            local _, error = shard:callrw(storageFunctions.schemaDropIndex, request, { timeout = configuration.timeout })
            if error ~= nil then
                throw(error)
            end
        end)
    end,

    createSpace = function(request)
        table.insert(request, configuration.bucketIdField)
        shards.forEach(function(shard)
            local _, error = shard:callrw(storageFunctions.schemaCreateSpace, request, { timeout = configuration.timeout })
            if error ~= nil and error ~= notCreatedMessage then
                throw(error)
            end
        end)
    end,

    spaces = function(request)
        return shards.flatMap(function(shard)
            local _, error = shard:callro(storageFunctions.schemaSpaces, request, { timeout = configuration.timeout })
            if error ~= nil then
                throw(error)
            end
        end)
    end,

    indices = function(request)
        return shards.flatMap(function(shard)
            local _, error = shard:callro(storageFunctions.schemaIndices, request, { timeout = configuration.timeout })
            if error ~= nil then
                throw(error)
            end
        end)
    end,
}

return schema
