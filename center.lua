--Center

local cp = require( "composer" )
local scene = cp.newScene()
local g = require( "globalVariables" )
local widget = require( "widget" )
local t = require( "transitions" )
local GGTwitter = require( "GGTwitter" )

-------Precalls 
local asc
local drop
local arrow
local fb
local twit
local settings
local extras
local rotate
------- 


function scene:create( event )
    local group = self.view
    
    g.create()
    
    --------------------------------------------Aero Star Creations
    asc = display.newText( "Aero Star Creations", display.contentCenterX, display.contentHeight+50, g.comBold, 30)
    asc:setFillColor( unpack(g.lightBlue) )
    group:insert(asc)
    ---------------------------------------------------------------
    
    --------------------------------------------Drop Logo
    drop = display.newImageRect( "images/name.png", 1020, 390 )
    local dropRatio = drop.height/drop.width
    drop.width = 0.77*display.contentWidth; drop.height = drop.width*dropRatio
    drop.x, drop.y = display.contentCenterX, -drop.height
    group:insert(drop)
    -----------------------------------------------------
    
    --------------------------------------------Arrow
    local arrowW, arrowH = 352, 457
    g.arrowRatio = arrowW/arrowH
    
    local function arrowFunction( event )
        g.goingToGame = true
        Runtime:removeEventListener( "accelerometer", rotate )
        t.transOutCenter( asc, drop, arrow, fb, twit, extras, settings )
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
        t.transOutCenter(asc, drop, arrow, fb, twit, extras, settings)
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
        t.transOutCenter( asc, drop, arrow, fb, twit, extras, settings )
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

end

function scene:show( event )
    local group = self.view
    local phase = event.phase
    
    if phase == "will" then
        
    elseif phase == "did" then
        
        g.show()
        
        cp.loadScene( "game" )
        
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
        
        t.transInCenter( asc, drop, arrow, fb, twit, extras, settings, transDone )
        
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