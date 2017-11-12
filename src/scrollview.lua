local scrollview

scrollview = {}

function scrollview.new(args)
    assert(type(args) == "table", ("Table expected, got %s."):format(type(args)))
    local obj = {
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or 0,
        h = args.h or 0,
        scrollx = args.scrollx or 0,
        scrolly = args.scrolly or 0,
        children = args.children or {}
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
    drawFct()
    love.graphics.translate(-x - w - scrollx, -y - h - scrolly)
end

return scrollview
