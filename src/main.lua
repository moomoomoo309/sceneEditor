--- The main file which runs the editor.
local sprite = require "sprite"

local handSprite = sprite {
    imagePath = "assets/hand.png",
    x = love.graphics.getWidth() / 2 - 150,
    y = love.graphics.getHeight() / 2 - 50,
    w = 300,
    h = 100
}

function love.update(dt)
end

function love.draw()
    sprite.drawAll()
end

