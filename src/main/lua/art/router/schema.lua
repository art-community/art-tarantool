local throw = require("art.router.error-thrower")
local storageFunctions = require("art.router.constants").storageFunctions
local configuration = require("art.router.configuration").configuration

local forEachShard = function(functor)
    local shards, error = vshard.router.routeall()

    if error ~= nil then
        throw(error)
    end

    for _, shard in pairs(shards) do
        functor(shard)
    end
end

local mapShards = function(mapper)
    local results = {}
    local shards, error = vshard.router.routeall()

    if error ~= nil then
        throw(error)
    end

    for _, shard in pairs(shards) do
        table.insert(results, mapper(shard))
    end

    return results
end

local flatMapShards = function(mapper)
    local results = {}
    local shards, error = vshard.router.routeall()

    if error ~= nil then
        throw(error)
    end

    for _, shard in pairs(shards) do
        for _, result in pairs(mapper(shard)) do
            table.insert(results, result)
        end
    end

    return results
end

local schema = {
    createIndex = function(request)
        forEachShard(function(shard)
            shard:callrw(storageFunctions.schemaCreateIndex, request)
        end)
    end,

    dropIndex = function(request)
        forEachShard(function(shard)
            shard:callrw(storageFunctions.schemaDropIndex, request)
        end)
    end,

    renameSpace = function(request)
        forEachShard(function(shard)
            shard:callrw(storageFunctions.schemaRenameSpace, request)
        end)
    end,

    formatSpace = function(request)
        forEachShard(function(shard)
            shard:callrw(storageFunctions.schemaFormat, request)
        end)
    end,

    dropSpace = function(request)
        forEachShard(function(shard)
            shard:callrw(storageFunctions.schemaDropIndex, request)
        end)
    end,

    createSpace = function(request, sharded)
        if (sharded) then
            table.insert(request, configuration.bucketIdField)
            forEachShard(function(shard)
                shard:callrw(storageFunctions.schemaCreateShardedSpace, request)
            end)
            return
        end

        forEachShard(function(shard)
            shard:callrw(storageFunctions.schemaCreateStorageSpace, request)
        end)
    end,

    spaces = function(request)
        return flatMapShards(function(shard)
            shard:callro(storageFunctions.schemaSpaces, request)
        end)
    end,

    indices = function(request)
        return flatMapShards(function(shard)
            shard:callro(storageFunctions.schemaIndices, request)
        end)
    end,
}

return schema
