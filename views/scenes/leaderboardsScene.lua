local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "other.globalVariables" )
local t = require( "other.transitions" )
local json = require( "json" )
local sd = require( "data.serverData" )
local colors = require( "other.colors" )
local logoModule = require( "other.logoModule" )
local fonts = require("other.fonts")


--Precalls
local TAG = "leaderboardsScene.lua:"

local drop
local backArrow
local trophyLogo
local trophyLogoX
local scoreButton
local timeButton
local specialButton
local leadersButton
local line
local tableView
local rowHeight = 100

local scoreRect
local timeRect
local specialRect
local leadersRect
local rectStrokeWidth = 6

local isScore = true        -- isTime otherwise
local isTricky = false -- is with specials otherwise
local isLeaders = false     -- is "by me" otherwise
----------

local function leaderboardDataCallback( entries )
    print(TAG, "leaderboardDataCallback()")
    tableView:deleteAllRows()
    for k,entry in pairs(entries) do
        local data = entry.data
        tableView:insertRow({
            rowColor = { default={ 1, 0, 0, 0 }, over={ 0, 0, 0 } },
            rowHeight = rowHeight,
            params = {
                -- country = data.country,
                rank = entry.Position,
                name = entry.DisplayName,
                -- date = data.when,
                value = entry.StatValue
            }
        })
    end
end

local function updateButtonRectVisibilities()
    scoreRect.isVisible = isScore
    timeRect.isVisible = not isScore
    specialRect.isVisible = not isTricky
    leadersRect.isVisible = isLeaders
end

local function buttonListener( event )
    local id = event.target.id
    print(TAG, id.." button pressed")
    local shouldUpdateRows = true
    if id == "score" then
        if isScore then shouldUpdateRows = false end
        isScore = true
    elseif id == "time" then
        if not isScore then shouldUpdateRows = false end
        isScore = false
    elseif id == "special" then
        isTricky = not isTricky
    elseif id == "leaders" then
        isLeaders = not isLeaders
    end
    if shouldUpdateRows then 
        -- sd.getLeaderboardData(isScore, not isTricky, isLeaders, leaderboardDataCallback)
        sd.getLeaderboard(isScore, isTricky, isLeaders, leaderboardDataCallback)
        updateButtonRectVisibilities()
    end
end

local function onRowRenderListener( event )
    local row = event.row
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    local params = row.params
    local cushion = 20

    local text = params.rank.."  "..params.name.."  "..params.value--.."  "..params.country

    ------- Background
    local bg = display.newRoundedRect(
        row,
        rowWidth * 0.5,
        cushion,
        rowWidth - 2 * cushion,
        rowHeight - cushion,
        20
    )
    bg.anchorY = 0
    bg.strokeWidth = 7

    if row.index % 2 == 0 then
        bg:setFillColor( unpack(colors.purple_xs) )
        bg:setStrokeColor( unpack(colors.purple) )
    else
        bg:setFillColor( unpack(colors.purple_s) )
        bg:setStrokeColor( unpack(colors.purple_l) )
    end

    ----- Rank
    local rank = display.newText({
        parent = row,
        text = params.rank,
        x = bg.x - bg.width * 0.5 + 30,
        y = bg.y + 0.5 * bg.height,
        font = fonts.getBold(),
        fontSize = 40
    })
    rank:setFillColor( 1 )
    rank.anchorX = 0

    ----- Name
    local name = display.newText({
        parent = row,
        text = params.name,
        x = bg.x,
        y = rank.y,
        font = fonts.getBold(),
        fontSize = 40
    })
    name:setFillColor( 1 )

    ----- Value
    local valueText
    if isScore then
        valueText = g.commas(params.value)
    else
        valueText = g.timeFormat(params.value)
    end
    local value = display.newText({
        parent = row,
        text = valueText,
        x = bg.x + bg.width * 0.5 - 30,
        y = rank.y,
        font = fonts.getBold(),
        fontSize = 40
    })
    value:setFillColor( 1 )
    value.anchorX = 1
end

local function transitionIn()
    local buttonX = display.actualContentWidth / 4
    transition.to( trophyLogo, {time=500, x=trophyLogoX, transition=easing.outSine})
    transition.to( scoreButton, {time=500, x=0*buttonX, delay=200, transition=easing.outCubic} )
    transition.to( timeButton, {time=500, x=1*buttonX, transition=easing.outCubic} )
    transition.to( specialButton, {time=500, x=2*buttonX, transition=easing.outCubic} )
    transition.to( leadersButton, {time=500, x=3*buttonX, delay=200, transition=easing.outCubic} )
    transition.to( scoreRect, {time=500, x=0*buttonX+0.5*rectStrokeWidth, delay=200, transition=easing.outCubic} )
    transition.to( timeRect, {time=500, x=1*buttonX+0.5*rectStrokeWidth, transition=easing.outCubic} )
    transition.to( specialRect, {time=500, x=2*buttonX+0.5*rectStrokeWidth, transition=easing.outCubic} )
    transition.to( leadersRect, {time=500, x=3*buttonX+0.5*rectStrokeWidth, delay=200, transition=easing.outCubic} )
    tableView:scrollToY({y=0, time=500})
end

local function transitionOut( callback )
    local buttonX = display.actualContentWidth / 4
    transition.to( trophyLogo, {time=500, x=display.contentWidth+0.5*trophyLogo.width, transition=easing.inSine})
    transition.to( scoreButton, {time=400, x=-2*buttonX, transition=easing.inQuad} )
    transition.to( timeButton, {time=400, delay=100, x=-buttonX, transition=easing.inQuad, onComplete=callback} )
    transition.to( specialButton, {time=400, delay=100, x=display.actualContentWidth, transition=easing.inQuad} )
    transition.to( leadersButton, {time=400, x=display.actualContentWidth+buttonX, transition=easing.inQuad} )
    transition.to( scoreRect, {time=400, x=-2*buttonX, transition=easing.inQuad} )
    transition.to( timeRect, {time=400, delay=100, x=-buttonX, transition=easing.inQuad} )
    transition.to( specialRect, {time=400, delay=100, x=display.actualContentWidth, transition=easing.inQuad} )
    transition.to( leadersRect, {time=400, x=display.actualContentWidth+buttonX, transition=easing.inQuad} )
    tableView:scrollToY({y=tableView.height, time=500})
end


function scene:create( event )

    local group = self.view
    
    g.create()
    
    ------------------------------------------Logo
    drop = logoModule.getSmallLogo(group)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local function baf( event )
        print( "Arrow Pressed" )
        transitionOut( function() cp.gotoScene("views.scenes.extras") end)
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

    -----------------------------------Trophy Logo
    trophyLogo = display.newImageRect( group, "images/logoRankings.png", 66, 66 )
    trophyLogo.height = backArrow.height
    trophyLogo.width = trophyLogo.height
    trophyLogo.x = display.contentWidth + 0.5*trophyLogo.width
    trophyLogo.y = backArrow.y
    trophyLogoX = drop.x + 0.5*drop.contentWidth + 0.5*(display.contentWidth - drop.x - 0.5*drop.contentWidth)
    ----------------------------------------------

    ---------------------------Leaderboard Buttons
    local labelOffsetY = 7
    local buttonWidth = display.actualContentWidth / 4

    scoreButton = widget.newButton({
        id = "score",
        left = -2 * buttonWidth,
        top = logoModule.getSmallLogoBottomY(),
        width = buttonWidth,
        height = 125,
        label = "SCORE",
        labelAlign = "center",
        labelColor = { default={ 0, 0, 0, 0.7 }, over={ 0, 0, 0, 0.5 } },
        labelYOffset = labelOffsetY,
        font = fonts.getRegular(),
        fontSize = 40,
        defaultFile = "images/squareGreen.jpg",
        onRelease = buttonListener
    })
    scoreButton.anchorX = 0
    group:insert(scoreButton)

    timeButton = widget.newButton({
        id = "time",
        x = -buttonWidth,
        y = scoreButton.y,
        width = buttonWidth,
        height = scoreButton.height,
        label = "TIME",
        labelAlign = "center",
        labelColor = { default={ 0, 0, 0, 0.7 }, over={ 0, 0, 0, 0.5 } },
        labelYOffset = labelOffsetY,
        font = fonts.getRegular(),
        fontSize = 40,
        defaultFile = "images/squareOrange.jpg",
        onRelease = buttonListener
    })
    timeButton.anchorX = 0
    group:insert(timeButton)

    specialButton = widget.newButton({
        id = "special",
        x = display.actualContentWidth,
        y = scoreButton.y,
        width = buttonWidth,
        height = scoreButton.height,
        label = "Specials",
        labelAlign = "center",
        labelColor = { default={ 0, 0, 0, 0.7 }, over={ 0, 0, 0, 0.5 } },
        labelYOffset = labelOffsetY,
        font = fonts.getRegular(),
        fontSize = 40,
        defaultFile = "images/squareBlue.jpg",
        onRelease = buttonListener
    })
    specialButton.anchorX = 0
    group:insert(specialButton)

    leadersButton = widget.newButton({
        id = "leaders",
        x = display.actualContentWidth + buttonWidth,
        y = scoreButton.y,
        width = buttonWidth,
        height = scoreButton.height,
        label = "Leaders",
        labelAlign = "center",
        labelColor = { default={ 0, 0, 0, 0.7 }, over={ 0, 0, 0, 0.5 } },
        labelYOffset = labelOffsetY,
        font = fonts.getRegular(),
        fontSize = 40,
        defaultFile = "images/squareRed.jpg",
        onRelease = buttonListener
    })
    leadersButton.anchorX = 0
    group:insert(leadersButton)
    ----------------------------------------------

    ----------------------------------Button Rects
    local rectWidth = scoreButton.width - rectStrokeWidth
    local rectHeight = scoreButton.height - rectStrokeWidth

    scoreRect = display.newRect(scoreButton.x, scoreButton.y, rectWidth, rectHeight)
    scoreRect.strokeWidth = rectStrokeWidth
    scoreRect:setStrokeColor( unpack(colors.darkGreen) )
    scoreRect:setFillColor( 0, 0, 0, 0 )
    scoreRect.anchorX = 0
    scoreRect.isVisible = isScore
    group:insert(scoreRect)

    timeRect = display.newRect(timeButton.x, timeButton.y, rectWidth, rectHeight)
    timeRect.strokeWidth = rectStrokeWidth
    timeRect:setStrokeColor( unpack(colors.darkOrange) )
    timeRect:setFillColor( 0, 0, 0, 0 )
    timeRect.anchorX = 0
    timeRect.isVisible = not isScore
    group:insert(timeRect)

    specialRect = display.newRect(specialButton.x, specialButton.y, rectWidth, rectHeight)
    specialRect.strokeWidth = rectStrokeWidth
    specialRect:setStrokeColor( unpack(colors.darkBlue) )
    specialRect:setFillColor( 0, 0, 0, 0 )
    specialRect.anchorX = 0
    specialRect.isVisible = not isTricky
    group:insert(specialRect)

    leadersRect = display.newRect(leadersButton.x, leadersButton.y, rectWidth, rectHeight)
    leadersRect.strokeWidth = rectStrokeWidth
    leadersRect:setStrokeColor( unpack(colors.darkRed) )
    leadersRect:setFillColor( 0, 0, 0, 0 )
    leadersRect.anchorX = 0
    leadersRect.isVisible = isLeaders
    group:insert(leadersRect)
    ----------------------------------------------

    -----------------------------------------Lines
    local lineStrokeWidth = 10
    local line1Y = scoreButton.y - 0.5 * scoreButton.height - 0.5 * lineStrokeWidth
    local line2Y = scoreButton.y + 0.5 * scoreButton.height + 0.5 * lineStrokeWidth
        
    -- line1 = display.newLine( group, 0, line1Y, display.contentWidth, line1Y )
    -- line1:setStrokeColor( unpack( g.purple ) )
    -- line1.strokeWidth = lineStrokeWidth

    -- line2 = display.newLine( group, 0, line2Y, display.contentWidth, line2Y )
    -- line2:setStrokeColor( unpack( g.purple ) )
    -- line2.strokeWidth = lineStrokeWidth
    ----------------------------------------------

    -------------------------------------Table View
    local topY = line2Y + 0.5 * lineStrokeWidth
    topY = scoreButton.y + 0.5 * scoreButton.height

    tableView = widget.newTableView({
        id = "table",
        left = 0,
        top = topY,
        width = display.actualContentWidth,
        height = display.actualContentHeight - topY,
        noLines = true,
        hideBackground = true,
        hideScrollBar = false,
        onRowRender = onRowRenderListener,
    })
    tableView:scrollToY({y=tableView.height, time=0})
    tableView:toBack()
    group:insert(tableView)
    ----------------------------------------------

end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()

        -- Transition into the scene
        transitionIn()

        -- Load initial leaderboard entries
        -- sd.getLeaderboardData(isScore, not isTricky, isLeaders, leaderboardDataCallback)
        sd.getLeaderboard(isScore, isTricky, isLeaders, leaderboardDataCallback)

        -- This is just test/sample data 
        -- if tableView:getNumRows() == 0 then
        --     for i=1,80 do
        --         tableView:insertRow({
        --             rowColor = { default={ 1, 0, 0, 0 }, over={ 0, 0, 0 } },
        --             rowHeight = rowHeight,
        --             params = {
        --                 country = "US",
        --                 rank = i,
        --                 name = "Nathan",
        --                 value = i*71
        --             }
        --         })
        --     end
        -- end

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