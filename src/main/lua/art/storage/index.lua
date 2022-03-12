local index = {
    first = function(space, index, keys)
        local foundIndex = box.space[space].index[index]
        if foundIndex.unique and #keys == 1 then
            return foundIndex:get(keys)
        end
        return foundIndex:select(keys, { limit = 1 })[1]
    end,

    select = function(space, index, keys)
        return box.space[space].index[index]:select(keys)
    end,

    find = function(space, index, keys)
        local result = {}
        for _, key in pairs(keys) do
            local foundIndex = box.space[space].index[index]
            if foundIndex.unique and #key == 1 then
                table.insert(result, foundIndex:get(key))
            end
            local found = foundIndex:select(key, { limit = 1 })[1]
            if found then
                table.insert(result, found)
            end
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
