local index = {
    findFirst = function(space, index, key)
        return box.space[space].index[index]:get(key)
    end,

    findAll = function(space, index, keys)
        local result = {}
        for _, key in pairs(keys) do
            table.insert(result, box.space[space].index[index]:get(key))
        end
        return result
    end,

    find = function(space, index, key, operators)
        local generator, parameter, state = box.space[space].index[index]:pairs(key)

        for _, operator in pairs(operators) do
            local name = operator[1]
            local parameters = operator[2]
            local functor = art.storage.stream.select(name)
            generator, parameter, state = functor(generator, parameter, state, parameters)
        end

        return art.storage.stream.collect(generator, parameter, state)
    end,

    count = function(space, index, key)
        return box.space[space].index[index]:count(key)
    end,

    multiple = require("art.storage.index-multiple-transformer"),

    single = require("art.storage.index-single-transformer"),
}

return index
