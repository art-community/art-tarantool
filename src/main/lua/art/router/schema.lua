local storageFunctions = require("art.router.constants").storageFunctions
local configuration = require("art.router.configuration").configuration
local shards = require("art.router.shard-service")

local schema = {
    createIndex = function(request)
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

    createSpace = function(request, sharded)
        if (sharded) then
            table.insert(request, configuration.bucketIdField)
            shards.forEach(function(shard)
                shard:callrw(storageFunctions.schemaCreateShardSpace, request)
            end)
            return
        end

        shards.forEach(function(shard)
            shard:callrw(storageFunctions.schemaCreateStorageSpace, request)
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
