local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "other.globalVariables" )
local colors = require( "other.colors" )
local logoModule = require( "other.logoModule" )
local controller = require( "controllers.marketController" )

----------

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

    ------------------------------------Store Logo
    local storeLogo = display.newImageRect( group, "images/logoStore.png", 66, 66 )
    storeLogo.height = backArrow.height
    storeLogo.width = storeLogo.height
    storeLogo.xIn = drop.x + 0.5*drop.contentWidth + 0.5*(display.contentWidth - drop.x - 0.5*drop.contentWidth)
    storeLogo.xOut = display.contentWidth + 0.5*storeLogo.width
    storeLogo.x = storeLogo.xOut
    storeLogo.y = backArrow.y
    controller.linkLogo(storeLogo)
    ----------------------------------------------

    -----------------------------------------Line
    local lineTopY = drop.y + 1.2 * drop.height
    local lineTop = display.newLine( group, 0, lineTopY, display.contentWidth, lineTopY )
    lineTop:setStrokeColor( unpack( colors.purple ) )
    lineTop.strokeWidth = 0
    lineTop.strokeWidthIn = 10
    controller.linkLineTop(lineTop)
    ----------------------------------------------

    ----------------------------------Message Text
    local message = display.newText({
        parent = group,
        text = "",
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = 0.6 * display.actualContentWidth,
        font = g.comRegular,
        fontSize = 45,
        align = "center"
    })
    message:setFillColor(unpack(colors.purple))
    message.isVisible = false
    controller.linkMessage(message)
    ----------------------------------------------

    -----------------------------------Scroll View
    local scrollView = widget.newScrollView( {
        left = 0,
        top = lineTop.y + lineTop.strokeWidthIn * 0.5,
        width = display.actualContentWidth,
        height = display.contentHeight - lineTop.y - lineTop.strokeWidthIn * 0.5,
        horizontalScrollDisabled = true,
        hideBackground = true,
        hideScrollBar = true,
        bottomPadding = 50
    })
    group:insert(scrollView)
    controller.linkScrollView(scrollView)
    ----------------------------------------------

    -----------------------------------IAP Buttons
    -- buttonGroups = {
    --     com.aerostarcreations.drop.adsbundle = {
    --         group = displayGroup,
    --         button = widgetButton,
    --         priceText = textObj,
    --         lifeText = textObj,
    --         shieldText = textObj
    --     },
    --     all.other.ids = {
    --         group = displayGroup,
    --         button = widgetButton,
    --         priceText = textObj
    --     }
    -- }
    local buttonGroups = {}
    local buttonWidth = 308
    local buttonHeight = 201
    local margin = (display.actualContentWidth - 2 * buttonWidth) / 6
    local buttonY = 0.5 * buttonHeight + margin
    local buttonX = {
        [1] = 2 * margin + 0.5 * buttonWidth,
        [2] = display.contentCenterX + margin + 0.5 * buttonWidth
    }

    if true then --TODO: set to sd.isAdsPurchased or whatever
        local buttonId = controller.getProductId(1)
        buttonGroups[buttonId] = {
            displayGroup = display.newGroup()
        }
        buttonGroups[buttonId].displayGroup.x = display.contentCenterX
        buttonGroups[buttonId].displayGroup.y = buttonY
        buttonGroups[buttonId].displayGroup.anchorX = 0.5
        buttonGroups[buttonId].displayGroup.anchorY = 0.5
        buttonGroups[buttonId].displayGroup.anchorChildren = true
        buttonGroups[buttonId].displayGroup.xScale = 0.001
        buttonGroups[buttonId].displayGroup.yScale = 0.001
        scrollView:insert(buttonGroups[buttonId].displayGroup)

        local button = widget.newButton({
            id = buttonId,
            width = 643,
            height = buttonHeight,
            defaultFile = controller.getButtonFileName(1),
            onEvent = controller.buttonListener
        })
        buttonY = buttonY + buttonHeight + margin
        buttonGroups[buttonId].button = button
        buttonGroups[buttonId].displayGroup:insert(button)

        local price = display.newText({
            parent = buttonGroups[buttonId].displayGroup,
            text = "$-.--",
            x = button.x,
            y = button.y + 7,
            width = button.width - 57,
            height = 0, -- this allows the height to auto-adjust
            font = g.comRegular,
            fontSize = 50,
            align = "right"
        })
        buttonGroups[buttonId].priceText = price

        local lifeValue = display.newText({
            parent = buttonGroups[buttonId].displayGroup,
            text = "+2",
            x = button.x - 35,
            y = button.y + 35,
            height = 0, -- this allows the height to auto-adjust
            font = g.comRegular,
            fontSize = 55,
            align = "center"
        })
        lifeValue:setFillColor(0)
        buttonGroups[buttonId].lifeText = lifeValue

        local shieldValue = display.newText({
            parent = buttonGroups[buttonId].displayGroup,
            text = "+4",
            x = button.x - 220,
            y = lifeValue.y,
            height = 0, -- this allows the height to auto-adjust
            font = g.comRegular,
            fontSize = 55,
            align = "center"
        })
        shieldValue:setFillColor(0)
        buttonGroups[buttonId].shieldText = shieldValue
    end

    for i = 1,6 do
        for j = 1,2 do
            local index = (i-1) * 2 + j + 1
            local buttonId = controller.getProductId(index)
            buttonGroups[buttonId] = {
                displayGroup = display.newGroup()
            }
            buttonGroups[buttonId].displayGroup.x = buttonX[j]
            buttonGroups[buttonId].displayGroup.y = buttonY
            buttonGroups[buttonId].displayGroup.anchorX = 0.5
            buttonGroups[buttonId].displayGroup.anchorY = 0.5
            buttonGroups[buttonId].displayGroup.anchorChildren = true
            buttonGroups[buttonId].displayGroup.xScale = 0.001
            buttonGroups[buttonId].displayGroup.yScale = 0.001
            scrollView:insert(buttonGroups[buttonId].displayGroup)

            local button = widget.newButton({
                id = controller.getProductId(index),
                width = buttonWidth,
                height = buttonHeight,
                label = "#",
                labelYOffset = 0,
                labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
                font = g.comRegular,
                fontSize = 38,
                defaultFile = controller.getButtonFileName(index),
                onEvent = controller.buttonListener
            })
            buttonGroups[buttonId].button = button
            buttonGroups[buttonId].displayGroup:insert(button)

            local price = display.newText({
                parent = buttonGroups[buttonId].displayGroup,
                text = "$-.--",
                x = button.x,
                y = button.y + 70,
                width = button.width,
                height = 0, -- this allows the height to auto-adjust
                font = g.comBold,
                fontSize = 40,
                align = "center"
            })
            price:setFillColor(unpack(colors.green))
            buttonGroups[buttonId].priceText = price
        end
        buttonY = buttonY + margin + buttonHeight
    end

    controller.linkButtonGroups(buttonGroups)

    -- Adjust scrollView height
    scrollView:setScrollHeight( scrollView._view._scrollHeight + margin + 0.5 * buttonHeight)

    -- Disable scrolling if buttons don't extend scroll area/height
    local shouldLock = scrollView.height > buttonY - 0.5 * buttonHeight
    scrollView:setIsLocked( shouldLock )

    -- Set IAP alpha
    -- if not marketplace.isStoreAvailable() and not testing then
    --     dimAndDisableButtons()
    -- end

    controller.sceneCreateComplete()
    ----------------------------------------------

end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()

        controller.sceneShow()
        
    end
end


function scene:hide( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.hide()

        controller.sceneHide()
        
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