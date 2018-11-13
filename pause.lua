local cp = require( "composer" )
local g = require( "globalVariables" )
local widget = require( "widget" )

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
            xScale=0, 
            yScale=0, 
            transition=easing.inBack
        })
        transition.to( countdownImage2, { 
            time=200, 
            delay=interval, 
            alpha=0, 
            xScale=0, 
            yScale=0,
            transition=easing.inBack
        })
        transition.to( countdownImage3, { 
            time=200, 
            delay=interval, 
            alpha=0, 
            xScale=0, 
            yScale=0,
            transition=easing.inBack,
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

local function resumeListener()
    functionToCallOnHide = parentScene.resumeGame
    transitionOutPause()
end

local function restartListener()
    functionToCallOnHide = parentScene.restartGame
    transitionOutPause()
end

local function mainListener()
    cp.gotoScene( "center" )
end
-------------------------------------------------------------------------------]

function scene:create( event )
    local group = self.view

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
end

function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    parentScene = event.parent
 
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
        functionToCallOnHide = nil
        transitionInPause()
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