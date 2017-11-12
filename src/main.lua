--- The main file which runs the editor.
require "gooi"
local sprite = require "sprite"
local colorpicker = require "bettercolorpicker"
local handSprite, handSpriteOutline
local picker
io.stdout:setvbuf "no"
local GUI = require "GUI"

function love.load()
	love.window.setTitle("Scene Editor")
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
    gooi.pressed(button, x, y)
end

function love.mousereleased(x, y, button)
    colorpicker.onRelease(x, y)
    gooi.released(button, x, y)
end

function love.mousemoved(x, y, dx, dy)
    colorpicker.onMove(x, y)
    gooi.mousemoved(x, y)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
