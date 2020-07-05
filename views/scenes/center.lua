--Requires
local controller = require( "controllers.centerController" )
local cp = require( "composer" )
local scene = cp.newScene()
local g = require( "other.globalVariables" )
local widget = require( "widget" )
local logoModule = require( "other.logoModule" )
local ld = require( "data.localData" )
local social = require("other.socialNetworks")
local metrics = require("other.metrics")
local fonts = require("other.fonts")
local colors = require("other.colors")

-- Precalls
local TAG = "center.lua: "

local achievementButton

function scene:create( event )
    local group = self.view
    
    g.create()

    --------------------------------------------Aero Star Creations
    local asc = display.newText( "Aero Star Creations", display.contentCenterX, 0, fonts.getBold(), 30)
    asc.yIn = display.contentHeight - 30
    asc.yOut = display.contentHeight + 50
    asc.y = asc.yOut
    asc:setFillColor( colors.purple:unpack() )
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
    local function socialButtonListener(event)
        if event.phase == "began" then
            event.target.xScale = 1.4;
            event.target.yScale = 1.4
        elseif event.phase == "moved" then
            event.target.xScale = 1;
            event.target.yScale = 1
        elseif event.phase == "ended" then
            print(TAG, event.target.id .. " pressed")
            event.target.xScale = 1;
            event.target.yScale = 1
            if event.target.id == "facebook" then
                social.openAscOnFacebook(group)
                metrics.logEvent("center_facebook_click")
            elseif event.target.id == "twitter" then
                social.followAscOnTwitter()
                metrics.logEvent("center_twitter_click")
            end
        end
    end
    
    local facebook = widget.newButton {
        id = "facebook",
        x = 0,
        y = 0.8 * display.contentHeight,
        width = 120,
        height = 120,
        defaultFile = "images/facebook.png",
        overFile = "images/facebookD.png",
        onEvent = socialButtonListener,
    }
    facebook.xIn = display.contentCenterX - 80
    facebook.xOut = -facebook.width
    facebook.x = facebook.xOut
    group:insert(facebook)
    controller.linkFacebook(facebook)
    
    local twitter = widget.newButton {
        id = "twitter",
        x = 0,
        y = facebook.y,
        width = facebook.width,
        height = facebook.height,
        defaultFile = "images/twitter.png",
        overFile = "images/twitterD.png",
        onEvent = socialButtonListener,
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
        font = fonts.getBold(),
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
        font = fonts.getBold(),
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
        label = ld.unawardedAchievementCount(),
        labelColor = { default={ 1, 1, 1 }, over={ 0.9, 0.9, 0.9 } },
        font = fonts.getBold(),
        fontSize = 40,
        shape = "circle",
        radius = circleRadius,
        fillColor = { default={ 1, 0, 0 }, over={ 0.9, 0.1, 0.1 } },
    })
    group:insert(achievementButton)
    achievementButton.xScale = 0.01
    achievementButton.yScale = 0.01
    achievementButton.isVisible = false
    controller.linkAchievementButton(achievementButton)
    -------------------------------------------------------------

end

function scene:show( event )
    local group = self.view
    local phase = event.phase
    
    if phase == "will" then
        
    elseif phase == "did" then
        
        g.show()
        
        cp.loadScene( "views.scenes.game" )

        controller.syncGameStatsAndAchievements()
        
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