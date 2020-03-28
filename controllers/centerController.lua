-------------------------------------------------------------------------------
-- Private Members ------------------------------------------------------------
-------------------------------------------------------------------------------
-- Imports
local logoModule = require( "other.logoModule" )
local cp = require( "composer" )
local ld = require( "data.localData" )
local bg = require( "controllers.backgroundController" )
local Alert = require( "views.other.Alert" )

-- View Objects
local asc
local drop
local arrow
local facebook
local twitter
local settings
local extras
local achievementButton
local livesImage
local livesText
local invincibilityImage
local invincibilityText
local rewardLives = 0
local rewardInvincibilites = 0
local distFromCenterX = display.actualContentWidth / 7

---------------------------------------------------------------------
-- Other Logic ------------------------------------------------------
---------------------------------------------------------------------
local function setRotation( event )
    local r = -event.xGravity * 90
    facebook.rotation = r
    twitter.rotation = r
    drop.rotation = -event.xGravity * 25
    return true
end

local function addRotationListener()
    Runtime:addEventListener( "accelerometer", setRotation )
end

local function setButtonsEnabled( isEnabled )
    arrow:setEnabled( isEnabled )
    facebook:setEnabled( isEnabled )
    twitter:setEnabled( isEnabled )
    extras:setEnabled( isEnabled )
    settings:setEnabled( isEnabled )
end

local function getArrowRotation()
    if math.random() < 0.5 then
        return arrow.rotation - 90
    end
    return arrow.rotation + 270
end

local function goToScene( scene )
    if scene == "game" then
        cp.gotoScene( "views.scenes.game2" )
    elseif scene == "extras" then
        cp.gotoScene( "views.scenes.extras" )
    elseif scene == "settings" then
        cp.gotoScene( "views.scenes.settings" )
    end
end

local function gameWasJustOpened()
    return arrow.xScale < arrow.xScaleOut
end

local function updateRewardTexts()
    livesText.text = "+" .. rewardLives
    invincibilityText.text = "+" .. rewardInvincibilites
end

local function updateRewardPosition()
    if rewardLives == 0 then
        invincibilityImage.x = display.contentCenterX
        invincibilityText.x = invincibilityImage.x
    elseif rewardInvincibilites == 0 then
        livesImage.x = display.contentCenterX
        livesText.x = livesImage.x
    else
        invincibilityImage.x = display.contentCenterX - distFromCenterX
        invincibilityText.x = invincibilityImage.x
        livesImage.x = display.contentCenterX + distFromCenterX
        livesText.x = livesImage.x
    end
end

local function setRewardScales()
    livesImage.xScale = 0.01
    livesImage.yScale = 0.01
    livesText.xScale = 0.01
    livesText.yScale = 0.01
    invincibilityImage.xScale = 0.01
    invincibilityImage.yScale = 0.01
    invincibilityText.xScale = 0.01
    invincibilityText.yScale = 0.01
end

local function setRewardAlpha()
    livesImage.alpha = 1
    livesText.alpha = 1
    invincibilityImage.alpha = 1
    invincibilityText.alpha = 1
end

local function playAnimation()
    local paramsIn = {time=300, xScale=1.3, yScale=1.3, transition=easing.outBack}
    local paramsOut = {delay=paramsIn.time+1000, time=200, xScale=4, yScale=4, alpha=0}
    if rewardLives > 0 then
        transition.to( livesImage, paramsIn )
        transition.to( livesText, paramsIn )
        transition.to( livesImage, paramsOut )
        transition.to( livesText, paramsOut)
    end
    if rewardInvincibilites > 0 then
        transition.to( invincibilityImage, paramsIn )
        transition.to( invincibilityText, paramsIn )
        transition.to( invincibilityImage, paramsOut )
        transition.to( invincibilityText, paramsOut )
    end
end

local function showRewardAnimation()
    updateRewardTexts()
    updateRewardPosition()
    setRewardScales()
    setRewardAlpha()
    playAnimation()
end

<<<<<<< HEAD
local function transitionOutAchievementButton()
    transition.to( achievementButton, { time=400, delay=400, xScale=0.01, yScale=0.01, transition=easing.inBack } )
end

=======
>>>>>>> refactored center scene
local function achievementListener( event )
    -- Get achievement reward from ld
    local reward = ld.getUnawardedAchievementReward()
    --Credit awards
    rewardLives = reward.lives
    rewardInvincibilites = reward.invincibilities
    ld.addLives( rewardLives )
    ld.addInvincibility( rewardInvincibilites )
    --Display achievement
    local alert = Alert:new( "Congrats!", reward.description, { "Claim!" }, showRewardAnimation )
    --Update achievementButton
    achievementButton:setLabel( ld.quantityUnawardedAchievements() )
    if not ld.hasUnawardedAchievement() then transitionOutAchievementButton() end
end

---------------------------------------------------------------------
-- Transitions ------------------------------------------------------
---------------------------------------------------------------------
local function arrowCheck( event )
    if arrow.x ~= display.contentCenterX+17 then
        arrow.x = -arrow.width
        transition.to( arrow, { time=800, transition=easing.outQuad, x=display.contentCenterX+17, onComplete=arrowCheck } )
    end
end

local function transitionIn()
    local logoY = logoModule.getBigLogoY(arrow)

    local function onComplete()
        setButtonsEnabled(true)
        addRotationListener()
    end
    
    transition.to( asc, { time=400, y=asc.yIn, transition=easing.outQuad } )
    transition.to( drop, { time=700, y=logoY, transition=easing.outQuad, xScale=drop.xScaleIn, yScale=drop.yScaleIn--[[, rotation=0--]], onComplete=onComplete } )
    transition.to( facebook, { time=700, x=facebook.xIn, transition=easing.outQuad } )
    transition.to( twitter, { time=700, x=twitter.xIn, transition=easing.outQuad } )
    transition.to( extras, { time=600, x=extras.xIn, y=extras.yIn, transition=easing.outQuad } )
    transition.to( settings, { time=600, x=settings.xIn, y=settings.yIn, transition=easing.outQuad } )
    
    if ld.hasUnawardedAchievement() then
<<<<<<< HEAD
        transition.to( achievementButton, { delay=300, time=300, xScale=1, yScale=1, transition=easing.outBack } )
=======
        -- transition.to( achievementButton, { delay=300, time=300, xScale=1, yScale=1, transition=easing.outBack } )
>>>>>>> refactored center scene
    end
    
    if gameWasJustOpened() then
        transition.to( arrow, { time=900, xScale=arrow.xScaleIn, yScale=arrow.yScaleIn, transition=easing.outBack } )
    elseif cp.getSceneName( "previous" ) == "views.scenes.game2" then --TODO: or gameStopped ???
        arrow.x = g.arrowX
        transition.to( arrow, { time=1200, transition=easing.outBack, x=arrow.xIn, y=arrow.yIn, xScale=arrow.xScaleIn, yScale=arrow.yScaleIn, rotation=0 })
    else
        arrow.x = -arrow.width
        transition.to( arrow, { time=800, transition=easing.outQuad, x=arrow.xIn, onComplete=arrowCheck } )
    end

    if ld.getChangingBackgroundsEnabled() then
        bg.fadeOutToDefault()
    end
end

local function transitionOut( scene )
    setButtonsEnabled(false)

    local function finishListener()
        goToScene(scene)
    end

    if scene == "game" then
        transition.to( asc, { time=400, delay=800, y=asc.yOut, transition=easing.inQuad } )
<<<<<<< HEAD
        transition.to( drop, { time=700, y=drop.yOutToGame, transition=easing.inQuad } )
=======
        transition.to( drop, { time=700, y=-drop.yOutToGame, transition=easing.inQuad } )
>>>>>>> refactored center scene
        transition.to( arrow, { time=2000, transition=easing.inOutBack, x=arrow.xOutToGame, y=arrow.yOut, xScale=arrow.xScaleOut, yScale=arrow.yScaleOut, rotation=getArrowRotation(), onComplete=finishListener })
        transition.to( facebook, { time=700, delay=500, x=facebook.xOut, transition=easing.inQuad } )
        transition.to( twitter, { time=700, delay=500, x=twitter.xOut, transition=easing.inQuad } )
        transition.to( extras, { time=600, delay=800, x=extras.xOut, y=extras.yOut, transition=easing.inQuad } )
        transition.to( settings, { time=600, delay=800, x=settings.xOut, y=settings.yOut, transition=easing.inQuad } )
    else
        transition.to( asc, { time=400, delay=400, y=asc.yOut, transition=easing.inQuad } )
        transition.to( drop, { time=500, delay=300, y=drop.yOut, transition=easing.inQuad, xScale=drop.xScaleOut, yScale=drop.yScaleOut, rotation=0 } )
        transition.to( arrow, { time=800, transition=easing.inQuad, x=arrow.xOut, onComplete=finishListener } )
        transition.to( facebook, { time=700, delay=100, x=facebook.xOut, transition=easing.inQuad } )
        transition.to( twitter, { time=700, delay=100, x=twitter.xOut, transition=easing.inQuad } )
        transition.to( extras, { time=600, delay=200, x=extras.xOut, y=extras.yOut, transition=easing.inQuad } )
        transition.to( settings, { time=600, delay=200, x=settings.xOut, y=settings.yOut, transition=easing.inQuad } )
    end

<<<<<<< HEAD
    transitionOutAchievementButton()
=======
    -- transitionOutAchievementButton()
>>>>>>> refactored center scene
end

-------------------------------------------------------------------------------
-- Public Members -------------------------------------------------------------
-------------------------------------------------------------------------------
local v = {}

function v.linkASC(viewObject)
    asc = viewObject
end

function v.linkDrop(viewObject)
    drop = viewObject
end

function v.linkArrow(viewObject)
    arrow = viewObject
end

function v.linkFacebook(viewObject)
    facebook = viewObject
end

function v.linkTwitter(viewObject)
    twitter = viewObject
end

function v.linkSettings(viewObject)
    settings = viewObject
end

function v.linkExtras(viewObject)
    extras = viewObject
end

function v.linkAchievementButton(viewObject)
    achievementButton = viewObject
end

function v.linkLivesImage(viewObject)
    livesImage = viewObject
end

function v.linkLivesText(viewObject)
    livesText = viewObject
end

function v.linkInvincibilityImage(viewObject)
    invincibilityImage = viewObject
end

function v.linkInvincibilityText(viewObject)
    invincibilityText = viewObject
end

function v.arrowListener(event)
    Runtime:removeEventListener( "accelerometer", setRotation )
    transitionOut("game")
end

function v.extrasListener(event)
    transitionOut("extras")
end

function v.settingsListener(event)
    transitionOut("settings")
end

function v.achievementButtonListener(event)
    achievementListener()
end

function v.transitionIn()
    transitionIn()
end

function v.transitionOut()
    transitionOut()
end

return v