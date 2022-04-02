local generateBucket = require("art.router.bucket-generator")
local storageFunctions = require("art.router.constants").storageFunctions
local bucketModifier = require("art.router.bucket-id-modifier")
local throw = require("art.router.error-thrower")
local spaceStream = require("art.router.stream").spaceStream
local configuration = require("art.router.configuration").configuration

local space = {
    first = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callro(generateBucket(bucketRequest), storageFunctions.spaceFirst, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    select = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callro(generateBucket(bucketRequest), storageFunctions.spaceSelect, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    find = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callro(generateBucket(bucketRequest), storageFunctions.spaceFind, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    stream = spaceStream,

    count = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callro(generateBucket(bucketRequest), storageFunctions.spaceCount, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return result
    end,

    truncate = function(bucketRequest, functionRequest)
        local _, error = vshard.router.callrw(generateBucket(bucketRequest), storageFunctions.spaceTruncate, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
    end,

    multiple = require("art.router.space-multiple-transformer"),

    single = require("art.router.space-single-transformer"),
}

return space
