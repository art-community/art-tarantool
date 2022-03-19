local throw = require("art.router.error-thrower")

local forEach = function(functor)
    local shards, error = vshard.router.routeall()

    if error ~= nil then
        throw(error)
    end

    for _, shard in pairs(shards) do
        functor(shard)
    end
end

local map = function(mapper)
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

local flatMap = function(mapper)
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

return {
    forEach = forEach,
    map = map,
    flatMap = flatMap
}
