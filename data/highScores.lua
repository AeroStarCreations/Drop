local ld = require( "data.localData" )
local sd = require( "data.serverData" )
local model = require( "models.highScoresModel" )

-- Local variables ------------------------------------------------------------[

-------------------------------------------------------------------------------]
    
-- Local functions ------------------------------------------------------------[
local function checkHighScore( score, time )
    print(model.getTag(), "checkHighScore()")
    print(model.getTag(), tostring(ld.getSpecialDropsEnabled()))

    local scorerShortCodes = model.getScorerShortCodes()

    if ld.getSpecialDropsEnabled() then
        if ld.setHighScore(scorerShortCodes[1], score) then
            print(model.getTag(), "high score set")
            sd.setHighScore(scorerShortCodes[1], score)
        end
        if ld.setHighScore(scorerShortCodes[3], time) then
        print(model.getTag(), "high time set")
            sd.setHighScore(scorerShortCodes[3], time)
        end
    else
        if ld.setHighScore(scorerShortCodes[2], score) then
        print(model.getTag(), "high tricky score set")
            sd.setHighScore(scorerShortCodes[2], score)
        end
        if ld.setHighScore(scorerShortCodes[4], time) then
        print(model.getTag(), "high tricky time set")
            sd.setHighScore(scorerShortCodes[4], time)
        end
    end
end

local function syncToDatabase()
    for k, shortCode in pairs(model.getScorerShortCodes()) do
        print(model.getTag(), "local high score: "..tostring(ld.getHighScore(shortCode)))
        sd.setHighScore(shortCode, ld.getHighScore(shortCode))
    end
end

local function syncLeaderboardListener(event)
    -- print(model.getTag(), "syncLeaderboardListener()")
    if sd.isLoggedIn() then
        print(model.getTag(), "is logged in")
        timer.cancel( event.source )
        syncToDatabase()
    end
    if event.count >= 60 then
        timer.cancel( event.source )
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.checkHighScore = function( score, time )
    checkHighScore( score, time )
end

v.init = function()
    print(model.getTag(), "high scores init")
    timer.performWithDelay(1000, syncLeaderboardListener, -1)
end

return v
-------------------------------------------------------------------------------]