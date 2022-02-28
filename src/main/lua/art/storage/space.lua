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

    stream = function(space, processingOperators, terminalOperator)
        local generator, param, state = box.space[space]:pairs()

        for _, operator in pairs(processingOperators) do
            local name = operator[1]
            local parameters = operator[2]
            generator, param, state = stream.processingFunctor(name)(generator, param, state, parameters)
        end

        return stream.terminalFunctor(terminalOperator)(generator, param, state)
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
