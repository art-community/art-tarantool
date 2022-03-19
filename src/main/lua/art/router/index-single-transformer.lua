local throw = require("art.router.error-thrower")
local generateBucket = require("art.router.bucket-generator")
local indexSingle = require("art.router.constants").storageFunctions.indexSingle
local bucketModifier = require("art.router.bucket-id-modifier")

local transformer = {
    delete = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callrw(generateBucket(bucketRequest), indexSingle.delete, functionRequest)
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    update = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callrw(generateBucket(bucketRequest), spaceSingle.update, functionRequest)
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,
}

return transformer
