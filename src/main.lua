--- The main file which runs the editor.
require "gooi"
local sprite = require "sprite"
local colorpicker = require "bettercolorpicker"
local scrollview = require "scrollview"
local properties = require "properties"
local handSprite, handSpriteOutline
local picker
io.stdout:setvbuf "no"
local GUI = require "GUI"
local shiftPressed = false

function love.load()
    love.window.setTitle "Scene Editor"
end

function love.update(dt)
    gooi.update(dt)
end

function love.draw()
    GUI.drawBackground()
    gooi.draw()
    --    sprite.drawGroup "default"
end

function love.mousepressed(x, y, button)
    colorpicker.onPress(x, y)
    scrollview.mousePressed(x, y, button)
    gooi.pressed(button, x, y)
end

function love.mousereleased(x, y, button)
    colorpicker.onRelease(x, y)
    scrollview.mouseReleased(x, y, button)
    gooi.released(button, x, y)
end

function love.mousemoved(x, y, dx, dy)
    colorpicker.onMove(x, y)
    scrollview.mouseMoved(dx, dy)
    gooi.mousemoved(x, y)
end

function love.keypressed(key)
    if key == "shift" then
        shiftPressed = true
    end
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(key)
    if key == "shift" then
        shiftPressed = false
    end
end

function love.wheelmoved(x, y)
    scrollview.wheelmoved(x, y, shiftPressed)
end
