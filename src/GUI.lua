require "gooi"

local properties, buttons
local fileButton, editButton, helpButton
local addSprite, addSpriteOverlay, remove, detach, attach
local largeFont = love.graphics.newFont(24)

local menuBarColor = { 12, 183, 242 }
local sideBarColor = { 12, 150, 196 }
local propertiesColor = { 12, 165, 219 }
local lightBackgroundColor = { 150, 150, 150 }
local darkBackgroundColor = { 100, 100, 100 }
local squareSize = 10

local w, h = love.graphics.getDimensions()

properties = gooi.newPanel {
    x = w * .75,
    y = h * .05,
    w = w * .25,
    h = h * .63, --.9*.7
    layout = "grid 1x1"
}

buttons = gooi.newPanel {
    x = w * .75,
    y = h * .72,
    w = w * .25,
    h = h * .27, --.3*.9
    layout = "grid 5x1"
}

fileButton = gooi.newButton({
    x = 2.5,
    y = 0,
    text = "File"
})


editButton = gooi.newButton {
    x = fileButton.x + fileButton.w + 10,
    y = 0,
    text = "Edit"
}

helpButton = gooi.newButton {
    x = editButton.x + editButton.w + 10,
    y = 0,
    text = "Help"
}

addSprite = gooi.newButton {
    text = "Add Sprite"
}
addSprite.style.font = largeFont

addSpriteOverlay = gooi.newButton {
    text = "Add Overlay"
}
addSpriteOverlay.style.font = largeFont

remove = gooi.newButton {
    text = "Remove"
}
remove.style.font = largeFont

attach = gooi.newButton {
    text = "Attach"
}
attach.style.font = largeFont

detach = gooi.newButton {
    text = "Detach"
}
detach.style.font = largeFont

buttons:add(addSprite, addSpriteOverlay, remove, attach, detach)

local function drawBackground()
    local oldColor = { love.graphics.getColor() }
    love.graphics.setScissor(0, fileButton.h, w * .75, h - fileButton.h)
    local start, lightGray = false, false
    for x = 0, w * .75, squareSize do
        lightGray = start
        start = not start
        for y = fileButton.h, h, squareSize do
            if lightGray then
                love.graphics.setColor(unpack(lightBackgroundColor))
            else
                love.graphics.setColor(unpack(darkBackgroundColor))
            end
            love.graphics.rectangle("fill", x, y, squareSize, squareSize)
            lightGray = not lightGray
        end
    end
    love.graphics.setScissor()
    love.graphics.setColor(unpack(propertiesColor))
    love.graphics.rectangle("fill", w * .75, 0, w * .25, h)
    love.graphics.setColor(unpack(menuBarColor))
    love.graphics.rectangle("fill", 0, 0, w, fileButton.h)
    love.graphics.setColor(unpack(sideBarColor))
    love.graphics.rectangle("fill", w * .755, fileButton.h + h * .0075, w * .2395, h * .65)
    love.graphics.setColor(unpack(oldColor))
end

return { drawBackground = drawBackground }