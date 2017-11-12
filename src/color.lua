--- A module containing functions converting a color from one format to another.
--- @module color

--- Converts HSV to RGB
--- @tparam number h The hue of the color.
--- @tparam number s The saturation of the color.
--- @tparam number v The value of the color.
--- @treturn number,number,number The r,g,b values of the new color.
local function hsv2rgb(h, s, v)
    h, s, v = h / 360, s / 255, v / 255
    h = (h * 6) % 6
    local i = math.floor(h)
    local p = 255 * v
    local q = p * (1 - s)

    if i == 0 then
        return p, q + p * s * (h - i), q
    elseif i == 1 then
        return p * (1 - s * (h - i)), p, q
    elseif i == 2 then
        return q, p, q + p * s * (h - i)
    elseif i == 3 then
        return q, p * (1 - s * (h - i)), p
    elseif i == 4 then
        return q + p * s * (h - i), q, p
    elseif i == 5 then
        return p, q, p * (1 - s * (h - i))
    end
end

local function rgb2hsv(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local h
    local rgb_max = math.max(r, g, b)
    local rgb_min = math.min(r, g, b)

    if rgb_min < rgb_max then
        if rgb_max == r then
            h = (g - b) / (r - rgb_min) * 60
        elseif rgb_max == g then
            h = 120 + (b - r) / (g - rgb_min) * 60
        else
            h = 240 + (r - g) / (b - rgb_min) * 60
        end

        if h < 0 then
            h = h + 360
        end

        return h, (1 - rgb_min / rgb_max) * 255, rgb_max * 255
    else
        return 0, 0, rgb_max * 255
    end
end

return { hsv2rgb = hsv2rgb, rgb2hsv = rgb2hsv }