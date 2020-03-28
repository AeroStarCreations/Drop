--Center

local controller = require( "controllers.centerController" )
local cp = require( "composer" )
local scene = cp.newScene()
local g = require( "other.globalVariables" )
local widget = require( "widget" )
local GGTwitter = require( "thirdParty.GGTwitter" )
local logoModule = require( "other.logoModule" )
local ld = require( "data.localData" )

-- Precalls
local facebook
local twitter
local achievementButton

local function transitionOutAchievementButton()
    transition.to( achievementButton, { time=400, delay=400, xScale=0.01, yScale=0.01, transition=easing.inBack } )
end

function scene:create( event )
    local group = self.view
    
    g.create()

    --------------------------------------------Aero Star Creations
    local asc = display.newText( "Aero Star Creations", display.contentCenterX, 0, g.comBold, 30)
    asc.yIn = display.contentHeight - 30
    asc.yOut = display.contentHeight + 50
    asc.y = asc.yOut
    asc:setFillColor( unpack(g.purple) )
    group:insert(asc)
    controller.linkASC(asc)
    ---------------------------------------------------------------
    
    --------------------------------------------Drop Logo
    local drop = logoModule.getBigLogo(group)
    drop.yOutToGame = -drop.height
    drop.yOut = logoModule.getSmallLogoY()
    drop.xScaleIn = 1
    drop.yScaleIn = 1
    drop.xScaleOut = 0.47
    drop.yScaleOut = 0.47
    controller.linkDrop(drop)
    -----------------------------------------------------
    
    --------------------------------------------Arrow
    local arrowW, arrowH = 352, 457
    g.arrowRatio = arrowW / arrowH
    
    local arrow = widget.newButton {
        id = "arrow",
        width = arrowW,
        height = arrowH,
        defaultFile = "images/arrow.png",
        overFile = "images/arrowD.png",
        onRelease = controller.arrowListener,
    }
    arrow.xIn = display.contentCenterX + 17
    arrow.xOut = display.contentWidth+arrow.width
    arrow.xOutToGame = display.contentCenterX
    arrow.yIn = display.contentCenterY
    arrow.yOut = display.contentHeight - 49.5
    arrow.xScaleIn = 1
    arrow.yScaleIn = 1
    arrow.xScaleOut = 0.33
    arrow.yScaleOut = 0.33
    arrow.x = arrow.xIn
    arrow.y = arrow.yIn
    arrow.xScale = 0.01
    arrow.yScale = 0.01
    group:insert(arrow)
    controller.linkArrow(arrow)
    -------------------------------------------------
    
    --------------------------------------------Social Buttons
    --MAKE A NEW FILE FOR OFFICIAL FACEBOOK AND TWITTER FUNCTIONS
    local function fbFunction (event)
        if event.phase == "began" then
            facebook.xScale = 1.4; facebook.yScale = 1.4
        elseif event.phase == "moved" then
            facebook.xScale = 1; facebook.yScale = 1
        elseif event.phase == "ended" then
            facebook.xScale = 1; facebook.yScale = 1
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
            twitter.xScale = 1.4; twitter.yScale = 1.4
        elseif event.phase == "moved" then
            twitter.xScale = 1; twitter.yScale = 1
        elseif event.phase == "ended" then
            twitter.xScale = 1; twitter.yScale = 1
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
    
    facebook = widget.newButton {
        id = "fb",
        x = 0,
        y = 0.8 * display.contentHeight,
        width = 120,
        height = 120,
        defaultFile = "images/facebook.png",
        overFile = "images/facebookD.png",
        onEvent = fbFunction,
    }
    facebook.xIn = display.contentCenterX - 80
    facebook.xOut = -facebook.width
    facebook.x = facebook.xOut
    group:insert(facebook)
    controller.linkFacebook(facebook)
    
    twitter = widget.newButton {
        id = "twit",
        x = 0,
        y = facebook.y,
        width = facebook.width,
        height = facebook.height,
        defaultFile = "images/twitter.png",
        overFile = "images/twitterD.png",
        onEvent = twitFunction,
    }
    twitter.xIn = display.contentCenterX + 80
    twitter.xOut = display.contentWidth + twitter.width
    twitter.x = twitter.xOut
    group:insert(twitter)
    controller.linkTwitter(twitter)
    -------------------------------------------------------------
    
    -----------------------------------------------------Settings
    local settings = widget.newButton {
        id = "settings",
        width = 120,
        height = 120,
        defaultFile = "images/settings.png",
        overFile = "images/settingsD.png",
        onRelease = controller.settingsListener,
    }
    settings.xIn = display.contentWidth
    settings.xOut = display.contentWidth + 200
    settings.yIn = display.contentHeight
    settings.yOut = display.contentHeight + 200
    settings.x = settings.xOut
    settings.y = settings.yOut
    settings.anchorX = 1
    settings.anchorY = 1
    group:insert( settings )
    controller.linkSettings(settings)
    -------------------------------------------------------------
    
    ---------------------------------------------------------More
    local extras = widget.newButton {
        id = "extras",
        width = 120,
        height = 120,
        defaultFile = "images/info.png",
        overFile = "images/infoD.png",
        onRelease = controller.extrasListener,
    }
    extras.xIn = 0
    extras.xOut = -200
    extras.yIn = display.contentHeight
    extras.yOut = display.contentHeight + 200
    extras.x = extras.xOut
    extras.y = extras.yOut
    extras.anchorX = 0
    extras.anchorY = 1
    group:insert( extras )
    controller.linkExtras(extras)
    -------------------------------------------------------------

    -------------------------------------------------Achievements
    local livesImage = display.newImageRect(group, "images/lives.png", 53, 53)
    livesImage.y = arrow.y - 0.6 * arrow.height
    livesImage.anchorX = 0
    livesImage.xScale, livesImage.yScale = 0.01, 0.01
    controller.linkLivesImage(livesImage)

    local invincibilitesImage = display.newImageRect(group, "images/invincibility.png", 53, 53)
    invincibilitesImage.y = livesImage.y
    invincibilitesImage.anchorX = 0
    invincibilitesImage.xScale, invincibilitesImage.yScale = 0.01, 0.01
    controller.linkInvincibilityImage(invincibilitesImage)

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
    controller.linkLivesText(livesText)

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
    controller.linkInvincibilityText(invincibilitesText)

    local circleRadius = 40
    achievementButton = widget.newButton({
        x = display.actualContentWidth - 1.5 * circleRadius,
        y = 0 + 1.5 * circleRadius,
        onRelease = controller.achievementButtonListener,
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
    controller.linkAchievementButton(achievementButton)
    -------------------------------------------------------------

end

function scene:show( event )
    local group = self.view
    local phase = event.phase
    
    if phase == "will" then
        
    elseif phase == "did" then
        
        g.show()
        
        cp.loadScene( "views.scenes.game2" )
        
        ----------------------------------------Show and Update Achievement Indicator
        -- For testing
        ld.addUnawardedAchievement( {
            shortCode = "shortCode",
            reward = {
                lives = 1,
                invincibilities = 1,
                description = "the description"
            }
        })
        ld.addUnawardedAchievement( {
            shortCode = "shortCode",
            reward = {
                lives = 1,
                invincibilities = 1,
                description = "the description"
            }
        })

        achievementButton:setLabel( ld.quantityUnawardedAchievements() )
        ---------------------------------------------------------------------------]]
        
        controller.transitionIn()

    end
end

function scene:hide( event )
    local group = self.view
    local phase = event.phase
    
    if phase == "will" then
        
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