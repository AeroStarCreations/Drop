local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "globalVariables" )
local t = require( "transitions" )
local GGTwitter = require( "GGTwitter" )


--Precalls
local drop
local backArrow
local asc
local lineTop
local lineBottom
local bio
local fb
local twit
----------


function scene:create( event )

    local group = self.view
    
    g.create()
    
    ------------------------------------------Logo
    drop = display.newImageRect( "images/name.png", 1020, 390 )
    local dropRatio = drop.height/drop.width
    drop.width = 0.77*display.contentWidth; drop.height = drop.width*dropRatio
    drop.x, drop.y = display.contentCenterX, 0.06*display.contentHeight+1
    drop.xScale, drop.yScale = 0.47, 0.47
    group:insert(drop)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local function baf( event )
        t.transOutAboutASC( ascLogo, lineTop, lineBottom, asc, bio, fb, twit )
        print( "Arrow Pressed" )
    end
    
    backArrow = widget.newButton{
        id = "backArrow",
        x = 90,
        y = 0,
        width = 100*g.arrowRatio,
        height = 100,
        defaultFile = "images/arrow.png",
        overFile = "images/arrowD.png",
        onRelease = baf,
    }
    backArrow.rotation = 180
    backArrow.x = drop.x-0.5*drop.width
    backArrow.y = drop.y - 7
    group:insert(backArrow)
    ----------------------------------------------

    --------------------------------------ASC Logo
    ascLogo = display.newImageRect( group, "images/ASClogo.png", 266, 266 )
    ascLogo.width, ascLogo.height = 0.53*drop.height, 0.53*drop.height
    ascLogo.x = display.contentWidth + 0.5*ascLogo.width
    ascLogo.y = backArrow.y + 10
    ascLogoX = drop.x + 0.5*drop.contentWidth + 0.5*(display.contentWidth - drop.x - 0.5*drop.contentWidth)
    ----------------------------------------------

    -------------------------"Aero Star Creations"
    asc = display.newText( group, "Aero Star Creations", display.contentCenterX, 0, g.comBold, 70, "center")
    asc:setFillColor( unpack(g.purple) )
    asc.y = 2*drop.y + 0.5*asc.height
    asc.alpha = 0
    ----------------------------------------------

    -----------------------------------------Lines
    lineTop = display.newLine( group, 0, drop.y*2, display.contentWidth, drop.y*2 )
    lineTop:setStrokeColor( unpack( g.purple ) )
    lineTop.strokeWidth = 2
    lineTop.x = -display.contentWidth

    lineBottom = display.newLine( group, 0, lineTop.y+2*(asc.y-lineTop.y), display.contentWidth, lineTop.y+2*(asc.y-lineTop.y) )
    lineBottom:setStrokeColor( unpack( g.purple ) )
    lineBottom.strokeWidth = 2
    lineBottom.x = display.contentWidth
    ----------------------------------------------

    ------------------------------------------Text
    bio = display.newText( group, "Joe Shmoe", display.contentCenterX, lineBottom.y, 0.9*display.contentWidth, 0, g.comRegular, 26, "center")
    bio:setFillColor( 0, 0, 0 )
    bio.anchorY = 0
    bio.text = "\n\n\tHello!  I'm Nathan Balli, the little man behind Aero Star Creations.  I hope you've enjoyed Drop so far!  I had an incredible time developing the game.  Now here's a bit about myself:\n\n\tWhen I was 15 (5 years ago) I began teaching myself how to develop mobile applications using Corona Labs.  I have quite a few hobbies, including soccer and ukulele, and app developing is one of my favorites.  I originally planned on pursuing a future in aeronautical engineering, but my little big randevu with app developing changed my mind.  Now I'm a second-year Computer Science and Engineering undergrad at The Ohio State University.  No regrets!  I have a long way to go, but I'm loving it thus far.  Mobile app development is completely separate from my schooling, so I have to make time for both. However, I won't be stopping either any time soon!  Like my page on Facebook or follow me on Twitter to stay up-to-date on the latest ASC news such as upcoming updates and apps.  Also feel free to contact me with suggestions!  I love hearing back from users.  It's the best way to make the best apps. \n\n\t\tThank you!\n\t\t\tNathan Balli"
    bio.alpha = 0
    ----------------------------------------------

    --------------------------------Social Buttons
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
        y = bio.y + bio.height + 0.5*(display.contentHeight - (bio.y + bio.height)),
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
    ----------------------------------------------
end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()
        
        t.transInAboutASC( ascLogo, ascLogoX, lineTop, lineBottom, asc, bio, fb, twit )

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