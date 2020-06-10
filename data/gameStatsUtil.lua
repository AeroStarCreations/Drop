-- Private Members ------------------------------------------------------------[
local sd = require("data.serverData")
local ld = require("data.localData")
local highScoresModel = require("models.highScoresModel")
local json = require("json")
local Drop = require("views.other.Drop")

local playFabDataKeys = {
    "generalGameStats",
    "scoresAndTimes",
    "dropData"
}
local syncGameStatsTimeout = 10

local syncGameStatsCounter
local syncGameStatsAndAchievementsCallback

--[[
This method gets the value 'gameStats' from the PlayFab method GetUserData().
All values in gameStats (if present) are read and set to local storage if
they are higher than the currently stored local value.
--]]
local function setLocalGameStatsIfHigher(gameStats)
    if gameStats.generalGameStats then
        local generalGameStats = json.decode(gameStats.generalGameStats.Value)
        ld.setGamesPlayedIfHigher(generalGameStats.gamesPlayed)
        ld.setDeathsIfHigher(generalGameStats.deaths)
        ld.setPhase(generalGameStats.highestLevel)
        ld.setHurricaneTime(generalGameStats.hurricaneTime)
        ld.setShieldUsesIfHigher(generalGameStats.shieldUses)
        ld.setLifeUsesIfHigher(generalGameStats.reviveUses)
    end

    if gameStats.scoresAndTimes then
        local scoresAndTimes = json.decode(gameStats.scoresAndTimes.Value)
        for k, lb in pairs(highScoresModel.getLeaderboardNames()) do
            ld.setHighScore(lb.name, scoresAndTimes[lb.name])
        end
    end

    if gameStats.dropData then
        local dropData = json.decode(gameStats.dropData.Value)
        for name, stats in pairs(dropData) do
            ld.setDropTypeStatsIfHigher(name, stats)
        end
    end
end

--[[
Get the data object that will be sent to PlayFab via UpdateUserData().
The names of the members of 'gameStats' match playFabDataKeys.

Members of 'gameStats' are converted to json because PlayFab limits the
number of values passed to UpdateUserData() to 10. Sending json also makes
it easy to edit values on the PlayFab dashboard. It also results
in numbers being returned as numbers instead of PlayFab returning
numbers as strings.
--]]
local function getGameStatsObjectToSendToPlayFab()
    local gameStats = {}

    local generalGameStats = {
        gamesPlayed = ld.getGamesPlayed(),
        deaths = ld.getDeaths(),
        highestLevel = ld.getPhase(),
        hurricaneTime = ld.getHurricaneTime(),
        shieldUses = ld.getInvincibilityUses(),
        reviveUses = ld.getLifeUses()
    }
    gameStats.generalGameStats = json.encode(generalGameStats)

    local scoresAndTimes = {}
    for k, lb in pairs(highScoresModel.getLeaderboardNames()) do
        scoresAndTimes[lb.name] = ld.getHighScore(lb.name)
    end
    gameStats.scoresAndTimes = json.encode(scoresAndTimes)

    local dropData = {}
    for i = 1, #Drop.types do
        dropData[Drop.types[i]] = ld.getDropTypeStats(Drop.types[i])
    end
    gameStats.dropData = json.encode(dropData)

    return gameStats
end

--[[
-- Read game stats from PlayFab and update local game stats to highest values.
-- Write local game stats (with new highest values) to PlayFab.
--]]
local function getPlayerStatsCallback(results)
    if results.error then
        return
    end
    setLocalGameStatsIfHigher(results)
    local gameStats = getGameStatsObjectToSendToPlayFab()
    sd.updateGameStatsAndAchievements(gameStats, syncGameStatsAndAchievementsCallback)
end

--[[
-- Wait up to 10 seconds for user to be logged in.
-- Once logged in, syncGameStatsAndAchievements game stats on PlayFab with local game stats 
--]]
local function syncGameStatsAndAchievements()
    if syncGameStatsCounter >= syncGameStatsTimeout then
        return
    end
    syncGameStatsCounter = syncGameStatsCounter + 1

    if (sd.isLoggedIn()) then
        sd.getGameStats(playFabDataKeys, getPlayerStatsCallback)
    else
        timer.performWithDelay(1000, syncGameStatsAndAchievements)
    end
end

-- Public Members -------------------------------------------------------------[
local v = {}

function v.syncGameStatsAndAchievements(callback)
    syncGameStatsAndAchievementsCallback = callback
    syncGameStatsCounter = 0
    syncGameStatsAndAchievements()
end

return v
