-- Private Members ------------------------------------------------------------[
local TAG = "highScores:"

local leaderboardNames = {
    {
        name = "HighScore",
        type = "score",
        isTricky = false
    },
    {
        name = "HighScoreTricky",
        type = "score",
        isTricky = true
    },
    {
        name = "HighTime",
        type = "time",
        isTricky = false
    },
    {
        name = "HighTimeTricky",
        type = "time",
        isTricky = true
    }
}

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getTag()
    return TAG
end

function v.getScorerShortCodes()
    -- return scorerShortCodes
end

function v.getLeaderboardNames()
    return leaderboardNames
end

return v