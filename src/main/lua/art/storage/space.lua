local space = {
    findFirst = function(space, key)
        return box.space[space]:get(key)
    end,

    findAll = function(space, keys)
        local result = {}
        for _, key in pairs(keys) do
            table.insert(result, box.space[space]:get(key))
        end
        return result
    end,

    find = function(space, key, operators)
        local generator, param, state = box.space[space]:pairs(key)

        for _, operator in pairs(operators) do
            local name = operator[1]
            local parameters = operator[2]
            local functor = art.storage.stream.select(name)
            generator, param, state = functor(generator, param, state, parameters)
        end

        return art.storage.stream.collect(generator, param, state)
    end,

    count = function(space)
        return box.space[space]:count()
    end,

    truncate = function(space)
        box.space[space]:truncate()
        return {}
    end,
}

return space