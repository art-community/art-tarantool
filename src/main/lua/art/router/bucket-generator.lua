local algorithms = require("art.router.constants").algorithms
return function(request)
    local algorithm = request[1]
    local data = request[2]
    if algorithm == algorithms.crc32 then
        return vshard.router.bucket_id_mpcrc32(data)
    end
    return vshard.router.bucket_id_mpcrc32(data)
end
