local ld = require( "localData" )
local sd = require( "serverData" )
local Drop = require( "Drop" )

-- Local variables ------------------------------------------------------------[
local TAG = "achievements:"

-------------------------------------------------------------------------------]

-- GameSparks Short Codes -----------------------------------------------------[
-- If this table is updated, it must also be updated in localData.lua
local normalAchievementsShortCodes = {
    "MIST",
    "DOUBLE_MIST",
    "DRIZZLE",
    "DOUBLE_DRIZZLE",
    "SHOWER",
    "DOUBLE_SHOWER",
    "DOWNPOUR",
    "DOUBLE_DOWNPOUR",
    "THUNDERSTORM",
    "DOUBLE_THUNDERSTORM",
    "TROPICAL_STORM",
    "DOUBLE_TROPICAL_STORM",
    "MIST_TRICKY",
    "DOUBLE_MIST_TRICKY",
    "DRIZZLE_TRICKY",
    "DOUBLE_DRIZZLE_TRICKY",
    "SHOWER_TRICKY",
    "DOUBLE_SHOWER_TRICKY",
    "DOWNPOUR_TRICKY",
    "DOUBLE_DOWNPOUR_TRICKY",
    "THUNDERSTORM_TRICKY",
    "DOUBLE_THUNDERSTORM_TRICKY",
    "TROPICAL_STORM_TRICKY",
    "DOUBLE_TROPICAL_STORM_TRICKY"
}

local progressAchievementsShortCodes = {
    ["HURRICANE_1"] = 60, -- seconds
    ["HURRICANE_5"] = 300,
    ["HURRICANE_10"] = 600,
    ["SHIELD_5"] = 5,
    ["SHIELD_15"] = 15,
    ["SHIELD_30"] = 30,
    ["REVIVE_1"] = 1,
    ["REVIVE_5"] = 5,
    ["REVIVE_15"] = 15,
    ["PLAY_10"] = 10,
    ["PLAY_50"] = 50,
    ["PLAY_100"] = 100,
    ["PLAY_500"] = 500,
    ["PLAY_1000"] = 1000,
    ["DIE_RED"] = 5,
    ["DIE_ORANGE"] = 10,
    ["DIE_YELLOW"] = 15,
    ["DIE_LIGHT_GREEN"] = 20,
    ["DIE_DARK_GREEN"] = 25,
    ["DIE_LIGHT_BLUE"] = 30,
    ["DIE_DARK_BLUE"] = 35,
    ["DIE_PINK"] = 40,
    ["SPECIAL_RED"] = 50,
    ["SPECIAL_ORANGE"] = 50,
    ["SPECIAL_YELLOW"] = 50,
    ["SPECIAL_LIGHT_GREEN"] = 50,
    ["SPECIAL_DARK_GREEN"] = 50,
    ["SPECIAL_LIGHT_BLUE"] = 50,
    ["SPECIAL_DARK_BLUE"] = 50,
    ["SPECIAL_PINK"] = 50
}
-------------------------------------------------------------------------------]
    
-- Local methods and ops ------------------------------------------------------[
local function checkPhaseAchievements( phase )
    local size = #normalAchievementsShortCodes / 2
    local tricky = not ld.getSpecialDropsEnabled()
    local shortCode

    for i = 1, size do
        if phase > i then
            if tricky then
                shortCode = normalAchievementsShortCodes[i + size]
            else
                shortCode = normalAchievementsShortCodes[i]
            end
            if not ld.getAchievementComplete(shortCode) then
                ld.setAchievementComplete(shortCode)
                sd.completeAchievement(shortCode)
            end
        end
    end
end

local function checkProgressAchievements( hurricaneTime)
    for shortCode, target in pairs(progressAchievementsShortCodes) do
        if not ld.getAchievementComplete(shortCode) then
            if (string.find(shortCode, "HURRICANE") and hurricaneTime >= target) or
            (string.find(shortCode, "SHIELD") and ld.getInvincibilityUses() >= target) or
            (string.find(shortCode, "REVIVE") and ld.getLifeUses() >= target) or
            (string.find(shortCode, "PLAY") and ld.getGamesPlayed() >= target) or
            (string.find(shortCode, "DIE") and ld.getDropNormalCollisions(Drop.scToDt(shortCode)) >= target) or
            (string.find(shortCode, "SPECIAL") and ld.getDropSpecialCollisions(Drop.scToDt(shortCode)) >= target) then
                ld.setAchievementComplete(shortCode)
                sd.completeAchievement(shortCode)
            end
        end
    end
end

local function has( table, entry ) 
    for k,v in pairs(table) do
        if v == entry then return true end
    end
    return false
end

-- Pushes local achievements to backend
local function syncToDatabase( player )
    print(TAG, "syncToDatabase()")
    local a = player.achievements
    for k, shortCode in pairs(normalAchievementsShortCodes) do
        print(TAG, shortCode.." : "..tostring(ld.getAchievementComplete(shortCode)).." : "..tostring(not has(a, shortCode)))
        if ld.getAchievementComplete(shortCode) and not has(a, shortCode) then
            print(TAG, "AWARDED")
            sd.completeAchievement(shortCode)
        end
    end
    for shortCode, t in pairs(progressAchievementsShortCodes) do
    print(TAG, shortCode.." : "..t.." : "..tostring(ld.getAchievementComplete(shortCode)).." : "..tostring(not has(a, shortCode)))
        if ld.getAchievementComplete(shortCode) and not has(a, shortCode) then
            print(TAG, "AWARDED")
            sd.completeAchievement(shortCode)
        end
    end
end

local function syncTimerListener(event)
    print(TAG, "syncTimerListener()")
    if sd.hasPlayerDetails() then
        print(TAG, "has player details")
        timer.cancel( event.source )
        syncToDatabase(sd.getPlayer())
    end
    if event.count >= 60 then
        timer.cancel( event.source )
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.normalAchievementsShortCodes = normalAchievementsShortCodes

v.progressAchievementsShortCodes = progressAchievementsShortCodes

v.checkAchievements = function( phase, hurricaneTime )
    checkPhaseAchievements(phase)
    checkProgressAchievements(hurricaneTime)
end

v.init = function()
    print(TAG, "achievements init")
    timer.performWithDelay(1000, syncTimerListener, -1)
end

return v
-------------------------------------------------------------------------------]
