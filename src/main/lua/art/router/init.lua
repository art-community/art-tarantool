local configure = require("art.router.configuration").configure

local function initialize(configuration)
    if configuration ~= nil then
        configure(configuration)
    end

    box.once("art:main", function()
        for name in pairs(art.space) do
            if name ~= "multiple" and name ~= "single" then
                box.schema.func.create("art.space." .. name, { if_not_exists = true })
            end
        end
        for name in pairs(art.space.single) do
            box.schema.func.create("art.space.single." .. name, { if_not_exists = true })
        end
        for name in pairs(art.space.multiple) do
            box.schema.func.create("art.space.multiple." .. name, { if_not_exists = true })
        end

        for name in pairs(art.index) do
            if name ~= "multiple" and name ~= "single" then
                box.schema.func.create("art.index." .. name, { if_not_exists = true })
            end
        end
        for name in pairs(art.index.single) do
            box.schema.func.create("art.index.single." .. name, { if_not_exists = true })
        end
        for name in pairs(art.index.multiple) do
            box.schema.func.create("art.index.multiple." .. name, { if_not_exists = true })
        end

        for name in pairs(art.schema) do
            box.schema.func.create("art.schema." .. name, { if_not_exists = true })
        end
    end)
end

art = {
    space = require("art.router.space"),

    index = require("art.router.index"),

    schema = require("art.router.schema"),

    stream = require("art.router.stream"),

    subscription = require("art.router.subscription"),

    initialize = initialize
}

return art
