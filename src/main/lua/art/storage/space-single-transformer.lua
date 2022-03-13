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

    replace = put,

    update = function(space, key, commands)
        return box.space[space]:update(space, key, commands)
    end
}

return transformer
