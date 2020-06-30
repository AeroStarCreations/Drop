local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "other.globalVariables" )
local ld = require( "data.localData" )
local physics = require( "physics" )
local Drop = require( "views.other.Drop" )
local bg = require( "controllers.backgroundController" )
local TimerBank = require( "other.TimerBank" )
local json = require( "json" )
local highScores = require( "data.highScores" )
local sounds = require( "other.sounds" )
local metrics = require( "other.metrics" )

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
-- local header2
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
local hurricaneTime
local timerBank

local timers = {}
----------

-- Local Functions ------------------------------------------------------------[
local function onSystemEvent(event)
    if "applicationSuspend" == event.type then
        sounds.pauseMusic()
        timerBank:pauseAllTimers()
        physics.pause()
    elseif "applicationResume" == event.type then
        sounds.resumeMusic()
        timerBank:resumeAllTimers()
        physics.start()
    end
end

local function headerGroupTransitionIn()
    local function listener()
        header1:setEnabled( true )
    end

    headerGroup.y = -headerGroup.height -- starting position
    local destinationY = display.topStatusBarContentHeight

    transition.to( headerGroup, {
        time = 500,
        y = destinationY - 0.43 * headerGroup.height,
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
    arrow:setLinearVelocity( 0, 0 )
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

    timeRemaining = timerBank:pause( timers.invincibilityTimer )
    timerBank:cancel( timers.invincibilityTimer )

    timers.invincibilityTimer = timerBank:createTimer(
        timeRemaining + 5000,
        invincibilityTimerListener
    )
end

local function tiltControlMovement( event )
    local velocity = 0
    if math.abs(event.xGravity) > 0.04 then
        local sensitivity = ld.getMovementSensitivity() * 2000
        velocity = event.xGravity * sensitivity
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
    Runtime:addEventListener( "system", onSystemEvent )
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
    Runtime:removeEventListener( "system", onSystemEvent )
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
    timers.spawnTimer = timerBank:createTimer(
        lvlParams.interval,
        spawnDrop,
        -1
    )
end

local function hurricaneTimerListener()
    hurricaneTime = hurricaneTime + 1
end

local function startHurricaneTimer()
    timers.hurricaneTimer = timerBank:createTimer( 
        1000, 
        hurricaneTimerListener,
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
        sounds.nextPhase()
        if ld.getChangingBackgroundsEnabled() then
            bg.fadeInNext()
        end
    end

    storm.text = lvlParams.stormName
    displayStormName()
    startSpawnTimer()
end

local function levelCompleteListener()
    timerBank:cancel( timers.spawnTimer )
    lvlParams = g.nextLevelParams( lvlParams.phase )
    timers.levelDelayTimer = timerBank:createTimer( 3000, levelStartListener )
end

function startLevelTimer()
    timers.levelTimer = timerBank:createTimer(
        lvlParams.duration,
        levelCompleteListener
    )
end

local function gameTimerListener()
    totalGameTime = totalGameTime + 1
    playTime.text = g.timeFormat( totalGameTime )
end

local function startGameTimer()
    timers.gameTimer = timerBank:createTimer( 1000, gameTimerListener, -1 )
end

local function scoreTimerListener()
    score = score + scoreMultiplier
    scoreText.text = g.commas( score )
end

local function startScoreTimer()
    timers.scoreTimer = timerBank:createTimer( 10, scoreTimerListener, -1 )
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
    timerBank:cancel( timers.gravityTimer )
    timers.gravityTimer = timerBank:createTimer( 10000, listener )
end

local function startScaleTimer( size )
    local function delayListener()
        updateArrowScale( size )
        local function listener()
            updateArrowScale( "regular" )
        end
        timerBank:cancel( timers.scaleTimer )
        timers.scaleTimer = timerBank:createTimer( 10000, listener )
    end
    -- slight delay is needed for collision calculations to complete
    timerBank:createTimer( 40, delayListener )
end

local function startScoreMultiplierTimer()
    local timeRemaining = 0
    if timerBank:exists(timers.multiplierTimer) then
        scoreMultiplier = scoreMultiplier + 3
        timeRemaining = timerBank:pause( timers.multiplierTimer )
        timerBank:cancel( timers.multiplierTimer )
    else
        scoreMultiplier = 3
    end
    local function listener()
        scoreMultiplier = 1
    end
    timers.multiplierTimer = timerBank:createTimer( 
        timeRemaining + 10000, 
        listener
    )
end

local function arrowCollisionListener( self, event )
    local drop = event.other.drop

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
            drop:deleteWithAnimation()
        elseif not isInvincible then
            ld.incrementDropNormalCollisions( drop.type )
            if arrowIsWorking then scene:endGame() end
        end
    end
end
-------------------------------------------------------------------------------]

-- Major game function --------------------------------------------------------[
function scene:startGame()
    -- Set variables
    lvlParams = g.level1AParams
    gravityPower = 1
    windForce = 0
    score = 0
    totalGameTime = 0
    hurricaneTime = 0
    scoreMultiplier = 1
    system.setAccelerometerInterval( 50 )

    -- Set Text
    storm.text = lvlParams.stormName
    scoreText.text = "0"
    playTime.text = "0:00"
    iconLivesText.text = ld.getLives()

    -- Set Visibility/Enabled
    -- header1.isVisible = true
    -- header2.isVisible = false
    system.setIdleTimer( false )

    -- Call Functions
    Drop:deleteAll()
    timerBank:cancelAllTimers()
    startPhysics()
    addEventListeners()
    startSpawnTimer()
    startLevelTimer()
    startGameTimer()
    startScoreTimer()
    displayStormName()
    bg.fadeOutToDefault()
    sounds.playMusic()

    -- Metrics
    metrics.logEvent("game_started", {
        isTricky = ld.getSpecialDropsEnabled()
    })
end

function scene:resumeGame()
    system.setIdleTimer( false )
    -- header1.isVisible = true
    -- header2.isVisible = false
    addEventListeners()
    timerBank:resumeAllTimers()
    sounds.resumeMusic()
    transition.resume()
    physics.start()
    system.setAccelerometerInterval( 50 )

    -- Metrics
    metrics.logEvent("game_resumed")
end

local function gameStopped( isPaused )
    system.setIdleTimer( true )
    -- header1.isVisible = false
    -- header2.isVisible = true
    system.setAccelerometerInterval( 30 )
    removeEventListeners()
    timerBank:pauseAllTimers()
    sounds.pauseMusic()
    transition.pause()
    physics.pause()
    cp.showOverlay( "views.overlays.gameStopped", {
        isModal = true,
        params = {
            isPaused = isPaused,
            scoreText = scoreText.text,
            timeText = playTime.text
        }
    })
end

function scene:pauseGame()
    gameStopped( true )

    -- Metrics
    metrics.logEvent("game_paused")
end

function scene:endGame()
    Drop:deleteAllWithAnimation()
    gameStopped( false )
    
    -- Metrics
    metrics.logEvent("game_death")
end

function scene:gameIsActuallyOver()
    -- Count games played since this is the only place where
    -- it's known that the user played a complete game.
    ld.incrementGamesPlayed()
    -- Save phase and hurricaneTime for achievement checks
    ld.setPhase( lvlParams.phase )
    ld.setHurricaneTime( hurricaneTime )
    -- Check high scores
    highScores.checkHighScore( score, totalGameTime )
    -- Stop music
    sounds.stopMusic()
    
    -- Metrics
    metrics.logEvent("game_over")
end
-------------------------------------------------------------------------------]

function scene:create( event )
    local group = self.view
    g.create()
    physics.start()
    dropsGroup = display.newGroup()
    group:insert( dropsGroup )
    timerBank = TimerBank:new()

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
    headerGroup:toFront()
    group:insert( headerGroup )

    -- Play/Pause buttons -----------------------------------------------------[
    header1 = widget.newButton {
        id = "header",
        width = 1000,
        height = 260,
        defaultFile = "images/header.png",
        onPress = scene.pauseGame,
    }
    header1.x = display.contentCenterX
    header1.y = 0.5 * header1.height
    headerGroup:insert(header1)
    header1:setEnabled( false )
    
    -- header2 = widget.newButton {
    --     parent = headerGroup,
    --     id = "header2",
    --     width = 1000,
    --     height = 260,
    --     defaultFile = "images/header2.png",
    --     onPress = scene.resumeGame,
    -- }
    -- header2.x, header2.y = header1.x, header1.y
    -- headerGroup:insert(header2)
    -- header2.isVisible = false
    ---------------------------------------------------------------------------]

    -- Score text -------------------------------------------------------------[
    scoreText = display.newText {
        parent = headerGroup,
        text = "0",
        x = 15,
        y = 0.55 * header1.height,
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
        timerBank:cancelAllTimers()
        transition.cancel()
        physics.stop()
        g.arrowX = arrow.x
        
    end
end


function scene:destroy( event )

    local group = self.view
    
    g.destroy()
    removeEventListeners()
    timerBank:cancelAllTimers()
    transition.cancel()
    physics.stop()
    
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene