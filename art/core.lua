local core = {
    schemaOf = function(space)
        return box.space['_' .. space .. art.config.schemaPostfix]
    end,

    mappingUpdatesOf = function(space)
        return box.space['_' .. space .. art.config.mappingSpacePostfix]
    end,

    clock = require('clock'),

    hash = function(key)
        local ldigest = require('digest')
        if type(key) ~= 'table' then
            return ldigest.crc32(tostring(key))
        else
            local crc32 = ldigest.crc32.new()
            for _, v in ipairs(key) do
                crc32:update(tostring(v))
            end
            return crc32:result()
        end
    end,

    fiber = require('fiber'),

    functionFromString = function(string)
        return loadstring('return ' .. string)()
    end,

    atomic = function(func, ...)
        if box.is_in_txn() then return func(...) end
        return box.atomic(func, ...)
    end,

    functional = require('fun'),

    bucketFromData = function(space, data)
        if not(box.space[space].index.bucket_id) then return end
        return data[1][ box.space[space].index.bucket_id.parts[1].fieldno ]
    end,

    insertBucket = function(space, data, bucket_id)
        if not(data) or not(bucket_id) then return end
        local dataTuple = box.tuple.new(data[1]):update({{'!', box.space[space].index.bucket_id.parts[1].fieldno, bucket_id}})
        return {dataTuple, data[2]}
    end,

    removeBucket = function(space, data)
        if not(data) or not(data[2]) then return data end
        local dataTuple = box.tuple.new(data[1]):update({{'#', box.space[space].index.bucket_id.parts[1].fieldno, 1}})
        return {dataTuple, data[2]}
    end,

    mapBucket = function(space, key)
        local mapping_entry = box.space[space]:get(key)
        if not (mapping_entry) then return end
        return mapping_entry.bucket_id
    end,

    correctUpdateOperations = function(space, operations)
        local fieldno = box.space[space].index.bucket_id.parts[1].fieldno
        for index, command in pairs(operations[1]) do
            if command[2] >= fieldno then operations[1][index][2] = command[2] + 1 end
        end
        return operations
    end,

    stream = {
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
                return not(object[fieldno] == value)
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
                return not((object[fieldno] >= startValue) and (object[fieldno] <= endValue))
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
}

return core