local functional = require('fun')

local filters = {}
filters["equals"] = function(filtering, field, value)
    return filtering[field] == value
end

filters["notEquals"] = function(filtering, field, value)
    return not (filtering[field] == value)
end

filters["more"] = function(filtering, field, value)
    return filtering[field] > value
end

filters["less"] = function(filtering, field, value)
    return filtering[field] < value
end

filters["in"] = function(filtering, field, startValue, endValue)
    return (filtering[field] >= startValue) and (filtering[field] <= endValue)
end

filters["notIn"] = function(filtering, field, startValue, endValue)
    return not ((filtering[field] >= startValue) and (filtering[field] <= endValue))
end

filters["like"] = function(filtering, field, pattern)
    return string.find(filtering[field], pattern) ~= nil
end

filters["startsWith"] = function(filtering, field, pattern)
    return string.startswith(filtering[field], pattern)
end

filters["endsWith"] = function(filtering, field, pattern)
    return string.endswith(filtering[field], pattern)
end

filters["contains"] = function(filtering, field, pattern)
    return string.find(filtering[field], pattern)
end

local filterSelector = function(name, field, request)
    return function(filtering)
        return filters[name](filtering, field, unpack(request))
    end
end

local comparators = {}
comparators["greater"] = function(first, second, field)
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

local streams = {}
streams["collect"] = function(generator, parameter, state)
    local results = {}
    for _, item in functional.iter(generator, parameter, state) do
        table.insert(results, item)
    end
    return results
end
local collect = streams["collect"]

streams["limit"] = function(generator, parameter, state, count)
    return functional.take_n(count, generator, parameter, state)
end

streams["offset"] = function(generator, parameter, state, count)
    return functional.drop_n(count, generator, parameter, state)
end

streams["filter"] = function(generator, parameter, state, request)
    return functional.filter(filterSelector(request), generator, parameter, state)
end

streams["sort"] = function(generator, parameter, state, field)
    local values = collect(generator, parameter, state)
    table.sort(values, comparatorSelector(field))
    return functional.iter(values)
end

streams["distinct"] = function(generator, parameter, state, field)
    local result = {}
    for _, item in functional.iter(generator, parameter, state) do
        result[item[field]] = item
    end
    return pairs(result)
end

return {
    select = function(stream)
        return streams[stream]
    end,

    collect = collect
}
