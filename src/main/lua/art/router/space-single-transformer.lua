local throw = require("art.router.error-thrower")
local generateBucket = require("art.router.bucket-generator")
local spaceSingle = require("art.router.constants").storageFunctions.spaceSingle
local bucketModifier = require("art.router.bucket-id-modifier")
local configuration = require("art.router.configuration").configuration

local transformer = {
    delete = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callrw(generateBucket(bucketRequest), spaceSingle.delete, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    insert = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertSingleBucketId(functionRequest[2], bucket)

        local result, error = vshard.router.callrw(bucket, spaceSingle.insert, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end

        return bucketModifier.removeSingleBucketId(result)
    end,

    put = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertSingleBucketId(functionRequest[2], bucket)

        local result, error = vshard.router.callrw(bucket, spaceSingle.put, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end

        return bucketModifier.removeSingleBucketId(result)
    end,

    update = function(bucketRequest, functionRequest)
        local result, error = vshard.router.callrw(generateBucket(bucketRequest), spaceSingle.update, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end
        return bucketModifier.removeSingleBucketId(result)
    end,

    upsert = function(bucketRequest, functionRequest)
        local bucket = generateBucket(bucketRequest)
        bucketModifier.insertSingleBucketId(functionRequest[2], bucket)

        local result, error = vshard.router.callrw(bucket, spaceSingle.upsert, functionRequest, { timeout = configuration.callTimeout })
        if error ~= nil then
            throw(error)
        end

        return bucketModifier.removeSingleBucketId(result)
    end
}

return transformer
