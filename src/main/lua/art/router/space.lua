local stream = require("art.router.stream")
local generateBucket = require("art.router.bucket-generator")
local spaceFunctions = require("art.router.constants").storageFunctions
local bucketModifier = require("art.router.bucket-id-modifier")

local space = {
    first = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), spaceFunctions.spaceFirst, functionRequest)
        if error then
            return error
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    select = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), spaceFunctions.spaceSelect, functionRequest)
        if error then
            return error
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    find = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), spaceFunctions.spaceFind, functionRequest)
        if error then
            return error
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    stream = function(space, processingOperators, terminatingOperator, baseKey)
    end,

    count = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), spaceFunctions.spaceCount, functionRequest)
        if error then
            return error
        end
        return result
    end,

    truncate = function(bucketRequest, functionRequest)
        local _, error = vshard.rouder.callrw(generateBucket(bucketRequest), spaceFunctions.spaceTruncate, functionRequest)
        if error then
            return error
        end
    end,

    multiple = require("art.router.space-multiple-transformer"),

    single = require("art.router.space-single-transformer"),
}

return space
