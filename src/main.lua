--- The main file which runs the editor.
local sprite = require "sprite"
local colorpicker = require "bettercolorpicker"
local handSprite, handSpriteOutline
local picker
local pressed = false
io.stdout:setvbuf "no"

function love.load()
    handSprite = sprite {
        imagePath = "assets/hand.png",
        x = love.graphics.getWidth() / 2 - 150,
        y = love.graphics.getHeight() / 2 - 50,
        w = 300,
        h = 100,
        visible = true
    }

    handSpriteOutline = sprite {
        imagePath = "assets/hand.png",
        x = love.graphics.getWidth() / 2 - 150,
        y = love.graphics.getHeight() / 2 - 50,
        w = 300,
        h = 100,
        shader = love.graphics.newShader("outline.glsl")
    }
    handSpriteOutline.shader:send("stepSize", { 5 / handSpriteOutline.image:getWidth(), 5 / handSpriteOutline.image:getHeight() })
    handSpriteOutline.shader:send("color", { 241 / 255, 66 / 255, 244 / 255 })
    picker = colorpicker {
        x = 50,
        y = 50,
        w = 300,
        h = 300
    }
end

function love.update(dt)
    handSpriteOutline.shader:send("color", { math.sin((love.timer.getTime()) + 1) / 2, math.sin((love.timer.getTime() + 127) + 1) / 2, math.sin((love.timer.getTime() - 127) + 1) / 2 })
end

function love.draw()
    picker:draw()
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
