--- The main file which runs the editor.
require "gooi"
local sprite = require "sprite"
local colorpicker = require "bettercolorpicker"
local handSprite, handSpriteOutline
local picker
io.stdout:setvbuf "no"
local GUI = require "GUI"

function love.load()

end

function love.update(dt)

end

function love.draw()
    GUI.drawBackground()
    gooi.draw()
    --    sprite.drawGroup "default"
end

function love.mousepressed(x, y)
    colorpicker.onPress(x, y)
    gooi.pressed(x, y)
end

function love.mousereleased(x, y)
    colorpicker.onRelease(x, y)
    gooi.released(x, y)
end

function love.mousemoved(x, y)
    colorpicker.onMove(x, y)
    gooi.mousemoved(x, y)
end
