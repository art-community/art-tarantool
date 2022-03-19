local algorithms = {
    crc32 = 0
}

local storageFunctions = {
    spaceFirst = "art.storage.space.first",
    spaceSelect = "art.storage.space.select",
    spaceFind = "art.storage.space.find",
    spaceCount = "art.storage.space.count",
    spaceTruncate = "art.storage.space.truncate",
    spaceStream = "art.storage.space.stream",
    spaceMultiple = {
        delete = "art.storage.space.multiple.delete",
        insert = "art.storage.space.multiple.insert",
        put = "art.storage.space.multiple.put",
        update = "art.storage.space.multiple.update",
    },
    spaceSingle = {
        delete = "art.storage.space.single.delete",
        insert = "art.storage.space.single.insert",
        put = "art.storage.space.single.put",
        update = "art.storage.space.single.update",
        upsert = "art.storage.space.single.upsert"
    },
    indexFirst = "art.storage.index.first",
    indexSelect = "art.storage.index.select",
    indexFind = "art.storage.index.find",
    indexCount = "art.storage.index.count",
    indexMultiple = {
        delete = "art.storage.index.multiple.delete",
        update = "art.storage.index.multiple.update",
    },
    indexSingle = {
        delete = "art.storage.index.single.delete",
        update = "art.storage.index.single.update",
    }
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
