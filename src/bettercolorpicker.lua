local object = require "object"
local color = require "color"
if not gooi then
    require "gooi"
end

local colorpicker = { type = "colorpicker" }
local colorpickers = setmetatable({}, { __mode = "v" })
colorpicker.colorpickers = colorpickers

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
        self.color = { color.rgb2hsv(hue, self.saturation, self.value) }
        self:triggerCallback("color", self.color)
        self.hueSlider:setValue(hue / 360)
        self.hueLabel.text = self.hueLabel:setText(hue)
        self.squareImg = nil
        return true
    end)
    obj:addCallback("saturation", function(self, saturation)
        self.color = { color.rgb2hsv(self.hue, saturation, self.value) }
        self:triggerCallback("color", self.color)
        self.saturationSlider:setValue(saturation / 255)
        self.saturationLabel.text = self.saturationLabel:setText(saturation)
        return true
    end)
    obj:addCallback("value", function(self, value)
        assert(value >= 0 and value <= 255, ("Value %d outside of 0-255!"):format(value))
        print(value)
        self.color = { color.rgb2hsv(self.hue, self.saturation, value) }
        self:triggerCallback("color", self.color)
        self.valueSlider:setValue(value / 255)
        self.valueLabel.text = self.valueLabel:setText(value)
        return true
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
        self.rLabel.text = self.rLabel:setText(_color[1])
        self.gLabel.text = self.gLabel:setText(_color[2])
        self.bLabel.text = self.bLabel:setText(_color[3])
        return true
    end)
    obj:addCallback("w", function(self, w)
        self.hueBarImg = nil
        self.square = love.image.newImageData(w * .85 + 1, args.h + 1)
        love.self.hueBar = love.image.newImageData(w * .1 + 1, self.h)
    end)
    obj:addCallback("h", function(self, h)
        self.hueBarImg = nil
        self.square = love.image.newImageData(args.w * .85 + 1, h + 1)
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
        x = obj.x + obj.w * 1.5,
        y = obj.y,
    }
    obj.hueLabel.w = obj.hueLabel.style.font:getWidth "255" + 10
    obj.saturationLabel = gooi.newLabel {
        x = obj.x + obj.w * 1.5,
        y = obj.y + obj.h * .175,
    }
    obj.saturationLabel.w = obj.saturationLabel.style.font:getWidth "255" + 10
    obj.valueLabel = gooi.newLabel {
        x = obj.x + obj.w * 1.5,
        y = obj.y + obj.h * .35,
    }
    obj.valueLabel.w = obj.valueLabel.style.font:getWidth "255" + 10
    obj.rLabel = gooi.newLabel {
        x = obj.x + obj.w * 1.5,
        y = obj.y + obj.h * .525,
    }
    obj.rLabel.w = obj.rLabel.style.font:getWidth "255" + 10
    obj.gLabel = gooi.newLabel {
        x = obj.x + obj.w * 1.5,
        y = obj.y + obj.h * .7,
    }
    obj.gLabel.w = obj.gLabel.style.font:getWidth "255" + 10
    obj.bLabel = gooi.newLabel {
        x = obj.x + obj.w * 1.5,
        y = obj.y + obj.h * .875,
    }
    obj.bLabel.w = obj.bLabel.style.font:getWidth "255" + 10
    obj.hueSlider = gooi.newSlider {
        value = obj.hue / 360,
        x = obj.x + obj.w * 1.05,
        y = obj.y,
        w = obj.w / 2.5,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.hue = self.value * 360
    end)
    obj.saturationSlider = gooi.newSlider {
        value = obj.saturation / 255,
        x = obj.x + obj.w * 1.05,
        y = obj.y + obj.h * .175,
        w = obj.w / 2.5,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.saturation = self.value * 255
    end)
    obj.valueSlider = gooi.newSlider {
        value = obj.value / 255,
        x = obj.x + obj.w * 1.05,
        y = obj.y + obj.h * .35,
        w = obj.w / 2.5,
        h = obj.h / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.value = self.value * 255
    end)
    obj.rSlider = gooi.newSlider {
        value = obj.color[1] / 255,
        x = obj.x + obj.w * 1.05,
        y = obj.y + obj.h * .525,
        w = obj.w / 2.5,
        h = obj.w / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.color[1] = self.value * 255 obj:triggerCallback("color", obj.color)
    end)
    obj.gSlider = gooi.newSlider {
        value = obj.color[2] / 255,
        x = obj.x + obj.w * 1.05,
        y = obj.y + obj.h * .7,
        w = obj.w / 2.5,
        h = obj.w / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.color[2] = self.value * 255 obj:triggerCallback("color", obj.color)
    end)
    obj.bSlider = gooi.newSlider {
        value = obj.color[3] / 255,
        x = obj.x + obj.w * 1.05,
        y = obj.y + obj.h * .875,
        w = obj.w / 2.5,
        h = obj.w / 8,
        group = "colorpicker" .. obj.id
    }:setCallback(function(self)
        obj.color[3] = self.value * 255 obj:triggerCallback("color", obj.color)
    end)
    for _, val in pairs { "hue", "saturation", "value", "color", "visible" } do
        obj:triggerCallback(val, obj[val])
    end
    return obj
end

local function drawSquare(x, y, w, h, hue, square, squareImg)
    if not squareImg then
        for _x = x, x + w * .85 - 1 do
            for _y = y, y + h - 1 do
                local r, g, b = color.hsv2rgb(hue * 255 / 360, (_x - x) / w * 255, (_y - y) / h * 255)
                square:setPixel(_x - x, _y - y, r, g, b, 255)
            end
        end
        squareImg = love.graphics.newImage(square)
    end
    love.graphics.draw(squareImg, x, y, 0, 1, 1)
    return squareImg
end

local function drawHueBar(x, y, w, h, hueBar, hueBarImg)
    local hueImg
    if not hueBarImg then
        for _x = x + w * .9, x + w * .99 - 1 do
            for _y = y, y + h - 1 do
                local r, g, b = color.hsv2rgb((_y - y) / h * 255, 255, 255)
                hueBar:setPixel(_x - x - w * .9, _y - y, r, g, b, 255)
            end
        end
        hueImg = love.graphics.newImage(hueBar)
    end
    love.graphics.draw(hueBarImg or hueImg, x + w * .9, y, 0, 1, 1)
    return hueBarImg or hueImg
end

local function drawSquareCursor(x, y, w, h, s, v)
    love.graphics.circle("line", x + s / 255 * w * .85, y + v / 255 * h, 10, 10)
end

local function drawHueCursor(x, y, w, h, hue)
    love.graphics.rectangle("line", x + w * .89, y + hue / 360 * h - h * .025, w * .11, h * .05, 5, 5)
end

function colorpicker:draw()
    if not self.visible then
        return
    end
    self.squareImg = drawSquare(self.x, self.y, self.w, self.h, self.hue, self.square, self.squareImg)
    self.hueBarImg = drawHueBar(self.x, self.y, self.w, self.h, self.hueBar, self.hueBarImg)
    drawSquare(self.x, self.y, self.w, self.h, self.hue, self.square)
    drawHueBar(self.x, self.y, self.w, self.h, self.hueBar)
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
        if self.focusIsSquare then
            local sat, val
            sat, val = (x - self.x) / (self.w * .85) * 255, (y - self.y) / self.h * 255
            local underX, overX, underY, overY = x < self.x, x > self.x + self.w * .85, y < self.y, y > self.y + self.h
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
            s, v = (x - self.x) / (self.w * .85) * 255, (y - self.y) / self.h * 255
            self.color = { color.hsv2rgb(h, s, v) }
        else
            h = math.max((y - self.y) / self.h * 360 - .1, 0)
            self.color = { color.hsv2rgb(h, s, v) }
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
