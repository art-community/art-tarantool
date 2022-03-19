local stream = art.stream

local index = {
    first = function(space, index, keys)
        local foundIndex = box.space[space].index[index]
        if foundIndex.unique or #keys == 1 then
            return foundIndex:get(keys)
        end
        return foundIndex:select(keys, { limit = 1 })[1]
    end,

    select = function(space, index, keys, options)
        if options == nil then
            return box.space[space].index[index]:select(keys)
        end
        return box.space[space].index[index]:select(keys, { offset = options[1], limit = options[2] })
    end,

    find = function(space, index, keys)
        local result = {}
        for _, key in pairs(keys) do
            for _, selected in pairs(box.space[space].index[index]:select(key)) do
                if selected ~= nil then
                    table.insert(result, selected)
                end
            end
        end
        return result
    end,

    stream = function(space, index, operators, options)
        local processingOperators = operators[1]
        local terminatingOperators = operators[2]
        local baseKey = options[1]

        local generator, param, state = box.space[space].index[index]:pairs(baseKey)

        for _, operator in pairs(processingOperators) do
            local name = operator[1]
            local parameters = operator[2]
            generator, param, state = stream.processingFunctor(name)(generator, param, state, parameters)
        end

        return stream.terminatingFunctor(terminatingOperators[1])(generator, param, state, terminatingOperators[2])
    end,

    count = function(space, index, key)
        return box.space[space].index[index]:count(key)
    end,

    multiple = require("art.storage.index-multiple-transformer"),

    single = require("art.storage.index-single-transformer"),
}

return index
