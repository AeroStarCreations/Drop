local ld = require( "data.localData" )
local sd = require( "data.serverDataOld" )
local Drop = require( "views.other.Drop" )
local Alert = require( "views.other.Alert" )
local model = require( "models.achievementsModel" )

-- Local variables ------------------------------------------------------------[

-------------------------------------------------------------------------------]
  
-- Local methods and ops ------------------------------------------------------[
local function checkNormalAchievements()
    local normalAchievements = model.getNormalAchievements()
    local size = #normalAchievements / 2
    local phase = ld.getPhase()
    local tricky = not ld.getSpecialDropsEnabled()
    local shortCode
    local achievement

    for i = 1, size do
        if phase > i then
            if tricky then
                shortCode = normalAchievements[i + size].shortCode
                achievement = normalAchievements[i + size]
            else
                shortCode = normalAchievements[i].shortCode
                achievement = normalAchievements[i]
            end
            if not ld.getAchievementComplete(shortCode) then
                ld.setAchievementComplete(shortCode)
                sd.completeAchievement(shortCode)
                ld.addUnawardedAchievement(achievement)
            end
        end
    end
end

local function checkProgressAchievements()
    local hurricaneTime = ld.getHurricaneTime()
    for k, achievement in pairs(model.getProgressAchievements()) do
        local shortCode = achievement.shortCode
        local target = achievement.targetValue
        if not ld.getAchievementComplete(shortCode) then
            if (string.find(shortCode, "HURRICANE") and hurricaneTime >= target) or
            (string.find(shortCode, "SHIELD") and ld.getInvincibilityUses() >= target) or
            (string.find(shortCode, "REVIVE") and ld.getLifeUses() >= target) or
            (string.find(shortCode, "PLAY") and ld.getGamesPlayed() >= target) or
            (string.find(shortCode, "DIE") and ld.getDropNormalCollisions(Drop.scToDt(shortCode)) >= target) or
            (string.find(shortCode, "SPECIAL") and ld.getDropSpecialCollisions(Drop.scToDt(shortCode)) >= target) then
                ld.setAchievementComplete(shortCode)
                sd.completeAchievement(shortCode)
                ld.addUnawardedAchievement(achievement)
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
    print(model.getTag(), "syncToDatabase()")
    local a = player.achievements
    -- Sync normal achievements
    for k, achievement in pairs(model.getNormalAchievements()) do
        local shortCode = achievement.shortCode
        print(model.getTag(), shortCode.." : "..tostring(ld.getAchievementComplete(shortCode)).." : "..tostring(not has(a, shortCode)))
        if ld.getAchievementComplete(shortCode) and not has(a, shortCode) then
            print(model.getTag(), "AWARDED")
            sd.completeAchievement(shortCode)
        end
    end
    -- Sync progress achievements
    for k, achievement in pairs(model.getProgressAchievements()) do
        local shortCode = achievement.shortCode
        print(model.getTag(), shortCode.." : "..achievement.targetValue.." : "..tostring(ld.getAchievementComplete(shortCode)).." : "..tostring(not has(a, shortCode)))
        if ld.getAchievementComplete(shortCode) and not has(a, shortCode) then
            print(model.getTag(), "AWARDED")
            sd.completeAchievement(shortCode)
        end
    end
end

local function syncTimerListener(event)
    -- print(TAG, "syncTimerListener()")
    if sd.hasPlayerDetails() then
        print(model.getTag(), "has player details")
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

function v.checkAchievements()
    checkNormalAchievements()
    checkProgressAchievements()
end

function v.init()
    print(model.getTag(), "achievements init")
    timer.performWithDelay(1000, syncTimerListener, -1)
end

return v
-------------------------------------------------------------------------------]
