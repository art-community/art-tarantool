local generateBucket = require("art.router.bucket-generator")
local spaceMultiple = require("art.router.constants").storageFunctions.spaceMultiple
local bucketModifier = require("art.router.bucket-id-modifier")

local transformer = {
    delete = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callrw(generateBucket(bucketRequest), spaceMultiple.delete, functionRequest)
        if error then
            return error
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    insert = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertMultipleBucketIds(functionRequest[1], bucket)

        local result, error = vshard.rouder.callrw(bucket, spaceMultiple.insert, functionRequest)
        if error then
            return error
        end

        return bucketModifier.removeMultipleBucketIds(result)
    end,

    put = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertMultipleBucketIds(functionRequest[1], bucket)

        local result, error = vshard.rouder.callrw(bucket, spaceMultiple.put, functionRequest)
        if error then
            return error
        end

        return bucketModifier.removeMultipleBucketIds(result)
    end,

    update = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callrw(generateBucket(bucketRequest), spaceMultiple.update, functionRequest)
        if error then
            return error
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,
}

return transformer
