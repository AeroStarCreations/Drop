-- Control center for writing and reading server storage data (PlayFab).
--
-- USES:
--  * Login
--  * Achievements
--  * High scores
--  * Purchases
--
-- !!! Make sure to call init() when using this module !!!

local playFabClientPlugin = require("plugin.playfab.client")
local gameNetwork = require("other.gameNetworkNew")
local json = require("json")
local highScoresModel = require("models.highScoresModel")
local ld = require("data.localData")

-- Local variables ------------------------------------------------------------[
local TAG = "serverData:"
local playFab
local alias
local loginCallback
local getLeaderboardCallback
local getAllLeaderboardValuesCallback
-------------------------------------------------------------------------------]

-- Leaderboards ---------------------------------------------------------------[
local function leaderboardSuccessListener(result)
    print(TAG, "Leaderboard SUCCESS")
    print(TAG, json.prettify(result))
    -- getLeaderboardCallback(result.Leaderboard)
end

local function getAllLeaderboardValuesSuccessListener(result)
    print(TAG, "Loaded all Leaderboard values")
    getAllLeaderboardValuesCallback(result)
end

local function leaderboardFailureListener(error)
    print(TAG, "Leaderboard FAILURE")
end

local function getAllLeaderboardValues()
    local request = {
        StatisticNames = {}
    }
    for k, board in pairs(highScoresModel.getLeaderboardNames()) do
        table.insert( request.StatisticNames, board.name )
    end
    playFab.GetPlayerStatistics(request, getAllLeaderboardValuesSuccessListener, leaderboardFailureListener)
end

local function setLeaderboardValue(score, time, isTricky)
    local trickySuffix = ""
    if isTricky then
        trickySuffix = "Tricky"
    end
    local request = {
        Statistics = {
            {
                StatisticName = "HighScore" .. trickySuffix,
                Value = score
            },
            {
                StatisticName = "HighTime" .. trickySuffix,
                Value = time
            }
        }
    }
    playFab.UpdatePlayerStatistics(request, leaderboardSuccessListener, leaderboardFailureListener)
end

local function getLeaderboard(isScore, isTricky, isTop)
    local name = "HighScore"
    if not isScore then
        name = "HighTime"
    end
    if isTricky then
        name = name .. "Tricky"
    end
    local request = {
        MaxResultsCount = 100,
        StatisticName = name
    }
    if isTop then
        playFab.GetLeaderboard(request, leaderboardSuccessListener, leaderboardFailureListener)
    else
        playFab.GetLeaderboardAroundPlayer(request, leaderboardSuccessListener, leaderboardFailureListener)
    end
end
-------------------------------------------------------------------------------]

-- Leaderboards ---------------------------------------------------------------[

-- gameStats = {
--     gamesPlayed = 1,
--     deaths = int,
--     drops = {
--         {
--             type = <dropType>,
--             normalDodges = int,
--             normalCollisions = int,
--             specialDodges = int,
--             specialCollisions = int
--         },
--         --one for each drop type
--     }
-- }
local function setPlayerGameData(gameStats)

end
-------------------------------------------------------------------------------]

-- Authentication -------------------------------------------------------------[
local function setupPlayFab()
    playFab = playFabClientPlugin.PlayFabClientApi
    playFab.settings.titleId = "C5B8B"
end

local function setDisplayName(displayName)
    if alias and string.len(alias) >= 3 then --PlayFab requires a minimum display name length of 3
        if displayName == nil or displayName ~= alias then
            playFab.UpdateUserTitleDisplayName({
                DisplayName = displayName
            })
        end
    end
end

local function loginSuccessListener(result)
    print(TAG, "PlayFab login SUCCESS: " .. result.PlayFabId)
    print(TAG, "Welcome: " .. result.InfoResultPayload.AccountInfo.TitleInfo.DisplayName)
    if loginCallback ~= nil then
        loginCallback(result)
    end

    local request = {
        FunctionName = "helloWorld",
        FunctionParameter = {inputValue = "Nathan Balli"}
    }
    playFab.ExecuteCloudScript(
        request,
        function(result) 
            print("**************", json.prettify(result) )
        end,
        function(error) 
            print("##############")
            json.prettify(error) 
        end
    )
end

local function loginFailureListener(error)
    print(TAG, "PlayFab login FAILURE: " .. error.errorMessage)
    if loginCallback then
        loginCallback(error)
    end
end

local function loginWithGameCenter(signature)
    local loginRequest = {
        CreateAccount = true,
        PublicKeyUrl = signature.keyURL,
        Salt = signature.salt,
        Signature = signature.signature,
        Timestamp = signature.timestamp,
        PlayerId = signature.playerId,
        InfoRequestParameters = { GetUserAccountInfo = true }
    }
    playFab.LoginWithGameCenter(loginRequest, loginSuccessListener, loginFailureListener)
end

local function loginWithGoogle(signature)
    local loginRequest = {
        CreateAccount = true,
        ServerAuthCode = signature.serverAuthCode,
        InfoRequestParameters = { GetUserAccountInfo = true }
    }
    playFab.LoginWithGoogleAccount(loginRequest, loginSuccessListener, loginFailureListener)
end

local function loginWithDeviceId()

end

local function gameNetworkCallback(type, signature)
    alias = signature.alias
    if signature.playerId == nil then
        loginWithDeviceId()
    elseif type == "gamecenter" then
        loginWithGameCenter(signature)
    elseif type == "google" then
        loginWithGoogle(signature)
    end
end
-------------------------------------------------------------------------------]
    
-- Returned values/table ------------------------------------------------------[
local v = {}

function v.init(callback)
    loginCallback = callback
    setupPlayFab()
    if system.getInfo("environment") == "simulator" then
        playFab.LoginWithCustomID({
                CustomId = "TestCustomId",
                CreateAccount = true,
                InfoRequestParameters = { GetUserAccountInfo = true }
            },
            loginSuccessListener,
            loginFailureListener
        )
    else
        gameNetwork.login(gameNetworkCallback)
    end
end

function v.setDisplayName(name)
    setDisplayName(name)
end

function v.sendToLeaderboard(score, time, isTricky)
    setLeaderboardValue(score, time, isTricky)
end

function v.getLeaderboard(isScore, isTricky, isTop, callback)
    getLeaderboardCallback = callback
    getLeaderboard(isScore, isTricky)
end

function v.getAllLeaderboardValues(callback)
    getAllLeaderboardValuesCallback = callback
    getAllLeaderboardValues()
end

function v.updatePlayerGameData(gameStats)
    setPlayerGameData(gameStats)
end

return v
-------------------------------------------------------------------------------]
