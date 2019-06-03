local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "globalVariables" )
local store = require( "store" )
local iapData = require( "iapData" )
local logoModule = require( "logoModule" )


--Precalls
local googleIAPv3
local platform
local buyThis
local currentProduct
local canLoad
----------

--Functions
local function transitionIn()
    transition.to( lineTop, {time=500, strokeWidth=10})
    transition.to( storeLogo, {time=500, x=storeLogoX, transition=easing.outSine})
end

local function transitionOut()
    local function listener( event )
        cp.gotoScene( "extras" )
    end

    transition.to( storeLogo, {time=500, x=display.contentWidth+0.5*storeLogo.width, transition=easing.inSine})
    transition.to( lineTop, {time=500, strokeWidth=0, onComplete=listener})
end
-----------


function scene:create( event )

    local group = self.view
    
    g.create()

    -------------------------------Set up platform
    googleIAPv3 = false
    platform = system.getInfo( "platformName" )
    
    if platform == "Mac OS X" or platform == "Win" then
        platform = system.getInfo( "environment" )
    end

    if ( platform == "Android" ) then
        store = require( "plugin.google.iap.v3" )
        googleIAPv3 = true
    elseif store.availableStores.apple then
    	-- iOS is supported
    elseif ( platform == "simulator" ) then
        native.showAlert( "Notice", "In-app purchases are not supported in the Corona Simulator.", { "OK" } )
    else
	    native.showAlert( "Notice", "In-app purchases are not supported on this system/device.", { "OK" } )
    end

    iapData.setProductList( platform )
    ----------------------------------------------

    -------------------------------------Functions
    local function onLoadProducts( event )
        iapData.setData( event )
        canLoad = true
    end

    local function loadStoreProducts()
        if store.isActive then
            if store.canLoadProducts then
                store.loadProducts( iapData.getList(), onLoadProducts )
            else
                native.showAlert( "Uh-oh!", "Unable to load products", { "Cancel"} )
            end
        end
    end

    local function transactionCallback( event )
        if event.transaction.state == "purchased" then
            iapData.giveReward( currentProduct )
            native.showAlert( "Enjoy!", "Purchase complete", { "Okay" } )
        elseif event.transaction.state == "restore" then
            -- store this info somewhere
        elseif event.transaction.state == "consumed" then
            -- google only
        elseif event.transaction.state == "refunded" then
            -- google only
        elseif event.transaction.state == "cancelled" then

        elseif event.transaction.state == "failed" then

        else
            -- unknown event
        end

        store.finishTransaction( event.transaction )
    end
    ----------------------------------------------

    ------------------------------Initialize Store
    if googleIAPv3 then
        store.init( "google", transactionCallback )
    elseif store.availableStores.apple then
        store.init( "apple", transactionCallback )
    elseif platform == "simulator" then
        print( "IAP not supported in simulator" )
    else
        print( "IAP not supported on this system/device" )
    end
    ----------------------------------------------

    -----------------------------Purchase Function
    function buyThis( productID )
        if not store.isActive then
            native.showAlert( "Uh-oh!", "Cannot access the store at this time, please try again later", { "Okay" } )
        elseif not store.canMakePurchases then
            native.showAlert( "Uh-oh!", "Store purchases are not available, please try again later", { "Okay" } )
        elseif productID then
            if platform == "Android" then
                store.purchase( productID )
            else
                store.purchase( { productID } )
            end
        end
    end
    ----------------------------------------------

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
    local scrollView = widget.newScrollView( {
        left = 0,
        top = lineTop.y + lineTop.width * 0.5,
        width = display.contentWidth,
        height = display.contentHeight - lineTop.y - lineTop.width * 0.5,
        horizontalScrollDisabled = true,
        hideBackground = true,
        hideScrollBar = true,
    })
    group:insert(scrollView)
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