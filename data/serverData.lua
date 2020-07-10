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
local metrics = require("other.metrics")

-- Local variables ------------------------------------------------------------[
local TAG = "serverData:"
local playFab
local gameNetworkAlias
local isLoggedIn

local loginCallback
local loginCallbackParams
local getLeaderboardCallback
local getAllLeaderboardValuesCallback
local updateLeaderboardCallback
local getGameStatsCallback
local updateGameStatsAndAchievementsCallback
local claimAchievementRewardCallback
local getProductInfoCallback
local validateReceiptCallback
-------------------------------------------------------------------------------]

-- Local Methods --------------------------------------------------------------[
local function getJson(table)
    return json.prettify(table)
end

local function getFormattedGameNetworkAlias()
    if not gameNetworkAlias then return nil end
    while string.len(gameNetworkAlias) < 3 do --PlayFab requires a minimum display name length of 3
        gameNetworkAlias = gameNetworkAlias.." "
    end
    return gameNetworkAlias
end

---isFailure: boolean,
---name: string,
---data: table (optional)
---alwaysPrintData: boolean (optional) Print data even if isSuccess
local function printResultMessage(isFailure, name, data, alwaysPrintData)
    local message
    if isFailure then
        message = "Failure: "..name
    else
        message = "Success: "..name
    end
    if (isFailure or alwaysPrintData) and type(data) == "table" then
        message = message.."\n"..getJson(data)
    end
    print(TAG, message)
end

---request: (optional)
local function startTimedMetric(eventId, playfabAPI, request)
    local params = {
        playfabAPI = playfabAPI
    }
    if request then
        params.request = getJson(request)
    end
    metrics.startTimedEvent(eventId, params)
end

local function stopTimedMetric(eventId, result)
    local params = {
        isFailure = result.error or result.Error
    }
    if result.error then
        params.httpStatus = result.status
        params.playfabErrorCode = result.error
        params.message = result.errorMessage
        params.details = result.errorDetails
    elseif result.Error then
        params.errorCode = result.Error.Error
        params.message = result.Error.Message
        params.stackTrace = result.Error.StackTrace
    end
    metrics.stopTimedEvent(eventId, params)
end
-------------------------------------------------------------------------------]

-- Leaderboards ---------------------------------------------------------------[
local function getAllLeaderboardValuesListener(result)
    if not result.error then
        getAllLeaderboardValuesCallback(result)
    end
    stopTimedMetric("playfab_getAllLeaderboardValues", result)
    printResultMessage(result.error, "get leaderboard values", result)
end

local function getAllLeaderboardValues()
    local request = {
        StatisticNames = {}
    }
    for k, board in pairs(highScoresModel.getLeaderboardNames()) do
        table.insert(request.StatisticNames, board.name)
    end
    playFab.GetPlayerStatistics(request, getAllLeaderboardValuesListener, getAllLeaderboardValuesListener)
    startTimedMetric("playfab_getAllLeaderboardValues", "GetPlayerStatistics", request)
end

local function updateLeaderboardListener(result)
    local isFailure = result.Error or result.error
    if not isFailure then
        updateLeaderboardCallback(result.FunctionResult)
    end
    stopTimedMetric("playfab_updateLeaderboard", result)
    printResultMessage(isFailure, "update leaderboard", result)
end

--- params = {
---     score: int,
---     time: int,
---     isTricky boolean
--- }
local function updateLeaderboard(params)
    local trickySuffix = ""
    if params.isTricky then
        trickySuffix = "Tricky"
    end
    local request = {
        FunctionName = "updateLeaderboard",
        FunctionParameter = {
            Statistics = {
                {
                    StatisticName = "HighScore" .. trickySuffix,
                    Value = params.score
                },
                {
                    StatisticName = "HighTime" .. trickySuffix,
                    Value = params.time
                }
            }
        }
    }
    playFab.ExecuteCloudScript(request, updateLeaderboardListener, updateLeaderboardListener)
    startTimedMetric("playfab_updateLeaderboard", "ExecuteCloudScript", request)
end

local function getLeaderboardListener(result)
    if not result.error then
        getLeaderboardCallback(result.Leaderboard)
    end
    stopTimedMetric("playfab_getLeaderboard", result)
    printResultMessage(result.error, "get leaderboard", result)
end

--- params = {
---     isScore: boolean,
---     isTricky: boolean,
---     isTop: boolean
--- }
local function getLeaderboard(params)
    local name = "HighScore"
    if not params.isScore then
        name = "HighTime"
    end
    if params.isTricky then
        name = name .. "Tricky"
    end
    local request = {
        MaxResultsCount = 100,
        StatisticName = name
    }
    local apiName
    if params.isTop then
        playFab.GetLeaderboard(request, getLeaderboardListener, getLeaderboardListener)
        apiName = "GetLeaderboard"
    else
        playFab.GetLeaderboardAroundPlayer(request, getLeaderboardListener, getLeaderboardListener)
        apiName = "GetLeaderboardAroundPlayer"
    end
    startTimedMetric("playfab_getLeaderboard", apiName, request)
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
local function getUserDataListener(result)
    if result.error then
        getGameStatsCallback(result)
    else
        getGameStatsCallback(result.Data)
    end
    stopTimedMetric("playfab_getGameStats", result)
    printResultMessage(result.error, "get user data", result)
end

--- params = {
---     keys: string[]
--- }
local function getGameStats(params)
    local request = {
        Keys = params.keys
    }
    playFab.GetUserData(request, getUserDataListener, getUserDataListener)
    startTimedMetric("playfab_getGameStats", "GetUserData", request)
end

local function updateGameStatsAndAchievementsListener(result)
    local isFailure = result.Error or result.error
    if not isFailure and updateGameStatsAndAchievementsCallback then
        updateGameStatsAndAchievementsCallback(result.FunctionResult.CompletedAchievements)
    end
    stopTimedMetric("playfab_updateGameStatsAndAchievements", result)
    printResultMessage(isFailure, "update user data", result)
end

--- params = {
---     gameStats: {}
--- }
local function updateGameStatsAndAchievements(params)
    local request = {
        FunctionName = "updateUserDataAndCheckAchievements",
        FunctionParameter = {
            Data = params.gameStats
        }
    }
    playFab.ExecuteCloudScript(request, updateGameStatsAndAchievementsListener, updateGameStatsAndAchievementsListener)
    startTimedMetric("playfab_updateGameStatsAndAchievements", "ExecuteCloudScript", request)
end
-------------------------------------------------------------------------------]

-- Achievements ---------------------------------------------------------------[
local function claimAchievementRewardListener(result)
    claimAchievementRewardCallback(result)
    local isFailure = result.Error or result.error
    stopTimedMetric("playfab_claimAchievementReward", result)
    printResultMessage(isFailure, "claim achievement reward", result)
end

--- params = {
---     achievementId: string
--- }
local function claimAchievementReward(params)
    local request = {
        FunctionName = "claimAchievementReward",
        FunctionParameter = {
            achievementId = params.achievementId
        }
    }
    playFab.ExecuteCloudScript(request, claimAchievementRewardListener, claimAchievementRewardListener)
    startTimedMetric("playfab_claimAchievementReward", "ExecuteCloudScript", request)
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

local function getProductInfoListener(result)
    getProductInfoCallback(result)
    stopTimedMetric("playfab_getProductInfo", result)
    printResultMessage(result.error, "get product info", result)
end

local function getProductInfo()
    local request = {
        CatalogVersion = nil  --this gets the default catalog
    }
    playFab.GetCatalogItems(request, getProductInfoListener, getProductInfoListener)
    startTimedMetric("playfab_getProductInfo", "GetCatalogItems", request)
end

local function validateReceiptListener(result)
    validateReceiptCallback(result)
    stopTimedMetric("playfab_validateReceipt", result)
    printResultMessage(result.error, "validate receipt", result)
end

--- params = {
---     currencyCode: string,
---     purchasePrice: string,
---     receipt: string,
---     signature: string
--- }
local function validateGoogleReceipt(params)
    local request = {
        CurrencyCode = params.currencyCode,
        PurchasePrice = params.purchasePrice,
        ReceiptJson = params.receipt,
        Signature = params.signature
    }
    playFab.ValidateGooglePlayPurchase(request, validateReceiptListener, validateReceiptListener)
    startTimedMetric("playfab_validateReceipt", "ValidateGooglePlayPurchase", request)
end

--- params = {
---     currencyCode: string,
---     purchasePrice: string,
---     receipt: string
--- }
local function validateAppleReceipt(params)
    local request = {
        CurrencyCode = params.currencyCode,
        PurchasePrice = params.purchasePrice,
        ReceiptData = params.receipt,
    }
    playFab.ValidateIOSReceipt(request, validateReceiptListener, validateReceiptListener)
    startTimedMetric("playfab_validateReceipt", "ValidateIOSReceipt", request)
end
-------------------------------------------------------------------------------]
    
-- Authentication -------------------------------------------------------------[
local function setupPlayFab()
    playFab = playFabClientPlugin.PlayFabClientApi
    playFab.settings.titleId = "C5B8B"
end

local function setDisplayNameListener(result)
    stopTimedMetric("playfab_setDisplayName", result)
    printResultMessage(result.error, "set display name", result)
end

local function setDisplayName(currentDisplayName)
    local newDisplayName

    if not gameNetworkAlias and not currentDisplayName then
        newDisplayName = "vapor"
    elseif gameNetworkAlias and not currentDisplayName then
        newDisplayName = getFormattedGameNetworkAlias()
    elseif gameNetworkAlias and currentDisplayName then
        if currentDisplayName ~= getFormattedGameNetworkAlias() then
            newDisplayName = getFormattedGameNetworkAlias()
        end
    end

    if newDisplayName then
        local request = {
            DisplayName = newDisplayName
        }
        playFab.UpdateUserTitleDisplayName(request, setDisplayNameListener, setDisplayNameListener)
        startTimedMetric("playfab_setDisplayName", "UpdateUserTitleDisplayName", request)
    end
end

local function loginListener(result)
    if result.error then
        if loginCallback and not loginCallbackParams then
            loginCallback(result.error)
        end
        loginCallback = nil
    else
        isLoggedIn = true
        local displayName = result.InfoResultPayload.AccountInfo.TitleInfo.DisplayName
        setDisplayName(displayName)
        if loginCallback then
            if loginCallbackParams then --This occurs when a normal PlayFab method was called but we needed to login to a game network first
                loginCallback(loginCallbackParams)
            else
                loginCallback(result)
            end
        end
    end
    loginCallback = nil
    loginCallbackParams = nil
    stopTimedMetric("playfab_login", result)
    printResultMessage(result.error, "login", result, true)
end

local function loginWithGameCenter(playerData)
    --Out of all the members of 'signature', playerId is at least needed to log in
    local loginRequest = {
        CreateAccount = true,
        PublicKeyUrl = playerData.keyURL,
        Salt = playerData.salt,
        Signature = playerData.signature,
        Timestamp = playerData.timestamp,
        PlayerId = playerData.playerId,
        InfoRequestParameters = {GetUserAccountInfo = true},
        TitleId = playFab.settings.titleId
    }
    playFab.LoginWithGameCenter(loginRequest, loginListener, loginListener)
    startTimedMetric("playfab_login", "LoginWithGameCenter", loginRequest)
end

local function loginWithGoogle(playerData)
    local loginRequest = {
        CreateAccount = true,
        ServerAuthCode = playerData.serverAuthCode,
        InfoRequestParameters = {GetUserAccountInfo = true}
    }
    playFab.LoginWithGoogleAccount(loginRequest, loginListener, loginListener)
    startTimedMetric("playfab_login", "LoginWithGoogleAccount", loginRequest)
end

local function loginWithDeviceId()
end

local function gameNetworkCallback(type, playerData)
    print(TAG, "gameNetworkCallback()\n".."type: "..type.."\n".."playerData:"..json.prettify(playerData))
    gameNetworkAlias = playerData.alias
    if playerData.playerId == nil then
        loginWithDeviceId()
    elseif type == "gamecenter" then
        loginWithGameCenter(playerData)
    elseif type == "google" then
        loginWithGoogle(playerData)
    end
end

local function authenticate(callback, params)
    loginCallback = callback
    loginCallbackParams = params
    setupPlayFab()
    if system.getInfo("environment") == "simulator" then
        local request = {
            CustomId = "TestCustomId",
            CreateAccount = true,
            InfoRequestParameters = {GetUserAccountInfo = true}
        }
        playFab.LoginWithCustomID(request, loginListener, loginListener)
        startTimedMetric("playfab_login", "LoginWithCustomID", request)
    else
        gameNetwork.login(gameNetworkCallback)
    end
end
-------------------------------------------------------------------------------]

-- Check If Authenticated -----------------------------------------------------[
local function completeTaskIfAuthenticated(functionToCall, params)
    if isLoggedIn then
        functionToCall(params)
    else
        authenticate(functionToCall, params)
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

function v.init(callback)
    authenticate(callback)
end

function v.isLoggedIn()
    return isLoggedIn
end

function v.getPlayfab()
    return playFab
end

function v.updateLeaderboard(score, time, isTricky, callback)
    updateLeaderboardCallback = callback
    completeTaskIfAuthenticated(updateLeaderboard, {
        score = score,
        time = time,
        isTricky = isTricky
    })
end

function v.getLeaderboard(isScore, isTricky, isTop, callback)
    getLeaderboardCallback = callback
    completeTaskIfAuthenticated(getLeaderboard, {
        isScore = isScore,
        isTricky = isTricky,
        isTop = isTop
    })
end

function v.getAllLeaderboardValues(callback)
    getAllLeaderboardValuesCallback = callback
    completeTaskIfAuthenticated(getAllLeaderboardValues)
end

function v.getGameStats(keys, callback)
    getGameStatsCallback = callback
    completeTaskIfAuthenticated(getGameStats, {
        keys = keys
    })
end

function v.updateGameStatsAndAchievements(gameStats, callback)
    updateGameStatsAndAchievementsCallback = callback
    completeTaskIfAuthenticated(updateGameStatsAndAchievements, {
        gameStats = gameStats
    })
end

function v.claimAchievementReward(achievementId, callback)
    claimAchievementRewardCallback = callback
    completeTaskIfAuthenticated(claimAchievementReward, {
        achievementId = achievementId
    })
end

function v.getProductInformationFromServer(callback)
    getProductInfoCallback = callback
    completeTaskIfAuthenticated(getProductInfo)
end

function v.validateGoogleReceipt(currencyCode, purchasePrice, receipt, signature, callback)
    validateReceiptCallback = callback
    completeTaskIfAuthenticated(validateGoogleReceipt, {
        currencyCode = currencyCode,
        purchasePrice = purchasePrice,
        receipt = receipt,
        signature = signature
    })
end

function v.validateAppleReceipt(currencyCode, purchasePrice, receipt, callback)
    validateReceiptCallback = callback
    completeTaskIfAuthenticated(validateAppleReceipt, {
        currencyCode = currencyCode,
        purchasePrice = purchasePrice,
        receipt = receipt
    })
end

return v
-------------------------------------------------------------------------------]
