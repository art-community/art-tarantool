local functional = require('fun')

local function deepEqual(first, second)
    if first == second then
        return true
    end

    if type(first) == "table" and type(second) == "table" then
        for key1, value1 in pairs(first) do
            local value2 = second[key1]

            if value2 == nil then
                return false
            end

            if value1 ~= value2 then
                if type(value1) == "table" and type(value2) == "table" then
                    if not deepEqual(value1, value2) then
                        return false
                    end
                end

                return false
            end
        end

        for key2, _ in pairs(second) do
            if first[key2] == nil then
                return false
            end
        end

        return true
    end

    return false
end

local applyFilter = function(filter, generator, parameter, state)
    return functional.filter(filter, generator, parameter, state)
end

local filters = {}

filters["equals"] = function(filtering, field, request)
    return deepEqual(filtering[field], request[1])
end

filters["notEquals"] = function(filtering, field, request)
    return not deepEqual(filtering[field], request[1])
end

filters["more"] = function(filtering, field, request)
    return filtering[field] > request[1]
end

filters["less"] = function(filtering, field, request)
    return filtering[field] < request[1]
end

filters["between"] = function(filtering, field, request)
    return (filtering[field] >= request[1]) and (filtering[field] <= request[2])
end

filters["notBetween"] = function(filtering, field, request)
    return not ((filtering[field] >= request[1]) and (filtering[field] <= request[2]))
end

filters["in"] = function(filtering, field, values)
    for _, value in pairs(values) do
        if deepEqual(filtering[field], value) then
            return true
        end
    end

    return false
end

filters["notIn"] = function(filtering, field, values)
    for _, value in pairs(values) do
        if deepEqual(filtering[field], value) then
            return false
        end
    end

    return true
end

filters["startsWith"] = function(filtering, field, request)
    return string.startswith(filtering[field], request[1])
end

filters["endsWith"] = function(filtering, field, request)
    return string.endswith(filtering[field], request[1])
end

filters["contains"] = function(filtering, field, request)
    return string.find(filtering[field], request[1])
end

local selectFilter = function(name, filtering, field, request)
    return filters[name](filtering, field, request)
end

local filterSelector = function(name, field, request)
    return function(filtering)
        return selectFilter(name, filtering, field, request)
    end
end

local comparators = {}

comparators["more"] = function(first, second, field)
    return first[field] > second[field]
end

comparators["less"] = function(first, second, field)
    return first[field] < second[field]
end

local comparatorSelector = function(name, field)
    return function(first, second)
        return comparators[name](first, second, field)
    end
end

local terminatingFunctors = {}

terminatingFunctors["collect"] = function(generator, parameter, state)
    local results = {}
    for _, item in functional.iter(generator, parameter, state) do
        table.insert(results, item)
    end
    return results
end

terminatingFunctors["count"] = function(generator, parameter, state)
    return functional.length(generator, parameter, state)
end

terminatingFunctors["all"] = function(generator, parameter, state, request)
    return functional.all(filterSelector(unpack(request)), generator, parameter, state)
end

terminatingFunctors["any"] = function(generator, parameter, state, request)
    return functional.any(filterSelector(unpack(request)), generator, parameter, state)
end

local processingFunctors = {}

processingFunctors["limit"] = function(generator, parameter, state, count)
    return functional.take_n(count, generator, parameter, state)
end

processingFunctors["offset"] = function(generator, parameter, state, count)
    return functional.drop_n(count, generator, parameter, state)
end

processingFunctors["filter"] = function(generator, parameter, state, request)
    return applyFilter(filterSelector(unpack(request)), generator, parameter, state)
end

processingFunctors["filterWith"] = function(generator, parameter, state, request)

    local filteringFunction = function(filtering)
        for _, requestElement in pairs(request) do
            local mapper = requestElement[1]
            local filter = requestElement[2]

            local mode = mapper[1]

            if mode == "byKey" then
                local mappedSpace = mapper[2]
                local keyField = mapper[3]
                local mapped = box.space[mappedSpace].get(filtering[keyField])
                if mapped == nil then
                    return false
                end
                local filterName = filter[1]
                local filterCurrentField = filter[2]
                local filterOtherFields = filter[3]
                local filterOtherValues = {}
                for _, otherField in pairs(filterOtherFields) do
                    table.insert(filterOtherValues, mapped[otherField])
                end
                if next(filterOtherValues) == nil then
                    return false
                end
                return selectFilter(filterName, filtering, filterCurrentField, { filterCurrentField, filterOtherValues })
            end

            if mode == "byIndex" then
                local mappedSpace = mapper[2]
                local mappedIndex = mapper[3]
                local keyFields = mapper[4]
                local indexKeys = {}
                for _, keyField in pairs(keyFields) do
                    table.insert(indexKeys, filtering[keyField])
                end
                if next(indexKeys) == nil then
                    return false
                end
                local mapped = box.space[mappedSpace]:index(mappedIndex).get(indexKeys)
                if mapped == nil then
                    return false
                end
                local filterName = filter[1]
                local filterCurrentField = filter[2]
                local filterOtherFields = filter[3]
                local filterOtherValues = {}
                for _, otherField in pairs(filterOtherFields) do
                    table.insert(filterOtherValues, mapped[otherField])
                end
                if next(filterOtherValues) == nil then
                    return false
                end
                return selectFilter(filterName, filtering, filterCurrentField, { filterCurrentField, filterOtherValues })
            end
        end
    end

    return applyFilter(filteringFunction, generator, parameter, state)
end

local collect = terminatingFunctors["collect"]
processingFunctors["sort"] = function(generator, parameter, state, request)
    local values = collect(generator, parameter, state)
    table.sort(values, comparatorSelector(unpack(request)))
    return functional.iter(values)
end

processingFunctors["distinct"] = function(generator, parameter, state, field)
    local result = {}
    for _, item in functional.iter(generator, parameter, state) do
        result[item[field]] = item
    end
    return pairs(result)
end

return {
    processingFunctor = function(stream)
        return processingFunctors[stream]
    end,

    terminatingFunctor = function(stream)
        return terminatingFunctors[stream]
    end,
}
