local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "globalVariables" )
local ld = require( "localData" )
local physics = require( "physics" )
local Drop = require( "Drop" )
local bg = require( "backgrounds" )
local timer = require( "timers" )
local json = require( "json" )

local arrowIsWorking = false

--Precalls
local arrow
local arrowWidth
local arrowShapeRegular
local arrowShapeSmall
local arrowShapeLarge
local arrowShape
local lvlParams = g.level1AParams
local headerGroup
local header1
local header2
local transparentRect
local storm
local gravityPower
local windForce
local touchPad
local isInvincible
local totalGameTime
local score
local scoreMultiplier
local dropsGroup
local scoreText
local playTime
local collisionRect
local endGame
local iconLivesText
local iconInvinceText

local timers = {}
----------

-- Local Functions ------------------------------------------------------------[
local function headerGroupTransitionIn()
    local function listener()
        header1:setEnabled( true )
    end
    transition.to( headerGroup, {
        time = 500,
        y = 0,
        transition = easing.outQuad,
        onComplete = listener
    })
end

local function displayStormName()
    local function listener()
        storm.x = -storm.width
    end
    transition.to( storm, {
        time = 1700,
        x = display.actualContentWidth + storm.width,
        transition = easing.outInCubic,
        onComplete = listener
    })
end

local function updateGravityY()
    local gx, gy = physics.getGravity()
    gy = gravityPower * lvlParams.gravity
    physics.setGravity( gx, gy )
end

local function updateWindPower()
    windForce = windForce + 0.003
    local wind = 0.15 * lvlParams.wind * math.sin( windForce )
    local gx, gy = physics.getGravity()
    physics.setGravity( wind, gy)
end

local function addArrowPhysics()
    physics.addBody( arrow, "kinematic", {
        shape = arrowShape,
        bounce = 0
    })
end

local function startPhysics()
    physics.start()
    addArrowPhysics()
    physics.addBody( collisionRect, "static" )
end

local function invincibilityTimerListener()
    isInvincible = false
    arrow.alpha = 1
end

local function giveInvincibility()
    isInvincible = true
    arrow.alpha = 0.5
    local timeRemaining = 0

    if timer.exists(timers.invincibilityTimer) then
        timeRemaining = timer.pause( timers.invincibilityTimer )
        timer.cancel( timers.invincibilityTimer )
    end

    timers.invincibilityTimer = timer.createTimer(
        timeRemaining + 10000,
        invincibilityTimerListener,
        "invincibility"
    )
end

local function tiltControlMovement( event )
    local velocity = 0
    if math.abs(event.xGravity) > 0.04 then
        local sensitivity = (ld.getMovementSensitivity() - 1) * 45
        local vel = event.xGravity * sensitivity
    end
    arrow:setLinearVelocity( velocity, 0 )
end

local function touchControlMovement( isGoingRight )
    local velocity = ld.getMovementSensitivity() * 500
    if not isGoingRight then
        velocity = -1 * velocity
    end
    arrow:setLinearVelocity( velocity, 0 )
end

local function touchPadListener( event )
    if not ld.getTiltControlEnabled() then
        if event.phase == "began" then
            if event.x < display.contentCenterX then
                touchControlMovement( false )
            else
                touchControlMovement( true )
            end
        elseif event.phase == "ended" then
            arrow:setLinearVelocity( 0, 0 )
        end
    end
    if event.phase == "moved" then
        local deltaY = event.yStart - event.y
        if deltaY > 200 and ld.getInvincibility() > 0 and not isInvincible then
            giveInvincibility()
            ld.addInvincibility( -1 )
            iconInvinceText.text = ld.getInvincibility()
        end
    end
end

local function checkArrowPortal()
    local leftMostX = -arrowWidth + 2
    local rightMostX = display.actualContentWidth + arrowWidth - 2
    if arrow.x < leftMostX then
        arrow.x = rightMostX
    elseif arrow.x > rightMostX then
        arrow.x = leftMostX
    end
end

local function addEventListeners()
    if ld.getTiltControlEnabled() then
        Runtime:addEventListener( "accelerometer", tiltControlMovement )
    end
    touchPad:addEventListener( "touch", touchPadListener )
    collisionRect:addEventListener( "collision", collisionRect )
    arrow:addEventListener( "collision", arrow )
    Runtime:addEventListener( "enterFrame", updateWindPower )
    Runtime:addEventListener( "enterFrame", checkArrowPortal )
end

local function removeEventListeners()
    if ld.getTiltControlEnabled() then
        Runtime:removeEventListener( "accelerometer", tiltControlMovement )
    end
    touchPad:removeEventListener( "touch", touchPad )
    collisionRect:removeEventListener( "collision", collisionRect )
    arrow:removeEventListener( "collision", arrow )
    Runtime:removeEventListener( "enterFrame", updateWindPower )
    Runtime:removeEventListener( "enterFrame", checkArrowPortal )
end

local function updateArrowScale( size )
    local scale
    physics.removeBody( arrow )

    if size == "small" then
        arrowShape = arrowShapeSmall
        scale = 0.26
    elseif size == "large" then
        arrowShape = arrowShapeLarge
        scale = 0.4
    else
        arrowShape = arrowShapeRegular
        scale = 0.33
    end

    arrow.xScale = scale
    arrow.yScale = scale
    arrow.y = display.actualContentHeight - 150 * scale

    addArrowPhysics()
end

local function spawnDrop()
    for i = 1, lvlParams.mode do
        local newDrop = Drop:new( dropsGroup )
        newDrop:addPhysics()
        if lvlParams.phase >= 9 then
            newDrop:setLinearVelocity( 0, 100 )
        end
    end
end

local function startSpawnTimer()
    timers.spawnTimer = timer.createTimer(
        lvlParams.interval,
        spawnDrop,
        "spawn",
        -1
    )
end

local function hurricaneTimerListener()
    -- TODO: save how long user survived in hurricane level
end

local function startHurricaneTimer()
    timers.hurricaneTimer = timer.createTimer( 
        1000, 
        hurricaneTimerListener,
        "hurricane",
        -1
    )
end

local startLevelTimer

local function levelStartListener()
    if lvlParams.phase ~= 13 then
        startLevelTimer()
    else
        startHurricaneTimer()
    end

    if lvlParams.mode == 1 then
        updateGravityY()
        if ld.getChangingBackgroundsEnabled() then
            bg.fadeInNext()
        end
    end

    storm.text = lvlParams.stormName
    displayStormName()
    startSpawnTimer()
end

local function levelCompleteListener()
    timer.cancel( timers.spawnTimer )
    lvlParams = g.nextLevelParams( lvlParams.phase )
    timers.levelDelayTimer = timer.createTimer( 3000, levelStartListener, "levelComplete" )
end

function startLevelTimer()
    timers.levelTimer = timer.createTimer( 
        lvlParams.duration, 
        levelCompleteListener,
        "levelStart"
    )
end

local function gameTimerListener()
    totalGameTime = totalGameTime + 1
    playTime.text = g.timeFormat( totalGameTime )
end

local function startGameTimer()
    timers.gameTimer = timer.createTimer( 1000, gameTimerListener, "startGame", -1 )
end

local function scoreTimerListener()
    score = score + 1 * scoreMultiplier
    scoreText.text = g.commas( score )
end

local function startScoreTimer()
    timers.scoreTimer = timer.createTimer( 10, scoreTimerListener, "score", -1 )
end

local function collisionRectListener( self, event )
    if event.phase == "began" then
        local drop = event.other.drop
        if drop.isSpecial then
            ld.incrementDropSpecialDodges( drop.type )
        else
            ld.incrementDropNormalDodges( drop.type )
        end
        drop:delete()
        score = score + 100
    end
end

local function startGravityTimer( power )
    gravityPower = power
    updateGravityY()
    local function listener()
        gravityPower = 1
        updateGravityY()
    end
    if timer.exists(timers.gravityTimer) then
        timer.cancel( timers.gravityTimer )
    end
    timers.gravityTimer = timer.createTimer( 10000, listener, "gravity" )
end

local function startScaleTimer( size )
    local function delayListener()
        updateArrowScale( size )
        local function listener()
            updateArrowScale( "regular" )
        end
        if timer.exists(timers.scaleTimer) then
            timer.cancel( timers.scaleTimer )
        end
        timers.scaleTimer = timer.createTimer( 10000, listener, "scale" )
    end
    -- slight delay is needed for collision calculations to complete
    timer.createTimer( 40, delayListener, "scaleDelay" )
end

local function startScoreMultiplierTimer()
    local timeRemaining = 0
    if timer.exists(timers.multiplierTimer) then
        scoreMultiplier = scoreMultiplier * 2--+ 3
        timerRemaining = timer.pause( timers.multiplierTimer )
        timer.cancel( timers.multiplierTimer )
    else
        scoreMultiplier = 3
    end
    local function listener()
        scoreMultiplier = 1
    end
    timers.multiplierTimer = timer.createTimer( 
        timeRemaining + 10000, 
        listener,
        "multiplier"
    )
end

local function deleteSpecialDrop( drop )
    local function listener( obj )
        if not obj.isDeleted then
            obj.isDeleted = true
            -- obj:removeSelf()
            -- obj = nil
            obj.drop:delete()
        end
    end
    transition.to( drop, { 
        time = 80, 
        alpha = 0, 
        width = drop.width*2,
        height = drop.height*2,
        onComplete = listener,
    })
end

local function arrowCollisionListener( self, event )
    if not arrowIsWorking then return end

    local drop = event.other

    if event.phase == "began" then
        if drop.isSpecial then
            ld.incrementDropSpecialCollisions( drop.type )
            if drop.type == "red" then
                startGravityTimer( 2 )
            elseif drop.type == "orange" then
                score = score - 3000 * scoreMultiplier
            elseif drop.type == "yellow" then
                giveInvincibility()
            elseif drop.type == "lightGreen" then
                startScaleTimer( "small" )
            elseif drop.type == "darkGreen" then
                startScoreMultiplierTimer()
            elseif drop.type == "lightBlue" then
                startGravityTimer( 0.5 )
            elseif drop.type == "darkBlue" then
                score = score + 3000 * scoreMultiplier
            elseif drop.type == "pink" then
                startScaleTimer( "large" )
            end
            deleteSpecialDrop( drop )
        elseif not isInvincible then
            ld.incrementDropNormalCollisions( drop.type )
            scene:endGame()
        end
    end
end
-------------------------------------------------------------------------------]

-- Major game function --------------------------------------------------------[
function scene:startGame()
    lvlParams = g.level1AParams
    gravityPower = 1
    windForce = 0
    score = 0
    totalGameTime = 0
    scoreMultiplier = 1
    headerGroup:toFront()
    dropsGroup = display.newGroup()
    storm.text = lvlParams.stormName
    transparentRect.isVisible = false
    header1.isVisible = true
    header2.isVisible = false
    Drop:deleteAll()
    startPhysics()
    addEventListeners()
    startSpawnTimer()
    startLevelTimer()
    startGameTimer()
    startScoreTimer()
    displayStormName()
    system.setIdleTimer( false )
end

function scene:resumeGame()
    system.setIdleTimer( false )
    header1.isVisible = true
    header2.isVisible = false
    transparentRect.isVisible = false
    addEventListeners()
    timer.resumeAllTimers()
    transition.resume()
    physics.start()
end

function scene:pauseGame()
    system.setIdleTimer( true )
    header1.isVisible = false
    header2.isVisible = true
    transparentRect.fill = transparentRect.blueFill
    transparentRect.isVisible = true
    removeEventListeners()
    timer.pauseAllTimers()
    transition.pause()
    physics.pause()
    cp.showOverlay( "pause", { isModal=true } )
end

function scene:endGame()
    system.setIdleTimer( true )
    removeEventListeners()
    timer.pauseAllTimers()
    transition.pause()
    physics.pause()
end
-------------------------------------------------------------------------------]

function scene:create( event )
    local group = self.view
    g.create()
    physics.start()

    -- Arrow Setup ------------------------------------------------------------[
    arrow = display.newImageRect(group, "images/arrow.png", 352, 457)
    arrow.id = "arrow"
    arrowScale = 0.33
    arrow.x = display.contentCenterX
    arrow.y = display.contentHeight-150 * arrowScale
    arrow.xScale = arrowScale
    arrow.yScale = arrowScale
    arrow.rotation = -90
    arrow.collision = arrowCollisionListener
    
    arrowShapeRegular = { 41.3,-10.6, 46.2,-0.3, 41.3,10.4, -31.1,68, -46.2,62.3, -46.2,-62.4, -31.1,-67.9 }
    arrowShapeSmall = { 32.54,-8.35, 36.4,-0.236, 32.54,8.194, -24.503,53.576, -36.4,49.084, -36.4,-49.16, -24.50,-53.497 }
    arrowShapeLarge = { 50.06,-12.85, 56,-0.3636, 50.06,12.606, -37.697,82.42, -56,75.515, -56,-75.636, -37.697,-82.303 }

    arrowShape = arrowShapeRegular
    arrowWidth = math.max( unpack(arrowShape) ) -- teleportation. Change when scale changes.
    ---------------------------------------------------------------------------]

    -- Countdown images -------------------------------------------------------[
    local countdownImage1 = display.newImageRect( group, "images/dropletYellow.png", 220, 330 )
    local countdownImage2 = display.newImageRect( group, "images/dropletYellow.png", 220, 330 )
    local countdownImage3 = display.newImageRect( group, "images/dropletGreen.png", 220, 330 )
    
    countdownImage1.x = display.contentCenterX
    countdownImage2.x = countdownImage1.x
    countdownImage3.x = countdownImage1.x
    
    countdownImage2.y = display.contentCenterY
    countdownImage1.y = countdownImage2.y - countdownImage1.height + 40
    countdownImage3.y = countdownImage2.y + countdownImage3.height - 40
    
    countdownImage1.alpha = 0
    countdownImage2.alpha = 0
    countdownImage3.alpha = 0
    ---------------------------------------------------------------------------]

    -- Header Group -----------------------------------------------------------[
    headerGroup = display.newGroup()
    group:insert( headerGroup )

    -- Play/Pause buttons -----------------------------------------------------[
    header1 = widget.newButton {
        parent = headerGroup,
        id = "header",
        width = 1000,
        height = 260,
        defaultFile = "images/header.png",
        onPress = scene.pauseGame,
    }
    header1.x = display.contentCenterX
    header1.y = display.topStatusBarContentHeight --0.5*header1.height
    headerGroup:insert(header1)
    header1:setEnabled( false )
    
    header2 = widget.newButton {
        parent = headerGroup,
        id = "header2",
        width = 1000,
        height = 260,
        defaultFile = "images/header2.png",
        onPress = scene.resumeGame,
    }
    header2.x, header2.y = header1.x, header1.y
    headerGroup:insert(header2)
    header2.isVisible = false
    ---------------------------------------------------------------------------]

    -- Score text -------------------------------------------------------------[
    scoreText = display.newText {
        parent = headerGroup,
        text = "0",
        x = 15,
        y = display.topStatusBarContentHeight + display.actualContentHeight * 0.01,
        font = g.comRegular,
        fontSize = 38,
    }
    scoreText.anchorX = 0
    ---------------------------------------------------------------------------]

    -- Play time --------------------------------------------------------------[
    playTime = display.newText {
        parent = headerGroup,
        text = "0:00",
        x = display.contentWidth-15,
        y = scoreText.y,
        font = g.comRegular,
        fontSize = 38,
    }
    playTime.anchorX = 1
    ---------------------------------------------------------------------------]

    -- Lives ------------------------------------------------------------------[
    local iconLives = display.newImageRect( 
        headerGroup, 
        "images/lives.png", 
        53, 
        53 
    )
    iconLives.x = display.contentWidth * 0.3
    iconLives.y = scoreText.y
    iconLives.anchorX = 1 
    
    iconLivesText = display.newText {
        parent = headerGroup,
        text = ld.getLives(),
        x = iconLives.x,
        y = iconLives.y,
        font = g.comLight,
        fontSize = 32
    }
    iconLivesText.anchorX = 0
    ---------------------------------------------------------------------------]

    -- Invincibilities --------------------------------------------------------[
    local iconInvince = display.newImageRect( headerGroup, "images/invincibility.png", 53, 53 )
    iconInvince.x = display.contentWidth*0.7
    iconInvince.y = scoreText.y
    iconInvince.anchorX = 0
    
    iconInvinceText = display.newText {
        parent = headerGroup,
        text = ld.getInvincibility(),
        x = iconInvince.x,
        y = iconInvince.y,
        font = g.comLight,
        fontSize = 32
    }
    iconInvinceText.anchorX = 1
    ---------------------------------------------------------------------------]

    headerGroup.y = -header1.height -- set to starting location (out of view)
    ---------------------------------------------------------------------------]

    -- Storm Name -------------------------------------------------------------[
    local stormOptions = {
        parent = group,
        text = lvlParams.stormName,
        x = 0,
        y = display.contentCenterY,
        width = display.contentWidth, --required for multi-line and alignment
        font = g.comLight,
        fontSize = 100,
        align = "center",
    }
    
    storm = display.newText( stormOptions )
    storm.x = -storm.width
    storm:setFillColor( unpack( g.purple ) )
    storm.anchorX, storm.anchorY = 0.5, 0.5
    storm:toBack()
    ---------------------------------------------------------------------------]
    
    -- Touch Pad --------------------------------------------------------------[
    touchPad = display.newImageRect(
        group,
        "images/fillT.png",
        display.actualContentWidth,
        display.actualContentHeight
    )
    touchPad.x = display.contentCenterX
    touchPad.y = header1.y + 0.5 * header1.height
    touchPad.anchorY = 0
    -- touchPad.touch = touchPadListener
    ---------------------------------------------------------------------------]
    
    -- Collision Rectangle ----------------------------------------------------[
    collisionRect = display.newRect(
        group,
        display.contentCenterX,
        display.contentHeight * 1.25,
        display.actualContentWidth * 4,
        10
    )
    collisionRect.myName = "collisionRect"
    collisionRect.collision = collisionRectListener
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
    -- transparentRect.redFill = { 1, 0, 0.15 }
    transparentRect.fill = transparentRect.blueFill
    transparentRect.isVisible = false
    transparentRect.alpha = 0.5
    ---------------------------------------------------------------------------]

    --  -------------------------------------------------------------[

    ---------------------------------------------------------------------------]
end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()
        headerGroupTransitionIn()
        scene:startGame()

        group:insert( dropsGroup )
        dropsGroup:toBack()

    end
end


function scene:hide( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.hide()

        system.setIdleTimer( true )
        removeEventListeners()
        -- timer.flushAllTimers()
        transition.cancel()
        physics.stop()
        
    end
end


function scene:destroy( event )

    local group = self.view
    
    g.destroy()
    
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene