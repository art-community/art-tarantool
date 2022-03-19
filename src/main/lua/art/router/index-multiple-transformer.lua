local throw = require("art.router.error-thrower")
local generateBucket = require("art.router.bucket-generator")
local indexMultiple = require("art.router.constants").storageFunctions.indexMultiple
local bucketModifier = require("art.router.bucket-id-modifier")

local transformer = {
    delete = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callrw(generateBucket(bucketRequest), indexMultiple.delete, functionRequest)
        if error then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    update = function(bucketRequest, functionRequest)
        local result, error = vshard.rouder.callrw(generateBucket(bucketRequest), indexMultiple.update, functionRequest)
        if error then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,
}

return transformer
