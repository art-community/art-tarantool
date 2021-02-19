--transaction request format: {string function, {arg1, ... argN} }
--arg format: {arg} or {dependency:{prev_response_index}} or {dependency:{prev_response_index, fieldname}}


local transaction = {
    execute = function(transaction, bucket_id)
        if not(bucket_id) then return false, 'Missing bucketId' end
        if not(art.transaction.isSafe(transaction)) then return false, 'Transaction contains unsafe operations for sharded cluster' end
        if not art.transaction.checkBuckets(transaction) then return false, 'Transaction should be bucket-local' end
        transaction = art.transaction.insertBuckets(transaction)
        return vshard.router.callrw(bucket_id, 'art.transaction.execute', {transaction, bucket_id})
    end,

    isSafe = function(transaction)
        for _, operation in pairs(transaction) do
            if (string.startswith(operation[1], 'art.api.space') and (not (operation[1]:find('list'))) ) then return false end
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

    checkBuckets = function(transaction)
        local bucket = -1
        for _, operation in pairs(transaction) do
            local current = art.transaction.bucketGetters[operation[1]](operation[2])
            if (bucket == -1) then bucket = current end
            if not (current == bucket) then return false end
        end
        if (bucket == -1) then return false end
        return true
    end,

    bucketInserters = {},

    bucketGetters = {},
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

inserters['art.api.space.list'] = identity
inserters['art.api.space.listIndices'] = identity

inserters['art.api.get'] = identity
inserters['art.api.delete'] = identity
inserters['art.api.update'] = identity

inserters['art.api.insert'] = insertBucket
inserters['art.api.put'] = insertBucket
inserters['art.api.autoIncrement'] = insertBucket
inserters['art.api.replace'] = insertBucket
inserters['art.api.upsert'] = insertBucket

transaction.bucketInserters = inserters




local getters = {}

local function fromKey(args)
    if not(args[2].dependency) then return -1 end
    return art.core.mapBucket(args[1], args[2])
end

local function fromData(args)
    if (args[3].dependency) then return -1 end
    return args[3]
end

local function empty()
    return -1
end

getters['art.api.space.list'] = empty
getters['art.api.space.listIndices'] = empty

getters['art.api.get'] = fromKey
getters['art.api.delete'] = fromKey
getters['art.api.update'] = fromKey

getters['art.api.insert'] = fromData
getters['art.api.put'] = fromData
getters['art.api.autoIncrement'] = fromData
getters['art.api.replace'] = fromData
getters['art.api.upsert'] = function(args)
    if (args[4].dependency) then return -1 end
    return args[4]
end

transaction.bucketGetters = getters

return transaction