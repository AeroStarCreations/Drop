local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "other.globalVariables" )
local logoModule = require( "other.logoModule" )
local marketplace = require( "Marketplace" )
local ld = require( "data.localData" )


--Precalls
local drop
local backArrow
local storeLogo
local storeLogoX
local lineTopY
local lineTop
local lineTopStrokeWidth = 10
local scrollView
local buttons = {}

-- TODO: switch to false before release
local testing = true

-- local buttonTitles = {
--     [1] = "Drop",
--     [2] = "Puddle",
--     [3] = "Pond",
--     [4] = "Lake",
--     [5] = "Sea",
--     [6] = "Ocean"
-- }

-- local buttonPrices = {
--     [1] = "$0.99",
--     [2] = "$4.99",
--     [3] = "$9.99",
--     [4] = "$19.99",
--     [5] = "$49.99",
--     [6] = "$99.99"
-- }

-- local buttonQuantities = {
--     [1] = "2",
--     [2] = "1",
--     [3] = "11",
--     [4] = "6",
--     [5] = "23",
--     [6] = "13",
--     [7] = "48",
--     [8] = "29",
--     [9] = "125",
--     [10] = "80",
--     [11] = "260",
--     [12] = "175"
-- }

-- local buttonIDs = {
--     [1] = "ads",
--     [2] = "shield1",
--     [3] = "lives1",
--     [4] = "shield5",
--     [5] = "lives5",
--     [6] = "shield10",
--     [7] = "lives10",
--     [8] = "shield20",
--     [9] = "lives20",
--     [10] = "shield50",
--     [11] = "lives50",
--     [12] = "shield100",
--     [13] = "lives100"
-- }

local buttonFileNames = {
    [1] = "images/iapAdsBundle.png",
    [2] = "images/iapShields1.png",
    [3] = "images/iapLives1.png",
    [4] = "images/iapShields5.png",
    [5] = "images/iapLives5.png",
    [6] = "images/iapShields10.png",
    [7] = "images/iapLives10.png",
    [8] = "images/iapShields20.png",
    [9] = "images/iapLives20.png",
    [10] = "images/iapShields50.png",
    [11] = "images/iapLives50.png",
    [12] = "images/iapShields100.png",
    [13] = "images/iapLives100.png"
}
----------

--Functions
local function transitionIn()
    transition.to( lineTop, {time=500, strokeWidth=lineTopStrokeWidth})
    transition.to( storeLogo, {time=500, x=storeLogoX, transition=easing.outSine})
    for k,v in pairs( buttons ) do
        transition.to( v, {time=350, delay=150, xScale=1, yScale=1, transition=easing.outBack} )
    end
end

local function transitionOut()
    local function listener( event )
        cp.gotoScene( "views.scenes.extras" )
    end

    transition.to( storeLogo, {time=500, x=display.contentWidth+0.5*storeLogo.width, transition=easing.inSine})
    transition.to( lineTop, {time=500, strokeWidth=0, onComplete=listener})
    for k,v in pairs( buttons ) do
        transition.to( v, {time=350, xScale=0.01, yScale=0.01, transition=easing.inBack} )
    end
end

local function dimButtons()
    for k,v in pairs( buttons ) do
        v.alpha = 0.4
    end
end

local function dimAndDisableButtons()
    dimButtons()
    for k,v in pairs( buttons ) do
        v:setEnabled( false )
    end
end

local function lightAndEnabledButtons()
    for k,v in pairs( buttons ) do
        v.alpha = 1
        v:setEnabled( true )
    end
end

local function buttonListener( event )
    local phase = event.phase

    if not marketplace.isStoreAvailable() and not testing then -- buttons disabled
        local dy = math.abs( event.y - event.yStart )
        if dy > 1 then
            scrollView:takeFocus( event )
        end
    else
        if phase == "moved" then
            -- https://docs.coronalabs.com/api/type/ScrollViewWidget/takeFocus.html
            local dy = math.abs( event.y - event.yStart )
            if dy > 10 then
                scrollView:takeFocus( event )
                event.target.xScale = 1
                event.target.yScale = 1
            end
        elseif phase == "began" then
            event.target.xScale = 0.9
            event.target.yScale = 0.9
        elseif phase == "ended" then
            event.target.xScale = 1
            event.target.yScale = 1
            dimAndDisableButtons()
            marketplace.purchase( event.target.id, lightAndEnabledButtons )
        end
    end
end
-----------


function scene:create( event )

    local group = self.view
    
    g.create()

    ------------------------------------------Logo
    drop = logoModule.getSmallLogo(group)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local function baf( event )
        print( "Arrow Pressed" )
        transitionOut()
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
    backArrow.x = 0.4 * (drop.x - 0.5 * drop.width)
    backArrow.y = drop.y + 0.5 * drop.height
    group:insert(backArrow)
    ----------------------------------------------

    ------------------------------------Store Logo
    storeLogo = display.newImageRect( group, "images/logoStore.png", 66, 66 )
    storeLogo.height = backArrow.height
    storeLogo.width = storeLogo.height
    storeLogo.x = display.contentWidth + 0.5*storeLogo.width
    storeLogo.y = backArrow.y
    storeLogoX = drop.x + 0.5*drop.contentWidth + 0.5*(display.contentWidth - drop.x - 0.5*drop.contentWidth)
    ----------------------------------------------

    -----------------------------------------Line
    lineTopY = drop.y + 1.2 * drop.height
    lineTop = display.newLine( group, 0, lineTopY, display.contentWidth, lineTopY )
    lineTop:setStrokeColor( unpack( g.purple ) )
    lineTop.strokeWidth = 0
    ----------------------------------------------

    -----------------------------------Scroll View
    scrollView = widget.newScrollView( {
        left = 0,
        top = lineTop.y + lineTopStrokeWidth * 0.5,
        width = display.contentWidth,
        height = display.contentHeight - lineTop.y - lineTopStrokeWidth * 0.5,
        horizontalScrollDisabled = true,
        hideBackground = true,
        hideScrollBar = true,
    })
    group:insert(scrollView)
    ----------------------------------------------

    -----------------------------------IAP Buttons
    local buttonWidth = 308
    local buttonHeight = 201
    local margin = (display.actualContentWidth - 2 * buttonWidth) / 6
    local buttonY = 0.5 * buttonHeight + margin
    local buttonX = {
        [1] = 2 * margin + 0.5 * buttonWidth,
        [2] = display.contentCenterX + margin + 0.5 * buttonWidth
    }

    --Display Ads Bundle button if ads are currently enabled
    if ld.getAdsEnabled() then
        buttons[1] = widget.newButton({
            parent = group,
            id = marketplace.productIDs[1],
            x = display.contentCenterX,
            y = 0,
            width = 643,
            height = 201,
            defaultFile = buttonFileNames[1],
            onEvent = buttonListener
        })
        buttons[1].y = 0.6 * buttons[1].height
        scrollView:insert(buttons[1])

        buttonY = buttons[1].y + 0.5 * (buttons[1].height + buttonHeight) + margin
    end

    --Display life and invincibility buttons
    for i = 1,6 do
        for j = 1,2 do
            local index = (i-1) * 2 + j + 1
            buttons[index] = widget.newButton({
                parent = group,
                id = marketplace.productIDs[index],
                x = buttonX[j],
                y = buttonY,
                width = buttonWidth,
                height = buttonHeight,
                defaultFile = buttonFileNames[index],
                onEvent = buttonListener
            })
            scrollView:insert(buttons[index])
        end
        buttonY = buttonY + margin + buttonHeight
    end

    -- Adjust scrollView height
    scrollView:setScrollHeight( scrollView._view._scrollHeight + margin + 0.5 * buttonHeight)

    --TODO: disable scrolling if buttons don't extend scroll area/height

    -- Set IAP alpha
    if not marketplace.isStoreAvailable() and not testing then
        dimButtons()
    end

    -- Set initial button scales
    for k,v in pairs( buttons ) do
        v.xScale = 0.01
        v.yScale = 0.01
    end
    ----------------------------------------------

end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()

        transitionIn()
        
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