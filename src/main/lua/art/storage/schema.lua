local schema = {
    createIndex = function(space, name, configuration)
        if not configuration then
            configuration = {}
        end
        return box.space[space]:create_index(name, configuration)
    end,

    dropIndex = function(space, name)
        box.space[space].index[name]:drop()
        return {}
    end,

    renameSpace = function(space, name)
        return box.space[space]:rename(name)
    end,

    formatSpace = function(space, format)
        return box.space[space]:format(format)
    end,

    dropSpace = function(space)
        box.space[space]:drop()
    end,

    createSpace = function(name, configuration)
        if not configuration then
            configuration = {}
        end
        box.schema.space.create(name, configuration)
    end,

    spaces = function()
        local result = {}
        for _, value in pairs(box.space._space:select()) do
            if not (string.startswith(value[3], '_')) then
                table.insert(result, value[3])
            end
        end
        return result
    end,

    indicies = function(space)
        local result = {}
        for _, value in pairs(box.space[space].index) do
            table.insert(result, value.name)
        end
        return result
    end,
}

return schema
