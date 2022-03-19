local throw = require("error-thrower")
local generateBucket = require("art.router.bucket-generator")
local storageFunctions = require("art.router.constants").storageFunctions
local bucketModifier = require("art.router.bucket-id-modifier")

local index = {
    first = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexFirst, functionRequest)
        if error then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    select = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexSelect, functionRequest)
        if error then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    find = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexFind, functionRequest)
        if error then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    stream = function(bucketRequest, functionRequest)
        local operators = functionRequest[3]
        local terminatingOperator = operators[2]

        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.spaceStream, functionRequest)
        if error then
            throw(error)
        end

        if terminatingOperator[1] == stream.terminatingFunctions.terminatingCollect then
            return bucketModifier.removeMultipleBucketIds(result)
        end

        return result
    end,

    count = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexCount, functionRequest)
        if error then
            throw(error)
        end
        return result
    end,

    multiple = require("art.router.index-multiple-transformer"),

    single = require("art.router.index-single-transformer"),
}

return index
