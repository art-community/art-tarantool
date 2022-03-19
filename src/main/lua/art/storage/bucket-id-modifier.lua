local shard = require("art.storage.configuration").configuration.shard

local removeSingleBucketId = function(item)
    table.remove(item, shard.bucketIdField)
    return item
end

local removeMultipleBucketIds = function(items)
    for _, item in pairs(items) do
        removeSingleBucketId(item)
    end
    return items
end

local insertSingleBucketId = function(item, id)
    table.insert(item, shard.bucketIdField, id)
    return item
end

local insertMultipleBucketIds = function(items, id)
    for _, item in pairs(items) do
        insertSingleBucketId(item, id)
    end
    return items
end

return {
    removeSingleBucketId = removeSingleBucketId,

    insertSingleBucketId = insertSingleBucketId,

    removeMultipleBucketIds = removeMultipleBucketIds,

    insertMultipleBucketIds = insertMultipleBucketIds,
}
