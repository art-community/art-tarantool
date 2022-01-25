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
        if box.is_in_txn() then
            return func(...)
        end
        return box.atomic(func, ...)
    end,

    functional = require('fun'),

    bucketFieldNumber = function(space)
        if not (box.space[space]) or not (box.space[space].index.bucket_id) then
            return
        end
        return box.space[space].index.bucket_id.parts[1].fieldno
    end,

    bucketFromData = function(space, data)
        if not (box.space[space].index.bucket_id) then
            return
        end
        return data[1][art.core.bucketFieldNumber(space)]
    end,

    insertBucket = function(space, data, bucket_id)
        if not (data) or not (bucket_id) then
            return
        end
        local dataTuple = box.tuple.new(data[1]):update({ { '!', art.core.bucketFieldNumber(space), bucket_id } })
        return { dataTuple, data[2] }
    end,

    removeBucket = function(space, data)
        if not (data) or not (data[2]) then
            return data
        end
        local dataTuple = box.tuple.new(data[1]):update({ { '#', art.core.bucketFieldNumber(space), 1 } })
        return { dataTuple, data[2] }
    end,

    mapBucket = function(space, key)
        local mapping_entry = box.space[space]:get(key)
        if not (mapping_entry) then
            return
        end
        return mapping_entry.bucket_id
    end,

    correctUpdateOperations = function(space, operations)
        for index, command in pairs(operations[1]) do
            if command[2] >= art.core.bucketFieldNumber(space) then
                operations[1][index][2] = command[2] + 1
            end
        end
        return operations
    end,


}

return core
