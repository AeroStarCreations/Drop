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
local player
local isLoggedIn
-------------------------------------------------------------------------------]

-- Authentication -------------------------------------------------------------[
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

local function getPlayerDetails( callback )
    local requestBuilder = gs.getRequestBuilder()
    local playerDetails = requestBuilder.createAccountDetailsRequest()
    playerDetails:send( function(response)
        if not response:hasErrors() then
            print(TAG, "Got player details")
            player = response.data
            if callback then callback(player) end
        else
            print(TAG, "Could not retrieve player")
            for k,v in pairs(response:getErrors()) do
                print(TAG, k.." : "..v)
            end
            if player and callback then callback(player) end
        end
    end)
end

local function authenticatedCallback( playerId )
    if playerId then
        print( "Player ID: " .. tostring(playerId) )
        isLoggedIn = true;
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
            getPlayerDetails()
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
            getPlayerDetails()
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

-- Achievements ---------------------------------------------------------------[
local function onAchievementMessage( message )
    print(TAG, "Earned: "..message:getAchievementName())
    print(TAG, json.prettify(message))
    -- update currency
end

local function setUpAchievementMessageHandler()
    gs.getMessageHandler().setAchievementEarnedMessageHandler(onAchievementMessage)
end

local function completeAchievement( shortCode )
    local requestBuilder = gs.getRequestBuilder()
    local request = requestBuilder.createLogEventRequest()
    request:setEventKey("ACHIEVEMENT")
    request:setEventAttribute("SHORT_CODE", shortCode)
    request:send( function( response )
        if not response:hasErrors() then
            print(TAG, "achievement completed")
        else
            print(TAG, "ERROR: could not complete achievement")
            for key,value in pairs(response:getErrors()) do
                print(key,value)
            end
        end
    end)
end
-------------------------------------------------------------------------------]

-- High Scores ----------------------------------------------------------------[
local function onHighScoreMessage( message )
    print(TAG, "Earned high score in: "..message:getLeaderboardName())
    print(TAG, json.prettify(message))
end

local function setUpHighScoreMessageHandler()
    gs.getMessageHandler().setNewHighScoreMessageHandler(onHighScoreMessage)
end

local function setHighScore( shortCode, value )
    local requestBuilder = gs.getRequestBuilder()
    local request = requestBuilder.createLogEventRequest()
    request:setEventKey(shortCode)
    request:setEventAttribute("SCORE", value)
    request:send( function( response )
        if not response:hasErrors() then
            print(TAG, "high score posted")
        else
            print(TAG, "ERROR: could not post high score")
            for key,value in pairs(response:getErrors()) do
                print(key,value)
            end
        end
    end)
end
-------------------------------------------------------------------------------]

-- Leaderboards ---------------------------------------------------------------[
local function getLeaderboardShortCode(isScore, withSpecials)
    local shortCode = "HIGH_"
    if isScore then
        shortCode = shortCode .. "SCORE_"
    else
        shortCode = shortCode .. "TIME_"
    end
    if not withSpecials then
        shortCode = shortCode .. "TRICKY_"
    end
    return shortCode .. "LEADERBOARD"
end

local function getLeaderboardData(isScore, withSpecials, areLeaders, callback)
    local shortCode = getLeaderboardShortCode(isScore, withSpecials)

    local requestBuilder = gs.getRequestBuilder()
    local getEntryRequest = requestBuilder.createLeaderboardDataRequest()
    if not areLeaders then
        getEntryRequest = requestBuilder.createAroundMeLeaderboardRequest()
    end

    getEntryRequest:setLeaderboardShortCode(shortCode)
    getEntryRequest:setEntryCount(100)
    getEntryRequest:send( function( response )
        if not response:hasErrors() then
            print(TAG, "leaderboard data retrieved")
            callback(response:getData())
        else
            print(TAG, "ERROR: could not retrieve leaderboard data")
            for key,value in pairs(response:getErrors()) do
                print(key,value)
            end
        end
    end)
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

v.init = function()
    isLoggedIn = false
    player = nil
    setUpGamesparks()
    setTypes()
    setUpGameNetwork()
    setUpAchievementMessageHandler()
    setUpHighScoreMessageHandler()
end

v.completeAchievement = function( shortCode )
    completeAchievement(shortCode)
end

v.setHighScore = function( shortCode, value )
    setHighScore( shortCode, value)
end

v.getPlayerDetails = function( callback )
    getPlayerDetails(callback)
end

v.getPlayer = function()
    return player
end

v.hasPlayerDetails = function()
    return not (player == nil)
end

v.isLoggedIn = function()
    return isLoggedIn
end

v.getLeaderboardData = function(isScore, withSpecials, areLeaders, callback)
    getLeaderboardData(isScore, withSpecials, areLeaders, callback)
end

return v
-------------------------------------------------------------------------------]