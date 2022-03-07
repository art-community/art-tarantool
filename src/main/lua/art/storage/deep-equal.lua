local function deepEqual(first, second)
    if first == second then
        return true
    end

    if type(first) == "table" and type(second) == "table" then
        for key1, value1 in pairs(first) do
            local value2 = second[key1]

            if value2 == nil then
                return false
            end

            if value1 ~= value2 then
                if type(value1) == "table" and type(value2) == "table" then
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

return deepEqual
