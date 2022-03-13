stream = require("art.storage.stream")

local space = {
    first = function(space, key)
        return box.space[space]:get(key)
    end,

    select = function(space, key, options)
        if options == nil then
            return box.space[space]:select(key)
        end
        return box.space[space]:select(key, { offset = options[1], limit = options[2] })
    end,

    find = function(space, keys)
        local result = {}
        for _, key in pairs(keys) do
            for _, selected in pairs(box.space[space]:select(key)) do
                if selected ~= nil then
                    table.insert(result, selected)
                end
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

    count = function(space, key)
        return box.space[space]:count(key)
    end,

    truncate = function(space)
        box.space[space]:truncate()
        return {}
    end,

    multiple = require("art.storage.space-multiple-transformer"),

    single = require("art.storage.space-single-transformer"),
}

return space
