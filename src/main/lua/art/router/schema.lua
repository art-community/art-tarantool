local storageFunctions = require("art.router.constants").storageFunctions
local configuration = require("art.router.configuration").configuration
local shards = require("art.router.shard-service")

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
            shard:callrw(storageFunctions.schemaCreateIndex, request)
        end)
    end,

    dropIndex = function(request)
        shards.forEach(function(shard)
            shard:callrw(storageFunctions.schemaDropIndex, request)
        end)
    end,

    renameSpace = function(request)
        shards.forEach(function(shard)
            shard:callrw(storageFunctions.schemaRenameSpace, request)
        end)
    end,

    formatSpace = function(request)
        shards.forEach(function(shard)
            shard:callrw(storageFunctions.schemaFormat, request)
        end)
    end,

    dropSpace = function(request)
        shards.forEach(function(shard)
            shard:callrw(storageFunctions.schemaDropIndex, request)
        end)
    end,

    createShardSpace = function(request)
        table.insert(request, configuration.bucketIdField)
        shards.forEach(function(shard)
            shard:callrw(storageFunctions.schemaCreateShardSpace, request)
        end)
    end,

    spaces = function(request)
        return shards.flatMap(function(shard)
            shard:callro(storageFunctions.schemaSpaces, request)
        end)
    end,

    indices = function(request)
        return shards.flatMap(function(shard)
            shard:callro(storageFunctions.schemaIndices, request)
        end)
    end,
}

return schema
