local licensing = require( "licensing" )
local json = require( "json" )
local gpgs = require( "plugin.gpgs" )
local ld = require( "data.localData" )
local metrics = require("other.metrics")

-- Local variables ------------------------------------------------------------[
local TAG = "googlePlay:"

local callbackFunction
local licensingInit
local signature = {}
-------------------------------------------------------------------------------]

local function showErrorAlert()
    native.showAlert(
        "Could not log in",
        "Please check your network connection and try again.",
        { "OK" } )
end

local function showLoadAlert()
    native.showAlert(
        "Could not load player info",
        "Please check your network connection and try again.",
        { "OK" } )
end

local function showAccountAlert()
    native.showAlert(
        "Could not log in",
        "Please set up your Google Play account to use features such as leaderboards.",
        { "OK" } )
end

local function showVerifyAlert()
    native.showAlert(
        "Could not verify application",
        "Please download Drop from the Google Play Store to use social features.",
        { "OK" } )
end

local function playerListener( event )
    local params = {
        isFailure = event.isError
    }
    if not event.isError then
        print(TAG, "player info retrieved")
        local player = event.players[1]
        signature.alias = player.name
        ld.setAlias( player.name )
        signature.playerId = player.id
        params.playerId = player.id
        params.alias = player.name
    else
        print(TAG, "could not retrieve player info")
        print(TAG, "errorCode: "..event.errorCode)
        print(TAG, "errorMessage: "..event.errorMessage)
        showLoadAlert()
        params.errorCode = event.errorCode
        params.message = event.errorMessage
    end
    callbackFunction( "google", signature )
end

local function getPlayerInfo()
    gpgs.players.load( { listener = playerListener } )
    metrics.startTimedEvent("googlePlay_getPlayerInfo")
end

local function serverAuthCodeListener(event)
    local params = {
        isFailure = event.isError
    }
    if event.isError then
        params.errorCode = event.errorCode
        params.message = event.errorMessage
    else
        signature.serverAuthCode = event.code
        getPlayerInfo()
    end
    metrics.stopTimedEvent("googlePlay_getServerAuthCode", params)
end

local function getServerAuthCode(event)
    gpgs.getServerAuthCode({
        serverId = "343244002104-106jjpricq9spkhr7e01qgr3i9njsuf1.apps.googleusercontent.com",
        listener = serverAuthCodeListener
    })
    metrics.startTimedEvent("googlePlay_getServerAuthCode")
end

local function loginListener( event )
    --event.phase ("logged in", "cancelled", "logged out")
    local params = {
        isFailure = event.isError
    }
    if not event.isError then
        if event.phase == "logged in" then
            print(TAG, "GPGS: logged in")
            getServerAuthCode()
        end
    else
        print(TAG, "GPGS: login attempt failed")
        print(TAG, "errorCode: "..event.errorCode)
        print(TAG, "errorMessage: "..event.errorMessage)
        params.errorCode = event.errorCode
        params.message = event.errorMessage
        showAccountAlert()
    end
    metrics.stopTimedEvent("googlePlay_login", params)
end

local function gpgsListener( event )
    if not event.isError then
        print(TAG, "GPGS successfully initialized")
        gpgs.login( { listener=loginListener } )
        metrics.startTimedEvent("googlePlay_login")
    else
        print(TAG, "GPGS could not be initialized")
        showErrorAlert()
    end
    metrics.logEvent("googlePlay_init", { isFailure = event.isError })
end

local function licensingListener( event )
    if not event.isVerified then
        -- Failed to verify app from the Google Play store; print a message
        print(TAG, "Pirates!!!" )
        print(TAG, "App could not be verified")
        showVerifyAlert()
    else
        print(TAG, "App successfully verified")
        gpgs.init( gpgsListener )
    end
    metrics.logEvent("googlePlay_licensing", { isFailure = (not event.isVerified) })
end

-- Returned values/table ------------------------------------------------------[
local v = {}

function v.init( callback )
    callbackFunction = callback
    licensingInit = licensing.init( "google" )
    if licensingInit then
        licensing.verify( licensingListener )
    end
end

return v
