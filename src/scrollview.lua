local object = require "object"
local scrollview

scrollview = { scrollviews = setmetatable({}, { __mode = "v" }), type = "scrollview" }
scrollview.class = scrollview
local scrollBarSize = .025
local scrollTrackColor = { 175, 175, 175, 128 }
local scrollThumbColor = { 125, 125, 125, 192 }
local scrollThumbHoverColor = { 150, 150, 150, 192 }
local zoomBase = 1.1

local function clamp(num, min, max)
    return math.max(min, math.min(max, num))
end

function scrollview.new(_, args)
    assert(type(args) == "table", ("Table expected, got %s."):format(type(args)))
    local obj = object {
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or 0,
        h = args.h or 0,
        scissorW = args.scissorW or 0,
        scissorH = args.scissorH or 0,
        scrollX = args.scrollX or args.x or 0,
        scrollY = args.scrollY or args.y or 0,
        children = args.children or {},
        hasFocus = false,
        zoom = args.zoom or 1,
        zoomPower = math.log(args.zoom or 1) / math.log(zoomBase),
        viewPortW = (args.scissorW or 0) * (args.zoom or 1),
        viewPortH = (args.scissorH or 0) * (args.zoom or 1)
    }
    obj.class = scrollview
    obj:addCallback("zoom", function(self, zoom)
        self.viewPortW = self.scissorW * zoom
        self.viewPortH = self.scissorH * zoom
    end)
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(obj.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(obj.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(obj.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(obj.h)))
    assert(type(obj.scrollX) == "number", ("Number expected, got %s."):format(type(obj.scrollX)))
    assert(type(obj.scrollY) == "number", ("Number expected, got %s."):format(type(obj.scrollY)))
    assert(type(obj.children) == "table", ("Table expected, got %s."):format(type(obj.children)))
    scrollview.scrollviews[#scrollview.scrollviews + 1] = obj
    return obj
end

function scrollview:draw(drawFct)
    local x, y, scrollX, scrollY = self.x, self.y, self.scrollX, self.scrollY
    local vertScrollBarX = self.x + self.scissorW * (1 - scrollBarSize)
    local horizScrollBarY = self.y + self.scissorH * (1 - scrollBarSize)
    --Draw Canvas
    love.graphics.translate(x - scrollX * self.w / vertScrollBarX * self.zoom, y - scrollY * self.h / self.scissorH * self.zoom)
    love.graphics.scale(self.zoom)
    love.graphics.setScissor(self.x, self.y, self.scissorW, self.scissorH)
    drawFct()
    love.graphics.setScissor()
    love.graphics.scale(1 / self.zoom)
    love.graphics.translate(-x + scrollX * self.w / vertScrollBarX * self.zoom, -y + scrollY * self.h / self.scissorH * self.zoom)
    local oldColor = { love.graphics.getColor() }
    --Draw tracks
    love.graphics.setColor(unpack(scrollTrackColor))
    if self.scissorW < self.w then
        love.graphics.rectangle("fill", vertScrollBarX, self.y, self.scissorW + self.x - vertScrollBarX, self.scissorH)
    end
    if self.scissorH < self.h then
        love.graphics.rectangle("fill", self.x, horizScrollBarY, vertScrollBarX, self.scissorH + self.y - horizScrollBarY)
    end
    --Draw Thumbs
    love.graphics.setColor(unpack(scrollThumbColor))
    if self.scissorW < self.w then
        love.graphics.setColor(unpack(self.hasFocus == "v" and scrollThumbHoverColor or scrollThumbColor))
        love.graphics.rectangle("fill", vertScrollBarX, self.y + self.scrollY, self.scissorW + self.x - vertScrollBarX, math.min(self.scissorH, self.scissorH ^ 2 / self.h / self.zoom))
    end
    if self.scissorH < self.h then
        love.graphics.setColor(unpack(self.hasFocus == "h" and scrollThumbHoverColor or scrollThumbColor))
        love.graphics.rectangle("fill", self.x + self.scrollX, horizScrollBarY, math.min(self.scissorW ^ 2 / self.w / self.zoom, vertScrollBarX), self.scissorH + self.y - horizScrollBarY)
    end
    love.graphics.setColor(unpack(oldColor))
end

function scrollview.wheelmoved(x, y, rawX, rawY, shiftPressed, ctrlPressed)
    for _, v in pairs(scrollview.scrollviews) do
        v:mousewheel(x, y, rawX, rawY, shiftPressed, ctrlPressed)
    end
end

function scrollview:mousewheel(x, y, rawX, rawY, shiftPressed, ctrlPressed)
    local vertScrollBarX = self.x + self.scissorW * (1 - scrollBarSize)
    if ctrlPressed then
        self.zoomPower = self.zoomPower + rawY
        self.zoom = clamp(zoomBase ^ self.zoomPower, .1, 32)
        local maxScrollX = vertScrollBarX - math.min(self.scissorW ^ 2 / self.w, self.scissorW - self.x + vertScrollBarX) / self.zoom
        local maxScrollY = self.scissorH - math.min(self.scissorH, self.scissorH ^ 2 / self.h) / self.zoom
        self.scrollX = clamp(self.scrollX, 0, maxScrollX)
        self.scrollY = clamp(self.scrollY, 0, maxScrollY)
    else
        local maxScrollX = vertScrollBarX - math.min(self.scissorW ^ 2 / self.w, self.scissorW - self.x + vertScrollBarX) / self.zoom
        local maxScrollY = self.scissorH - math.min(self.scissorH, self.scissorH ^ 2 / self.h) / self.zoom
        if shiftPressed then
            --When holding shift, vertical scrolling is interpreted as horizontal scrolling, and horizontal scrolling is ignored.
            if y ~= 0 then
                self.scrollX = clamp(self.scrollX - y, 0, maxScrollX)
            end
        else
            if y ~= 0 then
                self.scrollY = clamp(self.scrollY - y, 0, maxScrollY)
            end
            if x ~= 0 then
                self.scrollX = clamp(self.scrollX - x, 0, maxScrollX)
            end
        end
    end
end

function scrollview.mousepressed(x, y, button)
    if button ~= 1 then
        return
    end
    for _, v in pairs(scrollview.scrollviews) do
        v:mousePressed(x, y)
    end
end

function scrollview:mousePressed(x, y)
    local vertScrollBarX = self.x + self.scissorW * (1 - scrollBarSize)
    local horizScrollBarY = self.y + self.scissorH * (1 - scrollBarSize)
    local maxScrollX = vertScrollBarX - self.scissorW ^ 2 / self.w
    local maxScrollY = self.scissorH - self.scissorH ^ 2 / self.h
    if x >= vertScrollBarX and x <= self.scissorW and y >= self.y and y <= self.y + self.scissorH then
        if y >= self.scrollY and y <= self.scrollY + self.scissorH ^ 2 / self.h then
            self.hasFocus = "v"
        else
            self.scrollY = clamp(y - self.scissorH ^ 2 / self.h / 2, 0, maxScrollY)
        end
        scrollVelocityY = 0
    elseif x >= self.x and x <= self.x + self.scissorW and y >= horizScrollBarY and self.y <= self.y + self.scissorH then
        if x >= self.scrollX and x <= self.scrollX + self.scissorW ^ 2 / self.w then
            self.hasFocus = "h"
        else
            self.scrollX = clamp(x - self.scissorW ^ 2 / self.w / 2, 0, maxScrollX)
        end
        scrollVelocityX = 0
    end
end

function scrollview.mousemoved(dx, dy)
    for _, v in pairs(scrollview.scrollviews) do
        v:mouseMoved(dx, dy)
    end
end

function scrollview:mouseMoved(dx, dy)
    local vertScrollBarX = self.x + self.scissorW * (1 - scrollBarSize)
    if self.hasFocus == "h" then
        self.scrollX = clamp(self.scrollX + dx, 0, vertScrollBarX - self.scissorW ^ 2 / self.w)
    elseif self.hasFocus == "v" then
        self.scrollY = clamp(self.scrollY + dy, 0, self.scissorH - self.scissorH ^ 2 / self.h)
    end
end

function scrollview.mousereleased(x, y, button)
    if button ~= 1 then
        return
    end
    for _, v in pairs(scrollview.scrollviews) do
        v:mouseReleased(x, y)
    end
end

function scrollview:mouseReleased(x, y)
    self.hasFocus = false
end

return setmetatable(scrollview, { __call = scrollview.new, __index = object })
