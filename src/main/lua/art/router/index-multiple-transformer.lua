local throw = require("art.router.error-thrower")
local generateBucket = require("art.router.bucket-generator")
local indexMultiple = require("art.router.constants").storageFunctions.indexMultiple
local bucketModifier = require("art.router.bucket-id-modifier")
local configuration = require("art.router.configuration").configuration

local transformer = {
    delete = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callrw(generateBucket(bucketRequest), indexMultiple.delete, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    update = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callrw(generateBucket(bucketRequest), indexMultiple.update, functionRequest, { timeout = configuration.timeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,
}

return transformer
