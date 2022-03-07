local stream = {
    filters = {
        filterEquals = 1,
        filterNotEquals = 2,
        filterMore = 3,
        filterLess = 4,
        filterBetween = 5,
        filterNotBetween = 6,
        filterIn = 7,
        filterNotIn = 8,
        filterStartsWith = 9,
        filterEndsWith = 10,
        filterContains = 11,
    },
    conditions = {
        conditionAnd = 1,
        conditionOr = 2
    },
    filterModes = {
        filterBySpace = 1,
        filterByIndex = 2,
        filterByValue = 3,
        filterByFunction = 4
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
        map = 6,
        flatMap = 7
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
