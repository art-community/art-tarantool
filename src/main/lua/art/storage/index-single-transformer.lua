local transformer = {
    delete = function(space, index, key)
        return box.space[space].index[index]:delete(key)
    end,

    update = function(space, index, key, commandGroups)
        return box.atomic(function()
            local result
            for _, commands in pairs(commandGroups) do
                result = box.space[space].index[index]:update(key, commands)
            end
            return result
        end)
    end,
}

return transformer
