--Requires
local controller = require("controllers.aboutASCController")
local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "other.globalVariables" )
local logoModule = require( "other.logoModule" )
local social = require( "other.socialNetworks" )
local metrics = require("other.metrics")

--Precalls
local TAG = "aboutASC.lua: "

function scene:create( event )

    local group = self.view
    
    g.create()
    
    ------------------------------------------Logo
    local drop = logoModule.getSmallLogo(group)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local backArrow = widget.newButton{
        id = "backArrow",
        x = 90,
        y = 0,
        width = 100*g.arrowRatio,
        height = 100,
        defaultFile = "images/arrow.png",
        overFile = "images/arrowD.png",
        onRelease = controller.backArrowListener,
    }
    backArrow.rotation = 180
    backArrow.x = 0.4 * (drop.x - 0.5 * drop.width)
    backArrow.y = drop.y + 0.5 * drop.height
    group:insert(backArrow)
    ----------------------------------------------

    --------------------------------------ASC Logo
    local ascLogo = display.newImageRect( group, "images/ASClogo.png", 266, 266 )
    ascLogo.height = 1.1 * backArrow.height
    ascLogo.width = ascLogo.height
    ascLogo.xIn = drop.x + 0.5*drop.contentWidth + 0.5*(display.contentWidth - drop.x - 0.5*drop.contentWidth)
    ascLogo.xOut = display.contentWidth + 0.5*ascLogo.width
    ascLogo.x = ascLogo.xOut
    ascLogo.y = backArrow.y
    controller.linkASCLogo(ascLogo)
    ----------------------------------------------

    -------------------------"Aero Star Creations"
    local asc = display.newText( group, "Aero Star Creations", display.contentCenterX, 0, g.comBold, 70, "center")
    asc:setFillColor( unpack(g.purple) )
    asc.y = drop.y + drop.height + 0.7 * asc.height
    asc.alphaIn = 1
    asc.alphaOut = 0
    asc.alpha = asc.alphaOut
    controller.linkASC(asc)
    ----------------------------------------------

    -----------------------------------------Lines
    local lineTopY = asc.y - 0.5 * asc.height
    local lineTop = display.newLine( group, 0, lineTopY, display.contentWidth, lineTopY )
    lineTop:setStrokeColor( unpack( g.purple ) )
    lineTop.strokeWidth = 2
    lineTop.xIn = 0
    lineTop.xOut = display.contentWidth
    lineTop.x = -display.contentWidth
    controller.linkLineTop(lineTop)

    local lineBottomY = lineTopY + asc.height
    local lineBottom = display.newLine( group, 0, lineBottomY, display.contentWidth, lineBottomY )
    lineBottom:setStrokeColor( unpack( g.purple ) )
    lineBottom.strokeWidth = 2
    lineBottom.xIn = 0
    lineBottom.xOut = -display.contentWidth
    lineBottom.x = display.contentWidth
    controller.linkLineBottom(lineBottom)
    ----------------------------------------------

    ------------------------------------------Text
    local bio = display.newText( group, "Joe Shmoe", display.contentCenterX, lineBottom.y, 0.9*display.contentWidth, 0, g.comRegular, 26, "center")
    bio:setFillColor( 0, 0, 0 )
    bio.anchorY = 0
    bio.text = "\n\n\tHello!  I'm Nathan, the little man behind Aero Star Creations.  I hope you've enjoyed Drop so far!  I had an incredible time developing the game.  Now here's a bit about myself:\n\n\tWhen I was 15 (5 years ago) I began teaching myself how to develop mobile applications using Corona Labs.  I have quite a few hobbies, including soccer and ukulele, and app developing is one of my favorites.  I originally planned on pursuing a future in aeronautical engineering, but my little big randevu with app developing changed my mind.  Now I'm a second-year Computer Science and Engineering undergrad at The Ohio State University.  No regrets!  I have a long way to go, but I'm loving it thus far.  Mobile app development is completely separate from my schooling, so I have to make time for both. However, I won't be stopping either any time soon!  Like my page on Facebook or follow me on Twitter to stay up-to-date on the latest ASC news such as upcoming updates and apps.  Also feel free to contact me with suggestions!  I love hearing back from users.  It's the best way to make the best apps. \n\n\t\tThank you!\n\t\t\tNathan Balli"
    bio.alphaIn = 1
    bio.alphaOut = 0
    bio.alpha = bio.alphaOut
    controller.linkBio(bio)
    ----------------------------------------------

    --------------------------------Social Buttons
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
        y = bio.y + bio.height + 0.5*(display.contentHeight - (bio.y + bio.height)),
        width = 120,
        height = 120,
        defaultFile = "images/facebook.png",
        overFile = "images/facebookD.png",
        onEvent = socialButtonListener,
    }
    facebook.xIn = display.contentCenterX - 80
    facebook.xOut = -120
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
    ----------------------------------------------
end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()
        
        controller.transitionIn()

    end
end


function scene:hide( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.hide()
        
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