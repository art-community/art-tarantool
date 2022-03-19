local stream = require("art.router.constants").stream
local generateBucket = require("art.router.bucket-generator")
local storageFunctions = require("art.router.constants").storageFunctions
local bucketModifier = require("art.router.bucket-id-modifier")
local throw = require("error-thrower")

local removeBucket = function(operators)
    local processingOperators = operators[1]
    local terminatingOperator = operators[2]

    local removeBucket = terminatingOperator[1] == stream.terminatingFunctions.terminatingCollect

    for _, operator in ipairs(processingOperators) do
        if operator[1] == stream.processingFunctions.processingMap then
            local request = operator[2]
            if request[1] ~= stream.mappingModes.mapBySpace or request[1] ~= stream.mappingModes.mapByIndex then
                return false
            end
        end
    end

    return removeBucket
end

local spaceStream = function(bucketRequest, functionRequest)
    local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.spaceStream, functionRequest)
    if error ~= nil then
        throw(error)
    end

    if removeBucket(functionRequest[2]) then
        return bucketModifier.removeMultipleBucketIds(result)
    end

    return result
end

local indexStream = function(bucketRequest, functionRequest)
    local result, error = vshard.rouder.callro(generateBucket(bucketRequest), storageFunctions.indexStream, functionRequest)
    if error ~= nil then
        throw(error)
    end

    if removeBucket(functionRequest[3]) then
        return bucketModifier.removeMultipleBucketIds(result)
    end

    return result
end

return {
    spaceStream = spaceStream,

    indexStream = indexStream
}
