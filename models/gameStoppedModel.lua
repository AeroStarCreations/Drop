-- Private Members ------------------------------------------------------------[
local gamePausedText = "Game Paused"
local resumeLabel = "Resume"
local gameOverText = "Game Over"
local reviveLabel = "Revive"
local purchaseLabel = "Purchase Lives"
local mainButtonLabel = "Main"
local restartButtonLabel = "Restart"
local categoryText = "Score:\nTime:"
local highScoreText = "High Score\n• • •\n"
local highTimeText = "High Time\n• • •\n"

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getGamePausedText()
    return gamePausedText
end

function v.getResumeLabel()
    return resumeLabel
end

function v.getGameOverText()
    return gameOverText
end

function v.getReviveLabel()
    return reviveLabel
end

function v.getPurchaseLabel()
    return purchaseLabel
end

function v.getMainButtonLabel()
    return mainButtonLabel
end

function v.getRestartButtonLabel()
    return restartButtonLabel
end

function v.getCategoryText()
    return categoryText
end

function v.getHighScoreText()
    return highScoreText
end

function v.getHighTimeText()
    return highTimeText
end

return v