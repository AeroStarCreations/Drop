--Extras

local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "globalVariables" )
local t = require( "transitions" )
local ads = require( "ads" )
local ad = require( "advertisements" )
local GGTwitter = require( "GGTwitter" )
local chartboost = require( "plugin.chartboost" )
local ld = require( "localData" )
local logoModule = require( "logoModule" )

--Precalls
local drop
local backArrow
local red
local orange
local yellow
local green
local blue
local pink
local squareListener
local buttonGroup
local squares
local adTimer
local isEnabled
local logo
local countDown
----------

function scene:create( event )
    
    local group = self.view
    
    g.create()

    -------------------------------------Drop Logo
    drop = logoModule.getSmallLogo(group)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local function baf( event )
        t.transOutExtras( backArrow, buttonGroup[1], buttonGroup[2], buttonGroup[3], buttonGroup[4], buttonGroup[5], buttonGroup[6] )
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
    backArrow.x = -backArrow.width
    backArrow.y = drop.y + 0.5 * drop.height
    group:insert(backArrow)
    ----------------------------------------------
    
    ----------------------------------------------------------------------------
    --------------------------------------------------------------Square Buttons
    ----------------------------------------------------------------------------
    
    local focal = logoModule.getSmallLogoBottomY()
    local gap = math.round( 0.03333*display.contentWidth )
    local w = math.round((display.contentWidth-3*gap)*0.5)
    local h = math.round((display.contentHeight-focal-3*gap)/3)
    
    squares = {}
    buttonGroup = {}
    local label = {}
    local fill = {
        "images/squareGreen.jpg",
        "images/squareBlue.jpg",
        "images/squareOrange.jpg",
        "images/squareRed.jpg",
        "images/squareYellow.jpg",
        "images/squarePink.jpg",
    }
    logo = {}
    local logoFile = {
        "images/logoGameCenter.png",
        "images/logoStore.png",
        "images/logoAboutASC.png",
        "images/logoMusic.png",
        "images/logoWatchAd.png",
        "images/logoGameStats.png",
    }
    local labelText = {
        "Game Center",
        "Store",
        "About ASC",
        "The Music",
        "Watch Ad",
        "Game Info",
    }
    local strokeColor = {
        { 0.055, 0.545, 0.078 }, --green
        { 0.098, 0.329, 0.902 }, --blue
        { 1, 0.427, 0.063 },     --orange
        { 0.902, .141, 0.125 },  --red
        { 0.922, 0.678, 0.055 }, --yellow
        { 1, 0, 0.722 },         --pink
    }
    local coordinate = {
        { gap + 0.5*w, focal + 0.5*h },
        { display.contentWidth - gap - 0.5*w, focal + 0.5*h },
        { gap + 0.5*w, focal + 1.5*h + gap },
        { display.contentWidth - gap - 0.5*w, focal + 1.5*h + gap },
        { gap + 0.5*w, focal + 2*gap + 2.5*h },
        { display.contentWidth - gap - 0.5*w, focal + 2*gap + 2.5*h },
    }
    xPos = unpack( coordinate[1], 1, 1 )
    
    function squareListener( event )-------------------------
        local a = tonumber( event.target.id )
        
        if event.phase == "began" then
            
            if a ~=5 or isEnabled then
                transition.to( buttonGroup[ a ], { time=40, xScale=0.7, yScale=0.7 } )
            end
            display.getCurrentStage():setFocus( event.target )
            
        elseif event.phase == "ended" then
            
            display.getCurrentStage():setFocus( nil )
            transition.to( buttonGroup[ a ], { time=40, xScale=1, yScale=1 } )
            if event.x > buttonGroup[a].x-0.5*w and event.x < buttonGroup[a].x+0.5*w and event.y > buttonGroup[a].y-0.5*h and event.y < buttonGroup[a].y+0.5*h then
                print(event.target.id.." was pressed.")
                if a == 1 then                          -- Leaderboards
                    t.transOutExtrasOther( "leaderboardsScene", buttonGroup[1], buttonGroup[2], buttonGroup[3], buttonGroup[4], buttonGroup[5], buttonGroup[6] )
                elseif a == 2 then                      -- Store / Market
                    t.transOutExtrasOther( "market", buttonGroup[1], buttonGroup[2], buttonGroup[3], buttonGroup[4], buttonGroup[5], buttonGroup[6] )
                elseif a == 3 then                      -- About ASC
                    t.transOutExtrasOther( "aboutASC", buttonGroup[1], buttonGroup[2], buttonGroup[3], buttonGroup[4], buttonGroup[5], buttonGroup[6] )
                elseif a == 4 then
                    t.transOutExtrasOther( "aboutMusic", buttonGroup[1], buttonGroup[2], buttonGroup[3], buttonGroup[4], buttonGroup[5], buttonGroup[6] )
                elseif a == 5 then                      -- Watch Ad
                    if isEnabled == true then
                        ad.buttonColor = "yellow"
                        squares[a].isEnabled = false
                        ad.showAd()
                    end
                end
            end
            
        end
        return true
    end
    
    for i=1,6 do
        buttonGroup[i] = display.newGroup()
        group:insert( buttonGroup[i] )
        
        squares[i] = display.newRoundedRect( buttonGroup[i], 0, 0, w, h, 0.08 * display.actualContentWidth )
        squares[i].anchorX, squares[i].anchorY = 0.5, 0.5
        squares[i].strokeWidth = 3
        squares[i]:setStrokeColor( unpack( strokeColor[i] ) )
        squares[i].fill = { type="image", filename=fill[i] }
        squares[i].id = tostring(i)
        
        label[i] = display.newText( { parent=buttonGroup[i], text=labelText[i], x=squares[i].x, y=squares[i].y+0.5*h-50, width=w, height=h, font=g.comRegular, fontSize=50, align="center" } )
        
        logo[i] = display.newImageRect( buttonGroup[i], logoFile[i], 66, 66 )
        logo[i].y = 0.25*h
        
        buttonGroup[i].x, buttonGroup[i].y = unpack( coordinate[i] )
        buttonGroup[i].xScale, buttonGroup[i].yScale = 0.001, 0.001
    end
    
    logo[3].width, logo[3].height = 80, 80
    
    
    countDown = display.newText{
        parent = buttonGroup[5],
        text = " ",
        x = 0,
        y = -0.3*squares[5].height,
        font = g.comRegular,
        fontSize = 50,
        align = "center",
    }
    countDown:setFillColor( 0, 0.3, 0.8 )
    
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    
end


function scene:show( event )
    
    local group = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()
        
        local function addListeners()
            for i=1,6 do
                squares[i]:addEventListener( "touch", squareListener )
            end
        end
        
        --------------------------------------------------Watch Ad Button Config
        local d = os.date("%j") --day of year 001-366
        
        squares[5].isEnabled = false

        local currentTime
        local timeDifference
        local function times()
            currentTime = os.time( os.date('*t') ) --current seconds since 1970
            timeDifference = currentTime - ld.getVideoAdLastViewTime() --Count Down Time
        end
        times()
        
        if timeDifference >= 300 then --As soon as the scene opens, is the button enabled or disabled?
            squares[5].isEnabled = true
            isEnabled = true
        else
            isEnabled = false
            squares[5].alpha = 0.4
            logo[5].alpha = 0.4
        end
        
        if d ~= ld.getVideoAdDay() then --player gets 5 views per day
            ld.resetVideoAdViews()
            ld.setVideoAdDay( d )
        end
        
        local function listener()
            if ld.getVideoAdViews() < 5 then
                
                times()
                
                if timeDifference >= 300 then --180 seconds between video ads
                    if isEnabled == false then
                        squares[5].alpha = 1
                        logo[5].alpha = 1
                        isEnabled = true
                        squares[5].isEnabled = true
                        countDown.text = " "
                        print("a")
                    end
                else
                    if isEnabled == true then
                        squares[5].alpha = 0.4
                        logo[5].alpha = 0.4
                        isEnabled = false
                        squares[5].isEnabled = false
                        print("b")
                    end
                    countDown.text = g.timeFormat( 300-timeDifference )
                end
                
            else
                
                isEnabled = false
                logo[5].isEnabled = false
                squares[5].alpha = 0.3
                logo[5].alpha = 0.3
                
            end
        end
        listener()
        
        adTimer = timer.performWithDelay( 1000, listener, -1 )
        ------------------------------------------------------------------------
        
        if cp.getSceneName( "previous" ) == "center" then
            t.transInExtras( backArrow, drop, buttonGroup[1], buttonGroup[2], buttonGroup[3], buttonGroup[4], buttonGroup[5], buttonGroup[6], addListeners )
        else
            t.transInExtrasFromOther( buttonGroup[1], buttonGroup[2], buttonGroup[3], buttonGroup[4], buttonGroup[5], buttonGroup[6], xPos, addListeners )
        end

    end

end


function scene:hide( event )
    
    local group = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.hide()
        
        for i=1,6 do
            squares[i]:removeEventListener( "touch", squareListener )
        end
        
        if adTimer then
            timer.cancel( adTimer )
            adTimer = nil
        end
        
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
