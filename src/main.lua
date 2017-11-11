--- The main file which runs the editor.
local sprite = require "sprite"

local handSprite = sprite {
    imagePath = "assets/hand.png",
    x = love.graphics.getWidth() / 2 - 150,
    y = love.graphics.getHeight() / 2 - 50,
    w = 300,
    h = 100,
    visible = false
}

local handSpriteOutline = sprite {
    imagePath = "assets/hand.png",
    x = love.graphics.getWidth() / 2 - 150,
    y = love.graphics.getHeight() / 2 - 50,
    w = 300,
    h = 100,
    shader = love.graphics.newShader("outline.glsl")
}

handSpriteOutline.shader:send("stepSize", {1/handSpriteOutline.image:getWidth(), 1/handSpriteOutline.image:getHeight()})
handSpriteOutline.shader:send("color", {0.5, 1.0, 0.5})

function love.update(dt)
end

function love.draw()
    sprite.drawAll()
end

