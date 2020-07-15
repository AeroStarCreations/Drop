-- Private Members ------------------------------------------------------------[
local cp = require( "composer" )
local ads = require( "other.advertisements2" )
local Drop = require( "views.other.Drop" )
local ld = require( "data.localData" )
local social = require( "other.socialNetworks" )
local model = require( "models.gameStoppedModel" )
local metrics = require("other.metrics")
local stringUtils = require("other.stringUtils")
local colors = require("other.colors")

local TAG = "gameStoppedController:"

local transitionMaxTime = 200
local backgroundImage
local parentScene
local sceneHideCallback
local isGamePaused
local scoreValue
local timeValue
local valuesText
local messageText

----------------------------------------------------------------
-- Countdown Logic --
----------------------------------------------------------------
local countdownImageGroup = {}
local countdownInterval = 750

local countdownDropsTransitionOutOptions = {
    time = transitionMaxTime,
    delay = countdownInterval,
    alpha = 0,
    xScale = 0.001,
    yScale = 0.001,
    transition = easing.inBack
}

local countdownDropsTransitionInOptions = {
    time = 50,
    delay = countdownInterval,
    alpha = 1,
    onComplete = nil
}

local overlayBackgroundTransitionOutOptions = {
    time = transitionMaxTime,
    delay = countdownInterval,
    alpha = 0
    -- onComplete = set in v.beginCountdown()
}

local function showCountdown()
    for _, image in pairs(countdownImageGroup) do
        image.alpha = 0.2
        image.xScale, image.yScale = 1, 1
    end
end

local function hideCountdownDrops()
    for _, image in pairs(countdownImageGroup) do
        transition.to( image, countdownDropsTransitionOutOptions)
    end
end

local function hideCountdownBackground()
    transition.to( backgroundImage, overlayBackgroundTransitionOutOptions)
    local time = overlayBackgroundTransitionOutOptions.time + overlayBackgroundTransitionOutOptions.delay
    timer.performWithDelay(time, cp.hideOverlay)
end

local function hideCountdown()
    hideCountdownDrops()
    hideCountdownBackground()
end

local function beginCountdown()
    showCountdown()

    local delay = countdownDropsTransitionInOptions.delay
    for index = 1, #countdownImageGroup do
        countdownDropsTransitionInOptions.delay = index * delay
        -- print(TAG, "delay = " .. countdownDropsTransitionInOptions.delay)
        if (index == #countdownImageGroup) then
            countdownDropsTransitionInOptions.onComplete = hideCountdown
        end
        transition.to( countdownImageGroup[index], countdownDropsTransitionInOptions )
    end
    countdownDropsTransitionInOptions.delay = delay
    countdownDropsTransitionInOptions.onComplete = nil
end

----------------------------------------------------------------
-- Transition Logic --
----------------------------------------------------------------
local gamePausedObjects = {}
local gameOverObjects = {}
local buttonGroup = {}

local function setButtonsEnabled( enabled )
    for _, button in pairs(buttonGroup) do
        button:setEnabled( enabled )
    end
end

local function transitionInPause()
    for _, object in pairs(gamePausedObjects) do
        transition.to( object, {
            time = transitionMaxTime,
            x = object.xIn,
            y = object.yIn,
            transition = easing.outQuad
        })
    end
    transition.to( backgroundImage, {
        time = 100,
        alpha = 0.5
    })
    timer.performWithDelay( transitionMaxTime, setButtonsEnabled(true) )
end

local function transitionOutPause()
    setButtonsEnabled(false)
    for _, object in pairs(gamePausedObjects) do
        transition.to( object, {
            time = transitionMaxTime,
            x = object.xOut,
            y = object.yOut,
            transition = easing.inQuad
        })
    end
    timer.performWithDelay(
        transitionMaxTime,
        -- beginCountdown()
        beginCountdown(cp.hideOverlay)
    )
end

local function transitionInOver()
    for _, object in pairs(gameOverObjects) do
        if (object.shouldFade) then
            transition.to( object, {
                time = transitionMaxTime,
                alpha = 1
            })
        else
            transition.to( object, {
                time = transitionMaxTime,
                x = object.xIn,
                y = object.yIn,
                transition = easing.inQuad
            })
        end
    end
    -- facebook transition was 100
end

local function transitionOutOver()
    for _, object in pairs(gameOverObjects) do
        if (object.shouldFade) then
            transition.to( object, {
                time = transitionMaxTime,
                alpha = 0
            })
        else
            transition.to( object, {
                time = transitionMaxTime,
                x = object.xOut,
                y = object.yOut,
                transition = easing.inQuad
            })
        end
    end
    -- facebook transition was 100
end

local function transitionOut()
    transitionOutPause()
    if (not isGamePaused) then
        transitionOutOver()
    end
end

----------------------------------------------------------------
-- Button Logic --
----------------------------------------------------------------
local function mainButtonListenerAfterAd()
    parentScene:gameIsActuallyOver()
    cp.gotoScene( "views.scenes.center" )
end

local function mainButtonListener()
    ads.showNormalAd(mainButtonListenerAfterAd)
    metrics.logEvent("gameStopped_main_click")
end

local function restartButtonListenerAfterAd()
    Drop:deleteAllWithAnimation()
    parentScene:gameIsActuallyOver()
    transitionOut()
end

local function restartButtonListener()
    sceneHideCallback = parentScene.startGame
    ads.showNormalAd(restartButtonListenerAfterAd)
    metrics.logEvent("gameStopped_restart_click")
end

local function resumeGame()
    sceneHideCallback = parentScene.resumeGame
    transitionOut()
end

local function playerCanRevive()
    return ld.getInvincibility() > 0
end

local function reviveAndResumeGame()
    -- ask for confirmation?
    ld.addLives( -1 )
    sceneHideCallback = parentScene.resumeGame
    transitionOut()
end

local function resumeButtonListener()
    if (isGamePaused) then
        resumeGame()
        metrics.logEvent("gameStopped_resume_click")
    elseif (playerCanRevive()) then
        reviveAndResumeGame()
        metrics.logEvent("gameStopped_revive_click")
    elseif (not playerCanRevive()) then
        --TODO: purchase more lives
    end
end

local function socialButtonListener( event )
    if event.target.id == "twitter" then
        social.shareResultsOnTwitter( scoreValue )
        metrics.logEvent("gameStopped_facebook_click")
    elseif event.target.id == "facebook" then
        social.shareResultsOnFacebook( scoreValue )
        metrics.logEvent("gameStopped_twitter_click")
    end
end

----------------------------------------------------------------
-- Other Logic --
----------------------------------------------------------------
local function transitionAndSetupSceneBasedOnGameState()
    if (isGamePaused) then
        backgroundImage:setFillColor( unpack(backgroundImage.blueFill) )
        messageText.text = model.getGamePausedText()
        buttonGroup["resume"]:setLabel( model.getResumeLabel() )
    else
        backgroundImage:setFillColor( unpack(backgroundImage.redFill) )
        messageText.text = model.getGameOverText()
        transitionInOver()
        if (playerCanRevive()) then
            buttonGroup["resume"]:setLabel( model.getReviveLabel() )
        else
            buttonGroup["resume"]:setLabel( model.getPurchaseLabel() )
        end
    end
end

local function getHighScoreText()
    local key = "HighScore"
    if not ld.getSpecialDropsEnabled then
        key = key.."Tricky"
    end
    local label = model.getHighScoreText()
    local score = ld.getHighScore(key)
    return label..stringUtils.addCommasToNumber(score)
end

local function getHighTimeText()
    local key = "HighTime"
    if not ld.getSpecialDropsEnabled then
        key = key.."Tricky"
    end
    local label = model.getHighTimeText()
    local time = ld.getHighScore(key)
    return label..stringUtils.formatTime(time)
end

-- Public Members -------------------------------------------------------------[
local v = {}

----------------------------------------------------------------
-- Countdown Methods --
----------------------------------------------------------------
function v.beginCountdown( onComplete )
    overlayBackgroundTransitionOutOptions.onComplete = onComplete
    beginCountdown()
end

function v.connectCountdownImage( image, index )
    if (countdownImageGroup[index] ~= nil) then
        table.remove( countdownImageGroup, index )
    end
    table.insert( countdownImageGroup, index, image )
end

function v.connectBackgroundImage( image )
    backgroundImage = image
end

----------------------------------------------------------------
-- Transition Methods --
----------------------------------------------------------------
function v.addGamePausedObject( object )
    gamePausedObjects[object.id] = object
end

function v.addGameOverObject( object )
    gameOverObjects[object.id] = object
end

function v.transitionInPause()
    transitionInPause()
end

function v.transitionOutPause()
    transitionOutPause()
end

function v.transitionInOver()
    transitionInOver()
end

function v.transitionOutOver()
    transitionOutOver()
end

----------------------------------------------------------------
-- Button Methods --
----------------------------------------------------------------
function v.addButton( button )
    buttonGroup[button.id] = button
end

function v.mainButtonListener()
    mainButtonListener()
end

function v.restartButtonListener()
    restartButtonListener()
end

function v.resumeButtonListener()
    resumeButtonListener()
end

function v.socialButtonListener( event )
    socialButtonListener( event )
end

----------------------------------------------------------------
-- Other Methods --
----------------------------------------------------------------
function v.setParentScene( scene )
    parentScene = scene
end

function v.sceneHideCallback()
    if (sceneHideCallback ~= nil) then
        sceneHideCallback()
    end
end

function v.setSceneHideCallback( callback )
    sceneHideCallback = callback
end

function v.setGamePaused( isPaused )
    isGamePaused = isPaused
end

function v.setValues( scoreText, timeText )
    scoreValue = scoreText
    timeValue = timeText
    valuesText.text = scoreText.."\n"..timeText
end

function v.linkValuesText( object )
    valuesText = object
end

function v.linkMessageText( object )
    messageText = object
end

function v.transitionAndSetupSceneBasedOnGameState()
    transitionAndSetupSceneBasedOnGameState()
end

function v.getMainButtonLabel()
    return model.getMainButtonLabel()
end

function v.getRestartButtonLabel()
    return model.getRestartButtonLabel()
end

function v.getCategoryText()
    return model.getCategoryText()
end

function v.getHighScoreText()
    return getHighScoreText()
end

function v.getHighTimeText()
    return getHighTimeText()
end

return v