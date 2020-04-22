local ld = require( "data.localData" )
local sd = require( "data.serverData" )
local model = require( "models.highScoresModel" )
local json = require("json")

-- Local variables ------------------------------------------------------------[

-------------------------------------------------------------------------------]
    
-- Local functions ------------------------------------------------------------[
local function checkHighScore( score, time )
    print(model.getTag(), "checkHighScore()")

    local leaderboards = model.getLeaderboardNames()
    local didSetRecord = false
    local isTricky = not ld.getSpecialDropsEnabled()

    for k, board in pairs(leaderboards) do
        if isTricky == board.isTricky then
            local value = score
            if board.type == "time" then
                value = time
            end
            didSetRecord = ld.setHighScore(board.name, value) or didSetRecord
        end
    end

    if didSetRecord then
        sd.sendToLeaderboard(score, time, isTricky)
    end
end

local function storeHighScores(values)
    print(model.getTag(), json.prettify(values))
    for k, stat in pairs(values.Statistics) do
        ld.setHighScoreFromServer(stat.StatisticName, stat.Value)
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.checkHighScore = function( score, time )
    checkHighScore( score, time )
end

function v.storeHighScoresFromServer(values)
    storeHighScores(values)
end

return v
-------------------------------------------------------------------------------]