local encode = require("json").encode

return function(payload)
    error(encode(payload))
end
