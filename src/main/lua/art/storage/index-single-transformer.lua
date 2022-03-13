local transformer = {
    delete = function(space, index, key)
        local foundIndex = box.space[space].index[index]
        if foundIndex.unique and #key == 1 then
            return box.space[space].index[index]:delete(key)
        else
            for _, element in foundIndex:pairs(key) do
                return box.space[space].index[index]:delete(element)
            end
        end
    end,

    update = function(space, index, key, commands)
        local foundIndex = box.space[space].index[index]
        if foundIndex.unique and #key == 1 then
            return box.space[space].index[index]:update(key, commands)
        else
            for _, element in foundIndex:pairs(key) do
                return box.space[space].index[index]:update(element, commands)
            end
        end
    end,
}

return transformer
