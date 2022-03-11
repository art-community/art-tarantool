local constants = require("art.storage.constants").stream
local functional = require('fun')

return function(generator, parameter, state, request)
    local mappingFunction = function(mapping)
        local mode = request[1]

        if mode == constants.mappingModes.mapByFunction then
            local functionName = request[2]
            return box.func[functionName]:call(mapping)
        end

        if mode == constants.mappingModes.mapByField then
            local field = request[2]
            return mapping[field]
        end

        if mode == constants.mappingModes.mapBySpace then
            local otherSpace = request[2]
            local currentField = request[3]
            return box.space[otherSpace]:get(mapping[currentField])
        end

        if mode == constants.mappingModes.mapByIndex then
            local otherSpace = request[2]
            local currentFields = request[3]
            local otherIndex = request[4]
            local indexKeys = {}
            for _, keyField in pairs(currentFields) do
                table.insert(indexKeys, mapping[keyField])
            end
            if next(indexKeys) == nil then
                return nil
            end
            return box.space[otherSpace]:index(otherIndex):get(indexKeys)
        end
    end

    return functional.map(mappingFunction, generator, parameter, state)
end
