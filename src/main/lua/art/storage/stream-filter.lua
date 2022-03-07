local functional = require('fun')

function(generator, parameter, state, request)
    local filteringFunction = function(filtering)
        local result = true

        local applyCondition = function(condition, newResult)
            if condition == constants.conditions.conditionAnd then
                result = result & newResult
                return
            end

            if condition == constants.conditions.conditionOr then
                result = result | newResult
                return
            end
        end

        for _, filter in pairs(request) do
            local condition = filter[1]
            local mode = filter[2]

            if mode == constants.filterModes.filterByValue then
                local parameters = filter[3]
                local field = parameters[1]
                local name = parameters[2]
                local values = parameters[3]
                applyCondition(condition, applyFilter(name, filtering, field, values));
            end

            if mode == constants.filterModes.filterByFunction then
                local functionName = filter[3]
                applyCondition(condition, box.func[functionName]:call(filtering));
            end

            if mode == constants.filterModes.filterBySpace then
                local mappingParameters = filter[3]
                local otherSpace = mappingParameters[1]
                local currentField = mappingParameters[2]
                local mapped = box.space[otherSpace]:get(filtering[currentField])
                if mapped ~= nil then
                    local expressions = filter[3]
                    for _, expression in pairs(expressions) do
                        local expressionCondition = expression[1]
                        local expressionCurrentField = expression[2]
                        local expressionName = expression[3]
                        local expressionOtherFields = expression[4]
                        local expressionOtherValues = {}
                        for _, expressionField in pairs(expressionOtherFields) do
                            table.insert(expressionOtherValues, mapped[expressionField])
                        end
                        local newResult = applyFilter(expressionName, filtering, expressionCurrentField, expressionOtherValues)
                        applyCondition(expressionCondition, newResult);
                    end
                else
                    applyCondition(condition, false)
                end
            end

            if mode == constants.filterModes.filterByIndex then
                local mappingParameters = filter[3]
                local otherSpace = mappingParameters[1]
                local currentFields = mappingParameters[2]
                local otherIndex = mappingParameters[3]
                local indexKeys = {}
                for _, keyField in pairs(currentFields) do
                    table.insert(indexKeys, filtering[keyField])
                end
                if next(indexKeys) ~= nil then
                    local mapped = box.space[otherSpace]:index(otherIndex):get(indexKeys)
                    if mapped ~= nil then
                        local expressions = filter[3]
                        for _, expression in pairs(expressions) do
                            local expressionCondition = expression[1]
                            local expressionCurrentField = expression[2]
                            local expressionName = expression[3]
                            local expressionOtherFields = expression[4]
                            local expressionOtherValues = {}
                            for _, expressionField in pairs(expressionOtherFields) do
                                table.insert(expressionOtherValues, mapped[expressionField])
                            end
                            local newResult = applyFilter(expressionName, filtering, expressionCurrentField, expressionOtherValues)
                            applyCondition(expressionCondition, newResult);
                        end
                    else
                        applyCondition(condition, false)
                    end
                else
                    applyCondition(condition, false)
                end
            end
        end
    end

    return functional.filter(filteringFunction, generator, parameter, state)
end
