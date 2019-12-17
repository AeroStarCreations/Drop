--Global Variables

local cp = require( "composer" )
local widget = require( "widget" )
local ads = require( "ads" )
local GGData = require( "thirdParty.GGData" )
local ld = require( "data.localData" )

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

--The following is the font information
v.GGFont = require( "thirdParty.GGFont" )
v.fontManager = v.GGFont:new()

v.fontManager:add( "chalkDuster", "Chalkduster", "Chalkduster.ttf" )
v.chalk = v.fontManager:get("chalkDuster")

v.fontManager:add( "Comfortaa Light", "Comfortaa-Light", "Comfortaa-Light.ttf" )
v.comLight = v.fontManager:get("Comfortaa Light")

v.fontManager:add( "Comfortaa Regular", "Comfortaa", "Comfortaa-Regular.ttf" )
v.comRegular = v.fontManager:get("Comfortaa Regular")

v.fontManager:add( "Comfortaa Bold", "Comfortaa-Bold", "Comfortaa-Bold.ttf" )
v.comBold = v.fontManager:get("Comfortaa Bold")
-----------------------------------------

--The following are specified app colors
v.purple = { 0.4, 0.176, 0.569 }
v.lightBlue = { 0.047, 0.894, 0.918 }
v.regBlue = { 0.118, 0.565, 1 }
v.orange = { 0.965, 0.537, 0.231 }
----------------------------------------

--The following function generates +1 or -1 (CURRENTLY NOT USED)
--v.oneRandom = function( var )
--   local num1 = math.random( -1000, 1000 )
--   if num1 == 0 then
--      num1 = 1
--   end
--   var = num1/math.abs( num1 ) --this sets numer equal to 1 or -1
--   return var
--end
-------------------------------------------

-------------------------------------------------------------------Switch WIDGET
v.onOffSwitch = function( params )
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
    local name = display.newGroup()
    params.parent:insert(name)
    local circ1 = display.newImageRect(name, "images/switchCircle.png", params.height-3, params.height-3)
    local circ2 = display.newImageRect(name, "images/switchCircle.png", params.height-3, params.height-3)
    circ1.x = 0
    circ2.x = params.width-params.height
    local asdf = {
        width = params.height,
        height = params.height,
        numFrames = 9,
        sheetContentWidth = 270,
        sheetContentHeight = 270,
    }
    local sheetasdf = graphics.newImageSheet( "images/sheetSwitch.png", asdf )
    local fill1
    local fill2
    local mode
    local function bl(event)
        if event.target.id == "on" and mode == false then
            transition.to( fill1, {time=200, alpha=0.2 } )
            transition.to( fill2, {time=200, alpha=1 } )
            mode = true
            params.listener()
        elseif event.target.id == "off" and mode == true then
            transition.to( fill1, {time=200, alpha=1 } )
            transition.to( fill2, {time=200, alpha=0.2 } )
            mode = false
            params.listener()
        end
    end
    fill1 = widget.newButton{
        id = "off",
        sheet = sheetasdf,
        width = params.height,
        height = params.height,
        defaultFrame = 8,
        label = params.label1,
        font = v.comRegular,
        fontSize = 28,
        labelYOffset = params.height*0.06,
        labelColor = { default = {unpack(v.lightBlue)}},
        onRelease = bl,
    }
    fill2 = widget.newButton{
        id = "on",
        sheet = sheetasdf,
        width = params.height,
        height = params.height,
        defaultFrame = 4,
        label = params.label2,
        font = v.comRegular,
        fontSize = 28,
        labelYOffset = params.height*0.06,
        labelColor = { default = {unpack(v.orange)}},
        onRelease = bl,
    }
    name:insert(fill1)
    name:insert(fill2)
    fill1.x, fill1.y = circ1.x, circ1.y 
    fill2.x, fill2.y = circ2.x, circ2.y
    if params.isOn then
        fill1.alpha = 0.2
        mode = true
    else
        fill2.alpha = 0.2
        mode = false
    end
    name.anchorX, name.anchorY = 0.5, 0.5
    name.x, name.y = params.x, params.y
    name.anchorChildren = true
    return true
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
----------------------------------------------------------------Level Parameters
--------------------------------------------------------------------------------
local n = 1
-- for testing
n = 0.3

v.level1AParams = {
    phase = 1,
    duration = 30000*n,
    interval = 800,
    mode = 1,
    gravity = 9,
    wind = 1,
    stormName = "Mist",
}
v.level1BParams = {
    phase = 2,
    duration = 10000*n,
    interval = 800,
    mode = 2,
    gravity = 9,
    wind = 2,
    stormName = "Double Mist",
}
v.level2AParams = {
    phase = 3,
    duration = 30000*n,
    interval = 690,
    mode = 1,
    gravity = 11,
    wind = 3,
    stormName = "Drizzle",
}
v.level2BParams = {
    phase = 4,
    duration = 10000*n,
    interval = 690,
    mode = 2,
    gravity = 11,
    wind = 4,
    stormName = "Double Drizzle",
}
v.level3AParams = {
    phase = 5,
    duration = 30000*n,
    interval = 580,
    mode = 1,
    gravity = 13,
    wind = 5,
    stormName = "Shower",
}
v.level3BParams = {
    phase = 6,
    duration = 10000*n,
    interval = 580,
    mode = 2,
    gravity = 13,
    wind = 6,
    stormName = "Double Shower",
}
v.level4AParams = {
    phase = 7,
    duration = 30000*n,
    interval = 470,
    mode = 1,
    gravity = 15,
    wind = 7,
    stormName = "Downpour",
}
v.level4BParams = {
    phase = 8,
    duration = 10000*n,
    interval = 470,
    mode = 2,
    gravity = 15,
    wind = 8,
    stormName = "Double Downpour",
}
v.level5AParams = {
    phase = 9,
    duration = 30000*n,
    interval = 360,
    mode = 1,
    gravity = 17,
    wind = 9,
    stormName = "Thunderstorm",
}
v.level5BParams = {
    phase = 10,
    duration = 10000*n,
    interval = 360,
    mode = 2,
    gravity = 17,
    wind = 10,
    stormName = "Double Thunderstorm",
}
v.level6AParams = {
    phase = 11,
    duration = 30000*n,
    interval = 250,
    mode = 1,
    gravity = 19,
    wind = 11,
    stormName = "Tropical Storm",
}
v.level6BParams = {
    phase = 12,
    duration = 10000*n,
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

------------------------------------Function that unlocks the level achievements

function v.unlockLevelAchievements( phase )
    n = phase
    if ld.getSpecialDropsEnabled() then
        if n == 2 then
            v.achievement.normalAchievements[1].isComplete = true
        elseif n == 3 then
            v.achievement.normalAchievements[2].isComplete = true
        elseif n == 4 then
            v.achievement.normalAchievements[3].isComplete = true
        elseif n == 5 then
            v.achievement.normalAchievements[4].isComplete = true
        elseif n == 6 then
            v.achievement.normalAchievements[5].isComplete = true
        elseif n == 7 then
            v.achievement.normalAchievements[6].isComplete = true
        elseif n == 8 then
            v.achievement.normalAchievements[7].isComplete = true
        elseif n == 9 then
            v.achievement.normalAchievements[8].isComplete = true
        elseif n == 10 then
            v.achievement.normalAchievements[9].isComplete = true
        elseif n == 11 then
            v.achievement.normalAchievements[10].isComplete = true
        elseif n == 12 then
            v.achievement.normalAchievements[11].isComplete = true
        elseif n == 13 then
            v.achievement.normalAchievements[12].isComplete = true
        end
    else
        if n == 2 then
            v.achievement.normalAchievements[13].isComplete = true
        elseif n == 3 then
            v.achievement.normalAchievements[14].isComplete = true
        elseif n == 4 then
            v.achievement.normalAchievements[15].isComplete = true
        elseif n == 5 then
            v.achievement.normalAchievements[16].isComplete = true
        elseif n == 6 then
            v.achievement.normalAchievements[17].isComplete = true
        elseif n == 7 then
            v.achievement.normalAchievements[18].isComplete = true
        elseif n == 8 then
            v.achievement.normalAchievements[19].isComplete = true
        elseif n == 9 then
            v.achievement.normalAchievements[20].isComplete = true
        elseif n == 10 then
            v.achievement.normalAchievements[21].isComplete = true
        elseif n == 11 then
            v.achievement.normalAchievements[22].isComplete = true
        elseif n == 12 then
            v.achievement.normalAchievements[23].isComplete = true
        elseif n == 13 then
            v.achievement.normalAchievements[24].isComplete = true
        end
    end
    v.achievement:save()
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

-----------------------------------------------------------Records Droplet Stats
function v.dropletStats( name, c )
    -- local a = name:sub( 1, 1 )
    -- local b = name:sub( 3, 3 )
    -- if a == "1" then --normal drops
    --     if c == "rect" then --survived
    --         if b == "1" then
    --             v.stats.red = v.stats.red + 1
    --         elseif b == "2" then
    --             v.stats.orange = v.stats.orange + 1
    --         elseif b == "3" then
    --             v.stats.yellow = v.stats.yellow + 1
    --         elseif b == "4" then
    --             v.stats.lightGreen = v.stats.lightGreen + 1
    --         elseif b == "5" then
    --             v.stats.darkGreen = v.stats.darkGreen + 1
    --         elseif b == "6" then
    --             v.stats.lightBlue = v.stats.lightBlue + 1
    --         elseif b == "7" then
    --             v.stats.darkBlue = v.stats.darkBlue + 1
    --         elseif b == "8" then
    --             v.stats.pink = v.stats.pink + 1
    --         end
    --     elseif c == "arrow" then --killed
    --         if b == "1" then
    --             v.stats.redD = v.stats.redD + 1
    --         elseif b == "2" then
    --             v.stats.orangeD = v.stats.orangeD + 1
    --         elseif b == "3" then
    --             v.stats.yellowD = v.stats.yellowD + 1
    --         elseif b == "4" then
    --             v.stats.lightGreenD = v.stats.lightGreenD + 1
    --         elseif b == "5" then
    --             v.stats.darkGreenD = v.stats.darkGreenD + 1
    --         elseif b == "6" then
    --             v.stats.lightBlueD = v.stats.lightBlueD + 1
    --         elseif b == "7" then
    --             v.stats.darkBlueD = v.stats.darkBlueD + 1
    --         elseif b == "8" then
    --             v.stats.pinkD = v.stats.pinkD + 1
    --         end
    --     end
    -- elseif a == 2 then --special drops
    --     if c == "rect" then --missed
    --         if b == "1" then
    --             v.stats.red3 = v.stats.red3 + 1
    --         elseif b == "2" then
    --             v.stats.orange3 = v.stats.orange3 + 1
    --         elseif b == "3" then
    --             v.stats.yellow3 = v.stats.yellow3 + 1
    --         elseif b == "4" then
    --             v.stats.lightGreen3 = v.stats.lightGreen3 + 1
    --         elseif b == "5" then
    --             v.stats.darkGreen3 = v.stats.darkGreen3 + 1
    --         elseif b == "6" then
    --             v.stats.lightBlue3 = v.stats.lightBlue3 + 1
    --         elseif b == "7" then
    --             v.stats.darkBlue3 = v.stats.darkBlue3 + 1
    --         elseif b == "8" then
    --             v.stats.pink3 = v.stats.pink3 + 1
    --         end
    --     elseif c == "arrow" then --collected
    --         if b == "1" then
    --             v.stats.red2 = v.stats.red2 + 1
    --         elseif b == "2" then
    --             v.stats.orange2 = v.stats.orange2 + 1
    --         elseif b == "3" then
    --             v.stats.yellow2 = v.stats.yellow2 + 1
    --         elseif b == "4" then
    --             v.stats.lightGreen2 = v.stats.lightGreen2 + 1
    --         elseif b == "5" then
    --             v.stats.darkGreen2 = v.stats.darkGreen2 + 1
    --         elseif b == "6" then
    --             v.stats.lightBlue2 = v.stats.lightBlue2 + 1
    --         elseif b == "7" then
    --             v.stats.darkBlue2 = v.stats.darkBlue2 + 1
    --         elseif b == "8" then
    --             v.stats.pink2 = v.stats.pink2 + 1
    --         end
    --     end
    -- end
    -- v.stats:save()
end
--------------------------------------------------------------------------------



return v
