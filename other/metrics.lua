local flurry = require( "plugin.flurry.analytics" )
local json = require( "json" )

local TAG = "metrics.lua: "
local API_KEY = "JCWN6HJD7BYZXXX4JB4K"
local CRASH_REPORTING_ENABLED = true
local LOG_LEVEL = "default"             --default, debug, or all

local isInitialized

-- Private Members ------------------------------------------------------------[
local function toString(data)
    if type(data) == "table" then
        for k, v in pairs(data) do
            if type(v) ~= "string" then
                if type(v) == "table" then
                    data[k] = json.prettify(v)
                else
                    data[k] = tostring(v)
                end
            end
        end
        return data
    end
    return {}
end

local function logEvent(eventName, params)
    flurry.logEvent(eventName, params)
end

local function startTimedEvent(eventName, params)
    flurry.startTimedEvent(eventName, params)
end

local function stopTimedEvent(eventName, params)
    flurry.endTimedEvent(eventName, params)
end

local function completeTaskIfInitialized(functionToCall, eventName, params)
    if isInitialized then
        functionToCall(eventName, toString(params))
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
    local status = "Success"
    if (event.isError) then
        printData.errorCode = event.data.errorCode
        printData.errorReason = event.data.reason
        status = "Failure"
    end
    print(TAG, status.."\n"..json.prettify(printData))
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
