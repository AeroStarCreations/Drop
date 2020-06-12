-- Control center for writing and reading server storage data (PlayFab).
--
-- USES:
--  * Login
--  * Achievements
--  * High scores/Leaderboards
--  * Purchases
--
-- !!! Make sure to call init() when using this module !!!

local playFabClientPlugin = require("plugin.playfab.client")
local gameNetwork = require("other.gameNetworkNew")
local json = require("json")
local highScoresModel = require("models.highScoresModel")

-- Local variables ------------------------------------------------------------[
local TAG = "serverData:"
local playFab
local alias
local loginCallback
local getLeaderboardCallback
local getAllLeaderboardValuesCallback
local updateLeaderboardCallback
local getGameStatsCallback
local updateGameStatsAndAchievementsCallback
local claimAchievementRewardCallback
local getProductInfoCallback
local validateReceiptCallback
local isLoggedIn
-------------------------------------------------------------------------------]

-- Leaderboards ---------------------------------------------------------------[
local function getAllLeaderboardValuesSuccessListener(result)
    print(TAG, "Loaded all Leaderboard values")
    getAllLeaderboardValuesCallback(result)
end

local function getAllLeaderboardValuesFailureListener(error)
    print(TAG, "Failed to load all Leaderboard values")
    print(TAG, json.prettify(error))
end

local function getAllLeaderboardValues()
    local request = {
        StatisticNames = {}
    }
    for k, board in pairs(highScoresModel.getLeaderboardNames()) do
        table.insert(request.StatisticNames, board.name)
    end
    playFab.GetPlayerStatistics(request, getAllLeaderboardValuesSuccessListener, getAllLeaderboardValuesFailureListener)
end

local function updateLeaderboardSuccessListener(result)
    print(TAG, "updateLeaderboard SUCCESS")
    print(TAG, json.prettify(result))
    updateLeaderboardCallback(result.FunctionResult)
end

local function updateLeaderboardFailureListener(error)
    print(TAG, "updateLeaderboard FAILURE")
    print(TAG, json.prettify(error))
end

local function updateLeaderboard(score, time, isTricky)
    local trickySuffix = ""
    if isTricky then
        trickySuffix = "Tricky"
    end
    local request = {
        FunctionName = "updateLeaderboard",
        FunctionParameter = {
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
    }
    playFab.ExecuteCloudScript(request, updateLeaderboardSuccessListener, updateLeaderboardFailureListener)
end

local function getLeaderboardSuccessListener(result)
    print(TAG, "Leaderboard SUCCESS")
    print(TAG, json.prettify(result))
    getLeaderboardCallback(result.Leaderboard)
end

local function getLeaderboardFailureListener(error)
    print(TAG, "Leaderboard FAILURE")
    print(TAG, json.prettify(error))
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
        playFab.GetLeaderboard(request, getLeaderboardSuccessListener, getLeaderboardFailureListener)
    else
        playFab.GetLeaderboardAroundPlayer(request, getLeaderboardSuccessListener, getLeaderboardFailureListener)
    end
end
-------------------------------------------------------------------------------]

-- Player Stats ---------------------------------------------------------------[
-- result = {
--     Data = {
--         statName = {
--             Value = "1",
--             Permission = "Private",
--             LastUpdated = "2020-05-05T03:10:50.681Z"
--         }
--     },
--     DataVersion = 1
-- }
local function getUserDataSuccessListener(result)
    print(TAG, "get user data SUCCESS")
    -- print(TAG, json.prettify(result))
    getGameStatsCallback(result.Data)
end

local function getUserDataFailureListener(error)
    print(TAG, "get user data FAILURE")
    -- print(TAG, json.prettify(error))
    getGameStatsCallback(error)
end

local function getGameStats(keys)
    local request = {
        Keys = keys
    }
    playFab.GetUserData(request, getUserDataSuccessListener, getUserDataFailureListener)
end

local function updateGameStatsAndAchievementsSuccessListener(result)
    print(TAG, "update user data SUCCESS")
    if updateGameStatsAndAchievementsCallback then
        updateGameStatsAndAchievementsCallback(result.FunctionResult.CompletedAchievements)
    end
end

local function updateGameStatsAndAchievementsFailureListener(error)
    print(TAG, "update user data FAILURE")
    -- print(TAG, json.prettify(error))
end

local function updateGameStatsAndAchievements(gameStats)
    local request = {
        FunctionName = "updateUserDataAndCheckAchievements",
        FunctionParameter = {
            Data = gameStats
        }
    }
    playFab.ExecuteCloudScript(
        request,
        updateGameStatsAndAchievementsSuccessListener,
        updateGameStatsAndAchievementsFailureListener
    )
end
-------------------------------------------------------------------------------]

-- Achievements ---------------------------------------------------------------[
local function claimAchievementRewardSuccessListener(result)
    print(TAG, "claim achievement reward SUCCESS")
    claimAchievementRewardCallback(result)
end

local function claimAchievementRewardFailureListener(error)
    print(TAG, "claim achievement reward FAILURE")
    claimAchievementRewardCallback(error)
end

local function claimAchievementReward(achievementId)
    local request = {
        FunctionName = "claimAchievementReward",
        FunctionParameter = {
            achievementId = achievementId
        }
    }
    playFab.ExecuteCloudScript(
        request,
        claimAchievementRewardSuccessListener,
        claimAchievementRewardFailureListener
    )
end
-------------------------------------------------------------------------------]

-- Store ----------------------------------------------------------------------[
-- result = {
--     Catalog = {
--         {
--             Description = string,
--             Tags = {string},
--             Bundle = {
--                 BundledItems = {},
--                 BundledResultTables = {},
--                 BundledVirtualCurrencies = {
--                     SH = int,
--                     LF = int
--                 }
--             },
--             CanBecomeCharacter = boolean,
--             DisplayName = string,
--             InitialLimitedEditionCount = int,
--             Consumable = {},
--             IsLimitedEdition = boolean,
--             IsTradable = boolean,
--             VirtualCurrencyPrices = {
--                 RM = int
--             },
--             CatalogVersion = string,
--             IsStackable = boolean,
--             ItemId = string
--         },
--         ...
--     }
-- }

local function getProductInfoSuccessListener(result)
    print(TAG, "get product info SUCCESS")
    getProductInfoCallback(result)
end

local function getProductInfoFailureListener(error)
    print(TAG, "get product info FAILURE")
    getProductInfoCallback(error)
end

local function getProductInfo()
    local request = {
        CatalogVersion = nil  --this gets the default catalog
    }
    playFab.GetCatalogItems(
        request,
        getProductInfoSuccessListener,
        getProductInfoFailureListener
    )
end

local function validateReceiptSuccessListener(result)
    print(TAG, "validate receipt SUCCESS")
    validateReceiptCallback(result)
end

local function validateReceiptFailureListener(error)
    print(TAG, "validate receipt FAILURE")
    validateReceiptCallback(error)
end

local function validateGoogleReceipt(currencyCode, purchasePrice, receipt, signature)
    local request = {
        CurrencyCode = currencyCode,
        PurchasePrice = purchasePrice,
        ReceiptJson = receipt,
        Signature = signature
    }
    playFab.ValidateGooglePlayPurchase(
        request,
        validateReceiptSuccessListener,
        validateReceiptFailureListener
    )
end

local function validateAppleReceipt(currencyCode, purchasePrice, receipt)
    local request = {
        CurrencyCode = currencyCode,
        PurchasePrice = purchasePrice,
        ReceiptData = receipt,
    }
    playFab.ValidateIOSReceipt(
        request,
        validateReceiptSuccessListener,
        validateReceiptFailureListener
    )
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
            playFab.UpdateUserTitleDisplayName(
                {
                    DisplayName = displayName
                }
            )
        end
    end
end

local function loginSuccessListener(result)
    print(TAG, "PlayFab login SUCCESS: " .. result.PlayFabId)
    local displayName = result.InfoResultPayload.AccountInfo.TitleInfo.DisplayName
    print(TAG, "Welcome: " .. displayName)
    setDisplayName(displayName)
    isLoggedIn = true
    if loginCallback then
        loginCallback(result)
    end
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
        InfoRequestParameters = {GetUserAccountInfo = true}
    }
    playFab.LoginWithGameCenter(loginRequest, loginSuccessListener, loginFailureListener)
end

local function loginWithGoogle(signature)
    local loginRequest = {
        CreateAccount = true,
        ServerAuthCode = signature.serverAuthCode,
        InfoRequestParameters = {GetUserAccountInfo = true}
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
        playFab.LoginWithCustomID(
            {
                CustomId = "TestCustomId",
                CreateAccount = true,
                InfoRequestParameters = {GetUserAccountInfo = true}
            },
            loginSuccessListener,
            loginFailureListener
        )
    else
        gameNetwork.login(gameNetworkCallback)
    end
end

function v.isLoggedIn()
    return isLoggedIn
end

function v.setDisplayName(name)
    setDisplayName(name)
end

function v.updateLeaderboard(score, time, isTricky, callback)
    updateLeaderboardCallback = callback
    updateLeaderboard(score, time, isTricky)
end

function v.getLeaderboard(isScore, isTricky, isTop, callback)
    getLeaderboardCallback = callback
    getLeaderboard(isScore, isTricky)
end

function v.getAllLeaderboardValues(callback)
    getAllLeaderboardValuesCallback = callback
    getAllLeaderboardValues()
end

function v.getGameStats(keys, callback)
    getGameStatsCallback = callback
    getGameStats(keys)
end

function v.updateGameStatsAndAchievements(gameStats, callback)
    updateGameStatsAndAchievementsCallback = callback
    updateGameStatsAndAchievements(gameStats)
end

function v.claimAchievementReward(achievementId, callback)
    claimAchievementRewardCallback = callback
    claimAchievementReward(achievementId)
end

function v.getProductInformationFromServer(callback)
    getProductInfoCallback = callback
    getProductInfo()
end

function v.validateGoogleReceipt(currencyCode, purchasePrice, receipt, signature, callback)
    validateReceiptCallback = callback
    validateGoogleReceipt(currencyCode, purchasePrice, receipt, signature)
end

function v.validateAppleReceipt(currencyCode, purchasePrice, receipt, callback)
    validateReceiptCallback = callback
    validateAppleReceipt(currencyCode, purchasePrice, receipt)
end

return v
-------------------------------------------------------------------------------]
