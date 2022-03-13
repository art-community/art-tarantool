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

    update = function(space, keys, commandGroups)
        return box.atomic(function()
            local results = {}
            for _, key in pairs(keys) do
                local result
                for _, commands in pairs(commandGroups) do
                    result = box.space[space]:update(key, commands)
                end
                table.insert(results, result)
            end
            return results
        end)
    end,

    replace = put
}

return transformer
