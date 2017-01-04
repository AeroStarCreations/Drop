--Game

local cp = require( "composer" )
local scene = cp.newScene()
local g = require( "globalVariables" )
local t = require( "transitions" )
local widget = require( "widget" )
local physics = require( "physics" )
local GGData = require( "GGData" )
local ad = require( "advertisements" )
local gn = require( "gameNetworks" )
local chartboost = require( "plugin.chartboost" )

local arrowIsWorking = true

local arrow
local arrowShapeRegular
local arrowShapeSmall
local arrowShapeLarge
local headerGroup
local header1
local header2
local gamePause
local playTime
local scoreText
local acc
local touchPad
local touchToMove
local gameIsActive
local spawnTimer
local gameTimer
local scoreTimer
local score
local totalTime
local rect
local gravityTimer
local multiplierTimer
local invincibilityTimer
local invincibilityFunction
local scaleTimer
local lvlParams = g.level1AParams
local storm
local arrowScale
local arrowShape
local toBeScaled = false
local wind
local scaler
local timerIndex = {}
local timersPaused = {}
local green, red, blue
local initials
local spawnTimerFunction, levelTimerFunction, gameTimerFunction, scoreTimerFunction
local dropsTable
local dropsGroup
local pause
local gameOver = false
local checkIfGameIsOver = 0
local transparentRect
local statsBg
local sText1
local sText2
local tText1
local tText2
local statsLine1
local message
local vungleAdListener
local records
local shield = 0
local revive = 0
local hurricaneTime = 0
local twitter
local facebook

function scene:create( event )
    local group = self.view
    
    
    -----------------------------------------------------------------Arrow Setup
    arrow = display.newImageRect(group, "images/arrow.png", 352, 457)
    arrow.id = "arrow"
    arrowScale = 0.33
    arrow.x = display.contentCenterX; arrow.y = display.contentHeight-150*arrowScale
    arrow.xScale = arrowScale; arrow.yScale = arrowScale
    arrow.rotation = -90
    
    arrowShapeRegular = { 41.3,-10.6, 46.2,-0.3, 41.3,10.4, -31.1,68, -46.2,62.3, -46.2,-62.4, -31.1,-67.9 }
    arrowShapeSmall = { 32.54,-8.35, 36.4,-0.236, 32.54,8.194, -24.503,53.576, -36.4,49.084, -36.4,-49.16, -24.50,-53.497 }
    arrowShapeLarge = { 50.06,-12.85, 56,-0.3636, 50.06,12.606, -37.697,82.42, -56,75.515, -56,-75.636, -37.697,-82.303 }
    arrowShape = arrowShapeRegular
    g.arrowWidth = 68   -- Largest number in "arrowShape" table. Used for arrow 
    ---------------------- teleportation. Change when scale changes.
    
    
    ------------------------------------------------------------Opaque Rectangle
    transparentRect = display.newRect( group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
    transparentRect.alpha = 0.5
    
    
    -------------------------------------------------------------------Countdown
    local y1 = display.newImageRect( group, "images/dropletYellow.png", 220, 330 )
    local y2 = display.newImageRect( group, "images/dropletYellow.png", 220, 330 )
    local y3 = display.newImageRect( group, "images/dropletGreen.png", 220, 330 )
    
    local c = display.contentCenterX
    y1.x, y2.x, y3.x = c, c, c
    
    y2.y = display.contentCenterY
    y1.y = y2.y - y1.height + 40
    y3.y = y2.y + y3.height - 40
    
    y1.alpha, y2.alpha, y3.alpha = 0, 0, 0
    
    --------------------------------------------------------------Record Records
    
    --High score and time
    function records()
        if g.gameSettings.specials == true then -- this function sets high scores and times
            if score > g.leaderboard.lb[1].value then
                g.leaderboard.lb[1].value = score
                g.leaderboard:save()
            end
            if totalTime > g.leaderboard.lb[2].value then
                g.leaderboard.lb[2].value = totalTime
                g.leaderboard:save()
            end
        else
            if score > g.leaderboard.lb[3].value then
                g.leaderboard.lb[3].value = score
                g.leaderboard:save()
            end
            if totalTime > g.leaderboard.lb[4].value then
                g.leaderboard.lb[4].value = totalTime
                g.leaderboard:save()
            end
        end
        if hurricaneTime > 0 then -- this function / loop watches for hurricane achievements
            for i=1,3 do
                if hurricaneTime >= i then
                    g.achievement.normalAchievements[24+i].isComplete = true
                    g.achievement:save()
                    print("hurricanehurricanehurricanehurricanehurricane")
                end
            end
        end
        for i=0,2 do -- this loop watches for shield achievements
            if shield >= 2.5*(i^2+i+2) then--simplified quadratic formula ax^2+bx+c
                g.achievement.normalAchievements[28+i].isComplete = true
                g.achievement:save()
            end
        end
        for i=0,2 do -- this loop watches for revive achievements
            if revive >= 0.5*(i^2+7*i+2) then
                g.achievement.normalAchievements[31+i].isComplete = true
                g.achievement:save()
            end
        end
        for i=1,5 do -- this loop adjusts the number-of-games-played achievements
            if g.achievement.progressAchievements[i].isComplete == false then
                g.achievement.progressAchievements[i].number = g.stats.numGames
                g.achievement:save()
            end
        end
        local colorDeathsTable = {
            [6] = g.stats.redD,
            [7] = g.stats.orangeD,
            [8] = g.stats.yellowD,
            [9] = g.stats.lightGreenD,
            [10] = g.stats.darkGreenD,
            [11] = g.stats.lightBlueD,
            [12] = g.stats.darkBlueD,
            [13] = g.stats.pinkD,
        }
        for i=6,13 do -- this loop adjusts the death-by-color achievements
            if g.achievement.progressAchievements[i].isComplete == false then
                g.achievement.progressAchievements[i].number = colorDeathsTable[i]
                g.achievement:save()
            end
        end
        
        gn.checkAndRecord()
    end
    ---------------------
    
    ----------------------------------------------------Massive Header Functions
    local function clearDrops()
        local function listener( obj ) --remove drops
            display.remove( obj )
            obj = nil
        end
        for i = 1, dropsGroup.numChildren do
            transition.to( dropsGroup[i], { 
                time = 80, 
                alpha = 0, 
                width = dropsGroup[i].width*2,
                height = dropsGroup[i].height*2,
                onComplete = listener,
            } )
        end
    end
    
    function g.restart( event )
        
        header2:setEnabled( false )
        storm.x = -storm.width
        lvlParams = g.level1AParams
        scoreText.text = "0"
        playTime.text = "0:00"
        records()
        
        for i = 1, #timersPaused do --cancel timers
            timer.cancel( timerIndex[ timersPaused[i] ] )
            timerIndex[i] = nil
        end
        if g.gameSettings.bgChange == true then --fade background
            for i = 2, #g.bg do
                if g.bg[i].alpha > 0 then
                    transition.fadeOut( g.bg[i], { time=2500 } )
                end
            end
        end
        clearDrops()
        
        local function restart2()
            
            initials()
            header1.isVisible = true
            header2.isVisible = false
            header2:setEnabled( true )
            header2.alpha = 1
            storm.text = lvlParams.stormName
            gameIsActive = true
            checkIfGameIsOver = 0
            --Powerups
            arrowScale = 0.33
            arrowShape = arrowShapeRegular
            toBeScaled = true
            if invincibility == true then
                invincibility = false
                arrow.alpha = 1
            end
            --Timers
            timerIndex = {}
            timersPaused = {}
            spawnTimerFunction()
            levelTimerFunction()
            gameTimerFunction()
            scoreTimerFunction()
            
        end
        t.countDown( y1, y2, y3, transparentRect, restart2 )
        t.buttonsOut( green, red, blue, message )
        t.gameOverStatsOut( statsBG, sText1, sText2, tText1, tText2, statsLine1, statsLine2, statsLine3, scoreText, playTime, sHighText, tHighText, twitter, facebook )
    end
    
    
    local function play( event )------------------------------------
        print( "Play pressed" )
        
        header1.isVisible = true
        header2.isVisible = false
        header2:setEnabled( true )
        header2.alpha = 1
        
        local function listener()
            gameIsActive = true
            physics.start()
            transition.resume()
            for i = 1, #timersPaused do
                print( "Timer #"..timersPaused[i].." was resumed." )
                timer.resume( timerIndex[ timersPaused[i] ] )
            end
            
        end
        t.countDown( y1, y2, y3, transparentRect, listener )
        t.buttonsOut( green, red, blue, message )
        t.gameOverStatsOut( statsBG, sText1, sText2, tText1, tText2, statsLine1, statsLine2, statsLine3, scoreText, playTime, sHighText, tHighText, twitter, facebook )
        
        if gameOver == true then
            clearDrops()
            gameOver = false
        end
        
    end
    
    function pause( event )---------------------------------
        print( "Pause pressed" )
        
        gameIsActive = false
        header1.isVisible = false
        header2.isVisible = true
        transparentRect.alpha = 0.5
        transparentRect.isVisible = true
        physics.pause()
        transition.cancel( y1 )
        transition.cancel( y2 )
        transition.cancel( y3 )
        transition.cancel( g )
        transition.pause( )
        
        timersPaused = {}
        for i = 1, 9 do --From 1 to the number of timers in game
            if timerIndex[i] then
                print( "Timer #"..i.." was paused." )
                timer.pause( timerIndex[i] )
                timersPaused[ #timersPaused + 1 ] = i
            end
        end
        
        t.buttonsIn( green, red, blue, message )
        
    end
    
    
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------Header Group
    ----------------------------------------------------------------------------
    headerGroup = display.newGroup()
    group:insert(headerGroup)
    
    ----------------------------------------------------------Play/Pause Buttons
    header1 = widget.newButton {
        id = "header",
        width = 1000,
        height = 130,
        defaultFile = "images/header.png",
        onPress = pause,
    }
    header1.x = display.contentCenterX; header1.y = 0.5*header1.height
    headerGroup:insert(header1)
    header1:setEnabled( false )
    
    header2 = widget.newButton {
        id = "header2",
        width = 1000,
        height = 130,
        defaultFile = "images/header2.png",
        onPress = play,
    }
    header2.x, header2.y = header1.x, header1.y
    headerGroup:insert(header2)
    header2.isVisible = false
    
    -----------------------------------------------------------------------Score
    scoreText = display.newText {
        parent = headerGroup,
        text = "0",
        x = 15,
        y = 32,
        font = g.comRegular,
        fontSize = 38,
    }
    scoreText.anchorX, scoreText.anchorY = 0, 0.5
    
    
    ------------------------------------------------------------------------Time
    playTime = display.newText {
        parent = headerGroup,
        text = "0:00",
        x = display.contentWidth-15,
        y = 32,
        font = g.comRegular,
        fontSize = 38,
    }
    playTime.anchorX, playTime.anchorY = 1, 0.5
    
    -----------------------------------------------------------------------Lives
    local iconLives = display.newImageRect( headerGroup, "images/lives.png", 53, 53 )
    iconLives.x = display.contentWidth*0.3
    iconLives.anchorX, iconLives.anchorY = 1, 0
    
    g.iconLivesText = display.newText {
        parent = headerGroup,
        text = g.buy.lives,
        x = iconLives.x,
        y = iconLives.y+0.5*iconLives.height+4,
        font = g.comLight,
        fontSize = 32,
    }
    g.iconLivesText.anchorX, g.iconLivesText.anchorY = 0, 0.5
    
    -------------------------------------------------------------Invincibilities
    local iconInvince = display.newImageRect( headerGroup, "images/invincibility.png", 53, 53 )
    iconInvince.x = display.contentWidth*0.7
    iconInvince.anchorX, iconInvince.anchorY = 0, 0
    
    g.iconInvinceText = display.newText {
        parent = headerGroup,
        text = g.buy.invincibility,
        x = iconInvince.x,
        y = iconInvince.y+0.5*iconInvince.height+4,
        font = g.comLight,
        fontSize = 32,
    }
    g.iconInvinceText.anchorX, g.iconInvinceText.anchorY = 1, 0.5
    
    ------------------------------
    headerGroup.y = -header1.height
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    
 
    
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------Pause Screen
    ----------------------------------------------------------------------------
    
    local function greenListener( event )-----------------------------
        print( "Green pressed" )
        if checkIfGameIsOver == 1 then
            green:setLabel( "Are you sure?" )
            checkIfGameIsOver = 2
        elseif checkIfGameIsOver == 2 then
            g.buy.lives = g.buy.lives - 1
            g.buy:save()
            g.stats.revives = g.stats.revives + 1
            g.stats:save()
            g.iconLivesText.text = g.buy.lives
            revive = revive + 1
            play()
            checkIfGameIsOver = 0
            gameOver = false
        elseif checkIfGameIsOver == 0 then
            play()
        elseif checkIfGameIsOver == 4 then
            print( "You must purchase more lives" )
        end
    end
    local function redListener( event )-------------------------------
        print( "Red pressed" )
        ad.buttonColor = "red"
        if not g.buy.ads then
            ad.showAd()
        end
        --while( not g.adDone ) do end
        --g.adDone = false
        cp.gotoScene( "center" )
    end
    local function blueListener( event )------------------------------
        print( "Blue pressed" )
        ad.buttonColor = "blue"
        if not g.buy.ads then
            ad.showAd()
        end
        --while( not g.adDone ) do end
        --g.adDone = false
        --g.restart()
    end
    
    green = widget.newButton {
        id = "green",
        width = 550,
        height = 100,
        defaultFile = "images/buttonGreen.png",
        label = "Resume",
        labelYOffset = 8,
        labelColor = { default={ 0, 0.5, 0.36 }, over={ 0, 0.5, 0.36, 0.7 } },
        font = g.comLight,
        fontSize = 59,
        isEnabled = false,
        onRelease = greenListener,
    }
    group:insert( green )
    green.x, green.y = display.contentCenterX, 0
    green.anchorY = 1
    
    red = widget.newButton {
        id = "red",
        width = 250,
        height = 100,
        defaultFile = "images/buttonRed.png",
        label = "Main",
        labelYOffset = 8,
        labelColor = { default={ 0.63, 0.10, 0.14 }, over={ 0.63, 0.10, 0.14, 0.7 } },
        font = g.comLight,
        fontSize = 50,
        isEnabled = false,
        onRelease = redListener,
    }
    group:insert( red )
    red.x, red.y = -red.width, display.contentCenterY
    red.anchorX, red.anchorY = 0, 0
    
    blue = widget.newButton {
        id = "blue",
        width = 250,
        height = 100,
        defaultFile = "images/buttonBlue.png",
        label = "Restart",
        labelYOffset = 8,
        labelColor = { default={ 0.11, 0.46, 0.74 }, over={ 0.11, 0.46, 0.74, 0.7 } },
        font = g.comLight,
        fontSize = 50,
        isEnabled = false,
        onRelease = blueListener,
    }
    group:insert(blue)
    blue.x, blue.y = display.contentWidth+blue.width, red.y
    blue.anchorX, blue.anchorY = 1, 0
    
    
    
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    
    
    ------------------------------------------------------------------Storm Name
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
    
    -----------------------------------------------------Pause/Game Over Message
    local messageOptions = {
        parent = group,
        text = "Game Paused",
        y = 0.25*display.contentHeight,
        x = 0,
        width = display.contentWidth,
        font = g.comLight,
        fontSize = 100,
        align = "center",
    }
    message = display.newText( messageOptions )
    message.x = -0.5*message.width
    message:setFillColor( unpack( g.purple ) )
    message.anchorY = 0.5
    
    
    ----------------------------------------------------------------------------
    -------------------------------------------------------------Game Over Stats
    ----------------------------------------------------------------------------
    
    g.statsFocal = red.y+1.5*red.height
    g.statsAreaH = display.contentHeight - g.statsFocal
    local wh = 0.25 * g.statsAreaH
    
    statsBG = display.newImageRect(group, "images/statsBG.jpg", 800, 800) ------
    statsBG.x = display.contentCenterX
    statsBG.y = display.contentHeight
    statsBG.anchorY = 0
    statsBG.height = display.contentHeight - g.statsFocal
    statsBG.width = display.contentWidth
    statsBG.alpha = 0.8
    
    sText1 = display.newText( group, "Score: ", 0, 0, g.comRegular, 85 ) -------
    sText1:setFillColor( unpack( g.orange ) )
    local where = 0.33*(0.5*g.statsAreaH - 2*sText1.height)
    sText1.y = g.statsFocal + where + 7
    sText1.anchorX, sText1.anchorY = 1, 0
    
    sText2 = display.newText( group, " ", display.contentWidth, 0, g.comBold, 85 ) --
    sText2:setFillColor( unpack( g.orange ) )
    sText2.y = sText1.y - 0.16*sText2.height
    sText2.anchorX, sText2.anchorY = 0, sText1.anchorY
    
    tText1 = display.newText ( group, "Time: ", 0, 0, g.comRegular, 85 ) -------
    tText1:setFillColor( unpack( g.orange ) )
    tText1.y = g.statsFocal + 0.5*g.statsAreaH - where + 7
    tText1.anchorX, tText1.anchorY = 1, 1
    
    tText2 = display.newText ( group, " ", display.contentWidth, 0, g.comBold, 85 ) --
    tText2:setFillColor( unpack( g.orange ) )
    tText2.y = tText1.y - 0.05*tText2.height
    tText2.anchorX, tText2.anchorY = 0, tText1.anchorY
    
    statsLine1 = display.newLine( group, 0, g.statsFocal+0.5*g.statsAreaH, display.contentWidth, g.statsFocal+0.5*g.statsAreaH ) --
    statsLine1:setStrokeColor( unpack( g.purple ) )
    statsLine1.strokeWidth = 2
    statsLine1.alpha = 0
    
    statsLine2 = display.newLine( group, display.contentCenterX-0.5*wh, g.statsFocal+0.5*g.statsAreaH, display.contentCenterX-0.5*wh, display.contentHeight )
    statsLine2:setStrokeColor( unpack( g.purple ) )
    statsLine2.strokeWidth = 2
    statsLine2.alpha = 0
    
    statsLine3 = display.newLine( group, display.contentCenterX+0.5*wh, g.statsFocal+0.5*g.statsAreaH, display.contentCenterX+0.5*wh, display.contentHeight )
    statsLine3:setStrokeColor( unpack( g.purple ) )
    statsLine3.strokeWidth = 2
    statsLine3.alpha = 0
    
    local sHighTextOptions = { -------------------------------------------------
        parent = group,
        text = "High Score\n• • •\n",
        width = 0.5*display.contentWidth,
        height = 0,
        x = 0.5*statsLine2.x,
        font = g.comRegular,
        fontSize = 40,
        align = "center",
    }
    sHighText = display.newText( sHighTextOptions )
    sHighText:setFillColor( unpack( g.purple ) ) 
    --sHighText.x = 0.3*display.contentWidth
    sHighText.y = display.contentHeight+0.5*sHighText.height
    sHighText.anchorY = 0.5
    
    local tHighTextOptions = { -------------------------------------------------
        parent = group,
        text = "High Time\n• • •\n",
        width = 0.5*display.contentWidth,
        height = 0,
        x = display.contentWidth - sHighText.x,
        font = g.comRegular,
        fontSize = 40,
        align = "center",
    }
    tHighText = display.newText( tHighTextOptions )
    tHighText:setFillColor( unpack( g.purple ) )
    --tHighText.x = 0.7*display.contentWidth
    tHighText.y = sHighText.y
    tHighText.anchorY = sHighText.anchorY
    
    ----------------------------------------------------------------------------
    local function socialListener( event )
        
        local serviceName = event.target.id
        
        local isAvailable = native.canShowPopup( "social", serviceName )
        
        if isAvailable then
            
            native.showPopup( "social", 
            {
                service = serviceName,
                message = "I just dropped"..sText2.text.." points with a time of"..tText2.text.." in Drop - The Vertical Challenge! Check it out on the App Store!",
                --url = ,
            })
            
        else
            
            local bob
            if serviceName == "twitter" then
                bob = "Twitter"
            else
                bob = "Facebook"
            end
            
            native.showAlert(
                "Could not send "..bob.." message.",
                "Please setup your "..bob.." account or check your network connection.",
                { "OK" } )
            
        end
        
    end
    
    twitter = widget.newButton{
        id = "twitter",
        x = display.contentCenterX,
        y = g.statsFocal + 0.5 * g.statsAreaH,
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
        y = display.contentHeight,
        width = wh,
        height = wh,
        defaultFile = "images/facebook.png",
        overFile = "images/facebookD.png",
        onRelease = socialListener
    } 
    group:insert( facebook )
    facebook.anchorY = 1
    
    twitter.y = display.contentHeight + twitter.height
    facebook.y = twitter.y
    
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    
    
    ----------------------------------------------------------------------------
    -------------------------------------------------------------------------Ads
    ----------------------------------------------------------------------------
    
    
    
    g.create()
end


function scene:show( event )
    local group = self.view
    local phase = event.phase
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
        
        g.show()
        
        --g.countDown( group )
        
        --parse:logEvent( "Games", { ["screen"] = "Normal" } )
    
        --------------------------------------------------Important first things
        local windForce, gravityPower, multiplier, invincibility, s, m, h, dropsSpawned, dropsTable
        function initials() 
            system.setIdleTimer( false )
            system.setAccelerometerInterval( 60 )
            physics.start()
            physics.setGravity( 0, lvlParams.gravity )
            gravityPower = 1
            multiplier = 1
            invincibility  = false
            windForce = 0
            score = 0
            totalTime = 0
            s = 0
            m = 0
            h = 0
            dropsSpawned = 0
            dropsTable = {}
            dropsGroup = display.newGroup()
            group:insert( dropsGroup )
            dropsGroup:toBack()
            gameIsActive = true
            g.arrowX = arrow.x
            green:setLabel( "Resume" )
            blue:setLabel( "Restart" )
            transparentRect.isVisible = false
            transparentRect.fill = { 0, 0.65, 1 }
            gameOver = false
            g.stats.numGames = g.stats.numGames + 1
            g.stats:save()
            if g.gameSettings.specials == true then
                tHighText.text = "High Time\n• • •\n"..g.timeFormat( g.leaderboard.lb[2].value )
                sHighText.text = "High Score\n• • •\n"..g.commas( g.leaderboard.lb[1].value )
            else
                tHighText.text = "High Time\n• • •\n"..g.timeFormat( g.leaderboard.lb[4].value )
                sHighText.text = "High Score\n• • •\n"..g.commas( g.leaderboard.lb[3].value )
            end
            shield = 0
            revive = 0
            hurricaneTime = 0
            
        end
        initials()
        
        
        ------------------------------------------------------------------------
        -------------------------------------------------------------Transitions
        ------------------------------------------------------------------------
        
        ------------------------------------------------------------------Header
        local function headerTransitionListener( obj )
            header1:setEnabled( true )
        end
        transition.to( headerGroup, { time=500, y=0, transition=easing.outQuad, onComplete=headerTransitionListener } )
        
        --------------------------------------------------------------Storm Name
        local function stormName()
            local function listener()
                storm.x = -storm.width
            end
            transition.to( storm, { 
                time=1700, 
                x=display.contentWidth+storm.width, 
                transition=easing.outInCubic,
                onComplete = listener 
            } )
        end
        stormName()
        
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        
        
        ------------------------------------------------------------------------
        -----------------------------------------------------------------Gravity
        ------------------------------------------------------------------------
        
        ---------------------------------------------------------------Gravity Y
        local function gravityY()
            local gx, gy = physics.getGravity()
            gy = gravityPower*lvlParams.gravity
            physics.setGravity( gx, gy )
            print( "Gravity = "..gy )
        end
        
        --------------------------------------------------------Gravity X (Wind)
        function wind()
            windForce = windForce + 0.003
            local n = 0.15*lvlParams.phase*math.sin( windForce )
            local gx, gy = physics.getGravity()
            physics.setGravity( n, gy )
        end
        Runtime:addEventListener( "enterFrame", wind )
        
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        
        
        ------------------------------------------------------------------------
        ------------------------------------------------------------------ Arrow
        ------------------------------------------------------------------------
        
        physics.addBody( arrow, "static", { shape=arrowShape, friction=0, bounce=0 } )
        arrow.myName = "Arrow"
        
        ---------------------------------------------------------------Touch Pad
        touchPad = display.newImageRect( group, "images/fillT.png", display.contentWidth, display.contentHeight-header1.height )
        touchPad.x, touchPad.y = display.contentCenterX, header1.height
        touchPad.anchorY = 0
        
        ----------------------------------------------------------------Movement
        if g.gameSettings.tilt == true then --Tilt On
            local aw = 68--Largest # in "arrowShape" table
            local w = display.contentWidth
            function acc( event )
                if gameIsActive == true then
                    local x = arrow.x
                    local accelGravity = (35+10*(g.gameSettings.sensitivity-1))*event.xGravity
                    local t = x+accelGravity
                    if x < -aw+1 then
                        t = w+aw-1
                    elseif x > w+aw-1 then
                        t = -aw+1
                    end
                    if math.abs( event.xGravity ) > 0.04 then
                        arrow.x = t
                        g.arrowX = arrow.x
                    end
                end
                
            end
            Runtime:addEventListener( "accelerometer", acc )
        end
        --Touch On
        local aw = 68 --Arrow Width
        local w = display.contentWidth
        local X1 = -aw+2
        local X2 = w+aw-2
        local locationBegan
        local locationMoved
        local S = 1/(0.4*g.gameSettings.sensitivity)
        
        if g.gameSettings.tilt == false then
            local function arrowPortal( event )
                if gameIsActive == true then
                    local x = arrow.x
                    if x <= X1 then
                        arrow.x = X2-1
                        transition.to( arrow, { x=X1, time=S*arrow.x } )
                    elseif x >= X2 then
                        arrow.x = X1+1
                        transition.to( arrow, { x=X2, time=S*(w-arrow.x) } )
                    end
                    g.arrowX = arrow.x
                end
            end
            Runtime:addEventListener( "enterFrame", arrowPortal )
        end
        function touchPad:touch( event )
            if gameIsActive == true then
                if g.gameSettings.tilt == false then
                    if event.phase == "began" then
                        if event.x < display.contentCenterX then
                            lcoationBegan = "left"
                            transition.to( arrow, { x=X1, time=S*arrow.x } )
                        else
                            locationBegan = "right"
                            transition.to( arrow, { x=X2, time=S*(w-arrow.x) } )
                        end
                    elseif event.phase == "ended" then
                        transition.cancel( arrow )
                    end
                end
                if event.phase == "moved" then
                    local dy = event.yStart - event.y
                    if dy > 200 and invincibility == false and g.buy.invincibility > 0 then
                        invincibilityFunction( 5000 )
                        g.buy.invincibility = g.buy.invincibility - 1
                        g.buy:save()
                        g.iconInvinceText.text = g.buy.invincibility
                        shield = shield + 1
                    end
                end
            end
        end
        touchPad:addEventListener( "touch", touchPad )
        
        
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        
        
        ------------------------------------------------------------------------
        ---------------------------------------------------------Power Functions
        ------------------------------------------------------------------------
        
        -----------------------------------------------------------------Scaling
        function scaler()
            if toBeScaled == true then
                toBeScaled = false
                print( "Scaled" )
                physics.removeBody( arrow )
                arrow.xScale = arrowScale
                arrow.yScale = arrowScale
                arrow.y = display.contentHeight-150*arrowScale
                physics.addBody( arrow, "static", { shape=arrowShape, friction=0, bounce=0 } )
                arrow.myName = Arrow
            end
        end
        Runtime:addEventListener( "enterFrame", scaler )
        
        -----------------------------------------------------------Invincibility
        function invincibilityFunction( time )
            invincibility = true
            arrow.alpha = 0.5
            if invincibilityTimer then
                timer.cancel( invincibilityTimer )
            end
            local function listener()
                invincibility = false
                arrow.alpha = 1
                timerIndex[1] = nil
            end
            invincibilityTimer = timer.performWithDelay( time, listener )
            timerIndex[1] = invincibilityTimer
            g.stats.invinces = g.stats.invinces + 1
            g.stats:save()
        end
        
        
        ------------------------------------------------------------------------
        ----------------------------------------------------------------Droplets
        ------------------------------------------------------------------------
        local sheetOptions = {
            width = 110,
            height = 165,
            numFrames = 8,
            sheetContentWidth = 440,
            sheetContentHeight = 330,
        }
        local sheetNormal = graphics.newImageSheet( "images/dropletNormalSheet.png", sheetOptions )
        local sheetPower = graphics.newImageSheet( "images/dropletPowerSheet.png", sheetOptions)
        
        local dropRadius = 40
        local dropTriangle = { 0,-56, 28,-28, -28,-28 }
        
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        
        
        ------------------------------------------------------------------------
        ----------------------------------------------------------------Spawning
        ------------------------------------------------------------------------
        local lastXValue1 = 0
        local lastXValue2 = 0
        local sheet
        local frame
        local dropName
        
        ------------------------------------------------------Spawning Functions
        local numOfDropLocations = math.floor( display.contentWidth/80 ) + 1
        print( "There are "..numOfDropLocations.." drop locations for this device." )
        
        local dropCoordinates = {}
        for i = 1, numOfDropLocations do
            dropCoordinates[i] = (i-1)*80
        end
        
        local function randomDropImage()
            local n
            if g.gameSettings.specials == true then
                local r = math.random()
                if r <= 0.1 then ----------------------
                    sheet = sheetPower
                    n = 2
                else
                    sheet = sheetNormal
                    n = 1
                end
            else
                sheet = sheetNormal
                n = 1
            end
            frame = math.random( 1, 8 )
            dropName = n.."."..frame..":"..dropsSpawned+1
        end
        
        local function spawn( event )
            for i = 1, lvlParams.mode do
                dropsSpawned = dropsSpawned + 1
                dropsSpawned = s
                --Random x-values that don't repeat within 3 spawns
                local x
                repeat
                    x = math.random( 1, numOfDropLocations )
                until x ~= lastXValue1 and x ~= lastXValue2
                lastXValue2 = lastXValue1
                lastXValue1 = x
                --Spawn drop, add physics, add to dropsTable table
                randomDropImage()
                local drop = display.newImageRect( sheet, frame, 110, 165 )
                drop.x, drop.y = dropCoordinates[x], -0.5*drop.height
                dropsGroup:insert( drop )
                drop.myName = dropName
                dropsTable[s] = drop
                physics.addBody( drop, "dynamic", { radius=dropRadius, bounce=0.4 } )
                if lvlParams.phase >= 9 then
                    drop:setLinearVelocity( 0, 100 )
                end
            end
        end
        
        -------------------------------------------------------------Spawn Timer
        function spawnTimerFunction()
            spawnTimer = timer.performWithDelay( lvlParams.interval, spawn, -1 )
            timerIndex[2] = spawnTimer
        end
        spawnTimerFunction()
        
        ------------------------------------------------------------Level Timers
        local levelStart
        local levelComplete
        local levelTimer
        local levelDelayTimer
        local hurricaneTimer
        
        local function hurricaneTimerListener()
            local function listener2()
                hurricaneTime = 3
                timerIndex[10] = nil
            end
            local function listener1()
                hurricaneTime = 2
                timerIndex[10] = nil
                hurricaneTimer = timer.performWithDelay( 300000, listener2 )
                timerIndex[10] = hurricaneTimer
            end
            hurricaneTime = 1
            timerIndex[10] = nil
            hurricaneTimer = timer.performWithDelay( 240000, listener1 )
            timerIndex[10] = hurricaneTimer
        end
        
        function levelStart( event )
            print( lvlParams.stormName.." begun!" )
            timerIndex[4] = nil
            if lvlParams.phase ~= 13 then
                levelTimer = timer.performWithDelay( lvlParams.duration, levelComplete )
                timerIndex[3] = levelTimer
            else
                hurricaneTimer = timer.performWithDelay( 60000, hurricaneTimerListener )
                timerIndex[10] = hurricaneTimer
            end
            if lvlParams.mode == 1 then
                --Adjust gravity
                gravityY()
                --Switch background
                if g.gameSettings.bgChange == true then
                    g.m = (lvlParams.phase + 1)*0.5
                    local function listener()
                        g.bg[g.m-1].alpha = 0
                        g.bg[1].alpha = 1
                    end
                    transition.fadeIn( g.bg[g.m], { time=3500, onComplete=listener } )
                end
            end
            storm.text = lvlParams.stormName
            g.unlockLevelAchievements( lvlParams.phase )
            stormName()
            spawnTimerFunction()
        end
        
        function levelComplete( event )
            print( lvlParams.stormName.." complete!" )
            timerIndex[3] = nil
            timer.cancel( spawnTimer )
            timerIndex[2] = nil
            lvlParams = g.nextLevelParams( lvlParams.phase ) --switch params
            levelDelayTimer = timer.performWithDelay( 3000, levelStart )
            timerIndex[4] = levelDelayTimer
        end
        
        function levelTimerFunction()
            levelTimer = timer.performWithDelay( lvlParams.duration, levelComplete )
            timerIndex[3] = levelTimer
            print( lvlParams.stormName.." begun!")
        end
        levelTimerFunction()
        
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        
        
        --------------------------------------------------------------Game Timer
        local function gameTimerListener()
            totalTime = totalTime + 1
            playTime.text = g.timeFormat( totalTime )
        end
        function gameTimerFunction()
            gameTimer = timer.performWithDelay( 1000, gameTimerListener, 0 )
            timerIndex[5] = gameTimer
        end
        gameTimerFunction()
        
        
        -------------------------------------------------------------------Score
        local function scoreTimerListener()
            score = score + 1 * multiplier
            scoreText.text = g.commas( score )
        end
        function scoreTimerFunction()
            scoreTimer = timer.performWithDelay( 10, scoreTimerListener, 0 )
            timerIndex[6] = scoreTimer
        end
        scoreTimerFunction()
        
        ------------------------------------------------------------------------
        --------------------------------------------------------------Collisions
        ------------------------------------------------------------------------
        
        ------------------------------------------------------------Drop Removal
        rect = display.newRect( group, display.contentCenterX, display.contentHeight+sheetOptions.height, 4*display.contentWidth, 10 )
        physics.addBody( rect, "static", { bounce=1 } )
        rect.myName = "rect"
        local joe = 0
        function rectListener( self, event )
            if gameIsActive == true then
                if event.phase == "began" then
                    g.dropletStats( event.other.myName, "rect" )
                    display.remove( event.other )
                    event.other = nil
                    score = score + 100
                end
            end
        end
        rect.collision = rectListener
        rect:addEventListener( "collision", rect )
        
        ---------------------------------------------------------Arrow Collision
        local function arrowListener( self, event )
            if arrowIsWorking == true then
                if gameIsActive == true then
                    if event.phase == "began" then
                        
                        local p = string.sub( event.other.myName, 3, 3 )
                        
                        if string.sub( event.other.myName, 1, 1 ) == "1" then
                            
                            if invincibility == false then
                                gameOver = true
                                if g.buy.lives > 0 then
                                    checkIfGameIsOver = 1
                                    green:setLabel( "Revive with a life" )
                                else
                                    checkIfGameIsOver = 4
                                    green:setLabel( "Purchase lives" )
                                end
                                blue:setLabel( "Retry" )
                                message.text = "Game Over"
                                header2:setEnabled( false )
                                header2.alpha = 0.5
                                transparentRect.fill = { 1, 0, 0.15 }
                                pause()
                                g.stats.deaths = g.stats.deaths + 1
                                g.stats:save()
                                t.gameOverStatsIn( statsBG, sText1, sText2, tText1, tText2, statsLine1, statsLine2, statsLine3, scoreText, playTime, sHighText, tHighText, twitter, facebook )
                            end
                            
                        else
                            
                            if p == "1" then
                                gravityPower = 2
                                gravityY()
                                if gravityTimer then
                                    timer.cancel( gravityTimer )
                                end
                                local function listener()
                                    timerIndex[7] = nil
                                    gravityPower = 1
                                    gravityY()
                                end
                                gravityTimer = timer.performWithDelay( 10000, listener )
                                timerIndex[7] = gravityTimer
                            elseif p == "2" then
                                score = score - 3000 * multiplier
                            elseif p == "3" then
                                invincibilityFunction( 10000 )
                            elseif p == "4" then
                                if scaleTimer then
                                    timer.cancel( scaleTimer )
                                end
                                arrowScale = 0.26
                                arrowShape = arrowShapeSmall
                                toBeScaled = true
                                local function listener()
                                    timerIndex[8] = nil
                                    arrowScale = 0.33
                                    arrowShape = arrowShapeRegular
                                    toBeScaled = true
                                end
                                scaleTimer = timer.performWithDelay( 10000, listener )
                                timerIndex[8] = scaleTimer
                            elseif p == "5" then
                                if multiplierTimer then
                                    multiplier = multiplier + 3
                                    timer.cancel( multiplierTimer )
                                else
                                    multiplier = 3
                                end
                                local function listener()
                                    timerIndex[9] = nil
                                    multiplier = 1
                                end
                                multiplierTimer = timer.performWithDelay( 10000, listener )
                                timerIndex[9] = multiplierTimer
                            elseif p == "6" then
                                gravityPower = 0.5
                                gravityY()
                                if gravityTimer then
                                    timer.cancel( gravityTimer )
                                end
                                local function listener()
                                    timerIndex[7] = nil
                                    gravityPower = 1
                                    gravityY()
                                end
                                gravityTimer = timer.performWithDelay( 10000, listener )
                                timerIndex[7] = gravityTimer
                            elseif p == "7" then
                                score = score + 3000 * multiplier
                            elseif p == "8" then
                                if scaleTimer then
                                    timer.cancel( scaleTimer )
                                end
                                arrowScale = 0.4
                                arrowShape = arrowShapeLarge
                                toBeScaled = true
                                local function listener()
                                    timerIndex[8] = nil
                                    arrowScale = 0.33
                                    arrowShape = arrowShapeRegular
                                    toBeScaled = true
                                end
                                scaleTimer = timer.performWithDelay( 10000, listener )
                                timerIndex[8] = scaleTimer
                            end
                            
                            --animate and remove power drop
                            
                            --physics.removeBody( event.other ) --Produces arrow
                            
                            local function listener( obj )
                                display.remove( obj )
                                obj = nil
                            end
                            transition.to( event.other, { 
                                time = 80, 
                                alpha = 0, 
                                width = event.other.width*2,
                                height = event.other.height*2,
                                onComplete = listener,
                            } )
                            
                        end
                        g.dropletStats( event.other.myName, "arrow" ) --record stats about drops and their respective colors
                    end
                end
            end
        end
        arrow.collision = arrowListener
        arrow:addEventListener( "collision", arrow )
    end
end


function scene:hide( event )
    local group = self.view
    local phase = event.phase
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
        
        g.hide()
        
        system.setIdleTimer( true )
        system.setAccelerometerInterval( 30 )
        Runtime:removeEventListener( "accelerometer", acc )
        Runtime:removeEventListener( "enterFrame", wind )
        Runtime:removeEventListener( "enterFrame", scaler )
        Runtime:removeEventListener( "enterFrame", arrowPortal )
        touchPad:removeEventListener( "touch", touchPad )
        rect:removeEventListener( "collision", rect )
        arrow:removeEventListener( "collision", arrow )
        for i = 1, 10 do
            if timerIndex[i] then
                timer.cancel( timerIndex[i] )
            end
        end
        transition.cancel()
        physics.stop()
        
        
        records()
        
        cp.removeScene( "game" )
        
    end
end


function scene:destroy( event )
    local group = self.view
    
    print( "Scene was destroyed" )
    
    g.destroy()
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene