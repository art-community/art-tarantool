local throw = require("art.router.error-thrower")
local generateBucket = require("art.router.bucket-generator")
local spaceMultiple = require("art.router.constants").storageFunctions.spaceMultiple
local bucketModifier = require("art.router.bucket-id-modifier")
local configuration = require("art.router.configuration").configuration

local transformer = {
    delete = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callrw(generateBucket(bucketRequest), spaceMultiple.delete, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,

    insert = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertMultipleBucketIds(functionRequest[2], bucket)

        local result, error = vshard.router.callrw(bucket, spaceMultiple.insert, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end

        return bucketModifier.removeMultipleBucketIds(result)
    end,

    put = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertMultipleBucketIds(functionRequest[2], bucket)

        local result, error = vshard.router.callrw(bucket, spaceMultiple.put, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end

        return bucketModifier.removeMultipleBucketIds(result)
    end,

    update = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callrw(generateBucket(bucketRequest), spaceMultiple.update, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeMultipleBucketIds(result)
    end,
}

return transformer
