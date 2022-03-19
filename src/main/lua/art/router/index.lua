local throw = require("error-thrower")
local generateBucket = require("art.router.bucket-generator")
local storageFunctions = require("art.router.constants").storageFunctions
local bucketModifier = require("art.router.bucket-id-modifier")
local indexStream = require("art.router.stream").indexStream

local index = {
    first = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexFirst, functionRequest)
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    select = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexSelect, functionRequest)
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    find = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexFind, functionRequest)
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    stream = indexStream,

    count = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexCount, functionRequest)
        if error ~= nil then
            throw(error)
        end
        return result
    end,

    multiple = require("art.router.index-multiple-transformer"),

    single = require("art.router.index-single-transformer"),
}

return index
