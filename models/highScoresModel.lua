-- Private Members ------------------------------------------------------------[
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

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getTag()
    return TAG
end

function v.getScorerShortCodes()
    return scorerShortCodes
end

function v.getLeaderboardShortCodes()
    return leaderboardShortCodes
end

return v