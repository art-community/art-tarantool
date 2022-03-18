local generateBucket = require("art.router.bucket-generator")
local spaceSingle = require("art.router.constants").storageFunctions.spaceSingle
local bucketModifier = require("art.router.bucket-id-modifier")

local transformer = {
    delete = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callrw(generateBucket(bucketRequest), spaceSingle.delete, functionRequest)
        if error then
            return error
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    insert = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertSingleBucketId(functionRequest[1], bucket)

        local result, error = vshard.rouder.callrw(bucket, spaceSingle.insert, functionRequest)
        if error then
            return error
        end

        return bucketModifier.removeSingleBucketId(result)
    end,

    put = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertSingleBucketId(functionRequest[1], bucket)

        local result, error = vshard.rouder.callrw(bucket, spaceSingle.put, functionRequest)
        if error then
            return error
        end

        return bucketModifier.removeSingleBucketId(result)
    end,

    update = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callrw(generateBucket(bucketRequest), spaceSingle.update, functionRequest)
        if error then
            return error
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    upsert = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertSingleBucketId(functionRequest[1], bucket)

        local result, error = vshard.rouder.callrw(bucket, spaceSingle.upsert, functionRequest)
        if error then
            return error
        end

        return bucketModifier.removeSingleBucketId(result)
    end
}

return transformer
