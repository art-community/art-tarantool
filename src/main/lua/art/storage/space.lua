stream = require("art.storage.stream")

local space = {
    findFirst = function(space, key)
        return box.space[space]:get(key)
    end,

    findAll = function(space, keys)
        local result = {}
        for _, key in pairs(keys) do
            local value = box.space[space]:get(key)
            if value ~= nil then
                table.insert(result, value)
            end
        end
        return result
    end,

    stream = function(space, processingOperators, terminatingOperator)
        local generator, parameter, state = box.space[space]:pairs()

        for _, operator in pairs(processingOperators) do
            local name = operator[1]
            local parameters = operator[2]

            generator, parameter, state = stream.processingFunctor(name)(generator, parameter, state, parameters)
        end

        return stream.terminatingFunctor(terminatingOperator[1])(generator, parameter, state, terminatingOperator[2])
    end,

    count = function(space)
        return box.space[space]:count()
    end,

    truncate = function(space)
        box.space[space]:truncate()
        return {}
    end,

    multiple = require("art.storage.space-multiple-transformer"),

    single = require("art.storage.space-single-transformer"),
}

return space
