local controller = require( "controllers.extrasController" )
local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "other.globalVariables" )
local logoModule = require( "other.logoModule" )
local fonts = require("other.fonts")
local colors = require("other.colors")

function scene:create( event )
    
    local group = self.view
    
    g.create()

    -------------------------------------Drop Logo
    local drop = logoModule.getSmallLogo(group)
    controller.linkLogo(drop)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local backArrow = widget.newButton{
        id = "backArrow",
        x = 90,
        y = 0,
        width = 100 * g.arrowRatio,
        height = 100,
        defaultFile = "images/arrow.png",
        overFile = "images/arrowD.png",
        onRelease = controller.backArrowListener,
    }
    backArrow.rotation = 180
    backArrow.x = -backArrow.width
    backArrow.y = drop.y + 0.5 * drop.height
    group:insert(backArrow)
    controller.linkBackArrow(backArrow)
    ----------------------------------------------
    
    ----------------------------------------------------------------------------
    --------------------------------------------------------------Square Buttons
    ----------------------------------------------------------------------------
    local focal = logoModule.getSmallLogoBottomY()
    local gap = math.round( 0.03333 * display.contentWidth )
    local w = math.round((display.contentWidth - 3 * gap) * 0.5)
    local h = math.round((display.contentHeight - focal - 3 * gap) / 3)
    
    local squares = {}
    local buttonGroup = {}
    local label = {}
    local logo = {}
    local fill = controller.getFillImages()
    local logoFile = controller.getLogoImages()
    local labelText = controller.getLabelText()
    local strokeColor = controller.getStrokeColors()
    local ids = controller.getButtonIds()

    local coordinates = {
        { gap + 0.5*w, focal + 0.5*h },
        { display.contentWidth - gap - 0.5*w, focal + 0.5*h },
        { gap + 0.5*w, focal + 1.5*h + gap },
        { display.contentWidth - gap - 0.5*w, focal + 1.5*h + gap },
        { display.contentCenterX, focal + 2*gap + 2.5*h },
        { display.contentWidth - gap - 0.5*w, focal + 2*gap + 2.5*h },
    }

    controller.setButtonFocalX(unpack( coordinates[1], 1, 1 ))
    
    local numberOfButtons = 5
    for i=1,numberOfButtons do
        if i == numberOfButtons then
            w = w * 2 + gap
            coordinates[i][1] = display.contentCenterX
        end

        buttonGroup[i] = display.newGroup()
        buttonGroup[i].id = ids[i]
        group:insert( buttonGroup[i] )
        
        squares[i] = display.newRoundedRect( buttonGroup[i], 0, 0, w, h, 0.08 * display.actualContentWidth )
        squares[i].anchorX, squares[i].anchorY = 0.5, 0.5
        squares[i].strokeWidth = 3
        squares[i]:setStrokeColor( unpack( strokeColor[i] ) )
        squares[i].fill = { type="image", filename=fill[i] }
        squares[i].isEnabled = true;
        
        label[i] = display.newText( { parent=buttonGroup[i], text=labelText[i], x=squares[i].x, y=squares[i].y+0.5*h-50, width=w, height=h, font=fonts.getRegular(), fontSize=50, align="center" } )
        
        logo[i] = display.newImageRect( buttonGroup[i], logoFile[i], 66, 66 )
        logo[i].y = 0.25 * h
        
        buttonGroup[i].xIn = coordinates[i][1]
        buttonGroup[i].yIn = coordinates[i][2]
        if i == 5 then
            buttonGroup[i].xOut = buttonGroup[i].xIn
            buttonGroup[i].yOut = display.actualContentHeight + 0.51 * h
        elseif i % 2 == 0 then
            buttonGroup[i].xOut = display.actualContentWidth + 0.51 * w
            buttonGroup[i].yOut = buttonGroup[i].yIn
        else
            buttonGroup[i].xOut = -0.51 * w
            buttonGroup[i].yOut = buttonGroup[i].yIn
        end
        buttonGroup[i].x = buttonGroup[i].xIn
        buttonGroup[i].y = buttonGroup[i].yIn
        buttonGroup[i].rightEdge = buttonGroup[i].xIn + 0.5 * w
        buttonGroup[i].leftEdge = buttonGroup[i].rightEdge - w
        buttonGroup[i].topEdge = buttonGroup[i].yIn - 0.5 * h
        buttonGroup[i].bottomEdge = buttonGroup[i].topEdge + h
        buttonGroup[i].xScale, buttonGroup[i].yScale = 0.001, 0.001
    end

    logo[3].width, logo[3].height = 80, 80
    
    controller.linkButtons(buttonGroup)
    controller.linkSquares(squares)
    ----------------------------------------------

    ----------------------------------Ad Countdown
    local countDown = display.newText{
        parent = buttonGroup[5],
        text = " ",
        x = 0,
        y = -0.3 * squares[5].height,
        font = fonts.getRegular(),
        fontSize = 50,
        align = "center",
    }
    countDown:setFillColor( 0, 0.3, 0.8 )
    controller.linkCountDown(countDown)
    
end


function scene:show( event )
    
    local group = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()

        controller.onSceneShow(cp.getSceneName("previous"))
        
        --TODO: INSTEAD OF DOING THIS, JUST RELOAD THE SCORES WHEN THE GAME-INFO SCENE SHOWS
        -- Destroy gameInfo scene so that the scores reload next time the scene is opened
        if cp.getSceneName( "previous" ) == "views.scenes.gameInfo" then
            cp.removeScene( "gameInfo" )
        end

    end

end


function scene:hide( event )
    
    local group = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.hide()
        
        controller.onSceneHide()
        
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
