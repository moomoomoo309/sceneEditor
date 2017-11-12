local scrollview

scrollview = {}
local scrollBarSize = .025
local scrollTrackColor = { 175, 175, 175, 128 }
local scrollThumbColor = { 125, 125, 125, 128 }

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
        scissorW = args.scissorW or 0,
        scissorH = args.scissorH or 0,
        scrollx = args.scrollx or 0,
        scrolly = args.scrolly or 0,
        children = args.children or {},
        hasFocus = false
    }
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(obj.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(obj.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(obj.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(obj.h)))
    assert(type(obj.scrollx) == "number", ("Number expected, got %s."):format(type(obj.scrollx)))
    assert(type(obj.scrolly) == "number", ("Number expected, got %s."):format(type(obj.scrolly)))
    assert(type(obj.children) == "table", ("Table expected, got %s."):format(type(obj.children)))
    return obj
end

function scrollview:draw(drawFct)
    local x, y, w, h, scrollx, scrolly = self.x, self.y, self.w, self.h, self.scrollx, self.scrolly
    love.graphics.translate(x + w + scrollx, y + h + scrolly)
    love.graphics.setScissor(self.x, self.y, self.scissorW, self.scissorH)
    drawFct()
    love.graphics.setScissor()
    love.graphics.translate(-x - w - scrollx, -y - h - scrolly)
    local vertScrollBarX = self.x + self.scissorW * (1 - scrollBarSize)
    local horizScrollBarY = self.y + self.scissorH * (1 - scrollBarSize)
    local oldColor = { love.graphics.getColor() }
    love.graphics.setColor(unpack(scrollTrackColor))
    love.graphics.rectangle("fill", vertScrollBarX, 0, self.scissorW + self.x - vertScrollBarX, self.scissorH)
    love.graphics.rectangle("fill", 0, horizScrollBarY, self.scissorW, self.scissorH + self.y - horizScrollBarY)
    love.graphics.setColor(unpack(scrollThumbColor))
    love.graphics.rectangle("fill", vertScrollBarX, self.scrollY, self.scissorW + self.x - vertScrollBarX, self.scissorH ^ 2 / self.h)
    love.graphics.rectangle("fill", self.scrollX, horizScrollBarY, self.scissorW ^ 2 / self.w, self.scissorH + self.y - horizScrollBarY)
    love.graphics.setColor(unpack(oldColor))
end

function scrollview:mousewheel(x, y, horizontal)
    if horizontal then
        --When holding shift, vertical scrolling is interpreted as horizontal scrolling, and horizontal scrolling is ignored.
        if y ~= 0 then
            self.scrollx = clamp(self.scrollx * self.w / self.scissorW + y, 0, self.w - self.scissorW)
        end
    else
        if y ~= 0 then
            self.scrolly = clamp(self.scrolly * self.h / self.scissorH + y, 0, self.h - self.scissorH)
        elseif x ~= 0 then
            self.scrollx = clamp(self.scrollx * self.w / self.scissorW + x, 0, self.w - self.scissorW)
        end
    end
end

function scrollview:mouseClicked(x, y)
    local vertScrollBarX = self.x + self.scissorW * (1 - scrollBarSize)
    local horizScrollBarY = self.y + self.scissorH * (1 - scrollBarSize)
    if x >= vertScrollBarX and x <= self.w and y >= self.y and y <= self.y + self.h then
        self.hasFocus = "v"
    elseif x >= self.x and x <= self.x + self.w and self.y >= horizScrollBarY and self.y <= self.y + self.h then
        self.hasFocus = "h"
    end
end

function scrollview:mouseMoved(dx, dy)
    if self.hasFocus == "v" then
        self.scrollX = self.scrollX + dx
    elseif self.hasFocus == "h" then
        self.scrollY = self.scrollY + dy
    end
end

function scrollview:mouseReleased(x, y)
    self.hasFocus = false
end

return scrollview
