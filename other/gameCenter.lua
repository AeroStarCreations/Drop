local gameNetwork = require("gameNetwork")
local idVerify = require("plugin.idVerifySig")
local json = require("json")
local ld = require("data.localData")
local metrics = require("other.metrics")

-- Local variables ------------------------------------------------------------[
local TAG = "gameCenter:"

local callbackFunction
local playerData = {}
local didLoadPlayer
local didLoadSignature
-------------------------------------------------------------------------------]

-- Local methods and ops ------------------------------------------------------[
local function showErrorAlert()
    native.showAlert("Could not log in", "Please check your network connection and try again.", {"OK"})
end

local function showAccountAlert()
    native.showAlert(
        "Could not log in",
        "Please set up your GameCenter account to use features such as leaderboards.",
        {"OK"}
    )
end

local function requestOnComplete()
    if didLoadPlayer and didLoadSignature then
        callbackFunction("gamecenter", playerData)
    end
end

local function getPlayerInfoCallback(player)
    local metricParams = {
        isFailure = player.data == nil
    }
    if player.data then
        print(TAG, "Success: GameCenter player:\n"..json.prettify(player))
        playerData.playerId = player.data.playerID
        playerData.alias = player.data.alias
        didLoadPlayer = true
        requestOnComplete()

        ld.setAlias(player.data.alias)

        metricParams.playerId = player.playerId
        metricParams.alias = player.alias
        metricParams.isAuthenticated = player.isAuthenticated
        metricParams.isUnderage = player.isUnderage
    else
        print(TAG, "Failure: GameCenter could not load player")
    end
    metrics.stopTimedEvent("gameCenter_getPlayerInfo", metricParams)
end

-- event value
-- {
--     "keyURL":"<keyURL>",
--     "name":"IdVerifySigEvent",
--     "salt":"<salt>",
--     "signature":"<signature>",
--     "timestamp":12345678,
--     "isError":false
-- }
local function verifyListener(event)
    print(TAG, "*** verifyListener ***")
    if not event.isError then
        playerData.keyURL = event.keyURL
        playerData.salt = event.salt
        playerData.signature = event.signature
        playerData.timestamp = event.timestamp
        didLoadSignature = true
        requestOnComplete()
        print(TAG, "Success: Verify Signature\n" .. json.prettify(event))
    else
        print(TAG, "Failure: Verify Signature")
    end
    metrics.stopTimedEvent("gameCenter_getSignature", {isFailure = event.isError})
end

local function gamecenterCallback(event)
    print(TAG, "*** gamecenterCallback ***\n" .. json.prettify(event))
    if event.data then -- Success
        print(TAG, "GameCenter SUCCESS")
        if event.type == "init" then
            gameNetwork.request("loadLocalPlayer", {listener = getPlayerInfoCallback})
            idVerify.getSignature()
            metrics.startTimedEvent("gameCenter_getPlayerInfo")
            metrics.startTimedEvent("gameCenter_getSignature")
        end
    elseif event.errorCode then -- Network failure
        print("GameCenter ERROR: " .. event.errorMessage)
        showErrorAlert()
    else -- General failure
        print("GameCenter FAILURE")
        showAccountAlert()
    end

    local metricParams = {
        isFailure = (not event.data)
    }
    if event.errorCode then
        metricParams.errorCode = event.errorCode
        metricParams.errorMessage = event.errorMessage
    end
    metrics.logEvent("gameCenter_init", metricParams)
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.init = function(callback)
    callbackFunction = callback
    didLoadPlayer = false
    didLoadSignature = false
    idVerify.init(verifyListener)
    gameNetwork.init("gamecenter", gamecenterCallback)
end

return v
