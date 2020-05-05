-------------------------------------------------------------------------------
-- Private Members ------------------------------------------------------------
-------------------------------------------------------------------------------
-- Imports
local cp = require("composer")

-- View Objects
local musicLogo
local jeg
local lineTop
local lineBottom
local bio

---------------------------------------------------------------------
-- Transitions ------------------------------------------------------
---------------------------------------------------------------------
local function transitionIn()
    transition.to( musicLogo, { time=500, x=musicLogo.xIn, transition=easing.outSine } )
    transition.to( lineTop, {time=600, x=lineTop.xIn, transition=easing.outSine})
    transition.to( lineBottom, {time=600, x=lineBottom.xIn})
    transition.to( jeg, {time=500, alpha=jeg.alphaIn})
    transition.to( bio, {time=500, alpha=bio.alphaIn})
end

local function transitionOutListener()
    cp.gotoScene( "views.scenes.extras" )
end

local function transitionOut()
    transition.to( musicLogo, {time=500, x=musicLogo.xOut, transition=easing.inSine})
    transition.to( lineTop, {time=600, x=lineTop.xOut, onComplete=transitionOutListener})
    transition.to( lineBottom, {time=600, x=lineBottom.xOut})
    transition.to( jeg, {time=500, alpha=jeg.alphaOut})
    transition.to( bio, {time=500, alpha=bio.alphaOut})
end

---------------------------------------------------------------------
-- Other Logic ------------------------------------------------------
---------------------------------------------------------------------

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

function v.backArrowListener()
    print( "Back Arrow pressed" )
    transitionOut()
end

function v.linkMusicLogo(viewObject)
    musicLogo = viewObject
end

function v.linkJEG(viewObject)
    jeg = viewObject
end

function v.linkLineTop(viewObject)
    lineTop = viewObject
end

function v.linkLineBottom(viewObject)
    lineBottom = viewObject
end

function v.linkBio(viewObject)
    bio = viewObject
end

return v