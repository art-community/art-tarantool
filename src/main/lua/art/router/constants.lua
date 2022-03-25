local algorithms = {
    crc32 = 0
}

local storageFunctions = {
    spaceFirst = "art.space.first",
    spaceSelect = "art.space.select",
    spaceFind = "art.space.find",
    spaceCount = "art.space.count",
    spaceTruncate = "art.space.truncate",
    spaceStream = "art.space.stream",
    spaceMultiple = {
        delete = "art.space.multiple.delete",
        insert = "art.space.multiple.insert",
        put = "art.space.multiple.put",
        update = "art.space.multiple.update",
    },
    spaceSingle = {
        delete = "art.space.single.delete",
        insert = "art.space.single.insert",
        put = "art.space.single.put",
        update = "art.space.single.update",
        upsert = "art.space.single.upsert"
    },
    indexFirst = "art.index.first",
    indexSelect = "art.index.select",
    indexFind = "art.index.find",
    indexStream = "art.index.stream",
    indexCount = "art.index.count",
    indexMultiple = {
        delete = "art.index.multiple.delete",
        update = "art.index.multiple.update",
    },
    indexSingle = {
        delete = "art.index.single.delete",
        update = "art.index.single.update",
    },
    schemaCreateIndex = "art.schema.createIndex",
    schemaCreateStorageSpace = "art.schema.createStorageSpace",
    schemaCreateShardSpace = "art.schema.createShardSpace",
    schemaSpaces = "art.schema.spaces",
    schemaDropIndex = "art.schema.dropIndex",
    schemaRenameSpace = "art.schema.renameSpace",
    schemaDropSpace = "art.schema.dropSpace",
    schemaIndices = "art.schema.indices",
    schemaFormat = "art.schema.format"
}

local stream = {
    terminatingFunctions = {
        terminatingCollect = 1,
        terminatingCount = 2,
        terminatingAll = 3,
        terminatingAny = 4,
        terminatingNone = 5
    },
    processingFunctions = {
        processingMap = 6
    },
    mappingModes = {
        mapBySpace = 1,
        mapByIndex = 2,
        mapByFunction = 3,
        mapByField = 4
    },
}

return {
    algorithms = algorithms,
    storageFunctions = storageFunctions,
    stream = stream,
}
