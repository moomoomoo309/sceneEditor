local object = require "object"
local color = require "color"
local pretty = require "pl.pretty"

local colorpicker = { type = "colorpicker" }
local colorpickers = setmetatable({}, { __mode = "v" })

function colorpicker.new(_, args)
    local obj = object {
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or 0,
        h = args.h or 0,
        color = { 0, 0, 0 }
    }
    pretty.dump(args)
    pretty.dump(obj.realTbl)
    print(obj.x, obj.y, obj.w, obj.h)
    obj.class = colorpicker
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(args.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(args.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(args.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(args.h)))
    colorpickers[#colorpickers + 1] = obj
    return obj
end

local function drawSquare(x, y, w, h, hue)
    local oldColor = { love.graphics.getColor() }
    for _x = x, x + w * .85 do
        for _y = y, y + h do
            love.graphics.setColor(color.hsv(hue, (_x - x) / w * 256, (_y - y) / h * 256))
            love.graphics.points(_x + .5, _y + .5)
        end
    end
    love.graphics.setColor(oldColor)
end

local function drawHueBar(x, y, w, h)
    local oldColor = { love.graphics.getColor() }
    for _x = x + w * .9, x + w * .99 do
        for _y = y, y + h do
            love.graphics.setColor(color.hsv((_y - y) / h * 255, 255, 255))
            love.graphics.points(_x + .5, _y + .5)
        end
    end
    love.graphics.setColor(oldColor)
end

local function drawSquareCursor(x, y, w, h, _color)
    local _, s, b = color.hsv(unpack(_color))
    love.graphics.circle("line", x + s / 255 * w * .85, y + b / 255 * h, 10, 10)
end

local function drawHueCursor(x, y, w, h, hue)
    love.graphics.rectangle("line", x + w * .89, y + hue / 360 * h, w * .11, h * .05)
end

function colorpicker:draw()
    local hue = color.rgb(unpack(self.color))
    drawSquare(self.x, self.y, self.w, self.h, hue)
    drawHueBar(self.x, self.y, self.w, self.h)
    drawSquareCursor(self.x, self.y, self.w, self.h, self.color)
    drawHueCursor(self.x, self.y, self.w, self.h, hue)
end

function colorpicker._onPress(x, y)
    for _, picker in pairs(colorpickers) do
        if picker and picker.onPress then
            picker:onPress(x, y)
        end
    end
end

function colorpicker:onPress(x, y)
    local h, s, v = color.hsv(unpack(self.color))
    print(h)
    if y >= self.y and y <= self.y + self.h then
        if x >= self.x and x <= self.x + self.w * .85 then
            s, v = (x - self.x) / (self.w * .85) * 255, (y - self.y) / self.h * 255
            self.color = { color.rgb(h, s, v) }
            print((color.hsv(h, s, v)))
            print "sq"
        elseif x >= self.x + self.w * .9 and x <= self.x + self.w then
            h = (y - self.y) / self.h * 360
            print(h)
            self.color = { color.rgb(h, s, v) }
            print "hue"
        end
    end
end



return setmetatable(colorpicker, { __call = colorpicker.new })
