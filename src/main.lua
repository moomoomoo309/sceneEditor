--- The main file which runs the editor.
local sprite = require "sprite"

local handSprite = sprite {
    imagePath = "assets/hand.png",
    x = love.graphics.getWidth() / 2 - 150,
    y = love.graphics.getHeight() / 2 - 50,
    w = 300,
    h = 100,
    visible = true
}

local handSpriteOutline = sprite {
    imagePath = "assets/hand.png",
    x = love.graphics.getWidth() / 2 - 150,
    y = love.graphics.getHeight() / 2 - 50,
    w = 300,
    h = 100,
    shader = love.graphics.newShader("outline.glsl")
}

handSpriteOutline.shader:send("stepSize", {5/handSpriteOutline.image:getWidth(), 5/handSpriteOutline.image:getHeight()})
handSpriteOutline.shader:send("color", {241/255, 66/255, 244/255})

function love.update(dt)
	handSpriteOutline.shader:send("stepSize", {math.random(5,20)/handSpriteOutline.image:getWidth(), math.random(5,20)/handSpriteOutline.image:getHeight()})
	handSpriteOutline.shader:send("color", {math.random(0,255)/255, math.random(0,255)/255, math.random(0,255)/255})
end

function love.draw()
    sprite.drawGroup "default"
end

