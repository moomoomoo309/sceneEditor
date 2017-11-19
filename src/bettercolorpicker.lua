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
        saturationSlider = nil,
        valueSlider = nil,
        rSlider = nil,
        gSlider = nil,
        bSlider = nil,
        focusIsSquare = true,
        visible = args.visible == nil and true or args.visible
    }
    obj:addCallback("hue", function(self, hue) self.color = {color.rgb2hsv(hue, self.saturation, self.value)} self.squareImg = nil return true end)
    obj:addCallback("saturation", function(self, saturation) self.color = {color.rgb2hsv(self.hue, saturation, self.value)} return true end)
    obj:addCallback("value", function(self, value) self.color = {color.rgb2hsv(self.hue, self.saturation, value)} return true end)
    obj:addCallback("color", function(self, _color)
        if _color[1] == _color[2] and _color[2] == _color[3] then
            --Don't update hue for grayscale colors, they don't have a hue.s
            _, self.saturation, self.value = color.rgb2hsv(unpack(_color))
        else
            self.hue, self.saturation, self.value = color.rgb2hsv(unpack(_color))
        end
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
        error(("Tried to change id of colorpicker with id of %d to %d. Changing of ids is not allowed."):format(self.id, id)) end)
    obj:addCallback("visible", function(self, visible)
        self.hueSlider.visible = visible
        self.saturationSlider.visible = visible
        self.valueSlider.visible = visible
        self.rSlider.visible = visible
        self.gSlider.visible = visible
        self.bSlider.visible = visible
    end)
    obj.class = colorpicker
    for _,val in pairs{"hue", "saturation", "value", "color"} do
        obj:triggerCallback(val, obj[val])
    end
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(args.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(args.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(args.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(args.h)))
    colorpickers[obj.id] = obj
    obj.hueSlider = gooi.newSlider{
        value = obj.hue / 360,
        x = obj.x + obj.w,
        y = obj.y,
        w = obj.w / 2.5,
        h = obj.w / 10,
        group = "colorpicker"..obj.id
    }
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
    gooi.draw("colorpicker"..self.id)
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
            self.saturation, self.value = (x - self.x) / (self.w * .85) * 255, (y - self.y) / self.h * 255
            local underX, overX, underY, overY = x < self.x, x > self.x + self.w * .85, y < self.y, y > self.y + self.h
            if overX then
                self.saturation = 255
            end
            if overY then
                self.value = 255
            end
            if underX then
                self.saturation = 0
            end
            if underY then
                self.value = 0
            end
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
        id = id+1
    end
    return id
end

return setmetatable(colorpicker, { __call = colorpicker.new, __index = object })
