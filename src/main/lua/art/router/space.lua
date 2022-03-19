local generateBucket = require("art.router.bucket-generator")
local storageFunctions = require("art.router.constants").storageFunctions
local bucketModifier = require("art.router.bucket-id-modifier")
local throw = require("error-thrower")

local space = {
    first = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.spaceFirst, functionRequest)
        if error then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    select = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.spaceSelect, functionRequest)
        if error then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    find = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.spaceFind, functionRequest)
        if error then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    stream = function(bucketRequest, functionRequest)

    end,

    count = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.spaceCount, functionRequest)
        if error then
            throw(error)
        end
        return result
    end,

    truncate = function(bucketRequest, functionRequest)
        local _, error = vshard.rouder.callrw(generateBucket(bucketRequest), storageFunctions.spaceTruncate, functionRequest)
        if error then
            throw(error)
        end
    end,

    multiple = require("art.router.space-multiple-transformer"),

    single = require("art.router.space-single-transformer"),
}

return space
