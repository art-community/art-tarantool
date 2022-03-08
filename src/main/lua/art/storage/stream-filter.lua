local deepEqual = require('art.storage.deep-equal')
local constants = require("art.storage.constants").stream
local functional = require('fun')

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

local selector = function(name, field, request)
    return function(filtering)
        return applyFilter(name, filtering, field, request)
    end
end

local applyCondition = function(condition, currentResult, newResult)
    if condition == constants.conditions.conditionAnd then
        return currentResult & newResult
    end

    if condition == constants.conditions.conditionOr then
        return currentResult | newResult
    end
end

local processExpressions = function(expressions, filtering, mapped, currentResult)
    local result = currentResult
    for _, expression in pairs(expressions) do
        local expressionType = expression[1]
        local expressionCondition = expression[2]
        local expressionName = expression[3]
        local expressionField = expression[4]

        local expressionTarget
        local expressionValues

        if expressionType == constants.filterExpressions.filterExpressionField then
            expressionTarget = filtering
            for _, mappedField in pairs(expression[5]) do
                table.insert(expressionValues, mapped[mappedField])
            end
        end

        if expressionType == constants.filterExpressions.filterExpressionValue then
            expressionTarget = mapped
            expressionValues = expression[5]
        end

        local newResult = applyFilter(expressionName, expressionTarget, expressionField, expressionValues)
        result = applyCondition(expressionCondition, result, newResult);
    end
    return result
end

local processFilters
processFilters = function(filtering, inputFilters)
    local result = true
    for _, filter in pairs(inputFilters) do
        local condition = filter[1]
        local mode = filter[2]

        if mode == constants.filterModes.nestedFilter then
            result = applyCondition(condition, result, processFilters(filter[3]));
        end

        if mode == constants.filterModes.filterByField then
            local parameters = filter[3]
            local field = parameters[1]
            local name = parameters[2]
            local values = parameters[3]
            result = applyCondition(condition, result, applyFilter(name, filtering, field, values));
        end

        if mode == constants.filterModes.filterByFunction then
            local functionName = filter[3]
            result = applyCondition(condition, result, box.func[functionName]:call(filtering));
        end

        if mode == constants.filterModes.filterBySpace then
            local parameters = filter[3]
            local otherSpace = parameters[1]
            local filteringField = parameters[2]
            local mapped = box.space[otherSpace]:get(filtering[filteringField])
            if mapped ~= nil then
                result = processExpressions(filter[4], filtering, mapped, result)
            else
                result = applyCondition(condition, result, false)
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
                    result = processExpressions(filter[4], filtering, mapped, result)
                else
                    result = applyCondition(condition, result, false)
                end
            else
                result = applyCondition(condition, result, false)
            end
        end
    end
    return result
end

local filter = function(generator, parameter, state, request)
    local filteringFunction = function(filtering)
        return processFilters(filtering, request)
    end
    return functional.filter(filteringFunction, generator, parameter, state)
end

return {
    selector = selector,

    functor = filter
}
