-- Module for creating and organizing the background images
--
-- Update 'bgW' and 'bgH' to match the actual image file dimensions.
--
-- !!! Call init() somewhere in the code before using this module !!!

-- Local vars and methods -----------------------------------------------------[
local bgFileNames = {
    [1] = "images/bg.png",
    [2] = "images/bg2.png",
    [3] = "images/bg3.png",
    [4] = "images/bg4.png",
    [5] = "images/bg5.png",
    [6] = "images/bg6.png",
    [7] = "images/bg7.png",
}

local bgGroup
local bgImages = {}
local bgW = 1000
local bgH = 1500
local activeBackground

local function initializeBackgroundGroup()
    bgGroup = display.newGroup()
    bgGroup.anchorX = 0
    bgGroup.anchorY = 0
    bgGroup:toBack()
end

local function calculateBackgroundDimensions()
    local screenW = display.actualContentWidth
    local screenH = display.actualContentHeight
    local scale = math.max( screenW / bgW, screenH / bgH )
    bgW = bgW * scale
    bgH = bgH * scale
end

local function createBackgroundImages()
    for i = 1,#bgFileNames do
        bgImages[i] = display.newImageRect( bgGroup, bgFileNames[i], bgW, bgH )
        bgImages[i].anchorX = 0
        bgImages[i].anchorY = 0
        bgImages[i].alpha = 0
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.init = function()
    initializeBackgroundGroup()
    calculateBackgroundDimensions()
    createBackgroundImages()
    bgImages[1].alpha = 1
    activeBackground = 1
end

v.fadeOutToDefault = function()
    if activeBackground > 1 then
        bgImages[1].alpha = 1
        transition.fadeOut( bgImages[activeBackground], { time=2500 } )
        activeBackground = 1
    end
end

v.fadeInNext = function()
    local function listener()
        bgImages[activeBackground-1].alpha = 0
    end
    if activeBackground < #bgImages then
        transition.fadeIn( 
            bgImages[activeBackground+1], 
            { 
                time = 3500, 
                onComplete = listener
            } 
        )
        activeBackground = activeBackground + 1
    end
end

return v
-------------------------------------------------------------------------------]