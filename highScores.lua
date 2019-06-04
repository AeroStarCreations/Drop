local ld = require( "localData" )
local sd = require( "serverData" )

-- Local variables ------------------------------------------------------------[
local TAG = "highScores:"

local scorerShortCodes = {
    [1] = "HIGH_SCORE_SCORER",
    [2] = "HIGH_SCORE_TRICKY_SCORER",
    [3] = "HIGH_TIME_SCORER",
    [4] = "HIGH_TIME_TRICKY_SCORER"
}

local leaderboardShortCodes = {
    [1] = "HIGH_SCORE_LEADERBOARD",
    [2] = "HIGH_SCORE_TRICKY_LEADERBOARD",
    [3] = "HIGH_TIME_LEADERBOARD",
    [4] = "HIGH_TIME_TRICKY_LEADERBOARD"
}
-------------------------------------------------------------------------------]
    
-- Local functions ------------------------------------------------------------[
local function checkHighScore( score, time )
    print(TAG, "checkHighScore()")
    print(TAG, tostring(ld.getSpecialDropsEnabled()))
    if ld.getSpecialDropsEnabled() then
        if ld.setHighScore(scorerShortCodes[1], score) then
            print(TAG, "high score set")
            sd.setHighScore(scorerShortCodes[1], score)
        end
        if ld.setHighScore(scorerShortCodes[3], time) then
        print(TAG, "high time set")
            sd.setHighScore(scorerShortCodes[3], time)
        end
    else
        if ld.setHighScore(scorerShortCodes[2], score) then
        print(TAG, "high tricky score set")
            sd.setHighScore(scorerShortCodes[2], score)
        end
        if ld.setHighScore(scorerShortCodes[4], time) then
        print(TAG, "high tricky time set")
            sd.setHighScore(scorerShortCodes[4], time)
        end
    end
end

local function syncToDatabase()
    for k, shortCode in pairs(scorerShortCodes) do
        print(TAG, "local high score: "..tostring(ld.getHighScore(shortCode)))
        sd.setHighScore(shortCode, ld.getHighScore(shortCode))
    end
end

local function syncLeaderboardListener(event)
    -- print(TAG, "syncLeaderboardListener()")
    if sd.isLoggedIn() then
        print(TAG, "is logged in")
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
    print(TAG, "high scores init")
    timer.performWithDelay(1000, syncLeaderboardListener, -1)
end

return v
-------------------------------------------------------------------------------]