-- Control center for writing and reading server storage data.
-- Format of data can be found at the bottom of this file.
--
-- !!! Make sure to call init() when using this module !!!

local GS = require( "plugin.gamesparks" )
local json = require( "json" )
local ld = require( "localData" )
local gameCenter = require( "gameCenter" )
local googlePlay = require( "googlePlay" )

-- Local variables ------------------------------------------------------------[
local TAG = "serverData:"

local gs
local platformType
local isGamesparksAvailable
-------------------------------------------------------------------------------]

-- Local methods and ops ------------------------------------------------------[
local function setTypes()
    platformType = "ios"
    if system.getInfo( "platform" ) == "android" then
        platformType = "android"
    end
end

local function availabilityCallback( isAvailable )
    print( "Availability: " .. tostring(isAvailable) )
    if isAvailable then
        isGamesparksAvailable = true
    end
end

local function authenticatedCallback( playerId )
    if playerId then
        print( "Player ID: " .. tostring(playerId) )
    else
        print( "GameSparks authentication FAILED" )
    end
end

local function setUpGamesparks()
    gs = createGS()
    gs.setLogger( print )
    gs.setApiKey( "C372422jElYG" )
    gs.setApiSecret( "DvSJMXlWTLFeRaqZGMReJwRTU7d6BkA5" )
    gs.setApiCredential( "device" )
    gs.setAvailabilityCallback( availabilityCallback )
    gs.setAuthenticatedCallback( authenticatedCallback )
    gs.connect()
end

local function loginWithGameSparks( sig )
    local requestBuilder = gs.getRequestBuilder()
    authenticationRequest = requestBuilder.createAuthenticationRequest()
    authenticationRequest:setUserName( sig.playerId )
    authenticationRequest:setPassword( sig.playerId )
    authenticationRequest:send( function( response )
        if not response:hasErrors() then
            print(TAG, response:getDisplayName().." has logged in!")
        else
            print(TAG, "ERROR: loginWithGameSparks()")
            for k,v in pairs(response:getErrors()) do
                print(k,v)
            end
        end
    end)
end

local function registerWithGameSparks( sig )
    -- testText.text = json.prettify(sig)
    -- local requestBuilder = gs.getRequestBuilder()
    -- local connectRequest = requestBuilder.createGameCenterConnectRequest()
    -- connectRequest:setExternalPlayerId( sig.playerId )
    -- connectRequest:setDisplayName( sig.alias )
    -- connectRequest:setPublicKeyUrl( sig.keyURL)
    -- connectRequest:setTimestamp( sig.timestamp )
    -- connectRequest:setSalt( sig.salt )
    -- connectRequest:setSignature( sig.signature )
    -- connectRequest:send( function( response )
    --     testText.text = testText.text .. json.prettify(response)
    --     if not response:hasErrors() then
    --         print( "GameSparks login SUCCESS : "..response:getDisplayName())
    --     else
    --         print( "GameSparks login FAILURE" )
    --         for k,v in pairs(response:getErrors()) do 
    --             print("***")
    --             print(k)
    --             print(v)
    --         end
    --     end
    -- end)

    local requestBuilder = gs.getRequestBuilder()
    registerRequest = requestBuilder.createRegistrationRequest()
    registerRequest:setDisplayName( sig.alias )
    registerRequest:setUserName( sig.playerId )
    registerRequest:setPassword( sig.playerId )
    registerRequest:send( function( response )
        if not response:hasErrors() then
            print(TAG, response:getUserName().." has registered!")
        elseif response:getErrors().USERNAME == "TAKEN" then
            print(TAG, "register: username taken")
            loginWithGameSparks( sig )
        else
            print(TAG, "ERROR: registerWithGameSparks()")
            for key,value in pairs(response:getErrors()) do
                print(key,value)
            end
        end
    end)
end

-- 'sig' must contain 'alias' and 'playerId'
local function checkIfPlayerExists( sig )
    if ld.getAlias() == sig.alias then 
        print(TAG, "player exists")
        loginWithGameSparks( sig )
    else
        print(TAG, "player does not exist")
        registerWithGameSparks( sig )
        ld.setAlias( sig.alias )
    end
end

local function setUpGameNetwork()
    if platformType == "ios" then
        gameCenter.init( checkIfPlayerExists )
    elseif platformType == "android" then
        googlePlay.init( checkIfPlayerExists )
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.init = function()
    setUpGamesparks()
    setTypes()
    setUpGameNetwork()
end

return v
-------------------------------------------------------------------------------]