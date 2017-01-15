local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "globalVariables" )
local t = require( "transitions" )
local store = require( "store" )
local iapData = require( "iapData" )


--Precalls
local googleIAPv3
local platform
local buyThis
local currentProduct
local canLoad
----------


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
    drop = display.newImageRect( "images/name.png", 1020, 390 )
    local dropRatio = drop.height/drop.width
    drop.width = 0.77*display.contentWidth; drop.height = drop.width*dropRatio
    drop.x, drop.y = display.contentCenterX, 0.06*display.contentHeight+1
    drop.xScale, drop.yScale = 0.47, 0.47
    group:insert(drop)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local function baf( event )
        --t.transOutAboutASC( ascLogo, lineTop, lineBottom, asc, bio, fb, twit )
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

    -----------------------------------------Line
    lineTop = display.newLine( group, 0, drop.y*2, display.contentWidth, drop.y*2 )
    lineTop:setStrokeColor( unpack( g.purple ) )
    lineTop.strokeWidth = 10
    --lineTop.x = -display.contentWidth
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