--transaction request format: {string function, {arg1, ... argN} }
--arg format: {arg} or {dependency:{prev_response_index}} or {dependency:{prev_response_index, fieldname}}


local transaction = {
    execute = function(transaction, bucket_id)
        if not(bucket_id) then return false, 'Missing bucketId' end
        if not(art.transaction.isSafe(transaction)) then return false, 'Transaction contains unsafe operations for sharded cluster' end
        transaction = art.transaction.insertBuckets(transaction)
        local response = vshard.router.callrw(bucket_id, 'art.transaction.execute', { transaction})
        if response[1] then art.transaction.removeBuckets(transaction, response) end
        return response
    end,

    isSafe = function(transaction)
        for _, operation in pairs(transaction) do
            if (string.startswith(operation[1], 'art.api.space')) then return false end
            if (operation[1] == 'art.api.select') then return false end
        end
        return true
    end,

    insertBuckets = function(transaction)
        local results = {}
        for _, operation in pairs(transaction) do
            local updatedArgs = art.transaction.bucketInserters[operation[1]](operation[2])
            table.insert(results, {operation[1], updatedArgs})
        end
        return results
    end,

    removeBuckets = function(transaction, response)
        for index, tuple in pairs(response[2]) do
            response[2][index] = {art.core.removeBucket(transaction[index][2][1], tuple[1])}
        end
    end,

    bucketInserters = {},
}

local inserters = {}

local function insertBucket(args)
    if (args[2].dependency) then return args end
    args[2] = art.core.insertBucket(args[1], args[2], args[3])
    return args
end

local function identity(args)
    return args
end

inserters['art.api.get'] = identity
inserters['art.api.delete'] = identity
inserters['art.api.update'] = function(args)
    args[3] = art.core.correctUpdateOperations(args[1], args[3])
    return args
end

inserters['art.api.insert'] = insertBucket
inserters['art.api.put'] = insertBucket
inserters['art.api.autoIncrement'] = insertBucket
inserters['art.api.replace'] = insertBucket
inserters['art.api.upsert'] = function(args)
    args = insertBucket(args)
    args[3] = art.core.correctUpdateOperations(args[1], args[3])
    return args
end

transaction.bucketInserters = inserters

return transaction