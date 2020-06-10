local ld = require( "data.localData" )
local sd = require( "data.serverData" )
local model = require( "models.highScoresModel" )
local json = require("json")

-- Local variables ------------------------------------------------------------[

-------------------------------------------------------------------------------]

-- Local functions ------------------------------------------------------------[
local function sendToLeaderboardCallback(response)
    for k, stat in pairs(response) do
        ld.setHighScore(stat.StatisticName, stat.Value)
    end
end

local function checkHighScore( score, time )
    print(model.getTag(), "checkHighScore()")

    local leaderboards = model.getLeaderboardNames()
    local isTricky = not ld.getSpecialDropsEnabled()

    for k, board in pairs(leaderboards) do
        if isTricky == board.isTricky then
            local value = score
            if board.type == "time" then
                value = time
            end
            if ld.isHighScore(board.name, value) then
                sd.updateLeaderboard(score, time, isTricky, sendToLeaderboardCallback)
                break -- We break here because sd.updateLeaderboard() will send all value to PlayFab
            end
        end
    end
end

local function storeHighScores(values)
    for k, stat in pairs(values.Statistics) do
        ld.setHighScoreFromServer(stat.StatisticName, stat.Value)
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

function v.checkHighScore( score, time )
    checkHighScore( score, time )
end

function v.storeHighScoresFromServer(values)
    storeHighScores(values)
end

return v
-------------------------------------------------------------------------------]