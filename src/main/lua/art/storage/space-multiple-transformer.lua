local transformer = {
    delete = function(space, keys)
        return box.atomic(function()
            local results = {}
            for _, key in pairs(keys) do
                table.insert(results, box.space[space]:delete(key))
            end
            return results
        end)
    end,

    insert = function(space, values)
        return box.atomic(function()
            local results = {}
            for _, value in pairs(values) do
                table.insert(results, box.space[space]:insert(value))
            end
            return results
        end)
    end,

    put = function(space, values)
        return box.atomic(function()
            local results = {}
            for _, value in pairs(values) do
                table.insert(results, box.space[space]:put(value))
            end
            return results
        end)
    end,

    update = function(space, keys, commands)
        return box.atomic(function()
            local results = {}
            for _, key in pairs(keys) do
                table.insert(results, box.space[space]:update(key, commands))
            end
            return results
        end)
    end,

    replace = put
}

return transformer
