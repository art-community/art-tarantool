local function initialize()
    box.once("art:main", function()
        for name in pairs(art.box) do
            box.schema.func("art.box." .. name, { if_not_exists = true })
        end

        for name in pairs(art.stream) do
            box.schema.func("art.stream." .. name, { if_not_exists = true })
        end
    end)
end

return {
    box = require("art.storage.box"),

    stream = require("art.storage.stream"),

    initialize = initialize
}
