-- Module for creating and organizing the background images
--
-- Update 'bgW' and 'bgH' to match the actual image file dimensions.
--
-- !!! Call init() somewhere in the code before using this module !!!

-- Imports --------------------------------------------------------------------[
local model = require( "models.backgroundModel" )
-------------------------------------------------------------------------------]

-- Local vars and methods -----------------------------------------------------[
local bgW = model.getFileWidth()
local bgH = model.getFileHeight()

local function initializeBackgroundGroup()
    local group = display.newGroup()
    group.anchorX = 0
    group.anchorY = 0
    group:toBack()
    model.setImageGroup(group)
end

local function calculateBackgroundDimensions()
    local screenW = display.actualContentWidth
    local screenH = display.actualContentHeight
    local scale = math.max( screenW / bgW, screenH / bgH )
    bgW = bgW * scale
    bgH = bgH * scale
end

local function createBackgroundImages()
    local filesNames = model.getFileNames()
    for i = 1,#filesNames do
        local image = display.newImageRect( model.getImageGroup(), filesNames[i], bgW, bgH )
        image.anchorX = 0
        image.anchorY = 0
        image.alpha = 0
        model.setImage(i, image)
    end
end

local function fadeIn()
    local function listener()
        model.setImageAlpha(model.getActiveBackgroundIndex()-1, 0)
    end
    transition.fadeIn( 
        model.getActiveImage(1), 
        { 
            time = model.getFadeInTime(), 
            onComplete = listener
        } 
    )
end

local function fadeOut()
    transition.fadeOut( 
        model.getActiveImage(), 
        { 
            time=model.getFadeOutTime() 
        } 
    )
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.init = function()
    initializeBackgroundGroup()
    calculateBackgroundDimensions()
    createBackgroundImages()
    model.setImageAlpha(1, 1)
    model.setActiveBackgroundIndex(1)
end

v.fadeOutToDefault = function()
    if model.getActiveBackgroundIndex() > 1 then
        model.setImageAlpha(1, 1)
        fadeOut()
        model.setActiveBackgroundIndex(1)
    end
end

v.fadeInNext = function()
    if model.getActiveBackgroundIndex() < model.getImagesSize() then
        fadeIn()
        model.incrementActiveBackgroundIndex()
    end
end

return v
-------------------------------------------------------------------------------]