-------------------------------------------------------------------------------
-- Private Members ------------------------------------------------------------
-------------------------------------------------------------------------------
-- Imports
local cp = require( "composer" )

-- View Objects
local statsLogo
local lineGroup
local textGroup
local imageGroup
local iconGroup

-- Other
local fontSize = 55
local statsLogoX

---------------------------------------------------------------------
-- Logic ------------------------------------------------------------
---------------------------------------------------------------------
local function setFontSize(textObj, width)
    textObj.size = fontSize
    while textObj.width > width - 10 do
        textObj.size = textObj.size - 1
    end
end

---------------------------------------------------------------------
-- Transitions ------------------------------------------------------
---------------------------------------------------------------------
local function transitionIn()
    transition.to( statsLogo, {time=500, x=statsLogoX, transition=easing.outSine})
    for k,v in pairs(lineGroup) do
        transition.fadeIn(v, {time=500})
    end
    for k,v in pairs(textGroup) do
        transition.to(v, {time=500, xScale=1, yScale=1, transition=easing.outBack})
    end
    for k,v in pairs(imageGroup) do
        transition.to(v, {time=500, xScale=1, yScale=1, transition=easing.outBack})
    end
    for k,v in pairs(iconGroup) do
        transition.to(v, {time=500, xScale=1, yScale=1, transition=easing.outBack})
    end
end

local function transitionOut()
    local transTime = 500
    timer.performWithDelay( transTime, function()
        cp.gotoScene("views.scenes.extras")
    end)
    transition.to( statsLogo, {time=transTime, x=display.contentWidth+0.5*statsLogo.width, transition=easing.inSine})
    for k,v in pairs(lineGroup) do
        transition.fadeOut(v, {time=transTime})
    end
    for k,v in pairs(textGroup) do
        transition.to(v, {time=transTime, xScale=0.001, yScale=0.001, transition=easing.inBack})
    end
    for k,v in pairs(imageGroup) do
        transition.to(v, {time=transTime, xScale=0.001, yScale=0.001, transition=easing.inBack})
    end
    for k,v in pairs(iconGroup) do
        transition.to(v, {time=transTime, xScale=0.001, yScale=0.001, transition=easing.inBack})
    end
end

-------------------------------------------------------------------------------
-- Public Members -------------------------------------------------------------
-------------------------------------------------------------------------------
local v = {}

function v.transitionIn()
    transitionIn()
end

function v.transitionOut()
    transitionOut()
end

function v.setFontSize(textObj, width)
    setFontSize(textObj, width)
end

function v.backArrowListener(event)
    transitionOut()
end

function v.linkStatsLogo(viewObject, x)
    statsLogo = viewObject
    statsLogoX = x
end

function v.linkLineGroup(viewObjectTable)
    lineGroup = viewObjectTable
end

function v.linkTextGroup(viewObjectTable)
    textGroup = viewObjectTable
end

function v.linkImageGroup(viewObjectTable)
    imageGroup = viewObjectTable
end

function v.linkIconGroup(viewObjectTable)
    iconGroup = viewObjectTable
end

return v
