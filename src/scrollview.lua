local object = require "object"
local scrollview

scrollview = { scrollviews = setmetatable({}, { __mode = "v" }), type = "scrollview" }
scrollview.class = scrollview
local scrollTrackColor = { 175, 175, 175, 128 }
local scrollThumbColor = { 125, 125, 125, 192 }
local scrollThumbHoverColor = { 150, 150, 150, 192 }
local lastShiftPressed = false
local lastCtrlPressed = false

local function clamp(num, min, max)
    if min > max then
        min, max = max, min
    end
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
        viewPortW = (args.scissorW or 0) * (args.zoom or 1),
        viewPortH = (args.scissorH or 0) * (args.zoom or 1),
        velocityX = 0,
        velocityY = 0,
        velocityZoom = 0,
        scrollSpeed = args.scrollSpeed or 5,
        scrollAccelerationPower = args.scrollAccelerationPower or .85,
        scrollBarSize = args.scrollBarSize or .025,
        zoomBase = args.zoomBase or 1.05,
        zoomSpeed = args.zoomSpeed or .25,
        zoomAccelerationPower = args.zoomAccelerationPower or .25,
        lightBackgroundColor = args.lightBackgroundColor or { 150, 150, 150 },
        darkBackgroundColor = args.darkBackgroundColor or { 100, 100, 100 },
        squareSize = args.squareSize or 10,
        checkerboardCanvas = nil
    }
    obj.zoomPower = math.log(obj.zoom) / math.log(obj.zoomBase)
    obj.class = scrollview
    obj:addCallback("zoom", function(self, zoom)
        self.viewPortW = self.scissorW * zoom
        self.viewportH = self.scissorH * zoom
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

function scrollview:getScrollThumbDimensions(orientation)
    local vertScrollBarX = self.x + self.scissorW * (1 - self.scrollBarSize)
    local horizScrollBarY = self.y + self.scissorH * (1 - self.scrollBarSize)
    if orientation == "h" then
        return self.x + self.scrollX, horizScrollBarY, math.min(self.scissorW ^ 2 / self.w / self.zoom, vertScrollBarX), self.scissorH + self.y - horizScrollBarY
    elseif orientation == "v" then
        return vertScrollBarX, self.y + self.scrollY, self.scissorW + self.x - vertScrollBarX, math.min(self.scissorH, self.scissorH ^ 2 / self.h / self.zoom)
    end
end

function scrollview:getScrollTrackDimensions(orientation)
    local vertScrollBarX = self.x + self.scissorW * (1 - self.scrollBarSize)
    local horizScrollBarY = self.y + self.scissorH * (1 - self.scrollBarSize)
    if orientation == "v" then
        return vertScrollBarX, self.y, self.scissorW + self.x - vertScrollBarX, self.scissorH
    elseif orientation == "h" then
        return self.x, horizScrollBarY, vertScrollBarX, self.scissorH + self.y - horizScrollBarY
    end
end

function scrollview:getVertScrollBarX()
    return self.x + self.scissorW * (1 - self.scrollBarSize)
end

function scrollview:getHorizScrollBarY()
    return self.y + self.scissorH * (1 - self.scrollBarSize)
end

function scrollview:drawCheckerboard()
    if not self.checkerboardCanvas then
        self.checkerboardCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
        love.graphics.setCanvas(self.checkerboardCanvas)
        local oldColor = { love.graphics.getColor() }
        local start, lightGray = false, false
        for x = self.x, self.x + self.scissorW, self.squareSize do
            lightGray = start
            start = not start
            for y = self.y, self.y + self.scissorH, self.squareSize do
                if lightGray then
                    love.graphics.setColor(unpack(self.lightBackgroundColor))
                else
                    love.graphics.setColor(unpack(self.darkBackgroundColor))
                end
                love.graphics.rectangle("fill", x, y, self.squareSize, self.squareSize)
                lightGray = not lightGray
            end
        end
        love.graphics.setColor(unpack(oldColor))
        love.graphics.setCanvas()
    end
    love.graphics.draw(self.checkerboardCanvas)
end

function scrollview:draw(drawFct)
    local x, y, scrollX, scrollY = self.x, self.y, self.scrollX, self.scrollY
    local vertScrollBarX = self:getVertScrollBarX()
    --Draw Canvas
    love.graphics.setScissor(self.x, self.y, self.scissorW, self.scissorH)
    self:drawCheckerboard()
    if self.scissorW > self.w * self.zoom then
        love.graphics.translate((self.scissorW - self.w * self.zoom) / 2, 0)
    end
    if self.scissorH > self.h * self.zoom  then
        love.graphics.translate(0, (self.scissorH - self.h * self.zoom) / 2)
    end
    love.graphics.translate(x - scrollX * self.w / vertScrollBarX * self.zoom, y - scrollY * self.h / self.scissorH * self.zoom)
    love.graphics.scale(self.zoom)
    drawFct()
    love.graphics.setScissor()
    love.graphics.scale(1 / self.zoom)
    love.graphics.translate(-x + scrollX * self.w / vertScrollBarX * self.zoom, -y + scrollY * self.h / self.scissorH * self.zoom)
    if self.scissorW > self.w * self.zoom then
        love.graphics.translate((-self.scissorW + self.w * self.zoom) / 2, 0)
    end
    if self.scissorH > self.h * self.zoom then
        love.graphics.translate(0, (-self.scissorH + self.h * self.zoom) / 2)
    end
    --Draw tracks
    local oldColor = { love.graphics.getColor() }
    love.graphics.setColor(unpack(scrollTrackColor))
    if self.scissorW / self.zoom < self.w then
        love.graphics.rectangle("fill", self:getScrollTrackDimensions "h")
    end
    if self.scissorH / self.zoom < self.h then
        love.graphics.rectangle("fill", self:getScrollTrackDimensions "v")
    end
    --Draw Thumbs
    love.graphics.setColor(unpack(scrollThumbColor))
    if self.scissorW / self.zoom < self.w then
        love.graphics.setColor(unpack(self.hasFocus == "h" and scrollThumbHoverColor or scrollThumbColor))
        love.graphics.rectangle("fill", self:getScrollThumbDimensions "h")
    end
    if self.scissorH / self.zoom < self.h then
        love.graphics.setColor(unpack(self.hasFocus == "v" and scrollThumbHoverColor or scrollThumbColor))
        love.graphics.rectangle("fill", self:getScrollThumbDimensions "v")
    end
    love.graphics.setColor(unpack(oldColor))
end

function scrollview:mousewheel(x, y, shiftPressed, ctrlPressed)
    local vertScrollBarX = self:getVertScrollBarX()
    self.zoomPower = self.zoomPower + self.velocityZoom
    if self.zoom <= 1 / 32 or self.zoom >= 32 then
        self.velocityZoom = 0
    end
    self.zoom = clamp(self.zoomBase ^ self.zoomPower, 1 / 32, 32)
    local maxScrollX = math.max(0, vertScrollBarX - math.min(self.scissorW ^ 2 / self.w, self.scissorW - self.x + vertScrollBarX) / self.zoom)
    local maxScrollY = math.max(0, self.scissorH - math.min(self.scissorH, self.scissorH ^ 2 / self.h) / self.zoom)

    self.scrollX = clamp(self.scrollX, 0, maxScrollX)
    self.scrollY = clamp(self.scrollY, 0, maxScrollY)
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

function scrollview.wheelmoved(x, y, shiftPressed, ctrlPressed)
    for _, obj in pairs(scrollview.scrollviews) do
        if ctrlPressed then
            obj.velocityZoom = obj.velocityZoom + y * obj.zoomSpeed
        else
            obj.velocityX, obj.velocityY = obj.velocityX + x * obj.scrollSpeed, obj.velocityY + y * obj.scrollSpeed
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
    local vertScrollBarX = self:getVertScrollBarX()
    local maxScrollX = math.max(0, vertScrollBarX - math.min(self.scissorW ^ 2 / self.w, self.scissorW - self.x + vertScrollBarX) / self.zoom)
    local maxScrollY = math.max(0, self.scissorH - math.min(self.scissorH, self.scissorH ^ 2 / self.h) / self.zoom)
    local trackX, trackY, trackW, trackH = self:getScrollTrackDimensions "v"
    local thumbX, thumbY, thumbW, thumbH = self:getScrollThumbDimensions "v"
    if x >= trackX and x <= trackX + trackW and y >= trackY and y <= trackY + trackH then
        if x >= thumbX and x <= thumbX + thumbW and y >= thumbY and y <= thumbY + thumbH then
            self.hasFocus = "v"
        else
            self.scrollY = clamp(y - self.scissorH ^ 2 / self.h / 2, 0, maxScrollY)
        end
        self.velocityY = 0
    end
    local trackX, trackY, trackW, trackH = self:getScrollTrackDimensions "h"
    local thumbX, thumbY, thumbW, thumbH = self:getScrollThumbDimensions "h"
    if x >= trackX and x <= trackX + trackW and y >= trackY and y <= trackY + trackH then
        if x >= thumbX and x <= thumbX + thumbW and y >= thumbY and y <= thumbY + thumbH then
            self.hasFocus = "h"
        else
            self.scrollX = clamp(x - self.scissorW ^ 2 / self.w / 2, 0, maxScrollX)
        end
        self.velocityX = 0
    end
end

function scrollview.mousemoved(dx, dy)
    for _, v in pairs(scrollview.scrollviews) do
        v:mouseMoved(dx, dy)
    end
end

function scrollview:mouseMoved(dx, dy)
    local vertScrollBarX = self:getVertScrollBarX()
    local maxScrollX = math.max(0, vertScrollBarX - math.min(self.scissorW ^ 2 / self.w, self.scissorW - self.x + vertScrollBarX) / self.zoom)
    local maxScrollY = math.max(0, self.scissorH - math.min(self.scissorH, self.scissorH ^ 2 / self.h) / self.zoom)
    if self.hasFocus == "h" then
        self.scrollX = clamp(self.scrollX + dx, 0, maxScrollX)
    elseif self.hasFocus == "v" then
        self.scrollY = clamp(self.scrollY + dy, 0, maxScrollY)
    end
end

function scrollview.mousereleased(x, y, button)
    if button ~= 1 then
        return -- Focus should only be lost on left clicks.
    end
    for _, v in pairs(scrollview.scrollviews) do
        v:mouseReleased(x, y)
    end
end

function scrollview:mouseReleased(_, _)
    self.hasFocus = false
end

function scrollview.update(dt, shiftPressed, ctrlPressed)
    for _, obj in pairs(scrollview.scrollviews) do
        -- Prevent the user letting go or pressing shift from switching scroll direction with leftover velocity.
        if lastShiftPressed ~= shiftPressed then
            obj.velocityX = 0
            obj.velocityY = 0
        end
        -- Prevent the user letting go or pressing ctrl from switching to/from zoom with leftover velocity.
        if lastCtrlPressed ~= ctrlPressed then
            obj.velocityZoom = 0
        end
        --Scroll, then update velocity
        obj:mousewheel(obj.velocityX * math.abs(obj.velocityX) * dt,
            obj.velocityY * math.abs(obj.velocityY) * dt, shiftPressed, ctrlPressed)
        local mult = math.min(dt * obj.scrollSpeed / 2, 1)
        obj.velocityX = obj.velocityX - obj.velocityX * mult ^ obj.scrollAccelerationPower
        obj.velocityY = obj.velocityY - obj.velocityY * mult ^ obj.scrollAccelerationPower
        local zoomMult = math.min(dt * obj.zoomSpeed / 2, 1)
        obj.velocityZoom = obj.velocityZoom - obj.velocityZoom * zoomMult ^ obj.zoomAccelerationPower
    end
    lastShiftPressed = shiftPressed
    lastCtrlPressed = ctrlPressed
end

return setmetatable(scrollview, { __call = scrollview.new, __index = object })
