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
                        table.insert(results, box.space[space].index[index]:delete(element))
                    end
                end
            end
            return results
        end)
    end,
}

return transformer
