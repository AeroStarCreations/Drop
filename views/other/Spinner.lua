--Requires
local colors = require("other.colors")

--Precalls
local NUM_ARMS = 4
local TIMES = {1000, 1000, 800, 800}
local ROTATIONS = {180, -180, 180, -180}

-- Local Values --------------------------------------------------------------[
local function blockTouchListener()
    return true
end

local function getNewBackground(parent)
    local background = display.newRect(
        parent,
        display.contentCenterX,
        display.contentCenterY,
        display.actualContentWidth,
        display.actualContentHeight
    )
    background:setFillColor(0, 0, 0, 0.6)
    background:addEventListener("touch", blockTouchListener)
    return background
end

local function deleteBackground(background)
    if not background then return end
    background:removeEventListener("touch", blockTouchListener)
    background:removeSelf()
    background = nil
end

local function getNewSpinnerArm(parent)
    local arm = display.newRoundedRect(
        parent,
        display.contentCenterX,
        display.contentCenterY,
        120,
        20,
        10
    )
    arm:setFillColor(unpack(colors.purple_xl))
    return arm
end
------------------------------------------------------------------------------]

-- Returned values/table -----------------------------------------------------[
local Spinner = {}
local Spinner_mt = {__index = Spinner}

--parent: optional
--isBlocking: optional
function Spinner:new(parent, isBlocking)
    local self = {}

    setmetatable(self, Spinner_mt)

    if type(parent) == "table" then
        self.parent = parent
    else
        self.parent = display.newGroup()
    end
    if type(parent) == "boolean" then
        self.isBlocking = parent
    else
        self.isBlocking = isBlocking or false
    end
    self.spinnerArms = {}
    self.spinnerTransitions = {}

    return self
end

function Spinner:show()
    if self.isBlocking then
        self.background = getNewBackground(self.parent)
    end
    for i = 1, NUM_ARMS do
        self.spinnerArms[i] = getNewSpinnerArm(self.parent)
        self.spinnerTransitions[i] = transition.to(
            self.spinnerArms[i],
            {
                time = TIMES[i],
                iterations = -1,
                rotation = self.spinnerArms[i].rotation + ROTATIONS[i]
            }
        )
    end
end

function Spinner:delete()
    if self.isBlocking and self.background then
        deleteBackground(self.background)
    end
    for i=1, #self.spinnerTransitions do
        transition.cancel( self.spinnerTransitions[i] )
    end
    for i=1, #self.spinnerArms do
        if not self.spinnerArms[i] then return end
        self.spinnerArms[i]:removeSelf()
        self.spinnerArms[i] = nil
    end
end

return Spinner
-------------------------------------------------------------------------------]
