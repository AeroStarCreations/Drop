-------------------------------------------------------------------------------
-- Private Members ------------------------------------------------------------
-------------------------------------------------------------------------------
-- Imports
local cp = require("composer")

-- View Objects
local ascLogo
local drop
local backArrow
local asc
local lineTop
local lineBottom
local bio
local facebook
local twitter

---------------------------------------------------------------------
-- Transitions ------------------------------------------------------
---------------------------------------------------------------------
local function transitionIn()
    transition.to( ascLogo, { time=500, x=asc.xIn, transition=easing.outSine } )
    transition.to( lineTop, {time=600, x=lineTop.xIn, transition=easing.outSine})
    transition.to( lineBottom, {time=600, x=lineBottom.xIn})
    transition.to( asc, {time=500, alpha=asc.alphaIn})
    transition.to( bio, {time=500, alpha=bio.alphaIn})
    transition.to( facebook, { time=600, x=facebook.xIn, transition=easing.outQuad } )
    transition.to( twitter, { time=600, x=twitter.xIn, transition=easing.outQuad } )
end

local function transitionOutListener()
    cp.gotoScene( "views.scenes.extras" )
end

local function transitionOut()
    transition.to( ascLogo, {time=500, x=ascLogo.xOut, transition=easing.inSine})
    transition.to( lineTop, {time=600, x=lineTop.xOut, onComplete=transitionOutListener})
    transition.to( lineBottom, {time=600, x=lineBottom.xOut})
    transition.to( asc, {time=500, alpha=asc.alphaOut})
    transition.to( bio, {time=500, alpha=bio.alphaOut})
    transition.to( facebook, { time=600, x=facebook.xOut, transition=easing.outQuad } )
    transition.to( twitter, { time=600, x=twitter.xOut, transition=easing.outQuad } )
end

---------------------------------------------------------------------
-- Other Logic ------------------------------------------------------
---------------------------------------------------------------------
local function backArrowListener(event)
    print( "Back Arrow pressed" )
    transitionOut()
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

function v.backArrowListener()
    backArrowListener()
end

function v.linkDrop(viewObject)
    drop = viewObject
end

function v.linkBackArrow(viewObject)
    backArrow = viewObject
end

function v.linkASCLogo(viewObject)
    ascLogo = viewObject
end

function v.linkASC(viewObject)
    asc = viewObject
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

function v.linkFacebook(viewObject)
    facebook = viewObject
end

function v.linkTwitter(viewObject)
    twitter = viewObject
end

return v