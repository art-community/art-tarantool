local index = {
    first = function(space, index, keys)
    end,

    select = function(space, index, keys, options)
    end,

    find = function(space, index, keys)
    end,

    stream = function(space, index, processingOperators, terminatingOperator, baseKey)
    end,

    count = function(space, index, key)
    end,

    multiple = require("art.storage.index-multiple-transformer"),

    single = require("art.storage.index-single-transformer"),
}

return index
