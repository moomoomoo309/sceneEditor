local object = require "object"
local color = require "color"
local utf8 = require "utf8"
if not gooi then
    require "gooi"
end

local colorpicker = { type = "colorpicker" }
local colorpickers = setmetatable({}, { __mode = "v" })
colorpicker.colorpickers = colorpickers
--Preferably, the following should add up to 1, so the width is correct.
local squareWidth = .5
local squarePadding = .025
local hueBarWidth = .05
local sliderPadding = .015
local sliderWidth = .27
local labelPadding = .05
local labelWidth = .09
do
    local totalWidth = squareWidth + squarePadding + hueBarWidth + sliderPadding + sliderWidth + labelPadding + labelWidth
    assert(1 - totalWidth < 1e-7, ("Width of the colorpicker is incorrect! Should be 1, is %.3f."):format(totalWidth))
end

--- Local function used by left and right pad. Returns the pad string needed.
local function _getPad(str, len, padChar)
    padChar = padChar or "0"
    str = tostring(str) or ""
    local strLen = #str
    local numChars = 0
    if len > strLen then
        numChars = len - strLen
    end
    return padChar:rep(math.floor(numChars / #padChar)) .. padChar:sub(0, numChars % #padChar)
end

--- Pads a string to the given length by prepending padChar to the beginning.
local function leftPad(str, len, padChar)
    return _getPad(str, len, padChar) .. str
end

--- Pads a string to the given length by appending padChar to the end.
local function rightPad(str, len, padChar)
    return str .. _getPad(str, len, padChar)
end

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
        square = love.image.newImageData(args.w * squareWidth + 1 or 0, args.h + 1 or 0),
        hueBar = love.image.newImageData(args.w * .1 + 1 or 0, args.h + 1 or 0),
        hasFocus = false,
        focusIsSquare = true,
        id = colorpicker.id(),
        hueBarImg = nil,
        squareImg = nil,
        hueSlider = nil,
        focusIsSquare = true,
        visible = args.visible == nil and true or args.visible,
        saturationSlider = nil,
        valueSlider = nil,
        rSlider = nil,
        gSlider = nil,
        bSlider = nil,
        hueLabel = nil,
        saturationLabel = nil,
        valueLabel = nil,
        rLabel = nil,
        gLabel = nil,
        bLabel = nil
    }
    obj:addCallback("hue", function(self, hue)
        self:triggerCallback("color", { color.hsv2rgb(hue, self.saturation, self.value) })
        self.hueSlider:setValue(hue / 360) --- Local function used by left and right pad. Returns the pad string needed.
        self.hueLabel:setText("H: " .. leftPad(math.floor(hue), 3))
        self.squareImg = nil
    end)
    obj:addCallback("saturation", function(self, saturation)
        self:triggerCallback("color", { color.hsv2rgb(self.hue, saturation, self.value) })
        self.saturationSlider:setValue(saturation / 255)
        self.saturationLabel:setText("S: " .. leftPad(math.floor(saturation), 3))
    end)
    obj:addCallback("value", function(self, value)
        self:triggerCallback("color", { color.hsv2rgb(self.hue, self.saturation, value) })
        self.valueSlider:setValue(value / 255)
        self.valueLabel:setText("V: " .. leftPad(math.floor(value), 3))
    end)
    obj:addCallback("color", function(self, _color)
        if _color[1] == _color[2] and _color[2] == _color[3] then
            --Don't update hue for grayscale colors, they don't have a hue.
            _, self.saturation, self.value = color.rgb2hsv(unpack(_color))
        else
            self.hue, self.saturation, self.value = color.rgb2hsv(unpack(_color))
        end
        self.rSlider:setValue(_color[1] / 255)
        self.gSlider:setValue(_color[2] / 255)
        self.bSlider:setValue(_color[3] / 255)
        self.rLabel:setText("R: " .. leftPad(math.floor(_color[1]), 3))
        self.gLabel:setText("G: " .. leftPad(math.floor(_color[2]), 3))
        self.bLabel:setText("B: " .. leftPad(math.floor(_color[3]), 3))
    end)
    obj:addCallback("w", function(self, w)
        self.hueBarImg = nil
        self.square = love.image.newImageData(w * squareWidth + 1, args.h + 1)
        love.self.hueBar = love.image.newImageData(w * .1 + 1, self.h)
    end)
    obj:addCallback("h", function(self, h)
        self.hueBarImg = nil
        self.square = love.image.newImageData(args.w * squareWidth + 1, h + 1)
        self.hueBar = love.image.newImageData(self.w, h * .1 + 1)
    end)
    obj:addCallback("id", function(self, id)
        error(("Tried to change id of colorpicker with id of %d to %d. Changing of ids is not allowed."):format(self.id, id))
    end)
    obj:addCallback("visible", function(self, visible)
        self.hueSlider.visible = visible
        self.saturationSlider.visible = visible
        self.valueSlider.visible = visible
        self.rSlider.visible = visible
        self.gSlider.visible = visible
        self.bSlider.visible = visible
        self.hueLabel.visible = visible
        self.saturationLabel.visible = visible
        self.valueLabel.visible = visible
        self.rLabel.visible = visible
        self.gLabel.visible = visible
        self.bLabel.visible = visible
    end)
    obj.class = colorpicker
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(args.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(args.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(args.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(args.h)))
    colorpickers[obj.id] = obj
    obj.hueLabel = gooi.newLabel {
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderWidth + labelPadding),
        y = obj.y,
        group = "colorpicker" .. obj.id
    }
    obj.hueLabel.w = obj.w * labelWidth
    obj.saturationLabel = gooi.newLabel {
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderWidth + labelPadding),
        y = obj.y + obj.h * .175,
        group = "colorpicker" .. obj.id
    }
    obj.saturationLabel.w = obj.w * labelWidth
    obj.valueLabel = gooi.newLabel {
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderWidth + labelPadding),
        y = obj.y + obj.h * .35,
        group = "colorpicker" .. obj.id
    }
    obj.valueLabel.w = obj.w * labelWidth
    obj.rLabel = gooi.newLabel {
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderWidth + labelPadding),
        y = obj.y + obj.h * .525,
        group = "colorpicker" .. obj.id
    }
    obj.rLabel.w = obj.w * labelWidth
    obj.gLabel = gooi.newLabel {
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderWidth + labelPadding),
        y = obj.y + obj.h * .7,
        group = "colorpicker" .. obj.id
    }
    obj.gLabel.w = obj.w * labelWidth
    obj.bLabel = gooi.newLabel {
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderWidth + labelPadding),
        y = obj.y + obj.h * .875,
        group = "colorpicker" .. obj.id
    }
    obj.bLabel.w = obj.w * labelWidth
    obj.hueSlider = gooi.newSlider {
        value = obj.hue / 360,
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderPadding),
        y = obj.y,
        w = obj.w * sliderWidth,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.hue = self.value * 360
    end)
    obj.saturationSlider = gooi.newSlider {
        value = obj.saturation / 255,
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderPadding),
        y = obj.y + obj.h * .175,
        w = obj.w * sliderWidth,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.saturation = self.value * 255
    end)
    obj.valueSlider = gooi.newSlider {
        value = obj.value / 255,
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderPadding),
        y = obj.y + obj.h * .35,
        w = obj.w * sliderWidth,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.value = self.value * 255
    end)
    obj.rSlider = gooi.newSlider {
        value = obj.color[1] / 255,
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderPadding),
        y = obj.y + obj.h * .525,
        w = obj.w * sliderWidth,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.color[1] = self.value * 255
        obj:triggerCallback("color", obj.color)
    end)
    obj.gSlider = gooi.newSlider {
        value = obj.color[2] / 255,
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderPadding),
        y = obj.y + obj.h * .7,
        w = obj.w * sliderWidth,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.color[2] = self.value * 255
        obj:triggerCallback("color", obj.color)
    end)
    obj.bSlider = gooi.newSlider {
        value = obj.color[3] / 255,
        x = obj.x + obj.w * (squareWidth + squarePadding + hueBarWidth + sliderPadding),
        y = obj.y + obj.h * .875,
        w = obj.w * sliderWidth,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.color[3] = self.value * 255
        obj:triggerCallback("color", obj.color)
    end)
    for _, val in pairs { "color", "visible" } do
        obj:triggerCallback(val, obj[val])
    end
    return obj
end

local function drawSquare(x, y, w, h, hue, square, squareImg)
    if not squareImg then
        for _x = x, x + w * squareWidth - 1 do
            for _y = y, y + h - 1 do
                local r, g, b = color.hsv2rgb(hue, (_x - x) / w * 255, (_y - y) / h * 255)
                square:setPixel(_x - x, _y - y, r, g, b, 255)
            end
        end
        squareImg = love.graphics.newImage(square)
    end
    love.graphics.draw(squareImg, x, y, 0, 1, 1)
    return squareImg
end

local function drawHueBar(x, y, w, h, hueBar, hueBarImg)
    if not hueBarImg then
        for _x = x + w * (squareWidth + squarePadding), x + w * (squareWidth + squarePadding + hueBarWidth) do
            for _y = y, y + h do
                local r, g, b = color.hsv2rgb((_y - y) / h * 360, 255, 255)
                hueBar:setPixel(_x - x - w * (squareWidth + squarePadding), _y - y, r, g, b, 255)
            end
        end
        hueBarImg = love.graphics.newImage(hueBar)
    end
    love.graphics.draw(hueBarImg, x + w * (squareWidth + squarePadding), y, 0, 1, 1)
    return hueBarImg
end

local function drawSquareCursor(x, y, w, h, s, v)
    love.graphics.circle("line", x + s / 255 * w * squareWidth, y + v / 255 * h, 10, 10)
end

local function drawHueCursor(x, y, w, h, hue)
    love.graphics.rectangle("line", x + w * (squareWidth + squarePadding), y + hue / 360 * h - h * .025, w * (hueBarWidth), h * .05, 5, 5)
end

function colorpicker:draw()
    if not self.visible then
        return
    end
    self.squareImg = drawSquare(self.x, self.y, self.w, self.h, self.hue, self.square, self.squareImg)
    self.hueBarImg = drawHueBar(self.x, self.y, self.w, self.h, self.hueBar, self.hueBarImg)
    local oldColor = { love.graphics.getColor() }
    love.graphics.setColor(unpack(self.color))
    love.graphics.rectangle("fill", self.x + self.w * squareWidth, self.y, self.w * squarePadding, self.h)
    love.graphics.setColor(unpack(oldColor))
    drawSquareCursor(self.x, self.y, self.w, self.h, self.saturation, self.value)
    drawHueCursor(self.x, self.y, self.w, self.h, self.hue)
    gooi.draw("colorpicker" .. self.id)
end

function colorpicker.mousepressed(x, y)
    for _, picker in pairs(colorpickers) do
        if picker and picker.onMouse then
            picker.hasFocus, picker.focusIsSquare = picker:isInside(x, y)
            picker:onMouse(x, y)
        end
    end
end

function colorpicker.mousemoved(x, y)
    for _, picker in pairs(colorpickers) do
        if picker and picker.onMouse then
            if picker.hasFocus then
                picker:onMouse(x, y)
            end
        end
    end
end

function colorpicker.mousereleased()
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
        if x >= self.x and x <= self.x + self.w * squareWidth then
            return true, true
        elseif x >= self.x + self.w * (squareWidth + squarePadding) and x <= self.x + self.w * (squareWidth + squarePadding + hueBarWidth) then
            return true, false
        end
    end
    return false
end

function colorpicker:onMouse(x, y)
    local h, s, v = self.hue, self.saturation, self.value
    local isInside, isSquare = self:isInside(x, y)
    if self.hasFocus then
        if self.focusIsSquare then
            local sat, val
            sat, val = (x - self.x) / (self.w * squareWidth) * 255, (y - self.y) / self.h * 255
            local underX, overX, underY, overY = x < self.x, x > self.x + self.w * squareWidth, y < self.y, y > self.y + self.h
            if overX then
                sat = 255
            end
            if overY then
                val = 255
            end
            if underX then
                sat = 0
            end
            if underY then
                val = 0
            end
            self.saturation, self.value = sat, val
        elseif not self.focusIsSquare then
            self.hue = math.max(math.min(self.h, (y - self.y)) / self.h * 360 - .1, 0)
        end
    elseif isInside then
        self.hasFocus = true
        self.focusIsSquare = isSquare
        if isSquare then
            s, v = (x - self.x) / (self.w * squareWidth) * 255, (y - self.y) / self.h * 255
            self:triggerCallback("color", { color.hsv2rgb(h, s, v) })
        else
            h = math.max((y - self.y) / self.h * 360 - .1, 0)
            self:triggerCallback("color", { color.hsv2rgb(h, s, v) })
        end
    end
end

function colorpicker.id()
    local id = 1
    while colorpickers[id] do
        id = id + 1
    end
    return id
end

return setmetatable(colorpicker, { __call = colorpicker.new, __index = object })
