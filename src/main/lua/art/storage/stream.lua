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

local filterSelector = function(name, field, request)
    return function(filtering)
        return filters[name](filtering, field, request)
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

local terminalFunctors = {}

terminalFunctors["collect"] = function(generator, parameter, state)
    local results = {}
    for _, item in functional.iter(generator, parameter, state) do
        table.insert(results, item)
    end
    return results
end

terminalFunctors["count"] = function(generator, parameter, state)
    return functional.length(generator, parameter, state)
end

terminalFunctors["all"] = function(generator, parameter, state, request)
    return functional.all(filterSelector(unpack(request)), generator, parameter, state)
end

terminalFunctors["any"] = function(generator, parameter, state, request)
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
    return functional.filter(filterSelector(unpack(request)), generator, parameter, state)
end

local collect = terminalFunctors["collect"]
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
    terminalFunctor = function(stream)
        return terminalFunctors[stream]
    end,
}
