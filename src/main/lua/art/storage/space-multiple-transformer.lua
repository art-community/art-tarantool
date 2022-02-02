local transformer = {
    delete = function(space, keys)
        local results = {}
        for _, key in pairs(keys) do
            table.insert(results, box.space[space]:delete(key))
        end
        return results
    end,

    insert = function(space, values)
        local results = {}
        for _, value in pairs(values) do
            table.insert(results, box.space[space]:insert(value))
        end
        return results
    end,

    put = function(space, values)
        local results = {}
        for _, value in pairs(values) do
            table.insert(results, box.space[space]:put(value))
        end
        return results
    end,

    replace = art.storage.space.multiple.put
}

return transformer
