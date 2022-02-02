local transformer = {
    delete = function(space, index, keys)
        local results = {}
        for _, key in pairs(keys) do
            table.insert(results, box.space[space].index[index]:delete(key))
        end
        return results
    end,
}

return transformer
