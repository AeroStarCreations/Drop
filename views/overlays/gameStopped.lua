local cp = require( "composer" )
local g = require( "other.globalVariables" )
local widget = require( "widget" )
local controller = require( "controllers.gameStoppedController" )
local fonts = require("other.fonts")
local colors = require("other.colors")

local scene = cp.newScene()

-- Precalls -----
local params = {}
local message
local resumeButton
local mainButton
local restartButton
local countdownImage1
local countdownImage2
local countdownImage3
local overlayBG
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
-----------------

function scene:create( event )
    local group = self.view

    -- Message ----------------------------------------------------------------[
    local messageOptions = {
        parent = group,
        text = "",
        width = display.actualContentWidth,
        font = fonts.getLight(),
        fontSize = 100,
        align = "center"
    }
    message = display.newText( messageOptions )
    message.xIn = display.contentCenterX
    message.xOut = -0.5 * message.width
    message.yIn = 0.25 * display.actualContentHeight
    message.yOut = 0.25 * display.actualContentHeight
    message.x = message.xOut
    message.y = message.yOut
    message:setFillColor( unpack( colors.purple ) )
    message.anchorY = 0.5
    message.id = "message"
    controller.addGamePausedObject( message )
    controller.linkMessageText( message )
    ---------------------------------------------------------------------------]

    -- Buttons ----------------------------------------------------------------[
    resumeButton = widget.newButton {
        id = "resume",
        width = 550,
        height = 100,
        defaultFile = "images/buttonGreen.png",
        labelYOffset = 8,
        labelColor = { default={ 0, 0.5, 0.36 }, over={ 0, 0.5, 0.36, 0.7 } },
        font = fonts.getLight(),
        fontSize = 59,
        isEnabled = false,
        onRelease = controller.resumeButtonListener
    }
    group:insert( resumeButton )
    resumeButton.xIn = display.contentCenterX
    resumeButton.xOut = display.contentCenterX
    resumeButton.yIn = display.contentCenterY - 0.5 * resumeButton.height
    resumeButton.yOut = 0
    resumeButton.x = resumeButton.xOut
    resumeButton.y = resumeButton.yOut
    resumeButton.anchorY = 1
    controller.addGamePausedObject( resumeButton )
    controller.addButton( resumeButton )

    mainButton = widget.newButton {
        id = "main",
        width = 250,
        height = 100,
        defaultFile = "images/buttonRed.png",
        label = controller.getMainButtonLabel(),
        labelYOffset = 8,
        labelColor = { default={ 0.63, 0.10, 0.14 }, over={ 0.63, 0.10, 0.14, 0.7 } },
        font = fonts.getLight(),
        fontSize = 50,
        isEnabled = false,
        onRelease = controller.mainButtonListener
    }
    group:insert( mainButton )
    mainButton.xIn = resumeButton.x - 0.5 * resumeButton.width
    mainButton.xOut = -mainButton.width
    mainButton.yIn = display.contentCenterY
    mainButton.yOut = display.contentCenterY
    mainButton.x = mainButton.xOut
    mainButton.y = mainButton.yOut
    mainButton.anchorX = 0
    mainButton.anchorY = 0
    controller.addGamePausedObject( mainButton )
    controller.addButton( mainButton )

    restartButton = widget.newButton {
        id = "restart",
        width = 250,
        height = 100,
        defaultFile = "images/buttonBlue.png",
        label = controller.getRestartButtonLabel(),
        labelYOffset = 8,
        labelColor = { default={ 0.11, 0.46, 0.74 }, over={ 0.11, 0.46, 0.74, 0.7 } },
        font = fonts.getLight(),
        fontSize = 50,
        isEnabled = false,
        onRelease = controller.restartButtonListener,
        xIn = resumeButton.x + 0.5 * resumeButton.width,
        xOut = 0
    }
    group:insert( restartButton )
    restartButton.xIn = resumeButton.x + 0.5 * resumeButton.width
    restartButton.xOut = display.contentWidth + restartButton.width
    restartButton.yIn = mainButton.y
    restartButton.yOut = mainButton.y
    restartButton.x = restartButton.xOut
    restartButton.y = restartButton.yOut
    restartButton.anchorX = 1
    restartButton.anchorY = 0
    controller.addGamePausedObject( restartButton )
    controller.addButton( restartButton )
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

    controller.connectCountdownImage( countdownImage1, 1 )
    controller.connectCountdownImage( countdownImage2, 2 )
    controller.connectCountdownImage( countdownImage3, 3 )
    ---------------------------------------------------------------------------]

    -- Opaque Rectangle for pause/end -----------------------------------------[
    overlayBG = display.newRect(
        group,
        display.contentCenterX,
        display.contentCenterY,
        display.actualContentWidth,
        display.actualContentHeight
    )
    overlayBG.blueFill = { 0, 0.65, 1 }
    overlayBG.redFill = { 1, 0, 0.15 }
    overlayBG.alpha = 0
    overlayBG:toBack()
    controller.connectBackgroundImage( overlayBG )
    ---------------------------------------------------------------------------]

    statsFocal = mainButton.y + 1.5 * mainButton.height
    statsAreaH = display.actualContentHeight - statsFocal
    wh = 0.25 * statsAreaH

    -- Game Over Lines and Background -----------------------------------------[
    statsBG = display.newImageRect( group, "images/statsBG.jpg", 800, 800)
    statsBG.xIn = display.contentCenterX
    statsBG.xOut = statsBG.xIn
    statsBG.yIn = statsFocal
    statsBG.yOut = display.actualContentHeight
    statsBG.x = statsBG.xOut
    statsBG.y = statsBG.yOut
    statsBG.anchorY = 0
    statsBG.height = statsAreaH
    statsBG.width = display.actualContentWidth
    statsBG.alpha = 0.8
    statsBG.id = "statsBG"
    controller.addGameOverObject( statsBG )

    statsLine1 = display.newLine(
        group,
        0,
        statsFocal + 0.5 * statsAreaH,
        display.contentWidth,
        statsFocal + 0.5 * statsAreaH
    )
    statsLine1:setStrokeColor( unpack( colors.purple ) )
    statsLine1.strokeWidth = 2
    statsLine1.alpha = 0
    statsLine1.id = "line1"
    statsLine1.shouldFade = true
    controller.addGameOverObject( statsLine1 )

    statsLine2 = display.newLine(
        group,
        display.contentCenterX - 0.5 * wh,
        statsFocal + 0.5 * statsAreaH,
        display.contentCenterX - 0.5 * wh,
        display.actualContentHeight
    )
    statsLine2:setStrokeColor( unpack( colors.purple ) )
    statsLine2.strokeWidth = 2
    statsLine2.alpha = 0
    statsLine2.id = "line2"
    statsLine2.shouldFade = true
    controller.addGameOverObject( statsLine2 )

    statsLine3 = display.newLine(
        group,
        display.contentCenterX + 0.5 * wh,
        statsFocal + 0.5 * statsAreaH,
        display.contentCenterX + 0.5 * wh,
        display.contentHeight
    )
    statsLine3:setStrokeColor( unpack( colors.purple ) )
    statsLine3.strokeWidth = 2
    statsLine3.alpha = 0
    statsLine3.id = "line3"
    statsLine3.shouldFade = true
    controller.addGameOverObject( statsLine3 )
    ---------------------------------------------------------------------------]

    -- Game Over Stat Text ----------------------------------------------------[
    categoryText = display.newText({
        parent = group,
        text = controller.getCategoryText(),
        font = fonts.getRegular(),
        fontSize = 85,
        align = "right"
    })
    categoryText.xIn = display.contentCenterX - 0.15 * wh
    categoryText.xOut = 0
    categoryText.yIn = statsFocal + 0.25 * statsAreaH
    categoryText.yOut = categoryText.yIn
    categoryText.x = categoryText.xOut
    categoryText.y = categoryText.yOut
    categoryText:setFillColor( colors.orange:unpack() )
    categoryText.anchorX = 1
    categoryText.id = "categoryText"
    controller.addGameOverObject( categoryText )

    valuesText = display.newText({
        parent = group,
        text = " ",
        font = fonts.getRegular(),
        fontSize = 85,
        align = "left"
    })
    valuesText.xIn = display.contentCenterX + 0.15 * wh
    valuesText.xOut = display.actualContentWidth
    valuesText.yIn = categoryText.y
    valuesText.yOut = valuesText.yIn
    valuesText.x = valuesText.yOut
    valuesText.y = valuesText.yOut
    valuesText:setFillColor( colors.purple:unpack() )
    valuesText.anchorX = 0
    valuesText.id = "valuesText"
    controller.addGameOverObject( valuesText )
    controller.linkValuesText( valuesText )

    highScoreText = display.newText({
        parent = group,
        text = controller.getHighScoreText(),
        width = 0.5 * (display.actualContentWidth - wh),
        height = 0,
        x = 0.5 * statsLine2.x,
        font = fonts.getRegular(),
        fontSize = 40,
        align = "center"
    })
    highScoreText.xIn = 0.5 * statsLine2.x
    highScoreText.xOut = highScoreText.xIn
    highScoreText.yIn = statsFocal + statsAreaH * 0.75
    highScoreText.yOut = display.actualContentHeight + 0.5 * highScoreText.height
    highScoreText.x = highScoreText.xOut
    highScoreText.y = highScoreText.yOut
    highScoreText:setFillColor( unpack( colors.purple ) )
    highScoreText.id = "highScoreText"
    controller.addGameOverObject( highScoreText )

    highTimeText = display.newText({
        parent = group,
        text = controller.getHighTimeText(),
        width = highScoreText.width,
        height = 0,
        x = display.actualContentWidth - highScoreText.x,
        font = fonts.getRegular(),
        fontSize = 40,
        align = "center",
    })
    highTimeText.xIn = display.actualContentWidth - highScoreText.x
    highTimeText.xOut = highTimeText.xIn
    highTimeText.yIn = statsFocal + statsAreaH * 0.75
    highTimeText.yOut = highScoreText.y
    highTimeText.x = highTimeText.xOut
    highTimeText.y = highTimeText.yOut
    highTimeText:setFillColor( unpack( colors.purple ) )
    highTimeText.id = "highTimeText"
    controller.addGameOverObject( highTimeText )
    ---------------------------------------------------------------------------]

    -- Socail Button ----------------------------------------------------------[
    twitter = widget.newButton{
        id = "twitter",
        width = wh,
        height = wh,
        defaultFile = "images/twitter.png",
        overFile = "images/twitterD.png",
        onRelease = controller.socialButtonListener,
    }
    twitter.xIn = display.contentCenterX
    twitter.xOut = twitter.xIn
    twitter.yIn = statsFocal + 0.5 * statsAreaH
    twitter.yOut = display.actualContentHeight
    twitter.x = twitter.xOut
    twitter.y = twitter.yOut
    group:insert( twitter )
    twitter.anchorY = 0
    controller.addGameOverObject( twitter )

    facebook = widget.newButton{
        id = "facebook",
        width = wh,
        height = wh,
        defaultFile = "images/facebook.png",
        overFile = "images/facebookD.png",
        onRelease = controller.socialButtonListener
    }
    facebook.xIn = display.contentCenterX
    facebook.xOut = facebook.xIn
    facebook.yIn = display.actualContentHeight + 2 * wh
    facebook.yOut = twitter.y + 2 * wh
    facebook.x = facebook.xOut
    facebook.y = facebook.yOut
    group:insert( facebook )
    facebook.anchorY = 1
    controller.addGameOverObject( facebook )
    ---------------------------------------------------------------------------]
end

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase
    controller.setParentScene(event.parent)

    if ( phase == "will" ) then
    elseif ( phase == "did" ) then

        controller.setSceneHideCallback(nil)
        controller.setGamePaused(event.params.isPaused)
        controller.setValues(event.params.scoreText, event.params.timeText)

        controller.transitionInPause()
        controller.transitionAndSetupSceneBasedOnGameState()

    end
end

function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
        controller.sceneHideCallback()
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene