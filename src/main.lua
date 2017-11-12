--- The main file which runs the editor.
local sprite = require "sprite"
local colorpicker = require "bettercolorpicker"
local handSprite, handSpriteOutline
local picker
io.stdout:setvbuf "no"

function love.load()

end

function love.update(dt)
end

function love.draw()
    sprite.drawGroup "default"
end

function love.mousepressed(x, y)
    colorpicker.onPress(x, y)
end

function love.mousereleased(x, y)
    colorpicker.onRelease(x, y)
end

function love.mousemoved(x, y)
    colorpicker.onMove(x, y)
end
