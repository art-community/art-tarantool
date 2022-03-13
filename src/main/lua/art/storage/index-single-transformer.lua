local transformer = {
    update = function(space, index, key, commands)
        return box.space[space].index[index].update(space, key, commands)
    end,
}

return transformer
