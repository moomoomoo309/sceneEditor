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
scrollVelocityX, scrollVelocityY = 0, 0
local scrollSpeed = 20

function love.load()
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
        w = 300,
        h = 300
    }
end

function love.update(dt)
    scrollview.wheelmoved(scrollVelocityX * (math.abs(scrollVelocityX + 1) ^ .25 - 1) * dt,
        scrollVelocityY * (math.abs(scrollVelocityY + 1) ^ .25 - 1) * dt, nil, nil, shiftPressed)
    gooi.update(dt)
    local mult = math.min(dt * scrollSpeed / 2, 1)
    scrollVelocityX = scrollVelocityX - scrollVelocityX * mult
    scrollVelocityY = scrollVelocityY - scrollVelocityY * mult
end

function love.draw()
    GUI.drawBackground()
    gooi.draw()
    scrollView:draw(function()
        sprite.drawGroup "default"
    end)
    picker:draw()
end

function love.mousepressed(x, y, button)
    colorpicker.mousepressed(x, y)
    scrollview.mousepressed(x, y, button)
    gooi.pressed(button, x, y)
end

function love.mousereleased(x, y, button)
    colorpicker.mousereleased(x, y)
    scrollview.mousereleased(x, y, button)
    gooi.released(button, x, y)
end

function love.mousemoved(x, y, dx, dy)
    colorpicker.mousemoved(x, y)
    scrollview.mousemoved(dx, dy)
    gooi.mousemoved(x, y)
end

function love.keypressed(key)
    if key:sub(2) == "shift" then
        shiftPressed = true
    end
    if key == "escape" then
        love.event.quit()
    end
    if key:sub(2) == "ctrl" then
        ctrlPressed = true
    end
end

function love.keyreleased(key)
    if key:sub(2) == "shift" then
        shiftPressed = false
    end
    if key:sub(2) == "ctrl" then
        ctrlPressed = false
    end
end

function love.wheelmoved(x, y)
    scrollVelocityX, scrollVelocityY = scrollVelocityX + x * scrollSpeed, scrollVelocityY + y * scrollSpeed
    if ctrlPressed then
        scrollview.wheelmoved(nil, nil, x, y, shiftPressed, ctrlPressed)
    end
end
