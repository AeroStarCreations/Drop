--Center

local cp = require( "composer" )
local scene = cp.newScene()
local g = require( "globalVariables" )
local widget = require( "widget" )
local t = require( "transitions" )
local GGTwitter = require( "GGTwitter" )
local logoModule = require( "logoModule" )
local ld = require( "localData" )
local Alert = require( "Alert" )
local bg = require( "backgrounds" )

-------Precalls 
local asc
local drop
local arrow
local fb
local twit
local settings
local extras
local rotate
local achievementButton
------- 

------------------------------------------------------Functions
local function transitionOutAchievementButton()
    transition.to( achievementButton, { time=400, delay=400, xScale=0.01, yScale=0.01, transition=easing.inBack } )
end
---------------------------------------------------------------

----------------------------------------- Transition In and Out
local function transitionIn( onComplete )
    local function arrowCheck( event )
        if arrow.x ~= display.contentCenterX+17 then
            arrow.x = -arrow.width
            transition.to( arrow, { time=800, transition=easing.outQuad, x=display.contentCenterX+17, onComplete=arrowCheck } )
        end
    end

    local logoY = logoModule.getBigLogoY(arrow)
    
    transition.to( asc, { time=400, y=display.contentHeight-30, transition=easing.outQuad } )
    transition.to( drop, { time=700, y=logoY, transition=easing.outQuad, xScale=1, yScale=1--[[, rotation=0--]], onComplete=onComplete } )
    transition.to( fb, { time=700, x=display.contentCenterX - 80, transition=easing.outQuad } )
    transition.to( twit, { time=700, x=display.contentCenterX + 80, transition=easing.outQuad } )
    transition.to( extras, { time=600, x=0, y=display.contentHeight, transition=easing.outQuad } )
    transition.to( settings, { time=600, x=display.contentWidth, y=display.contentHeight, transition=easing.outQuad } )
    if ld.hasUnawardedAchievement() then
        transition.to( achievementButton, { delay=300, time=300, xScale=1, yScale=1, transition=easing.outBack } )
    end
    
    if g.justOpened then
        transition.to( arrow, { time=900, xScale=1, yScale=1, transition=easing.outBack } )
    elseif cp.getSceneName( "previous" ) == "game2" then
        arrow.x = g.arrowX
        transition.to( arrow, { time=1200, transition=easing.outBack, x=display.contentCenterX+17, y=display.contentCenterY, xScale=1, yScale=1, rotation=rot2 })
    else
        arrow.x = -arrow.width
        transition.to( arrow, { time=800, transition=easing.outQuad, x=display.contentCenterX+17, onComplete=arrowCheck } )
    end

    --Fade out the backgrounds from gameplay
    if ld.getChangingBackgroundsEnabled() then
        bg.fadeOutToDefault()
    end
end

local function transitionOut()
    local function startListener( event )
        arrow:setEnabled( false )
        fb:setEnabled( false )
        twit:setEnabled( false )
        extras:setEnabled( false )
        settings:setEnabled( false )
        
        print( "Transitions begun" )
    end
    
    local function finishListener( event )
        arrow:setEnabled( true )
        fb:setEnabled( true )
        twit:setEnabled( true )
        extras:setEnabled( true )
        settings:setEnabled( true )
        
        if g.goingToGame == true then
            cp.gotoScene( "game2" )
        elseif g.goingToExtras == true then
            cp.gotoScene( "extras" )
        elseif g.goingToSettings == true then
            cp.gotoScene( "settings" )
        end
        
        print( "Transitions complete" )
    end
    
    local a = math.random()
    if a < 0.5 then
        rot1 = arrow.rotation-90
        rot2 = 0--arrow.rotation+90
    else
        rot1 = arrow.rotation+270
        rot2 = 0--arrow.rotation-270
    end
    
    if g.goingToGame == true then
        transition.to( asc, { time=400, delay=800, y=display.contentHeight+50, transition=easing.inQuad } )
        transition.to( drop, { time=700, y=-drop.height, transition=easing.inQuad } )
        transition.to( arrow, { time=2000, transition=easing.inOutBack, x=display.contentCenterX, y=display.contentHeight-49.5, xScale=0.33, yScale=0.33, rotation=rot1, onStart=startListener, onComplete=finishListener })
        transition.to( fb, { time=700, delay=500, x=-fb.width, transition=easing.inQuad } )
        transition.to( twit, { time=700, delay=500, x=display.contentWidth+twit.width, transition=easing.inQuad } )
        transition.to( extras, { time=600, delay=800, x=-200, y=display.contentHeight+200, transition=easing.inQuad } )
        transition.to( settings, { time=600, delay=800, x=display.contentWidth+200, y=display.contentHeight+200, transition=easing.inQuad } )
    else
        transition.to( asc, { time=400, delay=400, y=display.contentHeight+50, transition=easing.inQuad } )
        transition.to( drop, { time=500, delay=300, y=logoModule.getSmallLogoY(), transition=easing.inQuad, xScale=0.47, yScale=0.47, rotation=0 } )
        transition.to( arrow, { time=800, transition=easing.inQuad, x=display.contentWidth+arrow.width, onStart=startListener, onComplete=finishListener } )
        transition.to( fb, { time=700, delay=100, x=-fb.width, transition=easing.inQuad } )
        transition.to( twit, { time=700, delay=100, x=display.contentWidth+twit.width, transition=easing.inQuad } )
        transition.to( extras, { time=600, delay=200, x=-200, y=display.contentHeight+200, transition=easing.inQuad } )
        transition.to( settings, { time=600, delay=200, x=display.contentWidth+200, y=display.contentHeight+200, transition=easing.inQuad } )
    end
    transitionOutAchievementButton()
end
--------------------------------------------------------------]]
    

function scene:create( event )
    local group = self.view
    
    g.create()

    --------------------------------------------Aero Star Creations
    asc = display.newText( "Aero Star Creations", display.contentCenterX, display.contentHeight+50, g.comBold, 30)
    asc:setFillColor( unpack(g.purple) )
    group:insert(asc)
    ---------------------------------------------------------------
    
    --------------------------------------------Drop Logo
    drop = logoModule.getBigLogo(group)
    -----------------------------------------------------
    
    --------------------------------------------Arrow
    local arrowW, arrowH = 352, 457
    g.arrowRatio = arrowW/arrowH
    
    local function arrowFunction( event )
        g.goingToGame = true
        Runtime:removeEventListener( "accelerometer", rotate )
        transitionOut()
    end
    
    arrow = widget.newButton {
        id = "arrow",
        x = display.contentCenterX+17,
        y = display.contentCenterY,
        width = arrowW,
        height = arrowH,
        defaultFile = "images/arrow.png",
        overFile = "images/arrowD.png",
        onRelease = arrowFunction,
    }
    group:insert(arrow)
    arrow.xScale, arrow.yScale = 0.01, 0.01
    -------------------------------------------------
    
    --------------------------------------------Social Buttons
    --MAKE A NEW FILE FOR OFFICIAL FACEBOOK AND TWITTER FUNCTIONS
    local function fbFunction (event)
        if event.phase == "began" then
            fb.xScale = 1.4; fb.yScale = 1.4
        elseif event.phase == "moved" then
            fb.xScale = 1; fb.yScale = 1
        elseif event.phase == "ended" then
            fb.xScale = 1; fb.yScale = 1
            print("Facebook pressed")
            local facebookView
            local facebookViewListener
            
            local button1
            
            local function buttonListener(event)
                facebookView:removeEventListener( "urlRequest", facebookViewListener )
                facebookView:removeSelf()
                facebookView = nil
                button1:removeSelf()
                button1 = nil
            end
            
            button1 = widget.newButton{
                width = display.contentWidth,
                height = 150,
                x = display.contentCenterX,
                y = display.contentHeight - 0.5*150,
                onRelease = buttonListener,
                label = "Close",
                labelYOffset = 7,
                font = g.comRegular,
                fontSize = 60,
                labelColor = { default={ 1, 1, 1 }, over={ 0.8, 0.8, 1 } },
                defaultFile = "images/buttonGreen.png",
            }
            group:insert(button1)
            
            function facebookViewListener(event)
                if event.url then
                    print("facebook 1")
                    facebookView:removeEventListener( "urlRequest", facebookViewListener )
                end
                if event.errorCode then
                    print("facebook 2")
                    native.showAlert( "Error!", event.errorMessage, { "OK" } )
                    facebookView:removeSelf()
                    button1:removeSelf()
                    button1 = nil
                    facebookView:removeEventListener( "urlRequest", facebookViewListener )
                    facebookView = nil
                end
            end
            
            facebookView = native.newWebView( display.contentCenterX, display.contentCenterY-0.5*150 ,display.contentWidth, display.contentHeight-150 )
            facebookView:request("https://www.facebook.com/AeroStarCreations")
            facebookView:addEventListener( "urlRequest", facebookViewListener )
        end
    end
    
    local function twitFunction (event)
        if event.phase == "began" then
            twit.xScale = 1.4; twit.yScale = 1.4
        elseif event.phase == "moved" then
            twit.xScale = 1; twit.yScale = 1
        elseif event.phase == "ended" then
            twit.xScale = 1; twit.yScale = 1
            print("Twitter pressed")
            local twitter
            local function twitterListener( event )
                if event.phase == "authorised" then
                    local function onComplete( event )
                        if event.action == "clicked" then
                            local i = event.index
                            if i == 1 then
                                --Dialog will dismiss automatically
                            elseif i == 2 then
                                twitter:follow( "Aero_SC" )
                                native.showAlert( "Done!", "You are know following Aero Star Creations (Aero_SC).", { "Alrighty" } )
                            end
                        end
                    end
                    native.showAlert( "Follow Aero Star Creations?", "Follow Aero_SC to stay up-to-date on news, sneak peeks, and more.", { "Later", "Follow" }, onComplete )
                elseif event.phase == "failed" then 
                    print( "Twitter not authorised" )
                end
            end
            twitter = GGTwitter:new( "C4gwN8bpltRt2N632U6epuQ9Q", "UDwrF3kWTpLId9IVr7GN81pQ9Lh5WaM7URygS1G4VRgVpBSkSI", twitterListener, "https://twitter.com/Aero_SC" )
            twitter:authorise()
        end
    end
    
    fb = widget.newButton {
        id = "fb",
        x = -120,
        y = 0.8*display.contentHeight,
        width = 120,
        height = 120,
        defaultFile = "images/facebook.png",
        overFile = "images/facebookD.png",
        onEvent = fbFunction,
    }
    group:insert(fb)
    
    twit = widget.newButton {
        id = "twit",
        x = display.contentWidth+fb.width,
        y = fb.y,
        width = fb.width,
        height = fb.height,
        defaultFile = "images/twitter.png",
        overFile = "images/twitterD.png",
        onEvent = twitFunction,
    }
    group:insert(twit)
    -------------------------------------------------------------
    
    -----------------------------------------------------Settings
    local function settingsFunction (event)
        g.goingToSettings = true
        transitionOut()
    end
    
    settings = widget.newButton {
        id = "settings",
        x = display.contentWidth + 200,
        y = display.contentHeight + 200,
        width = 120,
        height = 120,
        defaultFile = "images/settings.png",
        overFile = "images/settingsD.png",
        onRelease = settingsFunction,
    }
    group:insert( settings )
    settings.anchorX = 1; settings.anchorY = 1
    -------------------------------------------------------------
    
    ---------------------------------------------------------More
    local function extrasFunction (event)
        g.goingToExtras = true
        transitionOut()
    end
    
    extras = widget.newButton {
        id = "extras",
        x = - 200,
        y = display.contentHeight + 200,
        width = 120,
        height = 120,
        defaultFile = "images/info.png",
        overFile = "images/infoD.png",
        onRelease = extrasFunction,
    }
    group:insert( extras )
    extras.anchorX = 0; extras.anchorY = 1
    -------------------------------------------------------------

    -------------------------------------------------Achievements
    local distFromCenterX = display.actualContentWidth / 7
    local rewardLives = 0
    local rewardInvincibilites = 0

    local livesImage = display.newImageRect(group, "images/lives.png", 53, 53)
    livesImage.y = arrow.y - 0.6 * arrow.height
    livesImage.anchorX = 0
    livesImage.xScale, livesImage.yScale = 0.01, 0.01

    local invincibilitesImage = display.newImageRect(group, "images/invincibility.png", 53, 53)
    invincibilitesImage.y = livesImage.y
    invincibilitesImage.anchorX = 0
    invincibilitesImage.xScale, invincibilitesImage.yScale = 0.01, 0.01

    local livesText = display.newText({
        parent = group,
        text = " ",
        y = livesImage.y,
        x = livesImage.x,
        font = g.comBold,
        fontSize = 40
    })
    livesText:setFillColor(0, 0, 0)
    livesText.anchorX = 1
    livesText.xScale, livesText.yScale = 0.01, 0.01

    local invincibilitesText = display.newText({
        parent = group,
        text = " ",
        y = livesImage.y,
        x = invincibilitesImage.x,
        font = g.comBold,
        fontSize = 40
    })
    invincibilitesText:setFillColor(0, 0, 0)
    invincibilitesText.anchorX = 1
    invincibilitesText.xScale, invincibilitesText.yScale = 0.01, 0.01

    local function updateRewardTexts()
        livesText.text = "+" .. rewardLives
        invincibilitesText.text = "+" .. rewardInvincibilites
    end

    local function updateRewardPosition()
        if rewardLives == 0 then
            invincibilitesImage.x = display.contentCenterX
            invincibilitesText.x = invincibilitesImage.x
        elseif rewardInvincibilites == 0 then
            livesImage.x = display.contentCenterX
            livesText.x = livesImage.x
        else
            invincibilitesImage.x = display.contentCenterX - distFromCenterX
            invincibilitesText.x = invincibilitesImage.x
            livesImage.x = display.contentCenterX + distFromCenterX
            livesText.x = livesImage.x
        end
    end

    local function setRewardScales()
        livesImage.xScale = 0.01
        livesImage.yScale = 0.01
        livesText.xScale = 0.01
        livesText.yScale = 0.01
        invincibilitesImage.xScale = 0.01
        invincibilitesImage.yScale = 0.01
        invincibilitesText.xScale = 0.01
        invincibilitesText.yScale = 0.01
    end

    local function setRewardAlpha()
        livesImage.alpha = 1
        livesText.alpha = 1
        invincibilitesImage.alpha = 1
        invincibilitesText.alpha = 1
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
            transition.to( invincibilitesImage, paramsIn )
            transition.to( invincibilitesText, paramsIn )
            transition.to( invincibilitesImage, paramsOut )
            transition.to( invincibilitesText, paramsOut )
        end
    end

    local function showRewardAnimation()
        updateRewardTexts()
        updateRewardPosition()
        setRewardScales()
        setRewardAlpha()
        playAnimation()
    end

    local function achievementFunction( event )
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

    local circleRadius = 40
    achievementButton = widget.newButton({
        x = display.actualContentWidth - 1.5 * circleRadius,
        y = 0 + 1.5 * circleRadius,
        onRelease = achievementFunction,
        label = ld.quantityUnawardedAchievements(),
        labelColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },
        font = g.comBold,
        fontSize = 40,
        shape = "circle",
        radius = circleRadius,
        fillColor = { default={ 1, 0, 0 }, over={ 0.9, 0.1, 0.1 } },
    })
    group:insert(achievementButton)
    achievementButton.xScale = 0.01
    achievementButton.yScale = 0.01
    -------------------------------------------------------------

end

function scene:show( event )
    local group = self.view
    local phase = event.phase
    
    if phase == "will" then
        
    elseif phase == "did" then
        
        g.show()
        
        cp.loadScene( "game2" )
        
        -----------------------------------------Creates the accelerometer rotations
        function rotate( event )
            local r = -event.xGravity*90
            fb.rotation = r
            twit.rotation = r
            drop.rotation = -event.xGravity*25--r*0.25
            return true
        end
        local function transDone( )
            Runtime:addEventListener( "accelerometer", rotate )
        end
        -----------------------------------------------------------------------------

        ----------------------------------------Show and Update Achievement Indicator
        -- For testing
        -- ld.addUnawardedAchievement( {
        --     shortCode = "shortCode",
        --     reward = {
        --         lives = 1,
        --         invincibilities = 1,
        --         description = "the description"
        --     }
        -- })

        achievementButton:setLabel( ld.quantityUnawardedAchievements() )
        ---------------------------------------------------------------------------]]
        
        transitionIn( transDone )
        
    end
end

function scene:hide( event )
    local group = self.view
    local phase = event.phase
    
    if phase == "will" then
        
        g.justOpened = false
        
    elseif phase == "did" then
        
        g.hide()
        
    end
    
end

function scene:destroy( event )
    
    g.destroy()
    
end

---------------------------------------------------------------------------------
-- END OF IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )

scene:addEventListener( "show", scene )

scene:addEventListener( "hide", scene )

scene:addEventListener( "destroy", scene )

return scene
---------------------------------------------------------------------------------