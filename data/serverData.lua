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
local loginCallbackParams
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

-- Local Methods --------------------------------------------------------------[
local function getJson(table)
    return json.prettify(table)
end
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
    if params.isTop then
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

--- params = {
---     keys: string[]
--- }
local function getGameStats(params)
    local request = {
        Keys = params.keys
    }
    playFab.GetUserData(request, getUserDataSuccessListener, getUserDataFailureListener)
end

local function updateGameStatsAndAchievementsSuccessListener(result)
    if result.Error then
        print(TAG, "update user data FAILURE\n"..getJson(result))
    else
        print(TAG, "update user data SUCCESS\n"..getJson(result))
        if updateGameStatsAndAchievementsCallback then
            updateGameStatsAndAchievementsCallback(result.FunctionResult.CompletedAchievements)
        end
    end
end

local function updateGameStatsAndAchievementsFailureListener(error)
    print(TAG, "update user data FAILURE")
    -- print(TAG, json.prettify(error))
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
    playFab.ValidateGooglePlayPurchase(
        request,
        validateReceiptSuccessListener,
        validateReceiptFailureListener
    )
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
    if displayName then print(TAG, "displayName: "..displayName) end
    if alias then print(TAG, "alias: "..alias) end
    if alias and string.len(alias) >= 3 then --PlayFab requires a minimum display name length of 3
        if displayName ~= alias then
            playFab.UpdateUserTitleDisplayName(
                {
                    DisplayName = displayName --TODO: Does this need success and failure listeners?
                }
            )
        end
    end
end

local function loginSuccessListener(result)
    print(TAG, "PlayFab login SUCCESS: " .. getJson(result))
    local displayName = result.InfoResultPayload.AccountInfo.TitleInfo.DisplayName
    if displayName then
        print(TAG, "Welcome: " .. displayName)
    end
    setDisplayName(displayName)
    isLoggedIn = true
    if loginCallback then
        if loginCallbackParams then
            loginCallback(loginCallbackParams)
        else
            loginCallback(result)
        end
    end
    loginCallback = nil
    loginCallbackParams = nil
end

local function loginFailureListener(error)
    print(TAG, "PlayFab login FAILURE:\n" .. getJson(error))
    if loginCallback and not loginCallbackParams then
        loginCallback(error)
    end
    loginCallback = nil
end

local function loginWithGameCenter(signature)
    print(TAG, "*******************\n"..getJson(signature))
    --Out of all the members of 'signature', playerId is at least needed to log in
    local loginRequest = {
        CreateAccount = true,
        -- PublicKeyUrl = signature.keyURL,
        -- Salt = signature.salt,
        -- Signature = signature.signature,
        -- Timestamp = signature.timestamp,
        PlayerId = signature.playerId,
        InfoRequestParameters = {GetUserAccountInfo = true},
        TitleId = "C5B8B"
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

local function authenticate(callback, params)
    loginCallback = callback
    loginCallbackParams = params
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
    completeTaskIfAuthenticated(validateGoogleReceipt, {
        currencyCode = currencyCode,
        purchasePrice = purchasePrice,
        receipt = receipt
    })
end

return v
-------------------------------------------------------------------------------]
