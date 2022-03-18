local algorithms = {
    crc32 = 0
}

local storageFunctions = {
    spaceFirst = "art.storage.space.first",
    spaceSelect = "art.storage.space.select",
    spaceFind = "art.storage.space.find",
    spaceCount = "art.storage.space.count",
    spaceTruncate = "art.storage.space.truncate",
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
    }
}

return {
    algorithms = algorithms,
    storageFunctions = storageFunctions,
}
