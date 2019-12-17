-- A custom alternative to native.showAlert(...)
local g = require( "other.globalVariables" )
local widget = require( "widget" )
local colors = require( "other.colors" )

local TAG = "Alert.lua: "

-- Local variables ------------------------------------------------------------[

-------------------------------------------------------------------------------]

-- Local methods and ops ------------------------------------------------------[
local function createLine( viewGroup, x1, y1, x2, y2 )
    local messageLine = display.newLine(viewGroup, x1, y1, x2, y2)
    messageLine.strokeWidth = 1
    messageLine:setStrokeColor( 0, 0, 0 )
end

local function createView( alert )
    local w = display.actualContentWidth / 2
    local titleHeight = 80
    local labelMargin = 30
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
    messageBoxImage.alha = 0.5
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
    local buttonLabelOffset = 7

    local function buttonHandler(event)
        local index = tonumber(event.target.id)
        local event = { index=index }
        if alert.listener ~= nil then
            alert.listener(event)
        end
        alert:hide(true)
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
            labelYOffset = buttonLabelOffset,
            labelColor = { default={0, 0, 0}, over=colors.red },
            font = g.comRegular,
            fontSize = 30
        })
        alert.viewGroup:insert(button)
        button:toBack()
    end

    local numOfButtons = #alert.buttonLabels
    local index = 1
    local buttonY
    
    while index <= numOfButtons do
        local buttonX = w/4 * math.pow(-1, index)
        buttonY = messageBoxImage.y + messageBoxImage.height/2 + buttonHeight/2 + math.floor( (index-1)/2 ) * buttonHeight

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

    --Outline box
    outlineHeight = titleBoxImage.height + messageBoxImage.height + buttonHeight * math.ceil( numOfButtons/2 )
    outlineY = titleBoxImage.y - titleBoxImage.height/2 + outlineHeight/2
    local outline = display.newRect(alert.viewGroup, 0, outlineY, w, outlineHeight)
    outline.strokeWidth = 3
    outline:setFillColor( 0, 0, 0, 0 )
    outline:setStrokeColor( 0, 0, 0 )

    -- Touch-blocking background ---------------------
    local background = display.newRect(alert.viewGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
    background.alpha = 0.01
    background:toBack()
    background:addEventListener( "touch", alert.backgroundListener )

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
    self.backgroundListener = function() return true end

    createView(self)

    self:show()

    return self
end

function Alert:hide( destroy )
    local function listener()
        self.viewGroup.isVisible = false
        if destroy then
            self:destroy()
        end
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
    self.viewGroup.isVisible = true
    transition.to(self.viewGroup, {
        time = 200,
        xScale = 1,
        yScale = 1,
        transition = easing.outBack,
    })
end

function Alert:destroy()
    display.remove(self.viewGroup)
    self = nil
end

return Alert
-------------------------------------------------------------------------------]