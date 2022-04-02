local throw = require("art.router.error-thrower")
local generateBucket = require("art.router.bucket-generator")
local storageFunctions = require("art.router.constants").storageFunctions
local bucketModifier = require("art.router.bucket-id-modifier")
local indexStream = require("art.router.stream").indexStream
local configuration = require("art.router.configuration").configuration

local index = {
    first = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callro(generateBucket(bucketRequest), storageFunctions.indexFirst, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    select = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callro(generateBucket(bucketRequest), storageFunctions.indexSelect, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    find = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callro(generateBucket(bucketRequest), storageFunctions.indexFind, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    stream = indexStream,

    count = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callro(generateBucket(bucketRequest), storageFunctions.indexCount, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return result
    end,

    multiple = require("art.router.index-multiple-transformer"),

    single = require("art.router.index-single-transformer"),
}

return index
