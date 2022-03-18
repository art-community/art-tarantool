local hashAlgorithms = require("art.router.constants").hashAlgorithms

local call = function(bucket, request)
    local data = bucket[1]
    local algorithm = bucket[2]
    if algorithm == hashAlgorithms.crc32 then
        local bucketId = vshard.router.bucket_id_mpcrc32(data)
        return vshard.router.callrw(bucketId, request[1], request[2])
    end

    local bucketId = vshard.router.bucket_id_mpcrc32(data)
    return vshard.router.callro(bucketId, request[1], request[2])
end

return {
    call = call
}
