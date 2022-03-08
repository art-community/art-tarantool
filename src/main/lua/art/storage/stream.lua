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

local comparatorSelector = function(name, field)
    return function(first, second)
        return comparators[name](first, second, field)
    end
end

local terminatingFunctors = {}

terminatingFunctors[constants.terminatingFunctions.collect] = function(generator, parameter, state)
    local results = {}
    for _, item in functional.iter(generator, parameter, state) do
        table.insert(results, item)
    end
    return results
end

local collect = terminatingFunctors[constants.terminatingFunctions.collect]

terminatingFunctors[constants.terminatingFunctions.count] = function(generator, parameter, state)
    return functional.length(generator, parameter, state)
end

terminatingFunctors[constants.terminatingFunctions.all] = function(generator, parameter, state, request)
    return functional.all(streamFilter.selector(unpack(request)), generator, parameter, state)
end

terminatingFunctors[constants.terminatingFunctions.any] = function(generator, parameter, state, request)
    return functional.any(streamFilter.selector(unpack(request)), generator, parameter, state)
end

local processingFunctors = {}

processingFunctors[constants.processingFunctions.limit] = function(generator, parameter, state, count)
    return functional.take_n(count, generator, parameter, state)
end

processingFunctors[constants.processingFunctions.offset] = function(generator, parameter, state, count)
    return functional.drop_n(count, generator, parameter, state)
end

processingFunctors[constants.processingFunctions.distinct] = function(generator, parameter, state, field)
    local result = {}
    for _, item in functional.iter(generator, parameter, state) do
        result[item[field]] = item
    end
    return pairs(result)
end

processingFunctors[constants.processingFunctions.sort] = function(generator, parameter, state, request)
    local values = collect(generator, parameter, state)
    table.sort(values, comparatorSelector(unpack(request)))
    return functional.iter(values)
end

processingFunctors[constants.processingFunctions.filter] = streamFilter.functor

processingFunctors[constants.processingFunctions.map] = streamMapper

return {
    processingFunctor = function(stream)
        return processingFunctors[stream]
    end,

    terminatingFunctor = function(stream)
        return terminatingFunctors[stream]
    end,
}
