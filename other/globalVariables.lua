--Global Variables

local cp = require( "composer" )
local widget = require( "widget" )

local v = {}

---------------------------------------Functions for all scenes
v.create = function()
    
end

v.show = function()
    print( "Scene '"..cp.getSceneName( "current" ).."' was just entered.")
    
    v.goingToGame = false
    v.goingToExtras = false
    v.goingToSettings = false
    
end

v.hide = function()
    
end

v.destroy = function()
    
end
--------------------------------------------------------------

--------------------------------------------------------------------------------
----------------------------------------------------------------Level Parameters
--------------------------------------------------------------------------------
local singleTime = 30000
local doubleTime = 12000
local n = 1
-- for testing
-- n = 0.3

v.level1AParams = {
    phase = 1,
    duration = singleTime*n,
    interval = 800,
    mode = 1,
    gravity = 9,
    wind = 1,
    stormName = "Mist",
}
v.level1BParams = {
    phase = 2,
    duration = doubleTime*n,
    interval = 800,
    mode = 2,
    gravity = 9,
    wind = 2,
    stormName = "Double Mist",
}
v.level2AParams = {
    phase = 3,
    duration = singleTime*n,
    interval = 690,
    mode = 1,
    gravity = 11,
    wind = 3,
    stormName = "Drizzle",
}
v.level2BParams = {
    phase = 4,
    duration = doubleTime*n,
    interval = 690,
    mode = 2,
    gravity = 11,
    wind = 4,
    stormName = "Double Drizzle",
}
v.level3AParams = {
    phase = 5,
    duration = singleTime*n,
    interval = 580,
    mode = 1,
    gravity = 13,
    wind = 5,
    stormName = "Shower",
}
v.level3BParams = {
    phase = 6,
    duration = doubleTime*n,
    interval = 580,
    mode = 2,
    gravity = 13,
    wind = 6,
    stormName = "Double Shower",
}
v.level4AParams = {
    phase = 7,
    duration = singleTime*n,
    interval = 470,
    mode = 1,
    gravity = 15,
    wind = 7,
    stormName = "Downpour",
}
v.level4BParams = {
    phase = 8,
    duration = doubleTime*n,
    interval = 470,
    mode = 2,
    gravity = 15,
    wind = 8,
    stormName = "Double Downpour",
}
v.level5AParams = {
    phase = 9,
    duration = singleTime*n,
    interval = 360,
    mode = 1,
    gravity = 17,
    wind = 9,
    stormName = "Thunderstorm",
}
v.level5BParams = {
    phase = 10,
    duration = doubleTime*n,
    interval = 360,
    mode = 2,
    gravity = 17,
    wind = 10,
    stormName = "Double Thunderstorm",
}
v.level6AParams = {
    phase = 11,
    duration = singleTime*n,
    interval = 250,
    mode = 1,
    gravity = 19,
    wind = 11,
    stormName = "Tropical Storm",
}
v.level6BParams = {
    phase = 12,
    duration = doubleTime*n,
    interval = 250,
    mode = 2,
    gravity = 19,
    wind = 12,
    stormName = "Double Tropical Storm",
}
v.level7AParams = {
    phase = 13,
    duration = nil,
    interval = 175,
    mode = 1,
    gravity = 21,
    wind = 13,
    stormName = "Hurricane!",
}

--------------------Function that progresses to the next needed level parameters

function v.nextLevelParams( phase )
    n = phase
    local p
    if n == 1 then
        p = v.level1BParams
    elseif n == 2 then
        p = v.level2AParams
    elseif n == 3 then
        p = v.level2BParams
    elseif n == 4 then
        p = v.level3AParams
    elseif n == 5 then
        p = v.level3BParams
    elseif n == 6 then
        p = v.level4AParams
    elseif n == 7 then
        p = v.level4BParams
    elseif n == 8 then
        p = v.level5AParams
    elseif n == 9 then
        p = v.level5BParams
    elseif n == 10 then
        p = v.level6AParams
    elseif n == 11 then
        p = v.level6BParams
    else
        p = v.level7AParams
    end
    return p
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-------------------------------------------Format a number string to have commas
local function insertCommas( num, acc )
    local len = string.len( num )
    if len > 3 then
        acc = "," .. num:sub( len-2, len ) .. acc
        num = num:sub( 1, len-3 )
        return insertCommas( num, acc )
    else
        return num .. acc
    end
end

function v.commas( num )
    local numString = tostring( num )

    local isNegative = num < 0
    if isNegative then
        numString = numString:sub( 2, string.len( num ) )
    end
    
    numString = insertCommas( numString, "" )

    if isNegative then
        return "-" .. numString
    end
    return numString

end
--------------------------------------------------------------------------------

---------------------------------------------------------------Formats the Clock
function v.timeFormat( t )
    local hour = math.floor( t/3600 )
    local minute = math.floor( (t-hour*3600)/60 )
    local second = math.floor( t-hour*3600-minute*60 )
    if minute < 10 and hour > 0 then
        minute = "0"..minute
    end
    if second < 10 then
        second = "0"..second
    end
    local text
    if hour > 0 then
        text = hour..":"..minute..":"..second
    else
        text = minute..":"..second
    end
    return text
end
--------------------------------------------------------------------------------

return v
