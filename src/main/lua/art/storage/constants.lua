local stream = {
    filters = {
        filterEquals = 1,
        filterNotEquals = 2,
        filterMore = 3,
        filterMoreEquals = 4,
        filterLess = 5,
        filterLessEquals = 6,
        filterBetween = 7,
        filterNotBetween = 8,
        filterIn = 9,
        filterNotIn = 10,
        filterStartsWith = 11,
        filterEndsWith = 12,
        filterContains = 13,
    },
    conditions = {
        conditionAnd = 1,
        conditionOr = 2
    },
    filterModes = {
        filterBySpace = 1,
        filterByIndex = 2,
        filterByField = 3,
        filterByFunction = 4,
        nestedFilter = 5
    },
    filterExpressions = {
        filterExpressionField = 1,
        filterExpressionValue = 2,
    },
    mappingModes = {
        mapBySpace = 1,
        mapByIndex = 2,
        mapByFunction = 3,
        mapByField = 4
    },
    comparators = {
        comparatorMore = 1,
        comparatorLess = 2,
    },
    processingFunctions = {
        processingLimit = 1,
        processingOffset = 2,
        processingFilter = 3,
        processingSort = 4,
        processingDistinct = 5,
        processingMap = 6
    },
    terminatingFunctions = {
        terminatingCollect = 1,
        terminatingCount = 2,
        terminatingAll = 3,
        terminatingAny = 4
    }
}
return {
    stream = stream
}
