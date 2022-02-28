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

    stream = function(space, index, processingOperators, terminatingOperator)
        local generator, param, state = box.space[space].index[index]:pairs()

        for _, operator in pairs(processingOperators) do
            local name = operator[1]
            local parameters = operator[2]
            generator, param, state = stream.processingFunctor(name)(generator, param, state, parameters)
        end

        return stream.terminatingFunctor(terminatingOperator[1])(generator, param, state, terminatingOperator[2])
    end,

    count = function(space, index, key)
        return box.space[space].index[index]:count(key)
    end,

    multiple = require("art.storage.index-multiple-transformer"),

    single = require("art.storage.index-single-transformer"),
}

return index
