local TMW_ST = TMW_Script_Tools
local modes = {
    HORIZONTAL = 1,
    VERTICAL = 2
}

local colors = {
    white = CreateColor(1,1,1,1)
}

local Ticks = {
    modes = modes,
    colors = colors
}

TMW_ST.Ticks = Ticks

local default_size = 1

Ticks.addTick = function(icon, location, mode, color)
    if not icon.ticks then
        icon.ticks = {}
    end

    size = size or default_size
    mode = mode or modes.HORIZONTAL
    if (color and not color.r) then
        color = colors[color] or CreateColorFromHexString(color)
    end

    if not color then
        color = colors.white
    end

    local tick = CreateFrame("Frame", icon:GetName() .. '_tick', icon)
    
    local width = 0
    local height = 0
    local w,h = icon:GetSize()
    
    local top = 0
    local left = 0
    
    if (mode == modes.HORIZONTAL) then
        width = size
        height = h
        left = w / 100 * location - size / 2
    else
        width = w
        height = size
        top = h / 100 * location - size / 2
    end
    
    tick:SetPoint('TOPLEFT', left, top)
    tick:SetSize(width, height)

    tick.texture = tick:CreateTexture()
    tick.texture:SetAllPoints(tick)
    tick.texture:SetColorTexture(color.r, color.g, color.g, color.a)
    table.insert(icon.ticks, tick)
end

Ticks.addTicks = function(icon, number, mode, color)
    local width = 100 / (number + 1)
    local pos = width
    for i = 1, number do
        Ticks.addTick(icon,pos, mode, color)
        pos = pos + width 
    end
end

Ticks.clearTicks = function(icon)
    if (not icon.ticks) then return end
    for i=0,table.getn(icon.ticks) do
        if icon.ticks[i] then icon.ticks[i]:Hide() end
    end
    
    icon.ticks = {}
end