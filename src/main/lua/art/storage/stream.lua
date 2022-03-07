local functional = require('fun')
local deepEqual = require('art.storage.deep-equal')
local constants = require("art.storage.constants").stream

local filters = {}

filters[constants.filters.filterEquals] = function(filtering, field, request)
    return deepEqual(filtering[field], request[1])
end

filters[constants.filters.filterNotEquals] = function(filtering, field, request)
    return not deepEqual(filtering[field], request[1])
end

filters[constants.filters.filterMore] = function(filtering, field, request)
    return filtering[field] > request[1]
end

filters[constants.filters.filterLess] = function(filtering, field, request)
    return filtering[field] < request[1]
end

filters[constants.filters.filterBetween] = function(filtering, field, request)
    return (filtering[field] >= request[1]) and (filtering[field] <= request[2])
end

filters[constants.filters.filterNotBetween] = function(filtering, field, request)
    return not ((filtering[field] >= request[1]) and (filtering[field] <= request[2]))
end

filters[constants.filters.filterIn] = function(filtering, field, values)
    for _, value in pairs(values) do
        if deepEqual(filtering[field], value) then
            return true
        end
    end

    return false
end

filters[constants.filters.filterNotIn] = function(filtering, field, values)
    for _, value in pairs(values) do
        if deepEqual(filtering[field], value) then
            return false
        end
    end

    return true
end

filters[constants.filters.filterStartsWith] = function(filtering, field, request)
    return string.startswith(filtering[field], request[1])
end

filters[constants.filters.filterEndsWith] = function(filtering, field, request)
    return string.endswith(filtering[field], request[1])
end

filters[constants.filters.filterContains] = function(filtering, field, request)
    return string.find(filtering[field], request[1])
end

local applyFilter = function(name, filtering, field, request)
    return filters[name](filtering, field, request)
end

local filterSelector = function(name, field, request)
    return function(filtering)
        return applyFilter(name, filtering, field, request)
    end
end

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
    return functional.all(filterSelector(unpack(request)), generator, parameter, state)
end

terminatingFunctors[constants.terminatingFunctions.any] = function(generator, parameter, state, request)
    return functional.any(filterSelector(unpack(request)), generator, parameter, state)
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

processingFunctors[constants.processingFunctions.filter] = function(generator, parameter, state, request)
    local filteringFunction = function(filtering)
        local result = true

        local applyCondition = function(condition, newResult)
            if condition == constants.conditions.conditionAnd then
                result = result & newResult
                return
            end

            if condition == constants.conditions.conditionOr then
                result = result | newResult
                return
            end
        end

        for _, filter in pairs(request) do
            local condition = filter[1]
            local mode = filter[2]

            if mode == constants.filterModes.filterByValue then
                local parameters = filter[3]
                local field = parameters[1]
                local name = parameters[2]
                local values = parameters[3]
                applyCondition(condition, applyFilter(name, filtering, field, values));
            end

            if mode == constants.filterModes.filterByFunction then
                local functionName = filter[3]
                applyCondition(condition, box.func[functionName]:call(filtering));
            end

            if mode == constants.filterModes.filterBySpace then
                local parameters = filter[3]
                local otherSpace = parameters[1]
                local currentField = parameters[2]
                local mapped = box.space[otherSpace]:get(filtering[currentField])
                if mapped ~= nil then
                    local expressions = filter[4]
                    for _, expression in pairs(expressions) do
                        local expressionCondition = expression[1]
                        local expressionCurrentField = expression[2]
                        local expressionName = expression[3]
                        local expressionOtherFields = expression[4]
                        local expressionOtherValues = {}
                        for _, expressionField in pairs(expressionOtherFields) do
                            table.insert(expressionOtherValues, mapped[expressionField])
                        end
                        local newResult = applyFilter(expressionName, filtering, expressionCurrentField, expressionOtherValues)
                        applyCondition(expressionCondition, newResult);
                    end
                else
                    applyCondition(condition, false)
                end
            end

            if mode == constants.filterModes.filterByIndex then
                local parameters = filter[3]
                local otherSpace = parameters[1]
                local currentFields = parameters[2]
                local otherIndex = parameters[3]
                local indexKeys = {}
                for _, keyField in pairs(currentFields) do
                    table.insert(indexKeys, filtering[keyField])
                end
                if next(indexKeys) ~= nil then
                    local mapped = box.space[otherSpace]:index(otherIndex):get(indexKeys)
                    if mapped ~= nil then
                        local expressions = filter[4]
                        for _, expression in pairs(expressions) do
                            local expressionCondition = expression[1]
                            local expressionCurrentField = expression[2]
                            local expressionName = expression[3]
                            local expressionOtherFields = expression[4]
                            local expressionOtherValues = {}
                            for _, expressionField in pairs(expressionOtherFields) do
                                table.insert(expressionOtherValues, mapped[expressionField])
                            end
                            local newResult = applyFilter(expressionName, filtering, expressionCurrentField, expressionOtherValues)
                            applyCondition(expressionCondition, newResult);
                        end
                    else
                        applyCondition(condition, false)
                    end
                else
                    applyCondition(condition, false)
                end
            end
        end

        return result
    end

    return functional.filter(filteringFunction, generator, parameter, state)
end

processingFunctors[constants.processingFunctions.map] = function(generator, parameter, state, request)
    local mappingFunction = function(mapping)
        local mode = request[1]

        if mode == constants.mappingModes.mapByFunction then
            local functionName = request[2]
            return box.func[functionName]:call(mapping)
        end

        if mode == constants.mappingModes.mapBySpace then
            local otherSpace = request[3]
            local currentField = request[4]
            return box.space[otherSpace]:get(mapping[currentField])
        end

        if mode == constants.mappingModes.mapByIndex then
            local otherSpace = request[3]
            local currentFields = request[4]
            local otherIndex = request[5]
            local indexKeys = {}
            for _, keyField in pairs(currentFields) do
                table.insert(indexKeys, mapping[keyField])
            end
            if next(indexKeys) == nil then
                return nil
            end
            return box.space[otherSpace]:index(otherIndex):get(indexKeys)
        end
    end

    return functional.map(mappingFunction, generator, parameter, state)
end

return {
    processingFunctor = function(stream)
        return processingFunctors[stream]
    end,

    terminatingFunctor = function(stream)
        return terminatingFunctors[stream]
    end,
}
