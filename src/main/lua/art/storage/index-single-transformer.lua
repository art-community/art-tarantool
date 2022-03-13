local transformer = {
    delete = function(space, index, key)
        return box.space[space].index[index]:delete(key)
    end,

    update = function(space, index, key, commands)
        return box.space[space].index[index]:update(space, key, commands)
    end,
}

return transformer
