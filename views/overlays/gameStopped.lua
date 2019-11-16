local cp = require( "composer" )
local g = require( "globalVariables" )
local widget = require( "widget" )
local Drop = require( "Drop" )
local json = require( "json" )
local social = require( "socialNetworks" )
local ld = require( "localData" )
local ads = require( "advertisements2" )

local scene = cp.newScene()

-- Precalls -----
local params = {}
local message
local resumeButton
local mainButton
local restartButton
local parentScene
local countdownImage1
local countdownImage2
local countdownImage3
local functionToCallOnHide
local transparentRect
local statsBG
local categoryText
local valuesText
local statsLine1
local statsLine2
local statsLine3
local highScoreText
local highTimeText
local twitter
local facebook
local statsFocal
local statsAreaH
local wh
local isPaused
local isGameOver
local score
local canRevive
-----------------

-- Local Functions ------------------------------------------------------------[
local function countdown()
    local interval = 750

    countdownImage1.alpha = 0.2
    countdownImage2.alpha = 0.2
    countdownImage3.alpha = 0.2
    countdownImage1.xScale, countdownImage1.yScale = 1, 1
    countdownImage2.xScale, countdownImage2.yScale = 1, 1
    countdownImage3.xScale, countdownImage3.yScale = 1, 1

    local function listener()
        transition.to( countdownImage1, { 
            time=200, 
            delay=interval, 
            alpha=0, 
            xScale=0.001, 
            yScale=0.001, 
            transition=easing.inBack
        })
        transition.to( countdownImage2, { 
            time=200, 
            delay=interval, 
            alpha=0, 
            xScale=0.001, 
            yScale=0.001,
            transition=easing.inBack
        })
        transition.to( countdownImage3, { 
            time=200, 
            delay=interval, 
            alpha=0, 
            xScale=0.001, 
            yScale=0.001,
            transition=easing.inBack,
        })
        transition.to( transparentRect, {
            time=200,
            delay=interval,
            alpha=0,
            onComplete = cp.hideOverlay
        })
    end

    transition.to( countdownImage1, {
        time = 50,
        delay = 1 * interval,
        alpha = 1
    })
    transition.to( countdownImage2, {
        time = 50,
        delay = 2 * interval,
        alpha = 1
    })
    transition.to( countdownImage3, {
        time = 50,
        delay = 3 * interval,
        alpha = 1,
        onComplete = listener
    })
end

local function transitionInPause()
    local function listener()
        resumeButton:setEnabled( true )
        mainButton:setEnabled( true )
        restartButton:setEnabled( true )
    end
    transition.to( message, {
        time = 200,
        x = display.contentCenterX,
        transition = easing.outQuad
    })
    transition.to( resumeButton, {
        time = 200,
        y = display.contentCenterY - 0.5 * resumeButton.height,
        transition = easing.outQuad
    })
    transition.to( mainButton, {
        time = 200,
        x = resumeButton.x - 0.5 * resumeButton.width,
        transition = easing.outQuad
    })
    transition.to( restartButton, {
        time = 200,
        x = resumeButton.x + 0.5 * resumeButton.width,
        transition = easing.outQuad,
        onComplete = listener()
    })
    transition.to( transparentRect, {
        time = 100,
        alpha = 0.5
    })
end

local function transitionOutPause()
    resumeButton:setEnabled( false )
    mainButton:setEnabled( false )
    restartButton:setEnabled( false )
    transition.to( resumeButton, { 
        time = 200, 
        y = 0, 
        transition = easing.inQuad, 
        onComplete = countdown 
    })
    transition.to( mainButton, { 
        time = 200, 
        x = -mainButton.width, 
        transition = easing.inQuad 
    })
    transition.to( restartButton, { 
        time = 200, 
        x = display.contentWidth + restartButton.width, 
        transition = easing.inQuad 
    } )
    transition.to( message, { 
        time = 200, 
        x = display.contentWidth + 0.5 * message.width, 
        transition = easing.outQuad 
    })
end

local function transitionInOver()
    transition.to( statsBG, { 
        time = 200, 
        y = statsFocal, 
        transition = easing.inQuad 
    })
    transition.to( categoryText, { 
        time = 200, 
        x = display.contentCenterX - 0.15 * wh, 
        transition = easing.inQuad 
    })
    transition.to( valuesText, { 
        time = 200, 
        x = display.contentCenterX + 0.15 * wh, 
        transition = easing.inQuad 
    })
    transition.to( statsLine1, { time=200, alpha=1 } )
    transition.to( statsLine2, { time=200, alpha=1 } )
    transition.to( statsLine3, { time=200, alpha=1 } )
    transition.to( highScoreText, { 
        time = 200, 
        y = statsFocal + statsAreaH * 0.75, 
        transition = easing.inQuad 
    })
    transition.to( highTimeText, { 
        time = 200, 
        y = statsFocal + statsAreaH * 0.75, 
        transition = easing.inQuad 
    })
    transition.to( twitter, { 
        time = 200, 
        y = statsFocal + 0.5 * statsAreaH, 
        transition = easing.inQuad } )
    transition.to( facebook, { 
        time = 100, 
        y = display.actualContentHeight, 
        transition = easing.inQuad 
    })
end

local function transitionOutOver()
    transition.to( statsBG, { 
        time = 200, 
        y = display.actualContentHeight, 
        transition = easing.inQuad 
    })
    transition.to( categoryText, { 
        time = 200, 
        x = 0,
        transition = easing.inQuad 
    })
    transition.to( valuesText, { 
        time = 200, 
        x = display.actualContentWidth, 
        transition = easing.inQuad 
    })
    transition.to( statsLine1, { time=200, alpha=0 } )
    transition.to( statsLine2, { time=200, alpha=0 } )
    transition.to( statsLine3, { time=200, alpha=0 } )
    transition.to( highScoreText, { 
        time = 200, 
        y = display.actualContentHeight + 0.5 * highScoreText.height, 
        transition = easing.inQuad 
    })
    transition.to( highTimeText, { 
        time = 200, 
        y = display.actualContentHeight + 0.5 * highTimeText.height, 
        transition = easing.inQuad 
    })
    transition.to( twitter, { 
        time = 200, 
        y = display.actualContentHeight, 
        transition = easing.inQuad } )
    transition.to( facebook, { 
        time = 100, 
        y = display.actualContentHeight + 2 * wh, 
        transition = easing.inQuad 
    })
end

local function socialListener( event )
    if event.target.id == "twitter" then
        social.shareResultsOnTwitter( score )
    elseif event.target.id == "facebook" then
        social.shareResultsOnFacebook( score )
    end
end

local function transitionOut()
    transitionOutPause()
    if not isPaused then
        transitionOutOver()
    end
end

local function resumeGame()
    functionToCallOnHide = parentScene.resumeGame
    transitionOut()
end

local function resumeListener()
    if isPaused then
        resumeGame()
    elseif isGameOver and canRevive then
        -- ask for confirmation?
        ld.addLives( -1 )
        functionToCallOnHide = parentScene.startGame --Should this be resumeGame?
        transitionOut()
    elseif isGameOver and not canRevive then
        -- purchase more lives
    end
end

local function restartListenerAfterAd()
    Drop:deleteAllWithAnimation()
    parentScene:gameIsActuallyOver()
    transitionOut()
end

local function restartListener()
    functionToCallOnHide = parentScene.startGame
    ads.show( false, restartListenerAfterAd )
end

local function mainListenerAfterAd()
    parentScene:gameIsActuallyOver()
    cp.gotoScene( "views/scenes/center" )
end

local function mainListener()
    ads.show( false, mainListenerAfterAd )
end
-------------------------------------------------------------------------------]

function scene:create( event )
    local group = self.view

    -- Message ----------------------------------------------------------------[
    local messageOptions = {
        parent = group,
        text = "Game Paused",
        x = 0,
        y = 0.25 * display.actualContentHeight,
        width = display.actualContentWidth,
        font = g.comLight,
        fontSize = 100,
        align = "center"
    }
    message = display.newText( messageOptions )
    message.x = -0.5 * message.width
    message:setFillColor( unpack( g.purple ) )
    message.anchorY = 0.5
    ---------------------------------------------------------------------------]
    
    -- Buttons ----------------------------------------------------------------[
    resumeButton = widget.newButton {
        id = "resume",
        width = 550,
        height = 100,
        defaultFile = "images/buttonGreen.png",
        label = "Resume",
        labelYOffset = 8,
        labelColor = { default={ 0, 0.5, 0.36 }, over={ 0, 0.5, 0.36, 0.7 } },
        font = g.comLight,
        fontSize = 59,
        isEnabled = false,
        onRelease = resumeListener,
    }
    group:insert( resumeButton )
    resumeButton.x = display.contentCenterX
    resumeButton.y = 0
    resumeButton.anchorY = 1

    mainButton = widget.newButton {
        id = "main",
        width = 250,
        height = 100,
        defaultFile = "images/buttonRed.png",
        label = "Main",
        labelYOffset = 8,
        labelColor = { default={ 0.63, 0.10, 0.14 }, over={ 0.63, 0.10, 0.14, 0.7 } },
        font = g.comLight,
        fontSize = 50,
        isEnabled = false,
        onRelease = mainListener,
    }
    group:insert( mainButton )
    mainButton.x = -mainButton.width
    mainButton.y = display.contentCenterY
    mainButton.anchorX = 0 
    mainButton.anchorY = 0
    
    restartButton = widget.newButton {
        id = "restart",
        width = 250,
        height = 100,
        defaultFile = "images/buttonBlue.png",
        label = "Restart",
        labelYOffset = 8,
        labelColor = { default={ 0.11, 0.46, 0.74 }, over={ 0.11, 0.46, 0.74, 0.7 } },
        font = g.comLight,
        fontSize = 50,
        isEnabled = false,
        onRelease = restartListener,
    }
    group:insert( restartButton )
    restartButton.x = display.contentWidth + restartButton.width
    restartButton.y = mainButton.y
    restartButton.anchorX = 1
    restartButton.anchorY = 0
    ---------------------------------------------------------------------------]

    -- Countdown Images -------------------------------------------------------[
    countdownImage1 = display.newImageRect( group, "images/dropletYellow.png", 220, 330 )
    countdownImage2 = display.newImageRect( group, "images/dropletYellow.png", 220, 330 )
    countdownImage3 = display.newImageRect( group, "images/dropletGreen.png", 220, 330 )
    
    countdownImage1.x = display.contentCenterX
    countdownImage2.x = countdownImage1.x
    countdownImage3.x = countdownImage1.x
    
    countdownImage2.y = display.contentCenterY
    countdownImage1.y = countdownImage2.y - countdownImage1.height * 1.1
    countdownImage3.y = countdownImage2.y + countdownImage3.height * 1.1
    
    countdownImage1.alpha = 0
    countdownImage2.alpha = 0
    countdownImage3.alpha = 0
    ---------------------------------------------------------------------------]

    -- Opaque Rectangle for pause/end -----------------------------------------[
    transparentRect = display.newRect( 
        group, 
        display.contentCenterX, 
        display.contentCenterY, 
        display.actualContentWidth, 
        display.actualContentHeight 
    )
    transparentRect.blueFill = { 0, 0.65, 1 }
    transparentRect.redFill = { 1, 0, 0.15 }
    transparentRect.alpha = 0
    transparentRect:toBack()
    ---------------------------------------------------------------------------]
    
    statsFocal = mainButton.y + 1.5 * mainButton.height
    statsAreaH = display.actualContentHeight - statsFocal
    wh = 0.25 * statsAreaH

    -- Game Over Lines and Background -----------------------------------------[
    statsBG = display.newImageRect( group, "images/statsBG.jpg", 800, 800)
    statsBG.x = display.contentCenterX
    statsBG.y = display.actualContentHeight
    statsBG.anchorY = 0
    statsBG.height = statsAreaH
    statsBG.width = display.actualContentWidth
    statsBG.alpha = 0.8

    statsLine1 = display.newLine( 
        group, 
        0, 
        statsFocal + 0.5 * statsAreaH, 
        display.contentWidth, 
        statsFocal + 0.5 * statsAreaH
    )
    statsLine1:setStrokeColor( unpack( g.purple ) )
    statsLine1.strokeWidth = 2
    statsLine1.alpha = 0
    
    statsLine2 = display.newLine( 
        group, 
        display.contentCenterX - 0.5 * wh, 
        statsFocal + 0.5 * statsAreaH, 
        display.contentCenterX - 0.5 * wh, 
        display.actualContentHeight 
    )
    statsLine2:setStrokeColor( unpack( g.purple ) )
    statsLine2.strokeWidth = 2
    statsLine2.alpha = 0
    
    statsLine3 = display.newLine( 
        group, 
        display.contentCenterX + 0.5 * wh, 
        statsFocal + 0.5 * statsAreaH, 
        display.contentCenterX + 0.5 * wh, 
        display.contentHeight 
    )
    statsLine3:setStrokeColor( unpack( g.purple ) )
    statsLine3.strokeWidth = 2
    statsLine3.alpha = 0
    ---------------------------------------------------------------------------]
    
    -- Game Over Stat Text ----------------------------------------------------[
    categoryText = display.newText({
        parent = group,
        text = "Score:\nTime:",
        x = 0,
        y = statsFocal + 0.25 * statsAreaH,
        font = g.comRegular,
        fontSize = 85,
        align = "right"
    })
    categoryText:setFillColor( unpack( g.orange ) )
    categoryText.anchorX = 1

    valuesText = display.newText({
        parent = group,
        text = " ",
        x = display.actualContentWidth,
        y = categoryText.y,
        font = g.comRegular,
        fontSize = 85,
        align = "left"
    })
    valuesText:setFillColor( unpack( g.orange ) )
    valuesText.anchorX = 0

    highScoreText = display.newText({
        parent = group,
        text = "High Score\n• • •\n",
        width = 0.5 * (display.actualContentWidth - wh),
        height = 0,
        x = 0.5 * statsLine2.x,
        font = g.comRegular,
        fontSize = 40,
        align = "center"
    })
    highScoreText:setFillColor( unpack( g.purple ) ) 
    highScoreText.y = display.actualContentHeight + 0.5 * highScoreText.height

    highTimeText = display.newText({ 
        parent = group,
        text = "High Time\n• • •\n",
        width = highScoreText.width,
        height = 0,
        x = display.actualContentWidth - highScoreText.x,
        font = g.comRegular,
        fontSize = 40,
        align = "center",
    })
    highTimeText:setFillColor( unpack( g.purple ) )
    highTimeText.y = highScoreText.y
    ---------------------------------------------------------------------------]
    
    -- Socail Button ----------------------------------------------------------[
    twitter = widget.newButton{
        id = "twitter",
        x = display.contentCenterX,
        y = display.actualContentHeight,
        width = wh,
        height = wh,
        defaultFile = "images/twitter.png",
        overFile = "images/twitterD.png",
        onRelease = socialListener,
    } 
    group:insert( twitter )
    twitter.anchorY = 0
    
    facebook = widget.newButton{
        id = "facebook",
        x = display.contentCenterX,
        y = twitter.y + 2 * wh,
        width = wh,
        height = wh,
        defaultFile = "images/facebook.png",
        overFile = "images/facebookD.png",
        onRelease = socialListener
    } 
    group:insert( facebook )
    facebook.anchorY = 1
    ---------------------------------------------------------------------------]
end

function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    parentScene = event.parent
 
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then

        functionToCallOnHide = nil
        isPaused = event.params.isPaused
        isGameOver = not isPaused
        canRevive = ld.getInvincibility() > 0
        score = event.params.scoreText
        valuesText.text = score .. "\n" .. event.params.timeText

        transitionInPause()

        if isPaused then
            transparentRect:setFillColor( unpack(transparentRect.blueFill) )
            message.text = "Game Paused"
            resumeButton:setLabel( "Resume" )
        else
            transparentRect:setFillColor( unpack(transparentRect.redFill) )
            message.text = "Game Over"
            transitionInOver()
        end

        if isGameOver and canRevive then
            resumeButton:setLabel( "Revive" )
        elseif isGameOver and not canRevive then
            resumeButton:setLabel( "Purchase Lives" )
        end

    end
end

function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then 
    elseif ( phase == "did" ) then
        if functionToCallOnHide then 
            functionToCallOnHide()
        end
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene