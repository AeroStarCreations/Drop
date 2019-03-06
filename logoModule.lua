-- Location of all information and functions related to the drop logo

local cushion = 30
local imageWidth = 1020
local imageHieght = 390
local ratio = imageHieght/imageWidth
local bigLogoWidth = 0.77 * display.actualContentWidth
local bigLogoHeight = bigLogoWidth * ratio
local smallLogoWidth = 0.36 * display.actualContentWidth
local smallLogoHeight = smallLogoWidth * ratio

local function getTopY()
    local y = display.safeScreenOriginY
    if y == 0 then
        y = cushion
    end
    return y
end

local v = {}

v.cushion = cushion

v.getSmallLogoY = function()
    return getTopY()
end

v.getSmallLogoBottomY = function()
    return getTopY() + smallLogoHeight + cushion
end

v.getSmallLogo = function( parent )
    local drop = display.newImageRect( "images/name.png", imageWidth, imageHieght )
    drop.width = smallLogoWidth
    drop.height = smallLogoHeight
    drop.x = display.contentCenterX
    drop.y = getTopY()
    drop.anchorY = 0
    parent:insert(drop)
    return drop
end

v.getBigLogo = function( parent )
    local drop = display.newImageRect( "images/name.png", 1020, 390 )
    drop.width = bigLogoWidth
    drop.height = bigLogoHeight
    drop.x = display.contentCenterX
    drop.y = -drop.height
    drop.anchorY = 0
    parent:insert(drop)
    return drop
end

v.getBigLogoY = function( arrow )
    return display.safeScreenOriginY + 0.5 * (0.5 * (display.safeActualContentHeight - arrow.height) - bigLogoHeight)
end

return v