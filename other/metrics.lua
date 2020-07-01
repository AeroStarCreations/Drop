local flurry = require( "plugin.flurry.analytics" )
local json = require( "json" )

local TAG = "metrics.lua: "
local API_KEY = "JCWN6HJD7BYZXXX4JB4K"
local CRASH_REPORTING_ENABLED = true
--TODO: set to default
local LOG_LEVEL = "default"             --default, debug, or all

local isInitialized

-- Private Members ------------------------------------------------------------[
local function logEvent(eventName, params)
    flurry.logEvent(eventName, params)
end

local function startTimedEvent(eventName, params)
    flurry.startTimedEvent(eventName, params)
end

local function stopTimedEvent(eventName, params)
    flurry.stopTimedEvent(eventName, params)
end

local function completeTaskIfInitialized(functionToCall, eventName, params)
    if isInitialized then
        functionToCall(eventName, params)
    end
end

local function flurryListener(event)
    if (event.phase == "init") then  -- Successful initialization
        isInitialized = true
    end
    local printData = {
        phase = event.phase,
        type = event.type,
        eventName = event.data.event
    }
    local status = "SUCCESS"
    if (event.isError) then
        printData.errorCode = event.data.errorCode
        printData.errorReason = event.data.reason
        status = "FAILURE"
    end
end

-- Initialization -------------------------------------------------------------[
flurry.init(flurryListener, {
    apiKey = API_KEY,
    crashReportingEnabled = CRASH_REPORTING_ENABLED,
    logLevel = LOG_LEVEL
})

-- Public Members -------------------------------------------------------------[
local v = {}

function v.logEvent(eventName, params)
    completeTaskIfInitialized(logEvent, eventName, params)
end

function v.startTimedEvent(eventName, params)
    completeTaskIfInitialized(startTimedEvent, eventName, params)
end

function v.stopTimedEvent(eventName, params)
    completeTaskIfInitialized(stopTimedEvent, eventName, params)
end

return v
