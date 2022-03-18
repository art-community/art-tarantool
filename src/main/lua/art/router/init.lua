local function initialize()
    box.once("art:main", function()
        box.schema.func.create("art.router.immutable.call", { if_not_exists = true })
        box.schema.func.create("art.router.mutable.call", { if_not_exists = true })
    end)
end

art = {
    immutable = require("art.router.immutable"),

    mutable = require("art.router.mutable"),

    initialize = initialize
}

return art
