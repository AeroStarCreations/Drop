--Requires
local colors = require("other.colors")
local widget = require( "widget" )
local fonts = require("other.fonts")

--Precalls

-- Local Values --------------------------------------------------------------[
local function buttonListener(event)
    local switch = event.target.switch
    local sister = event.target.sister
    local mode = switch.mode
    print("ID: "..event.target.id.."\nMode: "..tostring(mode))
    if event.target.id == "on" and mode == false then
        transition.to( sister, {time=200, alpha=0.2 } )
        transition.to( event.target, {time=200, alpha=1 } )
        event.target.switch.mode = true
        switch.listener()
    elseif event.target.id == "off" and mode == true then
        transition.to( event.target, {time=200, alpha=1 } )
        transition.to( sister, {time=200, alpha=0.2 } )
        event.target.switch.mode = false
        switch.listener()
    end
end
------------------------------------------------------------------------------]

-- Returned values/table -----------------------------------------------------[
local Switch = {}
local Switch_mt = { __index = Switch }

---Creates a new on-off switch display object
-- params = {
--     parent = object,
--     x = int,
--     y = int,
--     width = int,
--     height = int,
--     label1 = string,
--     label2 = string,
--     isOn = bool,
--     listener = function
-- }
function Switch:new(params)
    local self = {}

    setmetatable(self, Switch_mt)

    -- Parent display group
    local displayGroup = display.newGroup()
    params.parent:insert(displayGroup)
    self.displayGroup = displayGroup

    -- Border circles
    local circle1 = display.newImageRect(displayGroup, "images/switchCircle.png", params.height-3, params.height-3)
    local circle2 = display.newImageRect(displayGroup, "images/switchCircle.png", params.height-3, params.height-3)
    circle1.x = 0
    circle2.x = params.width - params.height

    -- Image sheet
    local imageSheetParams = {
        width = params.height,
        height = params.height,
        numFrames = 9,
        sheetContentWidth = 270,
        sheetContentHeight = 270
    }
    local imageSheet = graphics.newImageSheet( "images/sheetSwitch.png", imageSheetParams )

    -- Fill buttons
    local fill1 = widget.newButton{
        id = "off",
        sheet = imageSheet,
        width = params.height,
        height = params.height,
        defaultFrame = 8,
        label = params.label1,
        font = fonts.getRegular(),
        fontSize = 28,
        labelYOffset = params.height*0.03,
        labelColor = { default = colors.lightBlue.rgb },
        onRelease = buttonListener,
    }
    displayGroup:insert(fill1)
    fill1.x = circle1.x
    fill1.y = circle1.y
    fill1.switch = self
    local fill2 = widget.newButton{
        id = "on",
        sheet = imageSheet,
        width = params.height,
        height = params.height,
        defaultFrame = 4,
        label = params.label2,
        font = fonts.getRegular(),
        fontSize = 28,
        labelYOffset = params.height*0.03,
        labelColor = { default = colors.orange.rgb },
        onRelease = buttonListener,
    }
    displayGroup:insert(fill2)
    fill2.x = circle2.x
    fill2.y = circle2.y
    fill2.switch = self
    fill1.sister = fill2
    fill2.sister = fill1

    -- Configure
    self.listener = params.listener
    if params.isOn then
        fill1.alpha = 0.2
        self.mode = true
    else
        fill2.alpha = 0.2
        self.mode = false
    end
    displayGroup.anchorX = 0.5
    displayGroup.anchorY = 0.5
    displayGroup.x = params.x
    displayGroup.y = params.y
    displayGroup.anchorChildren = true

    return self
end

return Switch
-------------------------------------------------------------------------------]
