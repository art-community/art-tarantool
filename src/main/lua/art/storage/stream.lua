local stream = {
    limit = function(gen, param, state, count)
        return art.core.functional.take_n(count, gen, param, state)
    end,

    offset = function(gen, param, state, count)
        return art.core.functional.drop_n(count, gen, param, state)
    end,

    filter = function(gen, param, state, args)
        return art.core.functional.filter(art.core.stream.filters.compile(unpack(args)), gen, param, state)
    end,

    sort = function(gen, param, state, args)
        local values = art.core.stream.collect(gen, param, state)
        table.sort(values, art.core.stream.comparators.compile(unpack(args)))
        return art.core.functional.iter(values)
    end,

    distinct = function(gen, param, state, fieldno)
        local result = {}
        for _, item in art.core.functional.iter(gen, param, state) do
            result[item[fieldno]] = item
        end
        return pairs(result)
    end,

    collect = function(gen, param, state)
        local results = {}
        for _, v in art.core.functional.iter(gen, param, state) do
            table.insert(results, v)
        end
        return results
    end,

    filters = {
        compile = function(filter, fieldno, arg1, arg2)
            return function(object)
                return art.core.functionFromString(filter)(object, fieldno, arg1, arg2)
            end
        end,

        equals = function(object, fieldno, value)
            return object[fieldno] == value
        end,

        notEquals = function(object, fieldno, value)
            return not (object[fieldno] == value)
        end,

        more = function(object, fieldno, value)
            return object[fieldno] > value
        end,

        less = function(object, fieldno, value)
            return object[fieldno] < value
        end,

        inRange = function(object, fieldno, startValue, endValue)
            return (object[fieldno] >= startValue) and (object[fieldno] <= endValue)
        end,

        notInRange = function(object, fieldno, startValue, endValue)
            return not ((object[fieldno] >= startValue) and (object[fieldno] <= endValue))
        end,

        like = function(object, fieldno, pattern)
            return string.find(object[fieldno], pattern) ~= nil
        end,

        startsWith = function(object, fieldno, pattern)
            return string.startswith(object[fieldno], pattern)
        end,

        endsWith = function(object, fieldno, pattern)
            return string.endswith(object[fieldno], pattern)
        end,

        contains = function(object, fieldno, pattern)
            return string.find(object[fieldno], pattern)
        end,

    },

    comparators = {
        compile = function(comparator, fieldno)
            return function(left, right)
                return art.core.functionFromString(comparator)(left, right, fieldno)
            end
        end,

        greater = function(first, second, fieldno)
            return first[fieldno] > second[fieldno]
        end,

        less = function(first, second, fieldno)
            return first[fieldno] < second[fieldno]
        end

    }
}

return stream
