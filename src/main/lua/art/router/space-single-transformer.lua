local transformer = {
    delete = function(bucketRequest, functionRequest)
        return box.space[space]:delete(key)
    end,

    insert = function(bucketRequest, functionRequest)
        return box.space[space]:insert(data)
    end,

    put = function(bucketRequest, functionRequest)
        return box.space[space]:put(data)
    end,

    update = function(bucketRequest, functionRequest)
        return box.atomic(function()
            local result
            for _, commands in pairs(commandGroups) do
                result = box.space[space]:update(key, commands)
            end
            return result
        end)
    end,

    upsert = function(bucketRequest, functionRequest)
        return box.atomic(function()
            local result
            for _, commands in pairs(commandGroups) do
                result = box.space[space]:upsert(data, commands)
            end
            return result
        end)
    end
}

return transformer
