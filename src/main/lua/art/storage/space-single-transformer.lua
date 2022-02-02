local transformer = {
    delete = function(space, key)
        return box.space[space]:delete(key)
    end,

    insert = function(space, data)
        return box.space[space]:insert(data)
    end,

    put = function(space, data)
        return box.space[space]:put(data)
    end,

    replace = art.box.put,

    update = function(space, key, commands)
        return box.space[space].update(space, key, commands)
    end,

    upsert = function(space, data, commands)
        return box.space[space].upsert(data, commands)
    end,
}

return transformer
