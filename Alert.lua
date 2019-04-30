-- A custom alternative to native.showAlert(...)
local g = require( "globalVariables" )
local widget = require( "widget" )
local colors = require( "colors" )

local TAG = "Alert.lua: "

-- Local methods and ops ------------------------------------------------------[
local function createLine( viewGroup, x1, y1, x2, y2 )
    local messageLine = display.newLine(viewGroup, x1, y1, x2, y2)
    messageLine.strokeWidth = 1
    messageLine:setStrokeColor( 0, 0, 0 )
end

local function createView( alert )
    local w = display.actualContentWidth / 2
    local titleHeight = 80
    local labelMargin = 20
    local buttonHeight = 80

    alert.viewGroup.x = display.contentCenterX
    alert.viewGroup.y = display.contentCenterY

    -- Message Box -----------------------------------
    local messageBoxLabel = display.newText({
        parent = alert.viewGroup,
        text = alert.message,
        x = 0,
        y = 0,
        width = w * 0.9,
        font = g.comRegular,
        fontSize = 30
    })
    messageBoxLabel:setFillColor(0, 0, 0)

    local messageBoxImage = display.newImageRect(alert.viewGroup, "images/squareBlue.jpg", w, (messageBoxLabel.height + 2 * labelMargin) )
    messageBoxImage.x = 0
    messageBoxImage.y = messageBoxLabel.y
    messageBoxImage:toBack()

    local lineY = messageBoxImage.y - messageBoxImage.height/2
    local messageLine = display.newLine(alert.viewGroup, -w/2, lineY, w/2, lineY)
    messageLine.strokeWidth = 2
    messageLine:setStrokeColor( 0, 0, 0 )

    local lineY = messageBoxImage.y - messageBoxImage.height/2
    createLine(alert.viewGroup, -w/2, lineY, w/2, lineY )

    -- Title Box ---------------------------------------
    local titleBoxImage = display.newImageRect(alert.viewGroup, "images/squareBlue.jpg", w, titleHeight)
    titleBoxImage.x = 0
    titleBoxImage.y = messageBoxImage.y - 0.5*messageBoxImage.height - 0.5*titleBoxImage.height

    local titleBoxLabel = display.newText({
        parent = alert.viewGroup,
        text = alert.title,
        x = 0,
        y = titleBoxImage.y,
        font = g.comBold,
        fontSize = 40,
    })
    titleBoxLabel:setFillColor(0, 0, 0)

    -- Buttons ------------------------------------------
    local function buttonHandler(event)
        local index = tonumber(event.source.id)
        local event = { index=index }
        alert.listener(event)
    end

    local function createButton( index, x, y, width )
        local button = widget.newButton({
            id = tostring(index),
            x = x,
            y = y,
            width = width or w/2,
            height = buttonHeight,
            defaultFile = "images/squareBlue.jpg",
            onRelease = buttonHandler,
            label = alert.buttonLabels[index],
            labelColor = { default={0, 0, 0}, over=colors.red },
            font = g.comRegular,
            fontSize = 30
        })
        alert.viewGroup:insert(button)
        button:toBack()
    end

    local numOfButtons = #alert.buttonLabels
    local index = 1
    
    while index <= numOfButtons do
        local buttonX = w/4 * math.pow(-1, index)
        local buttonY = messageBoxImage.y + messageBoxImage.height + math.floor( (index-1)/2 ) * buttonHeight

        --Create button
        if index == numOfButtons and numOfButtons % 2 == 1 then
            --Bottom/Wide button
            createButton(index, 0, buttonY, w)
        else
            --Normal/Thin button
            createButton(index, buttonX, buttonY)
        end

        --Create line
        if index % 2 == 1 then
            --Horizontal line
            local lineY = buttonY - buttonHeight/2
            createLine(alert.viewGroup, -w/2, lineY, w/2, lineY )
            --Vertical line
            if index ~= numOfButtons then
                lineY = buttonY-buttonHeight/2
                createLine(alert.viewGroup, 0, lineY, 0, lineY+buttonHeight)
            end
        end

        index = index + 1
    end

    --Make hidden
    alert.viewGroup.xScale = 0.01
    alert.viewGroup.yScale = 0.01
    alert.viewGroup.isVisible = false
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local Alert = {}
local Alert_mt = { __index = Alert }

function Alert:new( title, message, buttonLabels, listener )
    local self = {}
    setmetatable(self, Alert_mt)

    self.title = title
    self.message = message
    self.buttonLabels = buttonLabels
    self.listener = listener
    self.viewGroup = display.newGroup()

    createView(self)

    self:show()

    return self
end

function Alert:hide()
    local function listener()
        self.viewGroup.isVisible = false
    end
    transition.to(self.viewGroup, {
        time = 200,
        xScale = 0.01,
        yScale = 0.01,
        transition = easing.outBack,
        onComplete = listener
    })
end

function Alert:show()
    self.isVisible = true
    transition.to(self.viewGroup, {
        time = 200,
        xScale = 1,
        yScale = 1,
        transition = easing.outBack,
    })
end

function Alert:destroy()
end

return Alert
-------------------------------------------------------------------------------]