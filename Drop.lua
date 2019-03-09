-- Consider this like a Java object class
-- Each droplet in the game will be an instance of this class

local ld = require( "localData" )
local physics = require( "physics" )
local json = require( "json" )

-- Local methods and ops ------------------------------------------------------[
local dropCounter = 0
local dropWidth = 80
local dropSet = {}
local dropRadius = dropWidth / 2
local dropTriangle = { 0,-56, 28,-28, -28,-28 }
local numOfSheetFrames = 8
local oddsOfSpecial = 0.1
local parentDropCoordinate = -1
local grandparentDropCoordinate = -1
local numOfDropLocations = math.floor( display.actualContentWidth / dropWidth ) + 1

local dropCoordinates = {}
for i = 1,numOfDropLocations do
    dropCoordinates[i] = (i - 1) * dropWidth
end

local sheetOptions = {
    width = 110,
    height = 165,
    numFrames = numOfSheetFrames,
    sheetContentWidth = 440,
    sheetContentHeight = 330,
}
local sheetNormal = graphics.newImageSheet(
    "images/dropletNormalSheet.png",
    sheetOptions
)
local sheetSpecial = graphics.newImageSheet(
    "images/dropletPowerSheet.png",
    sheetOptions
)

local function shouldBeSpecial()
    return ld.getSpecialDropsEnabled() and (math.random() < oddsOfSpecial)
end

local function getSheet( isSpecial )
    if isSpecial then
        return sheetSpecial
    end
    return sheetNormal
end

local function getSheetFrame()
    return math.random( 1, numOfSheetFrames )
end

local function getDropSpawnX()
    local x
    repeat
        x = math.random( 1, numOfDropLocations )
    until x ~= parentDropCoordinate and x ~= grandparentDropCoordinate

    grandparentDropCoordinate = parentDropCoordinate
    parentDropCoordinate = x

    return dropCoordinates[x]
end

local function getID()
    local id = tostring( dropCounter )
    dropCounter = dropCounter + 1
    return id
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local Drop = {}
local Drop_mt = { __index = Drop }

Drop.types = {
    [1] = "red",
    [2] = "orange",
    [3] = "yellow",
    [4] = "lightGreen",
    [5] = "darkGreen",
    [6] = "lightBlue",
    [7] = "darkBlue",
    [8] = "pink"
}

function Drop:new( parent )
    local self = {}

    setmetatable( self, Drop_mt )

    local frame = getSheetFrame()
    local special = shouldBeSpecial()

    self.image = display.newImageRect(
        parent,
        getSheet( special ),
        frame,
        sheetOptions.width,
        sheetOptions.height
    )

    self.image.x = getDropSpawnX()
    self.image.y = -0.5 * sheetOptions.height
    self.image.drop = self
    self.isSpecial = special
    self.type = Drop.types[frame]
    self.id = getID()

    dropSet[self.id] = self

    return self
end

function Drop:addPhysics()
    physics.addBody( self.image, "dynamic", {
        radius = dropRadius,
        bounce = 0.4
    })
end

function Drop:setLinearVelocity( x, y )
    self.image:setLinearVelocity( x, y)
end

function Drop:delete()
    local drop = dropSet[self.id]
    if drop then
        dropSet[self.id].image:removeSelf()
        dropSet[self.id] = nil
    end
    return drop
end

function Drop:deleteWithAnimation()
    local function listener()
        self:delete()
    end
    transition.to( self.image, { 
        time = 80, 
        alpha = 0, 
        width = self.image.width*2,
        height = self.image.height*2,
        onComplete = listener
    })
end

function Drop:deleteAll()
    for k,v in pairs(dropSet) do
        v:delete()
    end
    dropSet = {}
end

function Drop:deleteAllWithAnimation()
    local interval = 200
    local delay = interval
    for k,v in pairs(dropSet) do
        timer.performWithDelay( delay, function() v:deleteWithAnimation() end)
        delay = delay + interval
    end
end

-- converts short code to drop type
function Drop.scToDt( shortCode )
    if string.find(shortCode, "RED") then
        return Drop.types[1]
    elseif string.find(shortCode, "ORANGE") then
        return Drop.types[2]
    elseif string.find(shortCode, "YELLOW") then
        return Drop.types[3]
    elseif string.find(shortCode, "GREEN") and string.find(shortCode, "LIGHT") then
        return Drop.types[4]
    elseif string.find(shortCode, "GREEN") and string.find(shortCode, "DARK") then
        return Drop.types[5]
    elseif string.find(shortCode, "BLUE") and string.find(shortCode, "LIGHT") then
        return Drop.types[6]
    elseif string.find(shortCode, "BLUE") and string.find(shortCode, "DARK") then
        return Drop.types[7]
    elseif string.find(shortCode, "PINK") then
        return Drop.types[8]
    end
end

-- Get a single drop image
-- 'dropType' corresponds to Drop.types
function Drop.getDropImage(parent, height, dropType, isSpecial)
    local image = display.newImageRect(
        parent,
        getSheet( isSpecial ),
        dropType,
        sheetOptions.width,
        sheetOptions.height
    )
    local ratio = sheetOptions.width / sheetOptions.height
    image.height = height
    image.width = height * ratio
    return image
end

function Drop.getNumberOfColors()
    return numOfSheetFrames
end

return Drop
-------------------------------------------------------------------------------]