local functional = require('fun')
local constants = require("art.storage.constants").stream
local streamFilter = require("art.storage.stream-filter")
local streamMapper = require("art.storage.stream-mapper")

local comparators = {}

comparators[constants.comparators.comparatorMore] = function(first, second, field)
    return first[field] > second[field]
end

comparators[constants.comparators.comparatorLess] = function(first, second, field)
    return first[field] < second[field]
end

local comparatorSelector = function(id, field)
    return function(first, second)
        return comparators[id](first, second, field)
    end
end

local terminatingFunctors = {}

terminatingFunctors[constants.terminatingFunctions.terminatingCollect] = function(generator, parameter, state)
    local results = {}
    for _, item in functional.iter(generator, parameter, state) do
        table.insert(results, item)
    end
    return results
end

local collect = terminatingFunctors[constants.terminatingFunctions.terminatingCollect]

terminatingFunctors[constants.terminatingFunctions.terminatingCount] = function(generator, parameter, state)
    return functional.length(generator, parameter, state)
end

terminatingFunctors[constants.terminatingFunctions.terminatingAll] = function(generator, parameter, state, request)
    return functional.all(streamFilter.functor(unpack(request)), generator, parameter, state)
end

terminatingFunctors[constants.terminatingFunctions.terminatingAny] = function(generator, parameter, state, request)
    return functional.any(streamFilter.functor(unpack(request)), generator, parameter, state)
end

terminatingFunctors[constants.terminatingFunctions.terminatingNone] = function(generator, parameter, state, request)
    return not functional.any(streamFilter.functor(unpack(request)), generator, parameter, state)
end

local processingFunctors = {}

processingFunctors[constants.processingFunctions.processingLimit] = function(generator, parameter, state, count)
    return functional.take_n(count, generator, parameter, state)
end

processingFunctors[constants.processingFunctions.processingOffset] = function(generator, parameter, state, count)
    return functional.drop_n(count, generator, parameter, state)
end

processingFunctors[constants.processingFunctions.processingDistinct] = function(generator, parameter, state, field)
    local result = {}
    for _, item in functional.iter(generator, parameter, state) do
        result[item[field]] = item
    end
    return pairs(result)
end

processingFunctors[constants.processingFunctions.processingSort] = function(generator, parameter, state, request)
    local values = collect(generator, parameter, state)
    table.sort(values, comparatorSelector(unpack(request)))
    return functional.iter(values)
end

processingFunctors[constants.processingFunctions.processingFilter] = streamFilter.filter

processingFunctors[constants.processingFunctions.processingMap] = streamMapper

return {
    processingFunctor = function(stream)
        return processingFunctors[stream]
    end,

    terminatingFunctor = function(stream)
        return terminatingFunctors[stream]
    end,
}
