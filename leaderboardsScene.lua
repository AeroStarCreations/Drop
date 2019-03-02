local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "globalVariables" )
local t = require( "transitions" )
local json = require( "json" )
local sd = require( "serverData" )


--Precalls
local TAG = "leaderboardsScene.lua:"

local scoreButton
local timeButton
local specialButton
local leadersButton
local line
local tableView

local isScore = true        -- isTime otherwise
local isWithSpecials = true -- is not with specials otherwise
local isLeaders = true      -- is "by me" otherwise
----------

local function dataCallback( entries )
    print(TAG, "dataCallback()")
    tableView:deleteAllRows()
    for k,entry in pairs(entries) do
        local data = entry.data
        tableView:insertRow({
            rowColor = { default={ 1, 0, 0, 0 }, over={ 0, 0, 0 } },
            params = {
                country = data.country,
                rank = data.rank,
                name = data.userName,
                date = data.when,
                value = data.SCORE
            }
        })
    end
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
        isWithSpecials = not isWithSpecials
    elseif id == "leaders" then
        isLeaders = not isLeaders
    end
    if shouldUpdateRows then 
        sd.getLeaderboardData(isScore, isWithSpecials, isLeaders, dataCallback)
    end
end

local function onRowRenderListener( event )
    local row = event.row
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    local params = row.params

    local text = params.rank.."  "..params.name.."  "..params.value.."  "..params.country

    local rank = display.newText( row, text, 0, 0, nil, 40 )
    rank:setFillColor( 0 )
    rank.anchorX = 0
    rank.x = 20
    rank.y = rowHeight * 0.5

    -- local name = display.newText( row, params.name, 0, 0, nil, 40 )
    -- name:setFillColor( 0 )
    -- name.anchorX = 0.5
    -- name.x = rowWidth * 0.5
    -- name.y = rowHeight * 0.5

    -- local score = display.newText( row, params.score, 0, 0, nil, 40 )
    -- score:setFillColor( 0 )
    -- score.anchorX = 1
    -- score.x = rowWidth - 20
    -- score.y = rowHeight * 0.5

end


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
        -- t.transOutAboutASC( ascLogo, lineTop, lineBottom, asc, bio, fb, twit )
        cp.gotoScene("extras")
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

    ---------------------------Leaderboard Buttons
    scoreButton = widget.newButton({
        id = "score",
        left = 0,
        top = drop.y * 2,
        width = display.actualContentWidth / 4,
        height = 100,
        label = "SCORE",
        labelAlign = "center",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        labelYOffset = 7,
        font = g.comRegular,
        fontSize = 40,
        defaultFile = "images/squareGreen.jpg",
        onRelease = buttonListener
    })
    group:insert(scoreButton)

    timeButton = widget.newButton({
        id = "time",
        x = scoreButton.x + scoreButton.width,
        y = scoreButton.y,
        width = scoreButton.width,
        height = scoreButton.height,
        label = "TIME",
        labelAlign = "center",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        labelYOffset = 7,
        font = g.comRegular,
        fontSize = 40,
        defaultFile = "images/squareOrange.jpg",
        onRelease = buttonListener
    })
    group:insert(timeButton)

    specialButton = widget.newButton({
        id = "special",
        x = timeButton.x + scoreButton.width,
        y = scoreButton.y,
        width = scoreButton.width,
        height = scoreButton.height,
        label = "   With\nSpecials",
        labelAlign = "center",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        font = g.comRegular,
        fontSize = 40,
        defaultFile = "images/squareBlue.jpg",
        onRelease = buttonListener
    })
    group:insert(specialButton)

    leadersButton = widget.newButton({
        id = "leaders",
        x = specialButton.x + scoreButton.width,
        y = scoreButton.y,
        width = scoreButton.width,
        height = scoreButton.height,
        label = "Leaders",
        labelAlign = "center",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        labelYOffset = 7,
        font = g.comRegular,
        fontSize = 40,
        defaultFile = "images/squareRed.jpg",
        onRelease = buttonListener
    })
    group:insert(leadersButton)
    ----------------------------------------------

    ------------------------------------------Line
    local lineStrokeWidth = 10
    local lineY = scoreButton.y + 0.5 * scoreButton.height + 0.5 * lineStrokeWidth
        
    line = display.newLine( group, 0, lineY, display.contentWidth, lineY )
    line:setStrokeColor( unpack( g.purple ) )
    line.strokeWidth = lineStrokeWidth
    ----------------------------------------------

    -------------------------------------Table View
    local topY = lineY + 0.5 * lineStrokeWidth

    tableView = widget.newTableView({
        id = "table",
        left = 0,
        top = topY,
        width = display.actualContentWidth,
        height = display.actualContentHeight - topY,
        noLines = true,
        hideBackground = true,
        hideScrollBar = true,
        onRowRender = onRowRenderListener,
    })
    group:insert(tableView)
    ----------------------------------------------

end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()

        -- Load initial leaderboard entries
        sd.getLeaderboardData(isScore, isWithSpecials, isLeaders, dataCallback)

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