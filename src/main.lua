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
local ctrlPressed = false
local scrollView

function love.load(arg)
    if arg and arg[#arg] == "-ideadebug" then package.path=[[/home/nicholasdelello/.IntelliJIdea2017.3/config/plugins/Lua/mobdebug/?.lua;]]  ..  package.path arg[#arg] = "-debug" end
    if arg and arg[#arg] == "-debug" then require "mobdebug".start() require "mobdebug".off() end
    love.window.setTitle "Scene Editor"
    handSprite = sprite {
        w = 2460,
        h = 2400,
        imagePath = "assets/Sink.png",
    }
    scrollView = scrollview {
        x = 0,
        y = fileButton.h,
        scissorW = love.graphics.getWidth() * spriteAreaSize,
        scissorH = love.graphics.getHeight() - fileButton.h,
        w = handSprite.w,
        h = handSprite.h
    }
    picker = colorpicker {
        x = 50,
        y = 50,
        w = 500,
        h = 300,
        visible = false
    }
end

function love.update(dt)
    scrollview.update(dt, shiftPressed, ctrlPressed)
    gooi.update(dt)
end

function love.draw()
    GUI.drawBackground()
    gooi.draw()
    scrollView:draw(function()
        sprite.drawGroup "default"
    end)
    picker:draw()
end

function love.mousepressed(x, y, button, isTouch)
    colorpicker.mousepressed(x, y)
    scrollview.mousepressed(x, y, button)
    gooi.pressed(isTouch, x, y)
end

function love.mousereleased(x, y, button)
    colorpicker.mousereleased(x, y)
    scrollview.mousereleased(x, y, button)
    gooi.released(button, x, y)
end

function love.mousemoved(x, y, dx, dy)
    colorpicker.mousemoved(x, y)
    scrollview.mousemoved(dx, dy)
end

function love.keypressed(key, scancode, isrepeat)
    if key:sub(2) == "shift" then
        shiftPressed = true
    end
    if key == "escape" then
        love.event.quit()
    end
    if key:sub(2) == "ctrl" then
        ctrlPressed = true
    end
    gooi.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key)
    if key:sub(2) == "shift" then
        shiftPressed = false
    end
    if key:sub(2) == "ctrl" then
        ctrlPressed = false
    end
    if key == "space" then
        picker.visible = not picker.visible
    end
    gooi.keyreleased()
end

function love.wheelmoved(x, y)
    scrollview.wheelmoved(x, y, shiftPressed, ctrlPressed)
end

function love.textinput(text)
    gooi.textinput(text)
end
