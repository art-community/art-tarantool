local constants = require("art.storage.constants")

return function(first, second)
    if first == second then
        return true
    end

    if type(first) == constants.table and type(second) == constants.table then
        for key1, value1 in pairs(first) do
            local value2 = second[key1]

            if value2 == nil then
                return false
            end

            if value1 ~= value2 then
                if type(value1) == constants.table and type(value2) == constants.table then
                    if not deepEqual(value1, value2) then
                        return false
                    end
                end

                return false
            end
        end

        for key2, _ in pairs(second) do
            if first[key2] == nil then
                return false
            end
        end

        return true
    end

    return false
end
