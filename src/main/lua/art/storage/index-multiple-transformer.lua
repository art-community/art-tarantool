local transformer = {
    delete = function(space, index, keys)
        return box.atomic(function()
            local results = {}
            local foundIndex = box.space[space].index[index]
            for _, key in pairs(keys) do
                if foundIndex.unique and #key == 1 then
                    table.insert(results, box.space[space].index[index]:delete(key))
                else
                    for _, element in foundIndex:pairs(key) do
                        table.insert(results, box.space[space]:delete(element[1]))
                    end
                end
            end
            return results
        end)
    end,

    update = function(space, index, keys, commands)
        return box.atomic(function()
            local results = {}
            local foundIndex = box.space[space].index[index]
            for _, key in pairs(keys) do
                if foundIndex.unique and #key == 1 then
                    table.insert(results, box.space[space].index[index]:update(key, commands))
                else
                    for _, element in foundIndex:pairs(key) do
                        table.insert(results, box.space[space]:update(element[1], commands))
                    end
                end
            end
            return results
        end)
    end,
}

return transformer
