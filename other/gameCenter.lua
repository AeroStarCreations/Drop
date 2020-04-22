local gameNetwork = require( "gameNetwork" )
local idVerify = require( "plugin.idVerifySig" )
local json = require( "json" )
local ld = require( "data.localData" )

-- Local variables ------------------------------------------------------------[
local TAG = "gameCenter:"

local gamesparks
local platformType
local networkType
local isGamesparksAvailable
local callbackFunction
local signature
-------------------------------------------------------------------------------]

-- Local methods and ops ------------------------------------------------------[
local function showErrorAlert()
    native.showAlert(
        "Could not log in",
        "Please check your network connection and try again.",
        { "OK" } )
end

local function showAccountAlert()
    native.showAlert(
        "Could not log in",
        "Please set up your GameCenter account to use features such as leaderboards.",
        { "OK" } )
end

local function getPlayerInfo()
    gameNetwork.request( "loadLocalPlayer", { listener = function(player)
        print(TAG, "getPlayerInfo():"..tostring(player))
        if player then
            -- testText.text = json.prettify(player) -- this works
            print(TAG, json.prettify(player))
            signature.playerId = player.data.playerID
            signature.alias = player.data.alias
            ld.setAlias( player.data.alias )
            callbackFunction( signature )
        else
            print(TAG, "gameNetwork could not get player")
        end
        callbackFunction( "gamecenter", signature )
    end})
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
local function verifyListener( event )
    signature = event
    if not signature.isError then
        print(TAG, "Verify Signature SUCCESS" )
        -- print(TAG, json.prettify(signature))
        -- testText.text = json.prettify(signature) -- this works
        getPlayerInfo()
    else
        print(TAG, "Verify Signature ERROR" )
    end
end

local function gamecenterCallback( event )
    if event.data then
        print(TAG, "GameCenter SUCCESS")
        idVerify.getSignature()
    elseif event.errorCode then
        print( "GameCenter ERROR" )
        showErrorAlert()
    else
        print( "GameCenter FAILURE" )
        showAccountAlert()
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.init = function( callback )
    callbackFunction = callback
    idVerify.init( verifyListener )
    gameNetwork.init( "gamecenter", gamecenterCallback )
end

return v