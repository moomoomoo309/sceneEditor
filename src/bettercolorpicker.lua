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
        color = { 128, 64, 128 },
        hue = 0,
        saturation = 0,
        value = 0,
        square = love.image.newImageData(args.w * .85 + 1 or 0, args.h + 1 or 0),
        hueBar = love.image.newImageData(args.w * .1 + 1 or 0, args.h + 1 or 0),
        hasFocus = false,
        focusIsSquare = true
    }
    obj:addCallback("hue", function(self, hue) self.color = color.rgb2hsv(hue, self.saturation, self.value) return true end)
    obj:addCallback("saturation", function(self, saturation) self.color = color.rgb2hsv(self.hue, saturation, self.value) return true end)
    obj:addCallback("value", function(self, value) self.color = color.rgb2hsv(self.hue, self.saturation, value) return true end)
    obj:addCallback("color",
        function(self, _color)
            pretty.dump(_color)
            if _color[1] == _color[2] and _color[2] == _color[3] then
                _, self.saturation, self.value = color.rgb2hsv(unpack(_color))
            else
                self.hue, self.saturation, self.value = color.rgb2hsv(unpack(_color))
            end
            return true
        end)
    obj.class = colorpicker
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(args.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(args.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(args.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(args.h)))
    colorpickers[#colorpickers + 1] = obj
    return obj
end

local function drawSquare(x, y, w, h, hue, square)
    for _x = x, x + w * .85 - 1 do
        for _y = y, y + h - 1 do
            local r, g, b = color.hsv2rgb(hue * 255 / 360, (_x - x) / w * 255, (_y - y) / h * 255)
            square:setPixel(_x - x, _y - y, r, g, b, 255)
        end
    end
    local squareImg = love.graphics.newImage(square)
    love.graphics.draw(squareImg, x, y, 0, 1, 1)
end

local function drawHueBar(x, y, w, h, hueBar)
    for _x = x + w * .9, x + w * .99 - 1 do
        for _y = y, y + h - 1 do
            local r, g, b = color.hsv2rgb((_y - y) / h * 255, 255, 255)
            hueBar:setPixel(_x - x - w * .9, _y - y, r, g, b, 255)
        end
    end
    local hueImg = love.graphics.newImage(hueBar)
    love.graphics.draw(hueImg, x + w * .9, y, 0, 1, 1)
end

local function drawSquareCursor(x, y, w, h, s, v)
    love.graphics.circle("line", x + s / 255 * w * .85, y + v / 255 * h, 10, 10)
end

local function drawHueCursor(x, y, w, h, hue)
    love.graphics.rectangle("line", x + w * .89, y + hue / 360 * h - h * .025, w * .11, h * .05, 5, 5)
end

function colorpicker:draw()
    drawSquare(self.x, self.y, self.w, self.h, self.hue, self.square)
    drawHueBar(self.x, self.y, self.w, self.h, self.hueBar)
    drawSquareCursor(self.x, self.y, self.w, self.h, self.saturation, self.value)
    drawHueCursor(self.x, self.y, self.w, self.h, self.hue)
end

function colorpicker.onPress(x, y)
    for _, picker in pairs(colorpickers) do
        if picker and picker.onMouse then
            picker.hasFocus, picker.focusIsSquare = picker:isInside(x, y)
            picker:onMouse(x, y)
        end
    end
end

function colorpicker.onMove(x, y)
    for _, picker in pairs(colorpickers) do
        if picker and picker.onMouse then
            if picker.hasFocus then
                picker:onMouse(x, y)
            end
        end
    end
end

function colorpicker.onRelease()
    for _, picker in pairs(colorpickers) do
        if picker and picker.onMouse then
            if picker.hasFocus then
                picker.hasFocus = false
            end
        end
    end
end

function colorpicker:isInside(x, y)
    if y >= self.y and y <= self.y + self.h then
        if x >= self.x and x <= self.x + self.w * .85 then
            return true, true
        elseif x >= self.x + self.w * .9 and x <= self.x + self.w then
            return true, false
        end
    end
    return false
end

function colorpicker:onMouse(x, y)
    local h, s, v = self.hue, self.saturation, self.value
    local isInside, isSquare = self:isInside(x, y)
    if self.hasFocus then
        if isSquare and self.focusIsSquare then
            self.saturation, self.value = (x - self.x) / (self.w * .85) * 255, (y - self.y) / self.h * 255
        elseif not isSquare and not self.focusIsSquare then
            self.hue = math.max(math.min(self.h, (y - self.y)) / self.h * 360 - .1, 0)
        end
    elseif isInside then
        self.hasFocus = true
        self.focusIsSquare = isSquare
        if isSquare then
            s, v = (x - self.x) / (self.w * .85) * 255, (y - self.y) / self.h * 255
            self.color = { color.hsv2rgb(h, s, v) }
        else
            h = math.max((y - self.y) / self.h * 360 - .1, 0)
            self.color = { color.hsv2rgb(h, s, v) }
        end
    end
end



return setmetatable(colorpicker, { __call = colorpicker.new, __index = object })
