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
        limit = 1,
        offset = 2,
        filter = 3,
        sort = 4,
        distinct = 5,
        map = 6
    },
    terminatingFunctions = {
        collect = 1,
        count = 2,
        all = 3,
        any = 4
    }
}
return {
    stream = stream
}
