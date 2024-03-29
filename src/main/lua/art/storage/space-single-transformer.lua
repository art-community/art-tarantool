local transformer = {
    delete = function(space, key)
        return box.space[space]:delete(key)
    end,

    insert = function(space, data)
        return box.space[space]:insert(data)
    end,

    put = function(space, data)
        return box.space[space]:put(data)
    end,

    update = function(space, key, commandGroups)
        return box.atomic(function()
            local result
            for _, commands in pairs(commandGroups) do
                result = box.space[space]:update(key, commands)
            end
            return result
        end)
    end,

    upsert = function(space, data, commandGroups)
        return box.atomic(function()
            local result
            for _, commands in pairs(commandGroups) do
                result = box.space[space]:upsert(data, commands)
            end
            return result
        end)
    end
}

return transformer
