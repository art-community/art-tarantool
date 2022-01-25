art = {
    box = require("art.storage.box"),

    stream = require("art.storage.stream")
}

for name in pairs(art.box) do
    box.schema.func("art.box." .. name, { if_not_exists = true })
end

for name in pairs(art.stream) do
    box.schema.func("art.stream." .. name, { if_not_exists = true })
end
