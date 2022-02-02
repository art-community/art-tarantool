local function initialize()
    box.once("art:main", function()
        for name in pairs(art.space) do
            if name ~= "multiple" and name ~= "single" then
                box.schema.func("art.space." .. name, { if_not_exists = true })
            end
        end
        for name in pairs(art.space.single) do
            box.schema.func("art.space.single" .. name, { if_not_exists = true })
        end
        for name in pairs(art.space.multiple) do
            box.schema.func("art.space.multiple" .. name, { if_not_exists = true })
        end

        for name in pairs(art.index) do
            if name ~= "multiple" and name ~= "single" then
                box.schema.func("art.index." .. name, { if_not_exists = true })
            end
        end
        for name in pairs(art.index.single) do
            box.schema.func("art.index.single" .. name, { if_not_exists = true })
        end
        for name in pairs(art.index.multiple) do
            box.schema.func("art.index.multiple" .. name, { if_not_exists = true })
        end

        for name in pairs(art.schema) do
            box.schema.func("art.schema." .. name, { if_not_exists = true })
        end
    end)
end

art = {
    space = require("art.storage.space"),

    index = require("art.storage.index"),

    schema = require("art.storage.schema"),

    stream = require("art.storage.stream"),

    initialize = initialize
}

return art
