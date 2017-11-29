local object = require "object"
require "gooi"

local properties = { properties = setmetatable({}, { __mode = "v" }) }

function properties.id()
    local id = 0
    while properties.properties[id] do
        id = id + 1
    end
    return id
end

--- Works like string.find, but from the back to the front. If you're using a lua pattern, make the lua pattern work for the reversed string.
local function findLast(str, char, index, plain)
    local lastIndex, lastIndexEnd = str:reverse():find((plain and char:reverse() or char), index, plain)
    return lastIndex and #str - lastIndexEnd + 1, #str - lastIndex + 1
end


function properties.getDisplayName(imagePath)
    local slashIndex, dotIndex = findLast(imagePath, "/", nil, true), findLast(imagePath, ".", nil, true)
    return imagePath:sub(slashIndex and slashIndex + 1 or 0, dotIndex and dotIndex - 1 or -1)
end

function properties.onPressed()
    for _, prop in pairs(properties.properties) do
        for _, btn in pairs(prop.btns) do
            properties.buttonOnPressed(btn)
        end
    end
end

function properties.buttonOnPressed(btn)
    local spr = btn.sprite
    if spr.overlays and #spr.overlays > 0 then
        btn.children = #btn.children > 0 and {} or spr.overlays
    end
end

function properties.new(_, args)
    local obj = object {
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or 0,
        h = args.h or 0,
        sprites = args.sprites or {},
        btns = {},
        labels = {},
        inputs = {},
        panel = nil
    }
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(obj.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(obj.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(obj.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(obj.h)))
    assert(type(obj.sprites) == "table", ("Table expected, got %s."):format(type(obj.sprites)))
    obj.class = properties
    obj.panel = gooi.newPanel {
        x = obj.x,
        y = obj.y,
        w = obj.w,
        h = obj.h,
        id = properties.id(),
        layout = "grid " .. #obj.sprites .. "x3"
    }
    obj.panel.group = "propertiespanel" .. obj.id
    obj.btns = {}
    obj.spacers = {}
    for i = 1, #obj.sprites do
        local v = obj.sprites[i]
        assert(v.type and v.type == "sprite", ("Sprite expected, got %s."):format(type(v) == "table" and v.type or type(v)))
        obj.btns[i] = gooi.newbutton {
            text = properties.getDisplayName(v.imagePath)
        }
        obj.btns[i].sprite = v
        obj.btns[i].children = {}
    end
    return obj
end

return setmetatable(properties, { __index = object, __call = properties.new })


