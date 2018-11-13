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
    self.id = tostring( dropCounter )

    dropSet[self.id] = self

    dropCounter = dropCounter + 1

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
    dropSet[self.id].image:removeSelf()
    dropSet[self.id] = nil
    return drop
end

function Drop:deleteAll()
    for k,v in pairs(dropSet) do
        v:delete()
    end
    dropSet = {}
    print(json.prettify(dropSet))
end

return Drop
-------------------------------------------------------------------------------]