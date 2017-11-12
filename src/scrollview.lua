local scrollview

scrollview = { scrollviews = setmetatable({}, { __mode = "v" }) }
local scrollBarSize = .025
local scrollTrackColor = { 175, 175, 175, 128 }
local scrollThumbColor = { 125, 125, 125, 128 }
local scrollThumbHoverColor = { 150, 150, 150, 192 }

local function clamp(num, min, max)
    return math.max(min, math.min(max, num))
end

function scrollview.new(args)
    assert(type(args) == "table", ("Table expected, got %s."):format(type(args)))
    local obj = {
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or 0,
        h = args.h or 0,
        drawFct = args.drawFct or function() end,
        scissorW = args.scissorW or 0,
        scissorH = args.scissorH or 0,
        scrollX = args.scrollX or 0,
        scrollY = args.scrollY or 0,
        children = args.children or {},
        hasFocus = false
    }
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(obj.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(obj.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(obj.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(obj.h)))
    assert(type(obj.scrollX) == "number", ("Number expected, got %s."):format(type(obj.scrollX)))
    assert(type(obj.scrollY) == "number", ("Number expected, got %s."):format(type(obj.scrollY)))
    assert(type(obj.children) == "table", ("Table expected, got %s."):format(type(obj.children)))
    return obj
end

function scrollview:draw()
    local x, y, w, h, scrollX, scrollY = self.x, self.y, self.w, self.h, self.scrollX, self.scrollY
    love.graphics.translate(x + w + scrollX, y + h + scrollY)
    love.graphics.setScissor(self.x, self.y, self.scissorW, self.scissorH)
    self:drawFct()
    love.graphics.setScissor()
    love.graphics.translate(-x - w - scrollX, -y - h - scrollY)
    local vertScrollBarX = self.x + self.scissorW * (1 - scrollBarSize)
    local horizScrollBarY = self.y + self.scissorH * (1 - scrollBarSize)
    local oldColor = { love.graphics.getColor() }
    love.graphics.setColor(unpack(scrollTrackColor))
    if self.scissorW < self.w then
        love.graphics.rectangle("fill", vertScrollBarX, 0, self.scissorW + self.x - vertScrollBarX, self.scissorH)
    end
    if self.scissorH < self.h then
        love.graphics.rectangle("fill", 0, horizScrollBarY, self.scissorW, self.scissorH + self.y - horizScrollBarY)
    end
    love.graphics.setColor(unpack(scrollThumbColor))
    if self.scissorW < self.w then
        love.graphics.setColor(unpack(self.hasFocus == "v" and scrollThumbHoverColor or scrollThumbColor))
        love.graphics.rectangle("fill", vertScrollBarX, self.scrollY, self.scissorW + self.x - vertScrollBarX, self.scissorH ^ 2 / self.h)
    end
    if self.scissorH < self.h then
        love.graphics.setColor(unpack(self.hasFocus == "h" and scrollThumbHoverColor or scrollThumbColor))
        love.graphics.rectangle("fill", self.scrollX, horizScrollBarY, self.scissorW ^ 2 / self.w, self.scissorH + self.y - horizScrollBarY)
    end
    love.graphics.setColor(unpack(oldColor))
end

function scrollview:mousewheel(x, y, horizontal)
    if horizontal then
        --When holding shift, vertical scrolling is interpreted as horizontal scrolling, and horizontal scrolling is ignored.
        if y ~= 0 then
            self.scrollX = clamp(self.scrollX * self.w / self.scissorW + y, 0, self.w - self.scissorW)
        end
    else
        if y ~= 0 then
            self.scrollY = clamp(self.scrollY * self.h / self.scissorH + y, 0, self.h - self.scissorH)
        elseif x ~= 0 then
            self.scrollX = clamp(self.scrollX * self.w / self.scissorW + x, 0, self.w - self.scissorW)
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
    if x >= vertScrollBarX and x <= self.w and y >= self.y and y <= self.y + self.h then
        if y >= self.scrollY and y <= self.scrollY + self.scissorH ^ 2 / self.h then
            self.hasFocus = "v"
        else
            self.scrollY = y + self.scissorH ^ 2 / self.h / 2
        end
    elseif x >= self.x and x <= self.x + self.w and self.y >= horizScrollBarY and self.y <= self.y + self.h then
        if x >= self.scrollX and x <= self.scrollX + self.scissorW ^ 2 / self.w then
            self.hasFocus = "h"
        else
            self.scrollX = x + self.scissorW ^ 2 / self.w / 2
        end
    end
end

function scrollview.mousemoved(dx, dy)
    for _, v in pairs(scrollview.scrollviews) do
        v:mouseMoved(dx, dy)
    end
end

function scrollview:mouseMoved(dx, dy)
    if self.hasFocus == "v" then
        self.scrollX = self.scrollX + dx
    elseif self.hasFocus == "h" then
        self.scrollY = self.scrollY + dy
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

return scrollview
