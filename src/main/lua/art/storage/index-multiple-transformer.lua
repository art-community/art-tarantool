local transformer = {
    delete = function(space, index, keys)
        return box.atomic(function()
            local results = {}
            for _, key in pairs(keys) do
                table.insert(results, box.space[space].index[index]:delete(key))
            end
            return results
        end)
    end,
}

return transformer
